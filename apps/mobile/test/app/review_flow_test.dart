import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_core/learning_core.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/content/course_content_repository.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';
import 'package:mandarin_mission/data/review/review_queue_repository.dart';
import 'package:mandarin_mission/features/review/application/review_providers.dart';

void main() {
  final now = DateTime.utc(2026, 7, 18, 9);
  late String contentSource;

  setUpAll(() async {
    contentSource = await rootBundle.loadString(
      CourseContentRepository.bundledCafeCourseAsset,
    );
  });

  testWidgets(
    'runs all four due review dimensions from Journey and saves them',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await _insertDueMastery(
        database,
        itemId: 'phrase-wo-yao',
        dimension: LearningDimension.listening,
        dueAt: now.subtract(const Duration(minutes: 4)),
      );
      await _insertDueMastery(
        database,
        itemId: 'noun-kafei',
        dimension: LearningDimension.tone,
        dueAt: now.subtract(const Duration(minutes: 3)),
      );
      await _insertDueMastery(
        database,
        itemId: 'sentence-wo-yao-yi-bei-kafei',
        dimension: LearningDimension.meaning,
        dueAt: now.subtract(const Duration(minutes: 2)),
      );
      await _insertDueMastery(
        database,
        itemId: 'phrase-wo-yao',
        dimension: LearningDimension.hanzi,
        dueAt: now.subtract(const Duration(minutes: 1)),
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          courseContentRepositoryProvider.overrideWithValue(
            CourseContentRepository(bundle: _StringAssetBundle(contentSource)),
          ),
          reviewNowProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MandarinMissionApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journey-review-due')), findsOneWidget);
      expect(find.text('4 due reviews'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('open-review')));
      await tester.tap(find.byKey(const Key('open-review')));
      await tester.pumpAndSettle();

      expect(find.text('Listening'), findsOneWidget);
      expect(find.byKey(const Key('review-audio-unavailable')), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-reveal-answer')));
      await tester.pumpAndSettle();
      await _rate(tester, const Key('review-rating-remembered'));

      expect(find.text('Tone'), findsOneWidget);
      expect(find.byKey(const Key('review-prompt-tone')), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-reveal-answer')));
      await tester.pumpAndSettle();
      await _rate(tester, const Key('review-rating-vague'));

      expect(find.text('Meaning'), findsOneWidget);
      expect(find.byKey(const Key('review-prompt-meaning')), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('review-answer-sentence-wo-yao-yi-bei-kafei')),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Correct. How clearly did you remember it?'),
        findsOneWidget,
      );
      await _rate(tester, const Key('review-rating-remembered'));

      expect(find.text('Hanzi'), findsOneWidget);
      expect(find.byKey(const Key('review-prompt-hanzi')), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-reveal-answer')));
      await tester.pumpAndSettle();
      await _rate(tester, const Key('review-rating-remembered'));

      expect(find.byKey(const Key('review-complete')), findsOneWidget);
      expect(find.text('Review saved'), findsOneWidget);

      final attempts = await database.select(database.reviewAttempts).get();
      final outbox = await database.select(database.syncOutboxEvents).get();
      expect(attempts, hasLength(4));
      expect(outbox, hasLength(4));
      expect(
        attempts
            .singleWhere(
              (attempt) =>
                  attempt.dimension == LearningDimension.listening.name,
            )
            .usedHint,
        isTrue,
      );
      expect(
        attempts
            .singleWhere(
              (attempt) => attempt.dimension == LearningDimension.tone.name,
            )
            .result,
        ReviewRating.vague.name,
      );
    },
  );

  testWidgets('keeps the current answer when a save fails and retries it', (
    tester,
  ) async {
    final queue = _FakeReviewQueue([
      _queueItem(
        itemId: 'phrase-wo-yao',
        dimension: LearningDimension.meaning,
        dueAt: now,
      ),
    ])..failSubmissions = true;
    final container = ProviderContainer(
      overrides: [
        courseContentRepositoryProvider.overrideWithValue(
          CourseContentRepository(bundle: _StringAssetBundle(contentSource)),
        ),
        reviewQueueRepositoryProvider.overrideWithValue(queue),
        reviewNowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    });
    await _openReviewFromJourney(tester, container);

    await tester.tap(find.byKey(const Key('review-answer-phrase-wo-yao')));
    await tester.pumpAndSettle();
    await _rate(tester, const Key('review-rating-remembered'), settle: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('review-save-error')), findsOneWidget);
    expect(find.byKey(const Key('review-objective-feedback')), findsOneWidget);
    expect(queue.submissions, hasLength(1));

    queue.failSubmissions = false;
    await tester.tap(find.byKey(const Key('review-save-retry')));
    await tester.pumpAndSettle();

    expect(queue.submissions, hasLength(2));
    expect(find.byKey(const Key('review-complete')), findsOneWidget);
  });

  testWidgets('retries a forgotten item at the end of the same session', (
    tester,
  ) async {
    final queue = _FakeReviewQueue([
      _queueItem(
        itemId: 'noun-kafei',
        dimension: LearningDimension.tone,
        dueAt: now,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        courseContentRepositoryProvider.overrideWithValue(
          CourseContentRepository(bundle: _StringAssetBundle(contentSource)),
        ),
        reviewQueueRepositoryProvider.overrideWithValue(queue),
        reviewNowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    });
    await _openReviewFromJourney(tester, container);

    await tester.tap(find.byKey(const Key('review-reveal-answer')));
    await tester.pumpAndSettle();
    await _rate(tester, const Key('review-rating-forgotten'));

    expect(find.byKey(const Key('review-prompt-tone')), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    await tester.tap(find.byKey(const Key('review-reveal-answer')));
    await tester.pumpAndSettle();
    await _rate(tester, const Key('review-rating-remembered'));

    expect(queue.submissions, hasLength(2));
    expect(queue.submissions.first.rating, ReviewRating.forgotten);
    expect(queue.submissions.last.rating, ReviewRating.remembered);
    expect(find.byKey(const Key('review-complete')), findsOneWidget);
  });

  testWidgets('shows and recovers from initial load failure', (tester) async {
    final queue = _FakeReviewQueue([
      _queueItem(
        itemId: 'phrase-wo-yao',
        dimension: LearningDimension.meaning,
        dueAt: now,
      ),
    ])..failOnLoadCall = 2;
    final container = ProviderContainer(
      overrides: [
        courseContentRepositoryProvider.overrideWithValue(
          CourseContentRepository(bundle: _StringAssetBundle(contentSource)),
        ),
        reviewQueueRepositoryProvider.overrideWithValue(queue),
        reviewNowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    });
    await _openReviewFromJourney(tester, container);

    expect(find.byKey(const Key('review-load-error')), findsOneWidget);
    queue.failOnLoadCall = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('review-prompt-meaning')), findsOneWidget);
  });

  testWidgets('shows the empty state when the due queue clears before entry', (
    tester,
  ) async {
    final queue = _FakeReviewQueue([
      _queueItem(
        itemId: 'phrase-wo-yao',
        dimension: LearningDimension.meaning,
        dueAt: now,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        courseContentRepositoryProvider.overrideWithValue(
          CourseContentRepository(bundle: _StringAssetBundle(contentSource)),
        ),
        reviewQueueRepositoryProvider.overrideWithValue(queue),
        reviewNowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MandarinMissionApp(),
      ),
    );
    await tester.pumpAndSettle();

    final openReview = find.byKey(const Key('open-review'));
    await tester.ensureVisible(openReview);
    queue.items.clear();
    await tester.tap(openReview);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('review-empty')), findsOneWidget);
    expect(find.text('You are all caught up'), findsOneWidget);
  });

  testWidgets('keeps the review content grid stable across wide viewports', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(768, 1000);
    final queue = _FakeReviewQueue([
      _queueItem(
        itemId: 'noun-kafei',
        dimension: LearningDimension.tone,
        dueAt: now,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        courseContentRepositoryProvider.overrideWithValue(
          CourseContentRepository(bundle: _StringAssetBundle(contentSource)),
        ),
        reviewQueueRepositoryProvider.overrideWithValue(queue),
        reviewNowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    });
    await _openReviewFromJourney(tester, container);

    for (final width in [768.0, 1024.0, 1280.0, 1440.0]) {
      tester.view.physicalSize = Size(width, 1000);
      await tester.pump();

      final frame = tester.getRect(find.byKey(const Key('review-content')));
      expect(frame.width, closeTo(640, 0.01));
      expect(frame.left, closeTo((width - 640) / 2, 0.01));
    }
  });

  testWidgets('supports a small screen at 200 percent text scale', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    final queue = _FakeReviewQueue([
      _queueItem(
        itemId: 'phrase-wo-yao',
        dimension: LearningDimension.listening,
        dueAt: now,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        courseContentRepositoryProvider.overrideWithValue(
          CourseContentRepository(bundle: _StringAssetBundle(contentSource)),
        ),
        reviewQueueRepositoryProvider.overrideWithValue(queue),
        reviewNowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    });
    await _openReviewFromJourney(tester, container);

    await tester.scrollUntilVisible(
      find.byKey(const Key('review-prompt-listening')),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('review-prompt-listening')), findsOneWidget);
    expect(find.byKey(const Key('review-audio-unavailable')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-reveal-answer')),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-reveal-answer')));
    await tester.pumpAndSettle();
    await _rate(tester, const Key('review-rating-remembered'));

    expect(find.byKey(const Key('review-complete')), findsOneWidget);
  });
}

