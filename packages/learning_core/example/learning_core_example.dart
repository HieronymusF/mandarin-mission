import 'package:learning_core/learning_core.dart';

void main() {
  const scheduler = ReviewScheduler();
  final now = DateTime.now().toUtc();
  final outcome = scheduler.apply(
    current: ReviewState(
      itemId: 'phrase-wo-yao',
      dimension: LearningDimension.listening,
      box: 0,
      dueAt: now,
      lastReviewedAt: now,
    ),
    rating: ReviewRating.remembered,
    correct: true,
    usedHint: false,
    answeredAt: now,
  );

  print('Next review: ${outcome.state.dueAt.toIso8601String()}');
}
