import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:record/record.dart';

import 'recording_service.dart';

/// 录音服务实现
class RecordingServiceImpl implements RecordingService {
  RecordingServiceImpl() {
    _initRecorder();
  }

  final AudioRecorder _recorder = AudioRecorder();
  final _recordingStateController =
      StreamController<RecordingState>.broadcast();
  final _recordingDurationController = StreamController<double>.broadcast();
  final _volumeLevelController = StreamController<double>.broadcast();

  String? _currentRecordingPath;
  Timer? _recordingTimer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  bool _isAvailable = true;
  bool _isPermanentlyDenied = false;

  void _initRecorder() {
    try {
      // 检查权限状态
      _checkPermissionStatus();
    } catch (e) {
      _isAvailable = false;
      _recordingStateController.add(RecordingState.unavailable);
    }
  }

  Future<void> _checkPermissionStatus() async {
    final status = await permissions.Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      _isPermanentlyDenied = true;
    }
  }

  @override
  Future<bool> get isAvailable async => _isAvailable;

  @override
  Future<bool> get hasPermission async =>
      permissions.Permission.microphone.isGranted;

  @override
  Future<bool> get isPermanentlyDenied async => _isPermanentlyDenied;

  @override
  Future<bool> requestPermission() async {
    try {
      _recordingStateController.add(RecordingState.requestingPermission);

      final status = await permissions.Permission.microphone.request();

      if (status.isGranted) {
        _isPermanentlyDenied = false;
        _recordingStateController.add(RecordingState.ready);
        return true;
      } else if (status.isPermanentlyDenied) {
        _isPermanentlyDenied = true;
        _recordingStateController.add(RecordingState.unavailable);
        return false;
      } else {
        _recordingStateController.add(RecordingState.idle);
        return false;
      }
    } catch (e) {
      _isAvailable = false;
      _recordingStateController.add(RecordingState.unavailable);
      return false;
    }
  }

  @override
  Future<void> openAppSettings() async {
    await permissions.openAppSettings();
  }

  @override
  Stream<RecordingState> get recordingState => _recordingStateController.stream;

  @override
  Stream<double> get recordingDuration => _recordingDurationController.stream;

  @override
  Stream<double> get volumeLevel => _volumeLevelController.stream;

  @override
  Future<void> startRecording() async {
    if (!_isAvailable) {
      _recordingStateController.add(RecordingState.unavailable);
      return;
    }

    // 检查权限
    if (!await hasPermission) {
      final granted = await requestPermission();
      if (!granted) {
        return;
      }
    }

    try {
      await clearRecording();

      // 生成临时文件路径
      final directory = await getTemporaryDirectory();
      _currentRecordingPath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // 开始录音 - 使用正确的 API
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: _currentRecordingPath!,
      );

      _recordingStateController.add(RecordingState.recording);

      // 启动录音计时器
      _startRecordingTimer();
      _startVolumeCheck();
    } catch (e) {
      _recordingStateController.add(RecordingState.error);
      _isAvailable = false;
    }
  }

  @override
  Future<String> stopRecording() async {
    if (!_isAvailable || _currentRecordingPath == null) {
      _recordingStateController.add(RecordingState.error);
      return '';
    }

    try {
      final path = await _recorder.stop();
      if (path != null && path.isNotEmpty) {
        _currentRecordingPath = path;
        _recordingStateController.add(RecordingState.stopped);
        return path;
      } else {
        _recordingStateController.add(RecordingState.error);
        return '';
      }
    } catch (e) {
      _recordingStateController.add(RecordingState.error);
      return '';
    } finally {
      _stopRecordingTimer();
      await _stopVolumeCheck();
    }
  }

  @override
  Future<void> cancelRecording() async {
    _stopRecordingTimer();
    await _stopVolumeCheck();
    try {
      await _recorder.cancel();
      _recordingStateController.add(RecordingState.idle);
    } catch (_) {
      _recordingStateController.add(RecordingState.error);
    } finally {
      await clearRecording();
    }
  }

  @override
  Future<void> playRecording(String filePath) async {
    // 录音服务本身不负责回放，由 AudioService 负责
    // 这里只更新状态
    _recordingStateController.add(RecordingState.playing);
  }

  @override
  Future<void> stopPlayback() async {
    _recordingStateController.add(RecordingState.stopped);
  }

  @override
  Future<void> clearRecording() async {
    final path = _currentRecordingPath;
    _currentRecordingPath = null;
    if (path == null || path.isEmpty) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // 临时文件清理失败不阻断课程。
    }
  }

  @override
  Future<double> getCurrentVolume() async {
    if (!_isAvailable) {
      return 0.0;
    }

    try {
      // record 包提供了获取音量的方法
      final amplitude = await _recorder.getAmplitude();
      return _normalizeAmplitude(amplitude.current);
    } catch (_) {
      return 0.0;
    }
  }

  double _normalizeAmplitude(double dbfs) {
    if (!dbfs.isFinite) return 0.0;
    return math.pow(10, dbfs / 20).toDouble().clamp(0.0, 1.0);
  }

  @override
  Future<bool> checkMinimumVolume(double threshold) async {
    final currentVolume = await getCurrentVolume();
    return currentVolume >= threshold;
  }

  void _startRecordingTimer() {
    double seconds = 0.0;
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      seconds += 0.1;
      _recordingDurationController.add(seconds);
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _startVolumeCheck() {
    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen(
          (amplitude) => _volumeLevelController.add(
            _normalizeAmplitude(amplitude.current),
          ),
        );
  }

  Future<void> _stopVolumeCheck() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
  }

  @override
  Future<void> dispose() async {
    _stopRecordingTimer();
    await _stopVolumeCheck();
    await _recorder.dispose();
    await clearRecording();
    await _recordingStateController.close();
    await _recordingDurationController.close();
    await _volumeLevelController.close();
  }
}
