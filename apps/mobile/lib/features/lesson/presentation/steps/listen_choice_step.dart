import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/audio_player_bar.dart';
import '../../../../shared/presentation/hanzi_pinyin_text.dart';
import 'lesson_choice_widgets.dart';

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
          LessonChoiceButton(
            key: Key('listen-option-$itemId'),
            selected: selectedOptionId == itemId,
            correct: itemId == step.itemId,
            revealResult: selectedOptionId != null,
            onPressed: () => onSelected(itemId),
            child: HanziPinyinText(
              hanzi: package.knowledgeItem(itemId).hanzi,
              pinyinSyllables: package.knowledgeItem(itemId).pinyinSyllables,
              hanziFontSize: 20,
              pinyinFontSize: 12,
              pinyinColor: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (selectedOptionId != null)
          LessonChoiceFeedback(
            key: const Key('listen-result-banner'),
            correct: selectedIsCorrect,
            correctText: 'Correct — that’s what you heard.',
            incorrectText: 'Not quite — listen again.',
          ),
      ],
    );
  }
}
