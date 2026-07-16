import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:learning_core/learning_core.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';

typedef RecordIdFactory = String Function();

final class LessonProgressRepository {
  LessonProgressRepository(
    this._database, {
    this._scheduler = const ReviewScheduler(),
    RecordIdFactory? idFactory,
  }) : _idFactory = idFactory ?? const Uuid().v4;

  final AppDatabase _database;
  final ReviewScheduler _scheduler;
  final RecordIdFactory _idFactory;

  Future<void> startLesson({
    required String lessonId,
    required String contentVersion,
    required DateTime startedAt,
  }) async {
    final existing = await (_database.select(
      _database.lessonProgressEntries,
    )..where((entry) => entry.lessonId.equals(lessonId))).getSingleOrNull();
    if (existing?.status == 'completed') {
      return;
    }

    await _database
        .into(_database.lessonProgressEntries)
        .insertOnConflictUpdate(
          LessonProgressEntriesCompanion.insert(
            lessonId: lessonId,
            status: 'in_progress',
            startedAt: Value(existing?.startedAt ?? startedAt),
            contentVersion: contentVersion,
            updatedAt: startedAt,
          ),
        );
  }

  Future<void> recordExerciseAttempt({
    required String lessonId,
    required String stepId,
    required String contentVersion,
    required String itemId,
    required LearningDimension dimension,
    required ReviewRating rating,
    required bool correct,
    required bool usedHint,
    required int latencyMs,
    required DateTime answeredAt,
  }) {
    return _database.transaction(
      () => _recordExerciseAttempt(
        sourceType: 'lesson',
        sourceId: lessonId,
        stepId: stepId,
        contentVersion: contentVersion,
        itemId: itemId,
        dimension: dimension,
        rating: rating,
        correct: correct,
        usedHint: usedHint,
        latencyMs: latencyMs,
        answeredAt: answeredAt,
      ),
    );
  }

  Future<void> recordReviewAttempt({
    required String contentVersion,
    required String itemId,
    required LearningDimension dimension,
    required ReviewRating rating,
    required bool correct,
    required bool usedHint,
    required int latencyMs,
    required DateTime answeredAt,
  }) {
    return _database.transaction(
      () => _recordExerciseAttempt(
        sourceType: 'review',
        sourceId: 'due-queue',
        contentVersion: contentVersion,
        itemId: itemId,
        dimension: dimension,
        rating: rating,
        correct: correct,
        usedHint: usedHint,
        latencyMs: latencyMs,
        answeredAt: answeredAt,
      ),
    );
  }

  Future<void> recordSpeakingAttempt({
    required String lessonId,
    required String stepId,
    required String contentVersion,
    required String targetId,
    required ReviewRating rating,
    required bool correct,
    required double localScore,
    required int latencyMs,
    required DateTime answeredAt,
  }) {
    return _database.transaction(() async {
      final speakingAttemptId = _idFactory();
      await _database
          .into(_database.speakingAttempts)
          .insert(
            SpeakingAttemptsCompanion.insert(
              attemptId: speakingAttemptId,
              targetId: targetId,
              localScore: Value(localScore),
              createdAt: answeredAt,
            ),
          );
      await _recordExerciseAttempt(
        sourceType: 'lesson',
        sourceId: lessonId,
        stepId: stepId,
        contentVersion: contentVersion,
        itemId: targetId,
        dimension: LearningDimension.tone,
        rating: rating,
        correct: correct,
        usedHint: false,
        latencyMs: latencyMs,
        answeredAt: answeredAt,
      );
      await _enqueueEvent(
        entityType: 'speaking_attempt',
        occurredAt: answeredAt,
        payload: {
          'attemptId': speakingAttemptId,
          'lessonId': lessonId,
          'stepId': stepId,
          'contentVersion': contentVersion,
          'targetId': targetId,
          'localScore': localScore,
        },
      );
    });
  }

