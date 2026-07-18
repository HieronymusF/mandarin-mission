import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../data/content/course_content_models.dart';
import '../hanzi_pinyin_text.dart';

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
          width: double.infinity,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.coffee, size: 21),
          ),
          title: const Text('Barista'),
          description: const Text('Hello, what would you like to drink?'),
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: HanziPinyinText(
              hanzi: prompt.text!,
              pinyinSyllables: prompt.pinyinSyllables,
              hanziFontSize: 21,
              pinyinFontSize: 10,
              pinyinColor: theme.colorScheme.mutedForeground,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ShadCard(
          width: double.infinity,
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          title: const Text('Your order'),
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              children: [
                HanziPinyinText(
                  hanzi: answer.hanzi,
                  pinyinSyllables: answer.pinyinSyllables,
                  hanziFontSize: 27,
                ),
                const SizedBox(height: 16),
                Icon(
                  LucideIcons.mic,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
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
