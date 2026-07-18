import 'package:drift/drift.dart';
import 'package:learning_core/learning_core.dart';

import '../local/app_database.dart';
import '../progress/lesson_progress_repository.dart';

abstract interface class ReviewQueueDataSource {
  Future<List<ReviewQueueItem>> dueItems({
    required DateTime now,
    int limit = 10,
  });

  Future<void> submitAttempt({
    required ReviewQueueItem item,
    required String contentVersion,
    required ReviewRating rating,
    required bool correct,
    required bool usedHint,
    required int latencyMs,
    required DateTime answeredAt,
  });
}

final class ReviewQueueItem {
  const ReviewQueueItem({
    required this.itemId,
    required this.dimension,
    required this.box,
    required this.confidence,
    required this.dueAt,
    required this.lastResult,
    required this.sameDayRetryCount,
  });

  final String itemId;
  final LearningDimension dimension;
  final int box;
  final double confidence;
  final DateTime dueAt;
  final ReviewRating? lastResult;
  final int sameDayRetryCount;

  ReviewQueueItem copyWith({int? sameDayRetryCount}) {
    return ReviewQueueItem(
      itemId: itemId,
      dimension: dimension,
      box: box,
      confidence: confidence,
      dueAt: dueAt,
      lastResult: lastResult,
      sameDayRetryCount: sameDayRetryCount ?? this.sameDayRetryCount,
    );
  }
}

final class ReviewQueueRepository implements ReviewQueueDataSource {
  const ReviewQueueRepository(this._database, this._progressRepository);

  final AppDatabase _database;
  final LessonProgressRepository _progressRepository;

  @override
  Future<List<ReviewQueueItem>> dueItems({
    required DateTime now,
    int limit = 10,
  }) async {
    if (!now.isUtc) {
      throw ArgumentError.value(now, 'now', 'must use UTC');
    }
    RangeError.checkValueInInterval(limit, 1, 100, 'limit');

    final rows = await (_database.select(
      _database.masteryStates,
    )..where((state) => state.dueAt.isSmallerOrEqualValue(now))).get();
    final items = rows.map(_toQueueItem).toList()..sort(_compareQueueItems);
    return List.unmodifiable(items.take(limit));
  }

  @override
  Future<void> submitAttempt({
    required ReviewQueueItem item,
    required String contentVersion,
    required ReviewRating rating,
    required bool correct,
    required bool usedHint,
    required int latencyMs,
    required DateTime answeredAt,
  }) {
    return _progressRepository.recordReviewAttempt(
      contentVersion: contentVersion,
      itemId: item.itemId,
      dimension: item.dimension,
      rating: rating,
      correct: correct,
      usedHint: usedHint,
      latencyMs: latencyMs,
      answeredAt: answeredAt,
    );
  }

  ReviewQueueItem _toQueueItem(MasteryState state) {
    return ReviewQueueItem(
      itemId: state.itemId,
      dimension: LearningDimension.values.byName(state.dimension),
      box: state.box,
      confidence: state.confidence,
      dueAt: state.dueAt,
      lastResult: state.lastResult == null
          ? null
          : ReviewRating.values.byName(state.lastResult!),
      sameDayRetryCount: state.sameDayRetryCount,
    );
  }

  int _compareQueueItems(ReviewQueueItem left, ReviewQueueItem right) {
    final failedComparison = _failedPriority(
      left,
    ).compareTo(_failedPriority(right));
    if (failedComparison != 0) {
      return failedComparison;
    }

    final dimensionComparison = _dimensionPriority(
      left.dimension,
    ).compareTo(_dimensionPriority(right.dimension));
    if (dimensionComparison != 0) {
      return dimensionComparison;
    }

    final dueComparison = left.dueAt.compareTo(right.dueAt);
    if (dueComparison != 0) {
      return dueComparison;
    }

    final itemComparison = left.itemId.compareTo(right.itemId);
    if (itemComparison != 0) {
      return itemComparison;
    }
    return left.dimension.index.compareTo(right.dimension.index);
  }

  int _failedPriority(ReviewQueueItem item) {
    return item.lastResult == ReviewRating.forgotten ? 0 : 1;
  }

  int _dimensionPriority(LearningDimension dimension) {
    return switch (dimension) {
      LearningDimension.listening || LearningDimension.tone => 0,
      LearningDimension.meaning || LearningDimension.hanzi => 1,
    };
  }
}
