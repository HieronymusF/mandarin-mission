import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/app_leading_row.dart';
import '../../../../shared/presentation/hanzi_pinyin_text.dart';
import '../lesson_audio_notice.dart';

class RepeatStep extends StatelessWidget {
  const RepeatStep({required this.item, required this.tip, super.key});

  final CourseKnowledgeItem item;
  final String? tip;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          width: double.infinity,
          child: Column(
            children: [
              HanziPinyinText(
                hanzi: item.hanzi,
                pinyinSyllables: item.pinyinSyllables,
                hanziFontSize: 28,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(item.english, style: theme.textTheme.muted),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ShadCard(
          width: double.infinity,
          height: AppLayout.mediaPanelHeight,
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          child: Center(
            child: Icon(
              LucideIcons.audioLines,
              size: 40,
              color: theme.colorScheme.accentForeground,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ShadCard(
          width: double.infinity,
          padding: AppLayout.compactCardPadding,
          backgroundColor: theme.colorScheme.custom['warning'],
          border: ShadBorder.none,
          title: const Text('Tone tip'),
          description: Text(tip ?? ''),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              LucideIcons.mic,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Microphone is used only for this practice.',
                style: theme.textTheme.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SpeakingFallback extends StatelessWidget {
  const SpeakingFallback({
    required this.item,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final CourseKnowledgeItem item;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          key: const Key('speaking-fallback-notice'),
          width: double.infinity,
          padding: AppLayout.compactCardPadding,
          backgroundColor: theme.colorScheme.custom['warning'],
          border: ShadBorder.none,
          child: AppLeadingRow(
            leadingWidth: AppLayout.noticeIconSlot,
            gap: AppSpacing.sm,
            leading: Icon(
              LucideIcons.circleAlert,
              size: 20,
              color: theme.colorScheme.custom['warningForeground'],
            ),
            child: const Text(
              'You can still finish. Listen, record locally, then judge your own attempt.',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ShadCard(
          key: const Key('speaking-fallback-phrase-card'),
          width: double.infinity,
          child: Column(
            children: [
              HanziPinyinText(
                hanzi: item.hanzi,
                pinyinSyllables: item.pinyinSyllables,
                hanziFontSize: 28,
              ),
              const SizedBox(height: AppSpacing.md),
              ShadButton.outline(
                height: AppLayout.controlHeight,
                onPressed: () => showLessonAudioUnavailable(context),
                leading: const Icon(LucideIcons.volume2, size: 16),
                child: const Text('Play example'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ShadCard(
          width: double.infinity,
          backgroundColor: theme.colorScheme.muted,
          border: ShadBorder.none,
          title: const Text('How did that sound?'),
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    key: const Key('self-check-needs-practice'),
                    height: AppLayout.controlHeight,
                    onPressed: () => onSelected('needs-practice'),
                    backgroundColor: selected == 'needs-practice'
                        ? theme.colorScheme.accent
                        : theme.colorScheme.card,
                    child: const Text('Needs practice'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ShadButton.outline(
                    key: const Key('self-check-sounded-close'),
                    height: AppLayout.controlHeight,
                    onPressed: () => onSelected('sounded-close'),
                    backgroundColor: selected == 'sounded-close'
                        ? theme.colorScheme.accent
                        : theme.colorScheme.card,
                    child: const Text('Sounded close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
