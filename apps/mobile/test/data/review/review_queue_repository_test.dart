import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_core/learning_core.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/progress/lesson_progress_repository.dart';
import 'package:mandarin_mission/data/review/review_queue_repository.dart';

void main() {
  late AppDatabase database;
  late ReviewQueueRepository repository;
  late int nextId;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    nextId = 0;
    repository = ReviewQueueRepository(
      database,
      LessonProgressRepository(database, idFactory: () => 'record-${nextId++}'),
    );
  });

  tearDown(() => database.close());

  test('returns only due items in review priority order', () async {
    final now = DateTime.utc(2026, 7, 17, 8);
    await _insertMastery(
      database,
      itemId: 'meaning-old',
      dimension: LearningDimension.meaning,
      dueAt: now.subtract(const Duration(days: 2)),
    );
    await _insertMastery(
      database,
      itemId: 'tone-failed',
      dimension: LearningDimension.tone,
      dueAt: now.subtract(const Duration(hours: 1)),
      lastResult: ReviewRating.forgotten,
    );
    await _insertMastery(
      database,
      itemId: 'listening-due',
      dimension: LearningDimension.listening,
      dueAt: now.subtract(const Duration(minutes: 30)),
    );
    await _insertMastery(
      database,
      itemId: 'hanzi-future',
      dimension: LearningDimension.hanzi,
      dueAt: now.add(const Duration(minutes: 1)),
    );

    final items = await repository.dueItems(now: now, limit: 2);

    expect(items.map((item) => item.itemId), ['tone-failed', 'listening-due']);
  });

  test('submits review attempts through scheduler and outbox', () async {
    final dueAt = DateTime.utc(2026, 7, 17, 8);
    await _insertMastery(
      database,
      itemId: 'sentence-order-coffee',
      dimension: LearningDimension.listening,
      dueAt: dueAt,
      box: 2,
    );
    final item = (await repository.dueItems(now: dueAt)).single;
    final answeredAt = dueAt.add(const Duration(seconds: 5));

    await repository.submitAttempt(
      item: item,
      contentVersion: '0.1.0',
      rating: ReviewRating.remembered,
      correct: true,
      usedHint: false,
      latencyMs: 5000,
      answeredAt: answeredAt,
    );

    final mastery = await database.select(database.masteryStates).getSingle();
    final attempt = await database.select(database.reviewAttempts).getSingle();
    final outbox = await database.select(database.syncOutboxEvents).getSingle();
    final payload = jsonDecode(outbox.payloadJson) as Map<String, Object?>;

    expect(mastery.box, 3);
    expect(mastery.dueAt, answeredAt.add(const Duration(days: 7)));
    expect(attempt.result, 'remembered');
    expect(payload['sourceType'], 'review');
    expect(payload['sourceId'], 'due-queue');
    expect(payload['contentVersion'], '0.1.0');
  });

  test('rejects non-UTC queue timestamps', () async {
    await expectLater(
      repository.dueItems(now: DateTime(2026, 7, 17, 8)),
      throwsArgumentError,
    );
  });
}

Future<void> _insertMastery(
  AppDatabase database, {
  required String itemId,
  required LearningDimension dimension,
  required DateTime dueAt,
  ReviewRating? lastResult,
  int box = 0,
}) {
  return database
      .into(database.masteryStates)
      .insert(
        MasteryStatesCompanion.insert(
          itemId: itemId,
          dimension: dimension.name,
          box: box,
          confidence: 0,
          dueAt: dueAt,
          lastResult: Value(lastResult?.name),
          updatedAt: dueAt,
        ),
      );
}
