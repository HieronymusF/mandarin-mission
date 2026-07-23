import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/core/theme/app_theme.dart';
import 'package:mandarin_mission/data/audio/audio_providers.dart';
import 'package:mandarin_mission/data/audio/audio_service.dart';
import 'package:mandarin_mission/data/audio/recording_service.dart';
import 'package:mandarin_mission/shared/presentation/audio_player_bar.dart';
import 'package:mandarin_mission/shared/presentation/recording_controls.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  testWidgets('audio bar shows loading, playing, paused, and error states', (
    tester,
  ) async {
    final audio = _FakeAudioService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [audioServiceProvider.overrideWithValue(audio)],
        child: const _TestApp(
          child: AudioPlayerBar(assetPath: 'assets/audio/cafe.m4a'),
        ),
      ),
    );

    await tester.tap(find.byIcon(LucideIcons.play));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(audio.lastPlayedPath, 'assets/audio/cafe.m4a');

    audio.emit(AudioState.playing);
    await tester.pump();
    expect(find.byIcon(LucideIcons.pause), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.pause));
    await tester.pump();
    expect(find.byIcon(LucideIcons.play), findsOneWidget);

    audio.emit(AudioState.error);
    await tester.pumpAndSettle();
    expect(
      find.text('Audio playback error. Please try again.'),
      findsOneWidget,
    );

    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(audio.playCount, 2);
    expect(audio.lastPlayedPath, 'assets/audio/cafe.m4a');

    await audio.dispose();
  });

  testWidgets('audio bar exposes the content fallback without an asset', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(child: AudioPlayerBar(assetPath: null)),
    );

    expect(find.text('Audio unavailable'), findsOneWidget);
  });

  testWidgets('recording UI distinguishes unavailable and permission states', (
    tester,
  ) async {
    final unavailable = _FakeRecordingService(isAvailable: false);
    await _pumpRecording(tester, unavailable);
    expect(find.text('Recording unavailable'), findsOneWidget);

    final denied = _FakeRecordingService();
    await _pumpRecording(tester, denied);
    expect(find.text('Allow Microphone Access'), findsOneWidget);
    await tester.tap(find.text('Allow Microphone Access'));
    await tester.pumpAndSettle();
    expect(find.text('Microphone access denied'), findsOneWidget);
    expect(
      find.text(
        'You can try again or continue below without recording and complete a self-check.',
      ),
      findsOneWidget,
    );
    expect(find.text('Try Microphone Access Again'), findsOneWidget);

    final permanent = _FakeRecordingService(waitForPermissionResult: true);
    await _pumpRecording(tester, permanent);
    await tester.tap(find.text('Allow Microphone Access'));
    await tester.pump();
    expect(find.text('Requesting microphone permission...'), findsOneWidget);

    permanent.completePermission(permanentlyDenied: true);
    await tester.pumpAndSettle();
    expect(find.text('Microphone permission required'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);

    await unavailable.dispose();
    await denied.dispose();
    await permanent.dispose();
  });

  testWidgets('recording UI records, plays back, and confirms one file', (
    tester,
  ) async {
    final audio = _FakeAudioService();
    final recording = _FakeRecordingService(hasPermission: true);
    String? confirmedPath;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(audio),
          recordingServiceProvider.overrideWithValue(recording),
        ],
        child: _TestApp(
          child: RecordingControls(
            onRecordingComplete: (path) => confirmedPath = path,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tap to record'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.mic));
    await tester.pumpAndSettle();
    recording
      ..emitDuration(5)
      ..emitVolume(.5);
    await tester.pumpAndSettle();
    expect(find.text('Tap to stop'), findsOneWidget);
    expect(find.text('00:05'), findsOneWidget);
    expect(find.text('Good volume'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.square));
    await tester.pump();
    expect(find.text('Use this recording'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.play));
    await tester.pump();
    expect(audio.lastPlayedPath, '/tmp/recording.m4a');
    expect(find.byIcon(LucideIcons.square), findsOneWidget);

    audio.emit(AudioState.stopped);
    await tester.pump();
    await tester.tap(find.text('Use this recording'));
    expect(confirmedPath, '/tmp/recording.m4a');

    await audio.dispose();
    await recording.dispose();
  });

  testWidgets('recording error offers a retry from the same step', (
    tester,
  ) async {
    final recording = _FakeRecordingService(hasPermission: true);
    await _pumpRecording(tester, recording);
    expect(find.text('Tap to record'), findsOneWidget);

    recording.emit(RecordingState.error);
    await tester.pump();
    expect(find.text('Recording error. Please try again.'), findsOneWidget);
    expect(find.text('Try recording again'), findsOneWidget);

    await tester.tap(find.text('Try recording again'));
    await tester.pump();
    expect(recording.startCount, 1);
    expect(find.text('Tap to stop'), findsOneWidget);

    await recording.dispose();
  });

  testWidgets('recording playback error offers playback retry', (tester) async {
    final audio = _FakeAudioService();
    final recording = _FakeRecordingService(hasPermission: true);
    final container = ProviderContainer(
      overrides: [
        audioServiceProvider.overrideWithValue(audio),
        recordingServiceProvider.overrideWithValue(recording),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(child: RecordingControls(onRecordingComplete: (_) {})),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(LucideIcons.mic));
    await tester.pump();
    await tester.tap(find.byIcon(LucideIcons.square));
    await tester.pump();
    await tester.tap(find.byIcon(LucideIcons.play));
    await tester.pump();
    expect(audio.playCount, 1);

    audio.emit(AudioState.playing);
    await tester.pump();

    audio.emit(AudioState.error);
    await tester.pumpAndSettle();
    expect(container.read(recordingControllerProvider).isPlaybackError, isTrue);

    expect(
      find.text('Recording playback failed. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Try playback again'), findsOneWidget);
    await tester.tap(find.text('Try playback again'));
    await tester.pump();
    expect(audio.playCount, 2);
    expect(audio.lastPlayedPath, '/tmp/recording.m4a');

    await audio.dispose();
    await recording.dispose();
  });
}

Future<void> _pumpRecording(
  WidgetTester tester,
  _FakeRecordingService recording,
) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [recordingServiceProvider.overrideWithValue(recording)],
      child: _TestApp(child: RecordingControls(onRecordingComplete: (_) {})),
    ),
  );
  await tester.pump();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = buildAppShadTheme();
    return ShadApp.custom(
      theme: theme,
      appBuilder: (context) => MaterialApp(
        theme: buildAppMaterialTheme(Theme.of(context), theme),
        home: Scaffold(body: Center(child: child)),
        builder: (context, child) =>
            ShadAppBuilder(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

final class _FakeAudioService implements AudioService {
  final _states = StreamController<AudioState>.broadcast();
  final _positions = StreamController<double>.broadcast();

  String? lastPlayedPath;
  int playCount = 0;

  @override
  Stream<AudioState> get audioState => _states.stream;

  @override
  Duration? get duration => const Duration(seconds: 10);

  @override
  Future<bool> get isAvailable async => true;

  @override
  Stream<double> get playbackPosition => _positions.stream;

  void emit(AudioState state) => _states.add(state);

  @override
  Future<void> pauseAudio() async => emit(AudioState.paused);

  @override
  Future<void> playAudio(String assetPath) async {
    playCount += 1;
    lastPlayedPath = assetPath;
  }

  @override
  Future<void> resumeAudio() async => emit(AudioState.playing);

  @override
  Future<void> seekTo(Duration position) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stopAudio() async => emit(AudioState.stopped);

  @override
  Future<void> dispose() async {
    await _states.close();
    await _positions.close();
  }
}

final class _FakeRecordingService implements RecordingService {
  _FakeRecordingService({
    this._hasPermission = false,
    this._isAvailable = true,
    this.waitForPermissionResult = false,
  });

  final _states = StreamController<RecordingState>.broadcast();
  final _durations = StreamController<double>.broadcast();
  final _volumes = StreamController<double>.broadcast();
  final bool _isAvailable;
  final bool waitForPermissionResult;
  Completer<bool>? _permissionResult;
  final bool _hasPermission;
  bool _permanentlyDenied = false;
  int startCount = 0;

  void completePermission({required bool permanentlyDenied}) {
    _permanentlyDenied = permanentlyDenied;
    _permissionResult!.complete(false);
  }

  void emitDuration(double value) => _durations.add(value);

  void emitVolume(double value) => _volumes.add(value);

  @override
  Future<bool> get hasPermission async => _hasPermission;

  @override
  Future<bool> get isAvailable async => _isAvailable;

  @override
  Future<bool> get isPermanentlyDenied async => _permanentlyDenied;

  @override
  Stream<double> get recordingDuration => _durations.stream;

  @override
  Stream<RecordingState> get recordingState => _states.stream;

  @override
  Stream<double> get volumeLevel => _volumes.stream;

  @override
  Future<void> cancelRecording() async => emit(RecordingState.idle);

  @override
  Future<void> clearRecording() async {}

  @override
  Future<bool> checkMinimumVolume(double threshold) async => true;

  @override
  Future<double> getCurrentVolume() async => .5;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> playRecording(String filePath) async =>
      emit(RecordingState.playing);

  @override
  Future<bool> requestPermission() async {
    emit(RecordingState.requestingPermission);
    if (waitForPermissionResult) {
      _permissionResult = Completer<bool>();
      return _permissionResult!.future;
    }
    return false;
  }

  @override
  Future<void> startRecording() async {
    startCount += 1;
    emit(RecordingState.recording);
  }

  @override
  Future<void> stopPlayback() async => emit(RecordingState.stopped);

  @override
  Future<String> stopRecording() async {
    emit(RecordingState.stopped);
    return '/tmp/recording.m4a';
  }

  @override
  Future<void> dispose() async {
    await _states.close();
    await _durations.close();
    await _volumes.close();
  }

  void emit(RecordingState state) => _states.add(state);
}