  Future<void> completeLesson({
    required String lessonId,
    required Iterable<String> itemIds,
    required String contentVersion,
    required int score,
    required DateTime completedAt,
  }) {
    return _database.transaction(() async {
      final existing = await (_database.select(
        _database.lessonProgressEntries,
      )..where((entry) => entry.lessonId.equals(lessonId))).getSingleOrNull();
      if (existing?.status == 'completed') {
        return;
      }

      for (final itemId in itemIds) {
        for (final dimension in LearningDimension.values) {
          await _database
              .into(_database.masteryStates)
              .insert(
                MasteryStatesCompanion.insert(
                  itemId: itemId,
                  dimension: dimension.name,
                  box: 0,
                  confidence: 0,
                  dueAt: completedAt.add(_scheduler.intervalForBox(0)),
                  updatedAt: completedAt,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }

      await _database
          .into(_database.lessonProgressEntries)
          .insertOnConflictUpdate(
            LessonProgressEntriesCompanion.insert(
              lessonId: lessonId,
              status: 'completed',
              score: Value(score),
              startedAt: Value(existing?.startedAt ?? completedAt),
              completedAt: Value(completedAt),
              contentVersion: contentVersion,
              updatedAt: completedAt,
            ),
          );
      await _enqueueEvent(
        entityType: 'lesson_progress',
        occurredAt: completedAt,
        payload: {
          'lessonId': lessonId,
          'status': 'completed',
          'score': score,
          'contentVersion': contentVersion,
          'completedAt': completedAt.toIso8601String(),
        },
      );
    });
  }

  Future<void> _recordExerciseAttempt({
    required String sourceType,
    required String sourceId,
    required String contentVersion,
    required String itemId,
    required LearningDimension dimension,
    required ReviewRating rating,
    required bool correct,
    required bool usedHint,
    required int latencyMs,
    required DateTime answeredAt,
    String? stepId,
  }) async {
    final dimensionName = dimension.name;
    final existing =
        await (_database.select(_database.masteryStates)..where(
              (entry) =>
                  entry.itemId.equals(itemId) &
                  entry.dimension.equals(dimensionName),
            ))
            .getSingleOrNull();
    final current = ReviewState(
      itemId: itemId,
      dimension: dimension,
      box: existing?.box ?? 0,
      dueAt: existing?.dueAt ?? answeredAt,
      lastReviewedAt: existing?.lastReviewedAt ?? answeredAt,
      sameDayRetryCount: existing?.sameDayRetryCount ?? 0,
    );
    final outcome = _scheduler.apply(
      current: current,
      rating: rating,
      correct: correct,
      usedHint: usedHint,
      answeredAt: answeredAt,
    );

    final attemptId = _idFactory();
    await _database
        .into(_database.reviewAttempts)
        .insert(
          ReviewAttemptsCompanion.insert(
            attemptId: attemptId,
            itemId: itemId,
            dimension: dimensionName,
            result: rating.name,
            correct: correct,
            usedHint: usedHint,
            latencyMs: latencyMs,
            createdAt: answeredAt,
          ),
        );
    await _database
        .into(_database.masteryStates)
        .insertOnConflictUpdate(
          MasteryStatesCompanion.insert(
            itemId: itemId,
            dimension: dimensionName,
            box: outcome.state.box,
            confidence: _confidenceFor(
              rating: rating,
              correct: correct,
              usedHint: usedHint,
            ),
            dueAt: outcome.state.dueAt,
            lastResult: Value(rating.name),
            lastReviewedAt: Value(answeredAt),
            sameDayRetryCount: Value(outcome.state.sameDayRetryCount),
            updatedAt: answeredAt,
          ),
        );
    final payload = <String, Object?>{
      'attemptId': attemptId,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'contentVersion': contentVersion,
      'itemId': itemId,
      'dimension': dimensionName,
      'result': rating.name,
      'correct': correct,
      'usedHint': usedHint,
      'latencyMs': latencyMs,
    };
    if (stepId != null) {
      payload['stepId'] = stepId;
    }
    if (sourceType == 'lesson') {
      payload['lessonId'] = sourceId;
    }
    await _enqueueEvent(
      entityType: 'review_attempt',
      occurredAt: answeredAt,
      payload: payload,
    );
  }

  Future<void> _enqueueEvent({
    required String entityType,
    required DateTime occurredAt,
    required Map<String, Object?> payload,
  }) {
    return _database
        .into(_database.syncOutboxEvents)
        .insert(
          SyncOutboxEventsCompanion.insert(
            eventId: _idFactory(),
            entityType: entityType,
            payloadJson: jsonEncode(payload),
            occurredAt: occurredAt,
          ),
        );
  }

  double _confidenceFor({
    required ReviewRating rating,
    required bool correct,
    required bool usedHint,
  }) {
    if (!correct || rating == ReviewRating.forgotten) {
      return 0;
    }
    if (rating == ReviewRating.vague) {
      return 0.5;
    }
    return usedHint ? 0.65 : 1;
  }
}