Future<void> _rate(WidgetTester tester, Key key, {bool settle = true}) async {
  final finder = find.byKey(key);
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  if (settle) {
    await tester.pumpAndSettle();
  }
}

Future<void> _openReviewFromJourney(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MandarinMissionApp(),
    ),
  );
  await tester.pumpAndSettle();
  final openReview = find.byKey(const Key('open-review'));
  await tester.scrollUntilVisible(
    openReview,
    240,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.tap(openReview);
  for (var attempt = 0; attempt < 60; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    final settled =
        find.byKey(const Key('review-content')).evaluate().isNotEmpty ||
        find.byKey(const Key('review-empty')).evaluate().isNotEmpty ||
        find.byKey(const Key('review-load-error')).evaluate().isNotEmpty;
    if (settled) {
      await tester.pumpAndSettle();
      return;
    }
  }
  final visibleText = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .join(' | ');
  fail('Review route did not finish loading. Visible text: $visibleText');
}

ReviewQueueItem _queueItem({
  required String itemId,
  required LearningDimension dimension,
  required DateTime dueAt,
}) {
  return ReviewQueueItem(
    itemId: itemId,
    dimension: dimension,
    box: 0,
    confidence: 0,
    dueAt: dueAt,
    lastResult: null,
    sameDayRetryCount: 0,
  );
}

