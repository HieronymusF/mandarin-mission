import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/app_leading_row.dart';
import '../../../../shared/presentation/audio_player_bar.dart';
import '../../../../shared/presentation/hanzi_pinyin_text.dart';

class ListenChoiceStep extends StatelessWidget {
  const ListenChoiceStep({
    required this.package,
    required this.step,
    required this.selectedOptionId,
    required this.onSelected,
    super.key,
  });

  final CoursePackage package;
  final CourseLessonStep step;
  final String? selectedOptionId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final selectedIsCorrect = selectedOptionId == step.itemId;
    final audioAssetPath = step.itemId == null
        ? null
        : package.audioAssetPathForItem(step.itemId!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AudioPlayerBar(
          key: const Key('listen-audio-player'),
          assetPath: audioAssetPath,
          showLabel: false,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final itemId in step.optionItemIds) ...[
          _AnswerButton(
            item: package.knowledgeItem(itemId),
            selected: selectedOptionId == itemId,
            correct: itemId == step.itemId,
            revealResult: selectedOptionId != null,
            onTap: () => onSelected(itemId),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (selectedOptionId != null)
          ShadCard(
            key: const Key('listen-result-banner'),
            width: double.infinity,
            padding: AppLayout.compactCardPadding,
            backgroundColor: selectedIsCorrect
                ? theme.colorScheme.custom['success']
                : theme.colorScheme.destructive.withValues(alpha: .10),
            border: ShadBorder.none,
            child: AppLeadingRow(
              leadingWidth: AppLayout.noticeIconSlot,
              gap: AppSpacing.sm,
              leading: Icon(
                selectedIsCorrect
                    ? LucideIcons.badgeCheck
                    : LucideIcons.circleAlert,
                size: 20,
                color: selectedIsCorrect
                    ? theme.colorScheme.custom['successForeground']
                    : theme.colorScheme.destructive,
              ),
              child: Text(
                selectedIsCorrect
                    ? 'That is the complete café order.'
                    : 'Not quite — you heard a full order, not only “I want.”',
                style: theme.textTheme.small,
              ),
            ),
          ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.item,
    required this.selected,
    required this.correct,
    required this.revealResult,
    required this.onTap,
  });

  final CourseKnowledgeItem item;
  final bool selected;
  final bool correct;
  final bool revealResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final selectedCorrect = selected && revealResult && correct;
    final selectedWrong = selected && revealResult && !correct;
    return ShadButton.outline(
      key: Key('listen-option-${item.id}'),
      width: double.infinity,
      height: AppLayout.answerControlHeight,
      onPressed: onTap,
      backgroundColor: selectedCorrect
          ? theme.colorScheme.custom['success']
          : selectedWrong
          ? theme.colorScheme.destructive.withValues(alpha: .10)
          : theme.colorScheme.card,
      foregroundColor: selectedWrong
          ? theme.colorScheme.destructive
          : theme.colorScheme.foreground,
      mainAxisAlignment: MainAxisAlignment.center,
      child: HanziPinyinText(
        hanzi: item.hanzi,
        pinyinSyllables: item.pinyinSyllables,
        hanziFontSize: 20,
        pinyinFontSize: 12,
        pinyinColor: theme.colorScheme.mutedForeground,
      ),
    );
  }
}
