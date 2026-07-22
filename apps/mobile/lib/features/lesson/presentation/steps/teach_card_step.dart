import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/audio_player_bar.dart';
import '../../../../shared/presentation/hanzi_pinyin_text.dart';

class TeachCardStep extends StatelessWidget {
  const TeachCardStep({
    required this.item,
    required this.lessonItems,
    required this.supportText,
    required this.audioAssetPath,
    super.key,
  });

  final CourseKnowledgeItem item;
  final List<CourseKnowledgeItem> lessonItems;
  final String? supportText;
  final String? audioAssetPath;

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
              // 示例音频播放
              AudioPlayerBar(
                assetPath: audioAssetPath,
                showLabel: true,
                label: 'Play example',
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
