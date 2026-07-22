import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service.dart';
import 'audio_providers.dart';
import 'recording_service.dart';

/// 音频播放器状态
class AudioPlayerState {
  const AudioPlayerState({
    this.isLoading = false,
    this.isPlaying = false,
    this.isPaused = false,
    this.hasError = false,
    this.errorMessage,
    this.currentPosition = 0.0,
    this.totalDuration = 0.0,
    this.isUnavailable = false,
  });

  final bool isLoading;
  final bool isPlaying;
  final bool isPaused;
  final bool hasError;
  final String? errorMessage;
  final double currentPosition;
  final double totalDuration;
  final bool isUnavailable;

  AudioPlayerState copyWith({
    bool? isLoading,
    bool? isPlaying,
    bool? isPaused,
    bool? hasError,
    Object? errorMessage = _unset,
    double? currentPosition,
    double? totalDuration,
    bool? isUnavailable,
  }) {
    return AudioPlayerState(
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      hasError: hasError ?? this.hasError,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isUnavailable: isUnavailable ?? this.isUnavailable,
    );
  }

  static const _unset = Object();
}

/// 音频播放器控制器
class AudioPlayerController extends Notifier<AudioPlayerState> {
  @override
  AudioPlayerState build() {
    _init();
    ref.onDispose(disposeController);
    return const AudioPlayerState();
  }

  StreamSubscription<AudioState>? _audioStateSubscription;
  StreamSubscription<double>? _playbackPositionSubscription;

  void _init() {
    final audioService = ref.read(audioServiceProvider);

    // 监听音频状态变化
    _audioStateSubscription = audioService.audioState.listen((audioState) {
      AudioPlayerState newState;
      switch (audioState) {
        case AudioState.loading:
          newState = state.copyWith(
            isLoading: true,
            hasError: false,
            errorMessage: null,
          );
          break;
        case AudioState.playing:
          newState = state.copyWith(
            isLoading: false,
            isPlaying: true,
            isPaused: false,
            hasError: false,
            errorMessage: null,
          );
          break;
        case AudioState.paused:
          newState = state.copyWith(
            isLoading: false,
            isPlaying: false,
            isPaused: true,
            hasError: false,
          );
          break;
        case AudioState.stopped:
        case AudioState.idle:
          newState = state.copyWith(
            isLoading: false,
            isPlaying: false,
            isPaused: false,
            currentPosition: 0.0,
          );
          break;
        case AudioState.error:
          newState = state.copyWith(
            isLoading: false,
            isPlaying: false,
            isPaused: false,
            hasError: true,
            errorMessage: 'Audio playback error. Please try again.',
          );
          break;
        case AudioState.unavailable:
          newState = state.copyWith(
            isLoading: false,
            isPlaying: false,
            isPaused: false,
            isUnavailable: true,
            hasError: true,
            errorMessage: 'Audio is currently unavailable.',
          );
          break;
      }
      state = newState;
    });

    // 监听播放位置变化
    _playbackPositionSubscription = audioService.playbackPosition.listen((
      position,
    ) {
      state = state.copyWith(currentPosition: position);
    });
  }

  /// 播放音频
  Future<void> playAudio(String assetPath) async {
    final audioService = ref.read(audioServiceProvider);
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );
    await audioService.playAudio(assetPath);
  }

  /// 停止播放
  Future<void> stopAudio() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.stopAudio();
  }

  /// 暂停播放
  Future<void> pauseAudio() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.pauseAudio();
  }

  /// 继续播放
  Future<void> resumeAudio() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.resumeAudio();
  }

  /// 跳转到指定位置
  Future<void> seekTo(double position) async {
    final audioService = ref.read(audioServiceProvider);
    final duration = audioService.duration;
    if (duration != null) {
      final seekPosition = Duration(
        milliseconds: (position * duration.inMilliseconds).round(),
      );
      await audioService.seekTo(seekPosition);
    }
  }

  void disposeController() {
    _audioStateSubscription?.cancel();
    _playbackPositionSubscription?.cancel();
  }
}

