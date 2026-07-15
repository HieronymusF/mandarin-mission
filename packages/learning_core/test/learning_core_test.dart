import 'package:learning_core/learning_core.dart';
import 'package:test/test.dart';

void main() {
  const scheduler = ReviewScheduler();
  final answeredAt = DateTime.utc(2026, 7, 15, 9);

  ReviewState state({
    int box = 2,
    int retries = 0,
    LearningDimension dimension = LearningDimension.listening,
  }) => ReviewState(
    itemId: 'phrase-wo-yao',
    dimension: dimension,
    box: box,
    dueAt: answeredAt,
    lastReviewedAt: answeredAt.subtract(const Duration(days: 1)),
    sameDayRetryCount: retries,
  );

  group('ReviewScheduler', () {
    test('remembered answer advances one box and uses its interval', () {
      final result = scheduler.apply(
        current: state(),
        rating: ReviewRating.remembered,
        correct: true,
        usedHint: false,
        answeredAt: answeredAt,
      );

      expect(result.state.box, 3);
      expect(result.state.dueAt, answeredAt.add(const Duration(days: 7)));
      expect(result.state.sameDayRetryCount, 0);
      expect(result.needsSameSessionRetry, isFalse);
    });

    test('hinted answer does not advance', () {
      final result = scheduler.apply(
        current: state(box: 3),
        rating: ReviewRating.remembered,
        correct: true,
        usedHint: true,
        answeredAt: answeredAt,
      );

      expect(result.state.box, 3);
      expect(result.state.dueAt, answeredAt.add(const Duration(days: 7)));
    });

    test('vague answer stays in its box and returns next day', () {
      final result = scheduler.apply(
        current: state(box: 4),
        rating: ReviewRating.vague,
        correct: true,
        usedHint: false,
        answeredAt: answeredAt,
      );

      expect(result.state.box, 4);
      expect(result.state.dueAt, answeredAt.add(const Duration(days: 1)));
    });

    test('forgotten answer drops two boxes and requests a retry', () {
      final result = scheduler.apply(
        current: state(box: 4),
        rating: ReviewRating.forgotten,
        correct: false,
        usedHint: false,
        answeredAt: answeredAt,
      );

      expect(result.state.box, 2);
      expect(result.state.dueAt, answeredAt.add(const Duration(minutes: 10)));
      expect(result.state.sameDayRetryCount, 1);
      expect(result.needsSameSessionRetry, isTrue);
    });

    test('same-session retries stop after two attempts', () {
      final result = scheduler.apply(
        current: state(box: 0, retries: 2),
        rating: ReviewRating.forgotten,
        correct: false,
        usedHint: false,
        answeredAt: answeredAt,
      );

      expect(result.state.box, 0);
      expect(result.state.sameDayRetryCount, 2);
      expect(result.needsSameSessionRetry, isFalse);
    });

    test('all four dimensions keep independent state', () {
      for (final dimension in LearningDimension.values) {
        final result = scheduler.apply(
          current: state(dimension: dimension),
          rating: ReviewRating.remembered,
          correct: true,
          usedHint: false,
          answeredAt: answeredAt,
        );

        expect(result.state.dimension, dimension);
      }
    });

    test('rejects non-UTC timestamps', () {
      expect(
        () => scheduler.apply(
          current: state(),
          rating: ReviewRating.remembered,
          correct: true,
          usedHint: false,
          answeredAt: DateTime(2026, 7, 15, 9),
        ),
        throwsArgumentError,
      );
    });
  });
}
