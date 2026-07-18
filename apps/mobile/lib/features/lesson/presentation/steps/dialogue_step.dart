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
    required this.supportText,
    super.key,
  });

  final CoursePackage package;
  final CourseDialogue dialogue;
  final String? supportText;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final prompt = dialogue.node(dialogue.startNodeId);
    final learnerNode = dialogue.node(prompt.nextNodeId!);
    final answer = package.knowledgeItem(learnerNode.itemId!);
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
                  icon: LucideIcons.coffee,
                  backgroundColor: theme.colorScheme.muted,
                  foregroundColor: theme.colorScheme.foreground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Barista', style: theme.textTheme.h3),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Hello, what would you like to drink?',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              HanziPinyinText(
                hanzi: prompt.text!,
                pinyinSyllables: prompt.pinyinSyllables,
                hanziFontSize: 20,
                pinyinFontSize: 12,
                pinyinColor: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ShadCard(
          key: const Key('dialogue-answer-card'),
          width: double.infinity,
          padding: AppLayout.cardPadding,
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Your order', style: theme.textTheme.h3),
              const SizedBox(height: AppSpacing.md),
              HanziPinyinText(
                hanzi: answer.hanzi,
                pinyinSyllables: answer.pinyinSyllables,
                hanziFontSize: 28,
              ),
              const SizedBox(height: AppSpacing.md),
              Icon(
                LucideIcons.mic,
                size: AppLayout.noticeIconSlot,
                color: theme.colorScheme.primary,
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
