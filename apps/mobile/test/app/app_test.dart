import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';

void main() {
  testWidgets('completes the data-driven café lesson flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MandarinMissionApp()));
    await tester.pumpAndSettle();

    expect(find.text('Your Mandarin journey'), findsOneWidget);
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
  });
}
