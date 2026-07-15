import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';

void main() {
  testWidgets('opens the café lesson from the journey', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MandarinMissionApp()));
    await tester.pumpAndSettle();

    expect(find.text('Your Mandarin journey'), findsOneWidget);
    expect(find.text('Order one coffee'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-cafe-lesson')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-overview-page')), findsOneWidget);
    expect(find.text('Lesson 1'), findsOneWidget);
    expect(find.text('cafe-01'), findsOneWidget);
  });
}