/// 录音控制器状态
class RecordingControllerState {
  const RecordingControllerState({
    this.isRequestingPermission = false,
    this.hasPermission = false,
    this.isRecording = false,
    this.isPlayingBack = false,
    this.hasRecording = false,
    this.recordingPath,
    this.recordingDuration = 0.0,
    this.currentVolume = 0.0,
    this.errorMessage,
    this.isUnavailable = false,
    this.isPermanentlyDenied = false,
  });

  final bool isRequestingPermission;
  final bool hasPermission;
  final bool isRecording;
  final bool isPlayingBack;
  final bool hasRecording;
  final String? recordingPath;
  final double recordingDuration;
  final double currentVolume;
  final String? errorMessage;
  final bool isUnavailable;
  final bool isPermanentlyDenied;

  RecordingControllerState copyWith({
    bool? isRequestingPermission,
    bool? hasPermission,
    bool? isRecording,
    bool? isPlayingBack,
    bool? hasRecording,
    Object? recordingPath = _unset,
    double? recordingDuration,
    double? currentVolume,
    Object? errorMessage = _unset,
    bool? isUnavailable,
    bool? isPermanentlyDenied,
  }) {
    return RecordingControllerState(
      isRequestingPermission:
          isRequestingPermission ?? this.isRequestingPermission,
      hasPermission: hasPermission ?? this.hasPermission,
      isRecording: isRecording ?? this.isRecording,
      isPlayingBack: isPlayingBack ?? this.isPlayingBack,
      hasRecording: hasRecording ?? this.hasRecording,
      recordingPath: identical(recordingPath, _unset)
          ? this.recordingPath
          : recordingPath as String?,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      currentVolume: currentVolume ?? this.currentVolume,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      isUnavailable: isUnavailable ?? this.isUnavailable,
      isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
    );
  }

  static const _unset = Object();
}

/// 录音控制器
class RecordingController extends Notifier<RecordingControllerState> {
  @override
  RecordingControllerState build() {
    _init();
    ref.onDispose(disposeController);
    return const RecordingControllerState();
  }

  StreamSubscription<RecordingState>? _recordingStateSubscription;
  StreamSubscription<double>? _recordingDurationSubscription;
  StreamSubscription<double>? _volumeLevelSubscription;
  StreamSubscription<AudioState>? _audioStateSubscription;

  void _init() {
    final recordingService = ref.read(recordingServiceProvider);

    // 监听录音状态变化
    _recordingStateSubscription = recordingService.recordingState.listen((
      recordingState,
    ) {
      RecordingControllerState newState;
      switch (recordingState) {
        case RecordingState.requestingPermission:
          newState = state.copyWith(
            isRequestingPermission: true,
            hasPermission: false,
          );
          break;
        case RecordingState.ready:
          newState = state.copyWith(
            isRequestingPermission: false,
            hasPermission: true,
          );
          break;
        case RecordingState.recording:
          newState = state.copyWith(
            isRecording: true,
            hasRecording: false,
            errorMessage: null,
          );
          break;
        case RecordingState.playing:
          newState = state.copyWith(isPlayingBack: true, hasRecording: true);
          break;
        case RecordingState.stopped:
          newState = state.copyWith(
            isRecording: false,
            isPlayingBack: false,
            hasRecording: true,
          );
          break;
        case RecordingState.idle:
          newState = state.copyWith(isRecording: false, isPlayingBack: false);
          break;
        case RecordingState.error:
          newState = state.copyWith(
            isRecording: false,
            isPlayingBack: false,
            errorMessage: 'Recording error. Please try again.',
          );
          break;
        case RecordingState.unavailable:
          newState = state.copyWith(isUnavailable: true);
          break;
      }
      state = newState;
    });

    // 监听录音时长变化
    _recordingDurationSubscription = recordingService.recordingDuration.listen((
      duration,
    ) {
      state = state.copyWith(recordingDuration: duration);
    });

    // 监听音量级别变化
    _volumeLevelSubscription = recordingService.volumeLevel.listen((volume) {
      state = state.copyWith(currentVolume: volume);
    });

    _audioStateSubscription = ref.read(audioServiceProvider).audioState.listen((
      audioState,
    ) {
      if (!state.isPlayingBack) return;
      if (audioState == AudioState.stopped ||
          audioState == AudioState.error ||
          audioState == AudioState.unavailable) {
        state = state.copyWith(isPlayingBack: false);
      }
    });

    unawaited(_loadInitialState(recordingService));
  }

