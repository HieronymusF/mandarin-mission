import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/app_leading_row.dart';
import '../../../../shared/presentation/audio_player_bar.dart';
import '../../../../shared/presentation/hanzi_pinyin_text.dart';
import '../../../../shared/presentation/recording_controls.dart';

class RepeatStep extends ConsumerWidget {
  const RepeatStep({
    required this.item,
    required this.tip,
    required this.audioAssetPath,
    required this.onRecordingComplete,
    super.key,
  });

  final CourseKnowledgeItem item;
  final String? tip;
  final String? audioAssetPath;
  final ValueChanged<String> onRecordingComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 目标短语卡片
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

        // 示例音频播放
        AudioPlayerBar(
          assetPath: audioAssetPath,
          showLabel: true,
          label: 'Play example',
        ),

        const SizedBox(height: AppSpacing.md),

        // 声调提示卡片
        if (tip != null)
          ShadCard(
            width: double.infinity,
            padding: AppLayout.compactCardPadding,
            backgroundColor: theme.colorScheme.custom['warning'],
            border: ShadBorder.none,
            title: const Text('Tone tip'),
            description: Text(tip!),
          ),

        const SizedBox(height: AppSpacing.sm),

        // 录音控制
        RecordingControls(
          onRecordingComplete: onRecordingComplete,
          maxDuration: 30.0,
          minVolumeThreshold: 0.1,
        ),

        const SizedBox(height: AppSpacing.sm),

        // 隐私提示
        Row(
          children: [
            Icon(
              LucideIcons.shield,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Recordings are stored locally and never uploaded.',
                style: theme.textTheme.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SpeakingFallback extends ConsumerWidget {
  const SpeakingFallback({
    required this.item,
    required this.audioAssetPath,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final CourseKnowledgeItem item;
  final String? audioAssetPath;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              'You can still finish. Listen, then judge your own attempt.',
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
