import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_controller.dart';
import 'audio_service.dart';
import 'audio_service_impl.dart';
import 'recording_service.dart';
import 'recording_service_impl.dart';

/// 音频服务 Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioServiceImpl();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 录音服务 Provider
final recordingServiceProvider = Provider<RecordingService>((ref) {
  final service = RecordingServiceImpl();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 音频播放器控制器 Provider
final audioPlayerControllerProvider =
    NotifierProvider<AudioPlayerController, AudioPlayerState>(
      () => AudioPlayerController(),
    );

/// 录音控制器 Provider
final recordingControllerProvider =
    NotifierProvider<RecordingController, RecordingControllerState>(
      () => RecordingController(),
    );
