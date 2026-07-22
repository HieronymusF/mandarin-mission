import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/data/audio/audio_providers.dart';
import 'package:mandarin_mission/data/audio/audio_service.dart';
import 'package:mandarin_mission/data/audio/recording_service.dart';

void main() {
  test('recording controller restores an existing permission state', () async {
    final audioService = _FakeAudioService();
    final recordingService = _FakeRecordingService(hasPermission: true);
    final container = _container(audioService, recordingService);
    addTearDown(() async {
      container.dispose();
      await audioService.dispose();
      await recordingService.dispose();
    });

    container.read(recordingControllerProvider);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(recordingControllerProvider);
    expect(state.hasPermission, isTrue);
    expect(state.isPermanentlyDenied, isFalse);
    expect(state.isUnavailable, isFalse);
  });

  test('permanent denial stays distinct from service unavailability', () async {
    final audioService = _FakeAudioService();
    final recordingService = _FakeRecordingService(isPermanentlyDenied: true);
    final container = _container(audioService, recordingService);
    addTearDown(() async {
      container.dispose();
      await audioService.dispose();
      await recordingService.dispose();
    });

    container.read(recordingControllerProvider);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(recordingControllerProvider);
    expect(state.hasPermission, isFalse);
    expect(state.isPermanentlyDenied, isTrue);
    expect(state.isUnavailable, isFalse);
  });

  test('recording playback clears when audio finishes', () async {
    final audioService = _FakeAudioService();
    final recordingService = _FakeRecordingService(hasPermission: true);
    final container = _container(audioService, recordingService);
    addTearDown(() async {
      container.dispose();
      await audioService.dispose();
      await recordingService.dispose();
    });

    final controller = container.read(recordingControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.stopRecording();
    await controller.playRecording();

    expect(container.read(recordingControllerProvider).isPlayingBack, isTrue);

    audioService.emit(AudioState.stopped);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(recordingControllerProvider).isPlayingBack, isFalse);
  });

  test(
    'service failure uses unavailable state without permission denial',
    () async {
      final audioService = _FakeAudioService();
      final recordingService = _FakeRecordingService(isAvailable: false);
      final container = _container(audioService, recordingService);
      addTearDown(() async {
        container.dispose();
        await audioService.dispose();
        await recordingService.dispose();
      });

      container.read(recordingControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(recordingControllerProvider);
      expect(state.isUnavailable, isTrue);
      expect(state.isPermanentlyDenied, isFalse);
    },
  );

  test('ending a media session stops playback and clears recording', () async {
    final audioService = _FakeAudioService();
    final recordingService = _FakeRecordingService(hasPermission: true);
    final container = _container(audioService, recordingService);
    addTearDown(() async {
      container.dispose();
      await audioService.dispose();
      await recordingService.dispose();
    });

    final controller = container.read(recordingControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.stopRecording();
    await controller.playRecording();

    await controller.endSession();

    expect(audioService.stopCount, 1);
    expect(recordingService.stopPlaybackCount, 1);
    expect(recordingService.clearRecordingCount, 1);
    expect(container.read(recordingControllerProvider).hasRecording, isFalse);
    expect(container.read(recordingControllerProvider).isPlayingBack, isFalse);
  });
}

ProviderContainer _container(
  AudioService audioService,
  RecordingService recordingService,
) {
  return ProviderContainer(
    overrides: [
      audioServiceProvider.overrideWithValue(audioService),
      recordingServiceProvider.overrideWithValue(recordingService),
    ],
  );
}

final class _FakeAudioService implements AudioService {
  final _stateController = StreamController<AudioState>.broadcast();
  final _positionController = StreamController<double>.broadcast();
  int stopCount = 0;

  @override
  Stream<AudioState> get audioState => _stateController.stream;

  @override
  Duration? get duration => const Duration(seconds: 1);

  @override
  Future<bool> get isAvailable async => true;

  @override
  Stream<double> get playbackPosition => _positionController.stream;

  void emit(AudioState state) => _stateController.add(state);

  @override
  Future<void> pauseAudio() async => emit(AudioState.paused);

  @override
  Future<void> playAudio(String assetPath) async => emit(AudioState.playing);

  @override
  Future<void> resumeAudio() async => emit(AudioState.playing);

  @override
  Future<void> seekTo(Duration position) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stopAudio() async {
    stopCount += 1;
    emit(AudioState.stopped);
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _positionController.close();
  }
}

final class _FakeRecordingService implements RecordingService {
  _FakeRecordingService({
    this._hasPermission = false,
    this._isAvailable = true,
    this._isPermanentlyDenied = false,
  });

  final _stateController = StreamController<RecordingState>.broadcast();
  final _durationController = StreamController<double>.broadcast();
  final _volumeController = StreamController<double>.broadcast();
  bool _hasPermission;
  final bool _isAvailable;
  final bool _isPermanentlyDenied;
  int clearRecordingCount = 0;
  int stopPlaybackCount = 0;

  @override
  Future<bool> get hasPermission async => _hasPermission;

  @override
  Future<bool> get isAvailable async => _isAvailable;

  @override
  Future<bool> get isPermanentlyDenied async => _isPermanentlyDenied;

  @override
  Stream<double> get recordingDuration => _durationController.stream;

  @override
  Stream<RecordingState> get recordingState => _stateController.stream;

  @override
  Stream<double> get volumeLevel => _volumeController.stream;

  @override
  Future<void> cancelRecording() async {
    _stateController.add(RecordingState.idle);
  }

  @override
  Future<void> clearRecording() async {
    clearRecordingCount += 1;
  }

  @override
  Future<bool> checkMinimumVolume(double threshold) async => true;

  @override
  Future<double> getCurrentVolume() async => 1;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> playRecording(String filePath) async {
    _stateController.add(RecordingState.playing);
  }

  @override
  Future<bool> requestPermission() async {
    _hasPermission = true;
    _stateController.add(RecordingState.ready);
    return true;
  }

  @override
  Future<void> startRecording() async {
    _stateController.add(RecordingState.recording);
  }

  @override
  Future<void> stopPlayback() async {
    stopPlaybackCount += 1;
    _stateController.add(RecordingState.stopped);
  }

  @override
  Future<String> stopRecording() async {
    _stateController.add(RecordingState.stopped);
    return '/tmp/recording.m4a';
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _durationController.close();
    await _volumeController.close();
  }
}
