import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/audio/audio_providers.dart';
import 'package:mandarin_mission/data/audio/audio_service.dart';
import 'package:mandarin_mission/data/audio/recording_service.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/content/course_content_repository.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';
import 'package:mandarin_mission/features/lesson/application/lesson_providers.dart';

void main() {
  testWidgets('lesson clears its media session when the app is backgrounded', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final audioService = _TrackingAudioService();
    final recordingService = _TrackingRecordingService();
    addTearDown(() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox.shrink());
      await database.close();
      await audioService.dispose();
      await recordingService.dispose();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          courseContentRepositoryProvider.overrideWithValue(
            CourseContentRepository(
              assetPath: CourseContentRepository.bundledCafeCourseAsset,
            ),
          ),
          audioServiceProvider.overrideWithValue(audioService),
          recordingServiceProvider.overrideWithValue(recordingService),
        ],
        child: const MandarinMissionApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('open-lesson-cafe-01')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-lesson-cafe-01')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-overview-page')), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('lesson-overview-page'))),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();

    expect(audioService.stopCount, 1);
    expect(recordingService.clearRecordingCount, 1);

    recordingService.setPermission(granted: true, permanentlyDenied: false);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(container.read(recordingControllerProvider).hasPermission, isTrue);

    final lessonController = container.read(
      lessonPlayerControllerProvider('cafe-01').notifier,
    );
    for (var index = 0; index < 8; index += 1) {
      lessonController.next(11);
    }
    await tester.pumpAndSettle();
    expect(find.text('9 / 11'), findsOneWidget);

    recordingService.emit(RecordingState.recording);
    await tester.pump();
    await tester.tap(find.byKey(const Key('lesson-back-action')));
    await tester.pumpAndSettle();

    expect(find.text('8 / 11'), findsOneWidget);
    expect(recordingService.cancelRecordingCount, 1);
    expect(audioService.stopCount, 2);
    expect(recordingService.clearRecordingCount, 2);
  });
}

final class _TrackingAudioService extends Fake implements AudioService {
  final _states = StreamController<AudioState>.broadcast();
  final _positions = StreamController<double>.broadcast();
  int stopCount = 0;

  @override
  Stream<AudioState> get audioState => _states.stream;

  @override
  Stream<double> get playbackPosition => _positions.stream;

  @override
  Future<void> stopAudio() async {
    stopCount += 1;
    _states.add(AudioState.stopped);
  }

  @override
  Future<void> dispose() async {
    await _states.close();
    await _positions.close();
  }
}

final class _TrackingRecordingService extends Fake implements RecordingService {
  final _states = StreamController<RecordingState>.broadcast();
  final _durations = StreamController<double>.broadcast();
  final _volumes = StreamController<double>.broadcast();
  bool _hasPermission = false;
  bool _isPermanentlyDenied = false;
  int clearRecordingCount = 0;
  int cancelRecordingCount = 0;

  void emit(RecordingState state) => _states.add(state);

  @override
  Future<bool> get hasPermission async => _hasPermission;

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<bool> get isPermanentlyDenied async => _isPermanentlyDenied;

  void setPermission({required bool granted, required bool permanentlyDenied}) {
    _hasPermission = granted;
    _isPermanentlyDenied = permanentlyDenied;
  }

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
  Future<void> cancelRecording() async {
    cancelRecordingCount += 1;
    _states.add(RecordingState.idle);
  }

  @override
  Future<void> dispose() async {
    await _states.close();
    await _durations.close();
    await _volumes.close();
  }
}
