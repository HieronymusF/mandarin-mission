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
    expect(find.text('1 / 7'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Say what you want'), findsOneWidget);
    expect(find.text('2 / 7'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Name the drink'), findsOneWidget);
    expect(find.text('3 / 7'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Which phrase did you hear?'), findsOneWidget);
    expect(find.text('4 / 7'), findsOneWidget);

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
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Make the tones land'), findsOneWidget);
    expect(find.text('5 / 7'), findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();
    expect(find.text('Speech check is unavailable'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('self-check-sounded-close')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('self-check-sounded-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Take your turn'), findsOneWidget);
    expect(find.text('6 / 7'), findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Coffee ordered!'), findsOneWidget);
    expect(find.text('7 / 7'), findsOneWidget);
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
    expect(attempts, hasLength(3));
    final listeningAttempts = attempts
        .where((attempt) => attempt.dimension == 'listening')
        .toList();
    expect(listeningAttempts, hasLength(2));
    expect(
      listeningAttempts.map((attempt) => attempt.usedHint),
      containsAll([false, true]),
    );
    expect(speaking, hasLength(1));
    expect(outbox, hasLength(5));
  });
}
