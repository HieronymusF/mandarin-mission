import 'package:flutter/material.dart';

import '../../core/theme/app_layout.dart';

class HanziPinyinText extends StatelessWidget {
  const HanziPinyinText({
    required this.hanzi,
    required this.pinyinSyllables,
    this.hanziFontSize = 30,
    this.pinyinFontSize = 14,
    this.pinyinColor,
    super.key,
  });

  final String hanzi;
  final List<String> pinyinSyllables;
  final double hanziFontSize;
  final double pinyinFontSize;
  final Color? pinyinColor;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    var syllableIndex = 0;

    for (final entry in hanzi.runes.indexed) {
      final character = String.fromCharCode(entry.$2);
      if (_isPunctuation(entry.$2)) {
        cells.add(
          Text(
            character,
            key: Key('punctuation-${entry.$1}'),
            style: TextStyle(
              fontSize: hanziFontSize,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        continue;
      }

      if (syllableIndex >= pinyinSyllables.length) {
        throw FlutterError('Missing pinyin syllable for $character in $hanzi.');
      }
      final pinyin = pinyinSyllables[syllableIndex++];
      cells.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                character,
                key: Key('hanzi-${entry.$1}'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: hanziFontSize,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                pinyin,
                key: Key('pinyin-${entry.$1}'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: pinyinColor ?? Theme.of(context).colorScheme.primary,
                  fontSize: pinyinFontSize,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (syllableIndex != pinyinSyllables.length) {
      throw FlutterError('Unused pinyin syllables for $hanzi.');
    }

    final line = Semantics(
      label: '$hanzi, ${pinyinSyllables.join(' ')}',
      excludeSemantics: true,
      child: Row(
        key: const Key('hanzi-pinyin-line'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cells,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return line;
        }
        return Align(
          alignment: Alignment.topCenter,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: line,
          ),
        );
      },
    );
  }

  bool _isPunctuation(int rune) {
    return const {
      0x3001,
      0x3002,
      0xFF01,
      0xFF0C,
      0xFF0E,
      0xFF1A,
      0xFF1B,
      0xFF1F,
      0x0021,
      0x002C,
      0x002E,
      0x003A,
      0x003B,
      0x003F,
    }.contains(rune);
  }
}
