import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../data/content/course_content_models.dart';
import '../hanzi_pinyin_text.dart';
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
                hanziFontSize: 30,
              ),
              const SizedBox(height: 14),
              Text(item.english, style: theme.textTheme.muted),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ShadCard(
          width: double.infinity,
          height: 86,
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          child: Center(
            child: Icon(
              LucideIcons.audioLines,
              size: 42,
              color: theme.colorScheme.accentForeground,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ShadCard(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          backgroundColor: theme.colorScheme.custom['warning'],
          border: ShadBorder.none,
          title: const Text('Tone tip'),
          description: Text(tip ?? ''),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              LucideIcons.mic,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 8),
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
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          backgroundColor: theme.colorScheme.custom['warning'],
          border: ShadBorder.none,
          leading: Icon(
            LucideIcons.circleAlert,
            color: theme.colorScheme.custom['warningForeground'],
          ),
          child: const Text(
            'You can still finish. Listen, record locally, then judge your own attempt.',
          ),
        ),
        const SizedBox(height: 14),
        ShadCard(
          width: double.infinity,
          child: Column(
            children: [
              HanziPinyinText(
                hanzi: item.hanzi,
                pinyinSyllables: item.pinyinSyllables,
                hanziFontSize: 28,
              ),
              const SizedBox(height: 16),
              ShadButton.outline(
                onPressed: () => showLessonAudioUnavailable(context),
                leading: const Icon(LucideIcons.volume2, size: 17),
                child: const Text('Play example'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ShadCard(
          width: double.infinity,
          backgroundColor: theme.colorScheme.muted,
          border: ShadBorder.none,
          title: const Text('How did that sound?'),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    key: const Key('self-check-needs-practice'),
                    onPressed: () => onSelected('needs-practice'),
                    backgroundColor: selected == 'needs-practice'
                        ? theme.colorScheme.accent
                        : theme.colorScheme.card,
                    child: const Text('Needs practice'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ShadButton.outline(
                    key: const Key('self-check-sounded-close'),
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
