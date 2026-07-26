import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/app_leading_row.dart';
import '../../../../shared/presentation/hanzi_pinyin_text.dart';

class DialogueStep extends StatelessWidget {
  const DialogueStep({
    required this.package,
    required this.dialogue,
    required this.currentNodeId,
    required this.supportText,
    required this.selectedReplyMethod,
    required this.onReplyMethodChanged,
    super.key,
  });

  final CoursePackage package;
  final CourseDialogue dialogue;
  final String currentNodeId;
  final String? supportText;
  final String? selectedReplyMethod;
  final ValueChanged<String> onReplyMethodChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final turn = dialogue.turnFrom(currentNodeId);
    final learnerNode = turn.learnerNode;
    final dialogueComplete = learnerNode == null;
    final answer = learnerNode == null
        ? null
        : package.knowledgeItem(learnerNode.itemId!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          key: const Key('dialogue-prompt-card'),
          width: double.infinity,
          padding: AppLayout.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppLeadingRow(
                leading: AppIconTile(
                  icon: LucideIcons.messageCircle,
                  backgroundColor: theme.colorScheme.muted,
                  foregroundColor: theme.colorScheme.foreground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scene partner', style: theme.textTheme.h3),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      dialogueComplete
                          ? 'The exchange is complete.'
                          : 'Read, then take your turn.',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              for (final systemNode in turn.systemNodes) ...[
                const SizedBox(height: AppSpacing.md),
                HanziPinyinText(
                  hanzi: systemNode.text!,
                  pinyinSyllables: systemNode.pinyinSyllables,
                  hanziFontSize: 20,
                  pinyinFontSize: 12,
                  pinyinColor: theme.colorScheme.mutedForeground,
                ),
              ],
            ],
          ),
        ),
        if (!dialogueComplete) const SizedBox(height: AppSpacing.md),
        if (!dialogueComplete && selectedReplyMethod == 'phrase-ticket')
          ShadCard(
            key: const Key('dialogue-answer-card'),
            width: double.infinity,
            padding: AppLayout.cardPadding,
            backgroundColor: theme.colorScheme.accent,
            border: ShadBorder.none,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Phrase ticket', style: theme.textTheme.h3),
                const SizedBox(height: AppSpacing.md),
                HanziPinyinText(
                  hanzi: answer!.hanzi,
                  pinyinSyllables: answer.pinyinSyllables,
                  hanziFontSize: 28,
                ),
              ],
            ),
          )
        else if (!dialogueComplete)
          ShadCard(
            key: const Key('dialogue-reply-status-card'),
            width: double.infinity,
            padding: AppLayout.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  selectedReplyMethod == 'said-aloud'
                      ? LucideIcons.circleCheck
                      : LucideIcons.mic,
                  size: AppLayout.noticeIconSlot,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  selectedReplyMethod == 'said-aloud'
                      ? 'Reply ready'
                      : 'Say your reply without looking at the answer.',
                  style: theme.textTheme.small,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        if (!dialogueComplete && selectedReplyMethod == 'phrase-ticket') ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Say the phrase aloud, then send your reply.',
            style: theme.textTheme.muted,
          ),
        ] else if (!dialogueComplete &&
            selectedReplyMethod == null &&
            (supportText ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(supportText!, style: theme.textTheme.muted),
        ],
        if (!dialogueComplete) ...[
          const SizedBox(height: AppSpacing.md),
          ShadButton.outline(
            key: const Key('dialogue-said-aloud'),
            height: AppLayout.controlHeight,
            onPressed: () => onReplyMethodChanged('said-aloud'),
            leading: const Icon(LucideIcons.mic, size: 16),
            child: Text(
              selectedReplyMethod == 'said-aloud'
                  ? 'Said aloud ✓'
                  : 'I said it aloud',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ShadButton.outline(
            key: const Key('dialogue-use-ticket'),
            height: AppLayout.controlHeight,
            onPressed: () => onReplyMethodChanged('phrase-ticket'),
            leading: const Icon(LucideIcons.ticket, size: 16),
            child: const Text('Use phrase ticket'),
          ),
        ],
      ],
    );
  }
}
