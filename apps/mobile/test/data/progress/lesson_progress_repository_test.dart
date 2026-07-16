import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_core/learning_core.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/progress/lesson_progress_repository.dart';

void main() {
  late AppDatabase database;
  late LessonProgressRepository repository;
  late int nextId;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    nextId = 0;
    repository = LessonProgressRepository(
      database,
      idFactory: () => 'record-${nextId++}',
    );
  });

  tearDown(() => database.close());

  test('persists submitted exercise attempts and updates mastery', () async {
    final firstAnswerAt = DateTime.utc(2026, 7, 16, 8);
    await repository.recordExerciseAttempt(
      lessonId: 'cafe-01',
      stepId: 'cafe-01-listen',
      contentVersion: '0.1.0',
      itemId: 'sentence-order-coffee',
      dimension: LearningDimension.listening,
      rating: ReviewRating.forgotten,
      correct: false,
      usedHint: false,
      latencyMs: 2500,
      answeredAt: firstAnswerAt,
    );
    await repository.recordExerciseAttempt(
      lessonId: 'cafe-01',
      stepId: 'cafe-01-listen',
      contentVersion: '0.1.0',
      itemId: 'sentence-order-coffee',
      dimension: LearningDimension.listening,
      rating: ReviewRating.remembered,
      correct: true,
      usedHint: true,
      latencyMs: 1400,
      answeredAt: firstAnswerAt.add(const Duration(minutes: 1)),
    );

    final attempts = await database.select(database.reviewAttempts).get();
    final mastery = await database.select(database.masteryStates).getSingle();
    final outbox = await database.select(database.syncOutboxEvents).get();

    expect(attempts.map((attempt) => attempt.result), [
      'forgotten',
      'remembered',
    ]);
    expect(attempts.last.usedHint, isTrue);
    expect(mastery.box, 0);
    expect(mastery.confidence, 0.65);
    expect(mastery.dueAt, firstAnswerAt.add(const Duration(minutes: 11)));
    expect(mastery.lastResult, 'remembered');
    expect(mastery.sameDayRetryCount, 0);
    expect(outbox, hasLength(2));
    expect(
      outbox.every((event) => event.entityType == 'review_attempt'),
      isTrue,
    );
    expect(
      jsonDecode(outbox.last.payloadJson),
      containsPair('contentVersion', '0.1.0'),
    );
  });

  test(
    'completes a lesson and creates missing four-dimensional states',
    () async {
      final startedAt = DateTime.utc(2026, 7, 16, 8);
      final completedAt = startedAt.add(const Duration(minutes: 9));
      await repository.startLesson(
        lessonId: 'cafe-01',
        contentVersion: '0.1.0',
        startedAt: startedAt,
      );
      await repository.recordSpeakingAttempt(
        lessonId: 'cafe-01',
        stepId: 'cafe-01-repeat',
        contentVersion: '0.1.0',
        targetId: 'sentence-order-coffee',
        rating: ReviewRating.remembered,
        correct: true,
        localScore: 1,
        latencyMs: 3200,
        answeredAt: completedAt.subtract(const Duration(minutes: 1)),
      );
      await repository.completeLesson(
        lessonId: 'cafe-01',
        itemIds: const [
          'phrase-i-want',
          'noun-coffee',
          'sentence-order-coffee',
        ],
        contentVersion: '0.1.0',
        score: 100,
        completedAt: completedAt,
      );
      await repository.completeLesson(
        lessonId: 'cafe-01',
        itemIds: const [
          'phrase-i-want',
          'noun-coffee',
          'sentence-order-coffee',
        ],
        contentVersion: '0.1.0',
        score: 20,
        completedAt: completedAt.add(const Duration(seconds: 1)),
      );

      final progress = await database
          .select(database.lessonProgressEntries)
          .getSingle();
      final mastery = await database.select(database.masteryStates).get();
      final speaking = await database.select(database.speakingAttempts).get();
      final outbox = await database.select(database.syncOutboxEvents).get();
      final persistedRepository = LessonProgressRepository(database);
      await persistedRepository.startLesson(
        lessonId: 'cafe-01',
        contentVersion: '0.1.0',
        startedAt: completedAt.add(const Duration(days: 1)),
      );
      final progressAfterReopen = await database
          .select(database.lessonProgressEntries)
          .getSingle();

      expect(progress.status, 'completed');
      expect(progress.score, 100);
      expect(progress.startedAt, startedAt);
      expect(progress.completedAt, completedAt);
      expect(mastery, hasLength(12));
      expect(
        mastery
            .where(
              (state) =>
                  state.itemId == 'sentence-order-coffee' &&
                  state.dimension == 'tone',
            )
            .single
            .box,
        1,
      );
      expect(speaking.single.localScore, 1);
      expect(outbox.map((event) => event.entityType), [
        'review_attempt',
        'speaking_attempt',
        'lesson_progress',
      ]);
      expect(progressAfterReopen.status, 'completed');
      expect(progressAfterReopen.completedAt, completedAt);
    },
  );
}
