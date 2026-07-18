import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../data/content/course_content_models.dart';
import '../hanzi_pinyin_text.dart';
import '../lesson_audio_notice.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadButton.secondary(
          key: const Key('replay-order-action'),
          width: double.infinity,
          height: 54,
          onPressed: () => showLessonAudioUnavailable(context),
          leading: const Icon(LucideIcons.volume2, size: 18),
          mainAxisAlignment: MainAxisAlignment.start,
          child: const Text('Replay the order'),
        ),
        const SizedBox(height: 16),
        for (final itemId in step.optionItemIds) ...[
          _AnswerButton(
            item: package.knowledgeItem(itemId),
            selected: selectedOptionId == itemId,
            correct: itemId == step.itemId,
            revealResult: selectedOptionId != null,
            onTap: () => onSelected(itemId),
          ),
          const SizedBox(height: 12),
        ],
        if (selectedOptionId != null)
          ShadCard(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            backgroundColor: selectedIsCorrect
                ? theme.colorScheme.custom['success']
                : theme.colorScheme.destructive.withValues(alpha: .10),
            border: ShadBorder.none,
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
      height: 72,
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
        pinyinFontSize: 11,
        pinyinColor: theme.colorScheme.mutedForeground,
      ),
    );
  }
}