  Future<void> _loadInitialState(RecordingService recordingService) async {
    final available = await recordingService.isAvailable;
    final hasPermission = await recordingService.hasPermission;
    final permanentlyDenied = await recordingService.isPermanentlyDenied;
    state = state.copyWith(
      hasPermission: hasPermission,
      isUnavailable: !available,
      isPermanentlyDenied: permanentlyDenied,
    );
  }

  /// 请求麦克风权限
  Future<void> requestPermission() async {
    final recordingService = ref.read(recordingServiceProvider);
    await recordingService.requestPermission();
    final available = await recordingService.isAvailable;
    state = state.copyWith(
      isRequestingPermission: false,
      hasPermission: await recordingService.hasPermission,
      isPermanentlyDenied: await recordingService.isPermanentlyDenied,
      isUnavailable: !available,
    );
  }

  /// 打开应用设置
  Future<void> openAppSettings() async {
    final recordingService = ref.read(recordingServiceProvider);
    await recordingService.openAppSettings();
  }

  /// 开始录音
  Future<void> startRecording() async {
    final recordingService = ref.read(recordingServiceProvider);
    state = state.copyWith(
      hasRecording: false,
      recordingPath: null,
      recordingDuration: 0.0,
      errorMessage: null,
    );
    await recordingService.startRecording();
  }

  /// 停止录音
  Future<void> stopRecording() async {
    final recordingService = ref.read(recordingServiceProvider);
    final path = await recordingService.stopRecording();
    if (path.isNotEmpty) {
      state = state.copyWith(recordingPath: path);
    }
  }

  /// 取消录音
  Future<void> cancelRecording() async {
    final recordingService = ref.read(recordingServiceProvider);
    await recordingService.cancelRecording();
    state = state.copyWith(
      hasRecording: false,
      recordingPath: null,
      recordingDuration: 0.0,
    );
  }

  /// 回放录音
  Future<void> playRecording() async {
    if (state.recordingPath == null || state.recordingPath!.isEmpty) {
      return;
    }

    // 使用 AudioService 来播放录音
    final audioService = ref.read(audioServiceProvider);
    state = state.copyWith(isPlayingBack: true);
    await audioService.playAudio(state.recordingPath!);
  }

  /// 停止回放
  Future<void> stopPlayback() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.stopAudio();
    state = state.copyWith(isPlayingBack: false);
  }

  /// 停止当前课程的媒体活动并清理临时录音。
  Future<void> endSession() async {
    final audioService = ref.read(audioServiceProvider);
    final recordingService = ref.read(recordingServiceProvider);
    final wasRecording = state.isRecording;
    final wasPlayingBack = state.isPlayingBack;

    await audioService.stopAudio();
    if (wasRecording) {
      await recordingService.cancelRecording();
    } else if (wasPlayingBack) {
      await recordingService.stopPlayback();
    }
    await recordingService.clearRecording();

    if (!ref.mounted) return;
    state = RecordingControllerState(
      hasPermission: state.hasPermission,
      isUnavailable: state.isUnavailable,
      isPermanentlyDenied: state.isPermanentlyDenied,
    );
  }

  /// 检查最小音量
  Future<bool> checkMinimumVolume(double threshold) async {
    final recordingService = ref.read(recordingServiceProvider);
    return await recordingService.checkMinimumVolume(threshold);
  }

  void disposeController() {
    _recordingStateSubscription?.cancel();
    _recordingDurationSubscription?.cancel();
    _volumeLevelSubscription?.cancel();
    _audioStateSubscription?.cancel();
  }
}