Future<void> _insertDueMastery(
  AppDatabase database, {
  required String itemId,
  required LearningDimension dimension,
  required DateTime dueAt,
}) {
  return database
      .into(database.masteryStates)
      .insert(
        MasteryStatesCompanion.insert(
          itemId: itemId,
          dimension: dimension.name,
          box: 0,
          confidence: 0,
          dueAt: dueAt,
          updatedAt: dueAt,
        ),
      );
}

final class _FakeSubmission {
  const _FakeSubmission({
    required this.item,
    required this.rating,
    required this.correct,
    required this.usedHint,
  });

  final ReviewQueueItem item;
  final ReviewRating rating;
  final bool correct;
  final bool usedHint;
}

final class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.source);

  final String source;

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}

final class _FakeReviewQueue implements ReviewQueueDataSource {
  _FakeReviewQueue(this.items);

  final List<ReviewQueueItem> items;
  final List<_FakeSubmission> submissions = [];
  int loadCalls = 0;
  int? failOnLoadCall;
  bool failSubmissions = false;

  @override
  Future<List<ReviewQueueItem>> dueItems({
    required DateTime now,
    int limit = 10,
  }) async {
    loadCalls += 1;
    if (loadCalls == failOnLoadCall) {
      throw StateError('load failed');
    }
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
  }) async {
    submissions.add(
      _FakeSubmission(
        item: item,
        rating: rating,
        correct: correct,
        usedHint: usedHint,
      ),
    );
    if (failSubmissions) {
      throw StateError('save failed');
    }
  }
}
