import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/features/review/application/review_providers.dart';

void main() {
  test('provides the shared learning-core review scheduler', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(reviewSchedulerProvider).intervalForBox(1),
      const Duration(days: 1),
    );
  });

  test('splits must-do and extra due review counts', () {
    const summary = ReviewQueueSummary(dueCount: 11);

    expect(summary.requiredCount, reviewSessionLimit);
    expect(summary.extraCount, 3);
    expect(summary.hasDueItems, isTrue);
  });
}
