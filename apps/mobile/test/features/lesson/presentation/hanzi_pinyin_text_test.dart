import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/shared/presentation/hanzi_pinyin_text.dart';

void main() {
  testWidgets('aligns each syllable and keeps punctuation separate', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: HanziPinyinText(
              hanzi: '我要一杯咖啡。',
              pinyinSyllables: ['wǒ', 'yào', 'yì', 'bēi', 'kā', 'fēi'],
            ),
          ),
        ),
      ),
    );

    expect(find.text('啡。'), findsNothing);
    expect(find.byKey(const Key('hanzi-5')), findsOneWidget);
    expect(find.byKey(const Key('pinyin-5')), findsOneWidget);
    expect(find.byKey(const Key('punctuation-6')), findsOneWidget);

    final hanziCenter = tester.getCenter(find.byKey(const Key('hanzi-5')));
    final pinyinCenter = tester.getCenter(find.byKey(const Key('pinyin-5')));
    expect(hanziCenter.dx, closeTo(pinyinCenter.dx, 0.01));
  });

  testWidgets('centers the phrase within bounded card content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              key: Key('phrase-host'),
              width: 320,
              child: HanziPinyinText(
                hanzi: '我要一杯咖啡。',
                pinyinSyllables: ['wǒ', 'yào', 'yì', 'bēi', 'kā', 'fēi'],
              ),
            ),
          ),
        ),
      ),
    );

    final host = tester.getRect(find.byKey(const Key('phrase-host')));
    final line = tester.getRect(find.byKey(const Key('hanzi-pinyin-line')));
    expect(line.center.dx, closeTo(host.center.dx, 0.01));
  });
}
