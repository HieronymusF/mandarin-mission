import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'audio_service.dart';

/// 音频服务实现
class AudioServiceImpl implements AudioService {
  AudioServiceImpl({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle {
    _initPlayer();
  }

  final AssetBundle _bundle;
  AudioPlayer? _player;
  final _audioStateController = StreamController<AudioState>.broadcast();
  final _playbackPositionController = StreamController<double>.broadcast();

  StreamSubscription<void>? _completionSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  Duration? _duration;
  bool _isAvailable = true;

  @override
  Future<bool> get isAvailable async => _isAvailable;

  @override
  Stream<AudioState> get audioState => _audioStateController.stream;

  @override
  Stream<double> get playbackPosition => _playbackPositionController.stream;

  @override
  Duration? get duration => _duration;

  void _initPlayer() {
    try {
      _player = AudioPlayer();

      _completionSubscription = _player!.onPlayerComplete.listen((_) {
        _audioStateController.add(AudioState.stopped);
      });

      _positionSubscription = _player!.onPositionChanged.listen((position) {
        if (_duration != null && _duration!.inMilliseconds > 0) {
          _playbackPositionController.add(
            position.inMilliseconds / _duration!.inMilliseconds,
          );
        }
      });

      _durationSubscription = _player!.onDurationChanged.listen((duration) {
        _duration = duration;
      });

      _stateSubscription = _player!.onPlayerStateChanged.listen((state) {
        switch (state) {
          case PlayerState.playing:
            _audioStateController.add(AudioState.playing);
            break;
          case PlayerState.paused:
            _audioStateController.add(AudioState.paused);
            break;
          case PlayerState.stopped:
            _audioStateController.add(AudioState.stopped);
            break;
          case PlayerState.completed:
            _audioStateController.add(AudioState.stopped);
            break;
          case PlayerState.disposed:
            _audioStateController.add(AudioState.idle);
            break;
        }
      });
    } catch (e) {
      _isAvailable = false;
      _audioStateController.add(AudioState.unavailable);
    }
  }

  @override
  Future<void> playAudio(String assetPath) async {
    if (!_isAvailable || _player == null) {
      _audioStateController.add(AudioState.unavailable);
      return;
    }

    try {
      _audioStateController.add(AudioState.loading);
      _duration = null;
      await _player!.play(await _sourceFor(assetPath));
      _audioStateController.add(AudioState.playing);
    } catch (_) {
      _audioStateController.add(AudioState.error);
    }
  }

  Future<Source> _sourceFor(String sourcePath) async {
    final file = File(sourcePath);
    if (file.isAbsolute) {
      if (!await file.exists()) {
        throw StateError('Audio file does not exist.');
      }
      return DeviceFileSource(sourcePath);
    }

    final relativeAssetPath = sourcePath.startsWith('assets/')
        ? sourcePath.substring('assets/'.length)
        : sourcePath;
    await _bundle.load('assets/$relativeAssetPath');
    return AssetSource(relativeAssetPath);
  }

  @override
  Future<void> stopAudio() async {
    if (!_isAvailable || _player == null) return;
    try {
      await _player!.stop();
      _audioStateController.add(AudioState.stopped);
    } catch (e) {
      _audioStateController.add(AudioState.error);
    }
  }

  @override
  Future<void> pauseAudio() async {
    if (!_isAvailable || _player == null) return;
    try {
      await _player!.pause();
      _audioStateController.add(AudioState.paused);
    } catch (e) {
      _audioStateController.add(AudioState.error);
    }
  }

  @override
  Future<void> resumeAudio() async {
    if (!_isAvailable || _player == null) return;
    try {
      await _player!.resume();
      _audioStateController.add(AudioState.playing);
    } catch (e) {
      _audioStateController.add(AudioState.error);
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (!_isAvailable || _player == null) return;
    try {
      await _player!.seek(position);
    } catch (e) {
      _audioStateController.add(AudioState.error);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    if (!_isAvailable || _player == null) return;
    try {
      await _player!.setVolume(volume);
    } catch (e) {
      // 音量设置失败不影响播放，仅记录
    }
  }

  @override
  Future<void> dispose() async {
    await _completionSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _stateSubscription?.cancel();
    await _player?.dispose();
    await _audioStateController.close();
    await _playbackPositionController.close();
  }
}
