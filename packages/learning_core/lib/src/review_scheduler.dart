import 'learning_core_base.dart';

/// Persisted scheduling state for one item and one learning dimension.
final class ReviewState {
  ReviewState({
    required this.itemId,
    required this.dimension,
    required this.box,
    required this.dueAt,
    required this.lastReviewedAt,
    this.sameDayRetryCount = 0,
  }) {
    RangeError.checkValueInInterval(box, 0, 5, 'box');
    RangeError.checkValueInInterval(
      sameDayRetryCount,
      0,
      2,
      'sameDayRetryCount',
    );
    _requireUtc(dueAt, 'dueAt');
    _requireUtc(lastReviewedAt, 'lastReviewedAt');
  }

  final String itemId;
  final LearningDimension dimension;
  final int box;
  final DateTime dueAt;
  final DateTime lastReviewedAt;
  final int sameDayRetryCount;

  static void _requireUtc(DateTime value, String name) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, name, 'must use UTC');
    }
  }
}

/// The result of applying one review attempt to a [ReviewState].
final class ReviewOutcome {
  const ReviewOutcome({
    required this.state,
    required this.needsSameSessionRetry,
  });

  final ReviewState state;
  final bool needsSameSessionRetry;
}

/// Deterministic 0-5 box scheduler used by the first MVP.
final class ReviewScheduler {
  const ReviewScheduler();

  static const List<Duration> _intervals = [
    Duration(minutes: 10),
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
  ];

  Duration intervalForBox(int box) {
    RangeError.checkValueInInterval(box, 0, 5, 'box');
    return _intervals[box];
  }

  ReviewOutcome apply({
    required ReviewState current,
    required ReviewRating rating,
    required bool correct,
    required bool usedHint,
    required DateTime answeredAt,
  }) {
    if (!answeredAt.isUtc) {
      throw ArgumentError.value(answeredAt, 'answeredAt', 'must use UTC');
    }

    final failed = !correct || rating == ReviewRating.forgotten;
    if (failed) {
      final retries = (current.sameDayRetryCount + 1).clamp(0, 2);
      return ReviewOutcome(
        state: ReviewState(
          itemId: current.itemId,
          dimension: current.dimension,
          box: (current.box - 2).clamp(0, 5),
          dueAt: answeredAt.add(_intervals[0]),
          lastReviewedAt: answeredAt,
          sameDayRetryCount: retries,
        ),
        needsSameSessionRetry: current.sameDayRetryCount < 2,
      );
    }

    if (rating == ReviewRating.vague) {
      return ReviewOutcome(
        state: ReviewState(
          itemId: current.itemId,
          dimension: current.dimension,
          box: current.box,
          dueAt: answeredAt.add(const Duration(days: 1)),
          lastReviewedAt: answeredAt,
        ),
        needsSameSessionRetry: false,
      );
    }

    final nextBox = usedHint ? current.box : (current.box + 1).clamp(0, 5);
    return ReviewOutcome(
      state: ReviewState(
        itemId: current.itemId,
        dimension: current.dimension,
        box: nextBox,
        dueAt: answeredAt.add(intervalForBox(nextBox)),
        lastReviewedAt: answeredAt,
      ),
      needsSameSessionRetry: false,
    );
  }
}
