import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
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
          key: const Key('teach-card'),
          width: double.infinity,
          padding: AppLayout.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ShadBadge.secondary(
                  child: Text(item.kind == 'phrase' ? 'PHRASE' : 'WORD'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              HanziPinyinText(
                hanzi: item.hanzi,
                pinyinSyllables: item.pinyinSyllables,
                hanziFontSize: 52,
                pinyinFontSize: 20,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                item.english,
                style: theme.textTheme.lead,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: ShadButton.outline(
                  height: AppLayout.controlHeight,
                  onPressed: () => showLessonAudioUnavailable(context),
                  leading: const Icon(LucideIcons.volume2, size: 16),
                  child: const Text('Play example'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ShadCard(
          width: double.infinity,
          padding: AppLayout.compactCardPadding,
          backgroundColor: theme.colorScheme.muted,
          border: ShadBorder.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Build the order', style: theme.textTheme.h3),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                lessonItems.map((entry) => entry.hanzi).join('  +  '),
                style: theme.textTheme.large,
              ),
            ],
          ),
        ),
        if ((supportText ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(supportText!, style: theme.textTheme.muted),
        ],
      ],
    );
  }
}
