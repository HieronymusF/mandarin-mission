import 'package:drift/drift.dart';

class InstalledContentPackages extends Table {
  late final packageId = text()();
  late final version = text()();
  late final schemaVersion = integer()();
  late final manifestHash = text()();
  late final installedAt = dateTime()();
  late final isActive = boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {packageId, version};
}

class LessonProgressEntries extends Table {
  late final lessonId = text()();
  late final Column<String> status = text().check(
    status.isIn(const ['not_started', 'in_progress', 'completed']),
  )();
  late final Column<int> score = integer().nullable().check(
    score.isNull() | score.isBetweenValues(0, 100),
  )();
  late final startedAt = dateTime().nullable()();
  late final completedAt = dateTime().nullable()();
  late final contentVersion = text()();
  late final updatedAt = dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {lessonId};
}

@TableIndex(name: 'mastery_states_due_at', columns: {#dueAt})
class MasteryStates extends Table {
  late final itemId = text()();
  late final Column<String> dimension = text().check(
    dimension.isIn(const ['meaning', 'listening', 'tone', 'hanzi']),
  )();
  late final Column<int> box = integer().check(box.isBetweenValues(0, 5))();
  late final Column<double> confidence = real().check(
    confidence.isBetweenValues(0, 1),
  )();
  late final dueAt = dateTime()();
  late final lastResult = text().nullable()();
  late final lastReviewedAt = dateTime().nullable()();
  late final Column<int> sameDayRetryCount = integer()
      .withDefault(const Constant(0))
      .check(sameDayRetryCount.isBetweenValues(0, 2))();
  late final updatedAt = dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemId, dimension};
}

@TableIndex(
  name: 'review_attempts_item_created_at',
  columns: {#itemId, #createdAt},
)
class ReviewAttempts extends Table {
  late final attemptId = text()();
  late final itemId = text()();
  late final Column<String> dimension = text().check(
    dimension.isIn(const ['meaning', 'listening', 'tone', 'hanzi']),
  )();
  late final Column<String> result = text().check(
    result.isIn(const ['forgotten', 'vague', 'remembered']),
  )();
  late final correct = boolean()();
  late final usedHint = boolean()();
  late final Column<int> latencyMs = integer().check(
    latencyMs.isBiggerOrEqualValue(0),
  )();
  late final createdAt = dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {attemptId};
}

class SpeakingAttempts extends Table {
  late final attemptId = text()();
  late final targetId = text()();
  late final Column<double> localScore = real().nullable().check(
    localScore.isNull() | localScore.isBetweenValues(0, 1),
  )();
  late final Column<double> providerScore = real().nullable().check(
    providerScore.isNull() | providerScore.isBetweenValues(0, 1),
  )();
  late final createdAt = dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {attemptId};
}

@TableIndex(name: 'sync_outbox_occurred_at', columns: {#occurredAt})
class SyncOutboxEvents extends Table {
  late final eventId = text()();
  late final entityType = text()();
  late final payloadJson = text()();
  late final occurredAt = dateTime()();
  late final Column<int> attempts = integer()
      .withDefault(const Constant(0))
      .check(attempts.isBiggerOrEqualValue(0))();
  late final acknowledgedAt = dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}
