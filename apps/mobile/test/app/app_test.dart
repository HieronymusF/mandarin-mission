import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';

void main() {
  testWidgets('completes the data-driven café lesson flow', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MandarinMissionApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Mandarin journey'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('open-cafe-lesson')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-cafe-lesson')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-overview-page')), findsOneWidget);
    expect(find.text('Order at the counter'), findsOneWidget);
    expect(find.text('1 / 8'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Say what you want'), findsOneWidget);
    expect(find.text('2 / 8'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Name the drink'), findsOneWidget);
    expect(find.text('3 / 8'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Write 咖啡'), findsOneWidget);
    expect(find.text('4 / 8'), findsOneWidget);

    await _drawOnWritingCanvas(tester);
    await tester.ensureVisible(
      find.byKey(const Key('hanzi-writing-start-recall')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-start-recall')));
    await tester.pumpAndSettle();
    await _drawOnWritingCanvas(tester);
    await tester.ensureVisible(find.byKey(const Key('hanzi-writing-compare')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-compare')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('hanzi-writing-looks-close')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-looks-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Which phrase did you hear?'), findsOneWidget);
    expect(find.text('5 / 8'), findsOneWidget);

    await tester.tap(find.byKey(const Key('listen-option-phrase-wo-yao')));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('listen-option-sentence-wo-yao-yi-bei-kafei')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
    _expectLeadingContentAligned(
      tester,
      card: find.byKey(const Key('listen-result-banner')),
      content: find.text('That is the complete café order.'),
      padding: 16,
      leadingWidth: 24,
      gap: 12,
    );
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Make the tones land'), findsOneWidget);
    expect(find.text('6 / 8'), findsOneWidget);
    _expectCenteredIn(
      tester,
      child: find.byKey(const Key('hanzi-pinyin-line')),
      parent: find.byType(SingleChildScrollView),
    );
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Speech check is unavailable'), findsOneWidget);
    _expectCenteredIn(
      tester,
      child: find.byKey(const Key('hanzi-pinyin-line')),
      parent: find.byKey(const Key('speaking-fallback-phrase-card')),
    );
    await tester.ensureVisible(
      find.byKey(const Key('self-check-sounded-close')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('self-check-sounded-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Take your turn'), findsOneWidget);
    expect(find.text('7 / 8'), findsOneWidget);
    _expectCenteredIn(
      tester,
      child: find.descendant(
        of: find.byKey(const Key('dialogue-answer-card')),
        matching: find.byKey(const Key('hanzi-pinyin-line')),
      ),
      parent: find.byKey(const Key('dialogue-answer-card')),
    );
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Coffee ordered!'), findsOneWidget);
    expect(find.text('8 / 8'), findsOneWidget);
    _expectLeadingContentAligned(
      tester,
      card: find.byKey(const Key('summary-star-understanding-card')),
      content: find.text('Understanding'),
      padding: 16,
      leadingWidth: 32,
      gap: 12,
    );
    _expectLeadingContentAligned(
      tester,
      card: find.byKey(const Key('summary-star-speaking-card')),
      content: find.text('Speaking'),
      padding: 16,
      leadingWidth: 32,
      gap: 12,
    );
    _expectLeadingContentAligned(
      tester,
      card: find.byKey(const Key('summary-star-memory-card')),
      content: find.text('Memory'),
      padding: 16,
      leadingWidth: 32,
      gap: 12,
    );
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Your Mandarin journey'), findsOneWidget);

    final progress = await database
        .select(database.lessonProgressEntries)
        .getSingle();
    final mastery = await database.select(database.masteryStates).get();
    final attempts = await database.select(database.reviewAttempts).get();
    final speaking = await database.select(database.speakingAttempts).get();
    final outbox = await database.select(database.syncOutboxEvents).get();

    expect(progress.status, 'completed');
    expect(progress.score, 80);
    expect(mastery, hasLength(12));
    expect(attempts, hasLength(4));
    final listeningAttempts = attempts
        .where((attempt) => attempt.dimension == 'listening')
        .toList();
    expect(listeningAttempts, hasLength(2));
    expect(
      listeningAttempts.map((attempt) => attempt.usedHint),
      containsAll([false, true]),
    );
    final writingAttempt = attempts.singleWhere(
      (attempt) => attempt.dimension == 'hanzi',
    );
    expect(writingAttempt.correct, isTrue);
    expect(writingAttempt.usedHint, isFalse);
    expect(speaking, hasLength(1));
    expect(outbox, hasLength(6));
  });

  testWidgets('keeps a shared content grid across wide viewports', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final width in [768.0, 1024.0, 1280.0, 1440.0]) {
      tester.view.physicalSize = Size(width, 1000);
      final database = AppDatabase(NativeDatabase.memory());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: const MandarinMissionApp(),
        ),
      );
      await tester.pumpAndSettle();

      final frame = tester.getRect(find.byKey(const Key('journey-content')));
      final todayCard = tester.getRect(
        find.byKey(const Key('journey-today-card')),
      );
      final todayTasks = tester.getRect(
        find.byKey(const Key('today-task-row')),
      );
      final cafeCard = tester.getRect(
        find.byKey(const Key('journey-cafe-card')),
      );
      final cafeBody = tester.getRect(find.byKey(const Key('cafe-card-body')));

      expect(frame.width, closeTo(640, 0.01));
      expect(frame.left, closeTo((width - 640) / 2, 0.01));
      expect(todayCard.left, closeTo(frame.left + 20, 0.01));
      expect(cafeCard.left, closeTo(frame.left + 20, 0.01));
      expect(todayTasks.left, closeTo(todayCard.left + 20, 0.01));
      expect(todayTasks.right, closeTo(todayCard.right - 20, 0.01));
      expect(cafeBody.left, closeTo(cafeCard.left + 20, 1.1));
      expect(cafeBody.right, closeTo(cafeCard.right - 20, 1.1));

      await tester.pumpWidget(const SizedBox.shrink());
      await database.close();
    }
  });
}

Future<void> _drawOnWritingCanvas(WidgetTester tester) async {
  final canvas = find.byKey(const Key('hanzi-writing-canvas'));
  await tester.ensureVisible(canvas);
  await tester.pumpAndSettle();
  final rect = tester.getRect(canvas);
  await tester.dragFrom(
    Offset(rect.left + rect.width * .2, rect.top + rect.height * .2),
    Offset(rect.width * .2, rect.height * .45),
  );
  await tester.pump();
}

void _expectLeadingContentAligned(
  WidgetTester tester, {
  required Finder card,
  required Finder content,
  required double padding,
  required double leadingWidth,
  required double gap,
}) {
  final cardRect = tester.getRect(card);
  final contentRect = tester.getRect(content);
  expect(
    contentRect.left,
    closeTo(cardRect.left + padding + leadingWidth + gap, 1.1),
  );
}

void _expectCenteredIn(
  WidgetTester tester, {
  required Finder child,
  required Finder parent,
}) {
  final childRect = tester.getRect(child);
  final parentRect = tester.getRect(parent);
  expect(childRect.center.dx, closeTo(parentRect.center.dx, 0.01));
}
