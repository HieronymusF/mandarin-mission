import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/features/settings/data/local_data_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('clears learner data but keeps the installed content package', () async {
    final now = DateTime.utc(2026, 7, 27, 8);
    await database.batch((batch) {
      batch.insert(
        database.installedContentPackages,
        InstalledContentPackagesCompanion.insert(
          packageId: 'm2',
          version: '0.2.7',
          schemaVersion: 1,
          manifestHash: 'hash',
          installedAt: now,
          isActive: const Value(true),
        ),
      );
      batch.insert(
        database.lessonProgressEntries,
        LessonProgressEntriesCompanion.insert(
          lessonId: 'cafe-01',
          status: 'completed',
          score: const Value(100),
          contentVersion: '0.2.7',
          updatedAt: now,
        ),
      );
      batch.insert(
        database.masteryStates,
        MasteryStatesCompanion.insert(
          itemId: 'phrase-wo-yao',
          dimension: 'meaning',
          box: 1,
          confidence: 1,
          dueAt: now,
          updatedAt: now,
        ),
      );
      batch.insert(
        database.reviewAttempts,
        ReviewAttemptsCompanion.insert(
          attemptId: 'review-1',
          itemId: 'phrase-wo-yao',
          dimension: 'meaning',
          result: 'remembered',
          correct: true,
          usedHint: false,
          latencyMs: 100,
          createdAt: now,
        ),
      );
      batch.insert(
        database.speakingAttempts,
        SpeakingAttemptsCompanion.insert(
          attemptId: 'speaking-1',
          targetId: 'phrase-wo-yao',
          localScore: const Value(1),
          createdAt: now,
        ),
      );
      batch.insert(
        database.syncOutboxEvents,
        SyncOutboxEventsCompanion.insert(
          eventId: 'event-1',
          entityType: 'lesson_progress',
          payloadJson: '{}',
          occurredAt: now,
        ),
      );
    });

    await DriftLocalDataRepository(database).clearLearningData();

    expect(
      await database.select(database.installedContentPackages).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.lessonProgressEntries).get(),
      isEmpty,
    );
    expect(await database.select(database.masteryStates).get(), isEmpty);
    expect(await database.select(database.reviewAttempts).get(), isEmpty);
    expect(await database.select(database.speakingAttempts).get(), isEmpty);
    expect(await database.select(database.syncOutboxEvents).get(), isEmpty);
  });
}
