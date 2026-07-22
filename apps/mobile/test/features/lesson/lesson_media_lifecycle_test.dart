import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/audio/audio_providers.dart';
import 'package:mandarin_mission/data/audio/audio_service.dart';
import 'package:mandarin_mission/data/audio/recording_service.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';

void main() {
  testWidgets('lesson clears its media session when the app is backgrounded', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final audioService = _TrackingAudioService();
    final recordingService = _TrackingRecordingService();
    addTearDown(() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await database.close();
      await audioService.dispose();
      await recordingService.dispose();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          audioServiceProvider.overrideWithValue(audioService),
          recordingServiceProvider.overrideWithValue(recordingService),
        ],
        child: const MandarinMissionApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('open-cafe-lesson')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-cafe-lesson')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-overview-page')), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();

    expect(audioService.stopCount, 1);
    expect(recordingService.clearRecordingCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.byKey(const Key('lesson-back-action')));
    await tester.pumpAndSettle();

    expect(audioService.stopCount, 2);
    expect(recordingService.clearRecordingCount, 2);
  });
}

final class _TrackingAudioService extends Fake implements AudioService {
  final _states = StreamController<AudioState>.broadcast();
  int stopCount = 0;

  @override
  Stream<AudioState> get audioState => _states.stream;

  @override
  Future<void> stopAudio() async {
    stopCount += 1;
    _states.add(AudioState.stopped);
  }

  @override
  Future<void> dispose() => _states.close();
}

final class _TrackingRecordingService extends Fake implements RecordingService {
  final _states = StreamController<RecordingState>.broadcast();
  final _durations = StreamController<double>.broadcast();
  final _volumes = StreamController<double>.broadcast();
  int clearRecordingCount = 0;

  @override
  Future<bool> get hasPermission async => false;

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<bool> get isPermanentlyDenied async => false;

  @override
  Stream<double> get recordingDuration => _durations.stream;

  @override
  Stream<RecordingState> get recordingState => _states.stream;

  @override
  Stream<double> get volumeLevel => _volumes.stream;

  @override
  Future<void> clearRecording() async {
    clearRecordingCount += 1;
  }

  @override
  Future<void> dispose() async {
    await _states.close();
    await _durations.close();
    await _volumes.close();
  }
}
