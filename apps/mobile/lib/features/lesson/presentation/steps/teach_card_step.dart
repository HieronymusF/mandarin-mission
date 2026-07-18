import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../data/content/course_content_models.dart';
import '../hanzi_pinyin_text.dart';
import '../lesson_audio_notice.dart';

class TeachCardStep extends StatelessWidget {
  const TeachCardStep({
    required this.item,
    required this.lessonItems,
    required this.supportText,
    super.key,
  });

  final CourseKnowledgeItem item;
  final List<CourseKnowledgeItem> lessonItems;
  final String? supportText;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          width: double.infinity,
          title: Align(
            alignment: Alignment.centerLeft,
            child: ShadBadge.secondary(
              child: Text(item.kind == 'phrase' ? 'PHRASE' : 'WORD'),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 22),
            child: Column(
              children: [
                HanziPinyinText(
                  hanzi: item.hanzi,
                  pinyinSyllables: item.pinyinSyllables,
                  hanziFontSize: 52,
                  pinyinFontSize: 19,
                ),
                const SizedBox(height: 16),
                Text(item.english, style: theme.textTheme.lead),
                const SizedBox(height: 18),
                ShadButton.outline(
                  onPressed: () => showLessonAudioUnavailable(context),
                  leading: const Icon(LucideIcons.volume2, size: 17),
                  child: const Text('Play example'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ShadCard(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          backgroundColor: theme.colorScheme.muted,
          border: ShadBorder.none,
          title: const Text('Build the order'),
          description: Text(
            lessonItems.map((entry) => entry.hanzi).join('  +  '),
            style: theme.textTheme.large,
          ),
        ),
        if ((supportText ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(supportText!, style: theme.textTheme.muted),
        ],
      ],
    );
  }
}
