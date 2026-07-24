import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/audio_player_bar.dart';
import 'lesson_choice_widgets.dart';

class ToneContrastStep extends StatelessWidget {
  const ToneContrastStep({
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
    final target = package.knowledgeItem(step.itemId!);
    final selectedIsCorrect = selectedOptionId == step.itemId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          width: double.infinity,
          padding: AppLayout.compactCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                target.hanzi,
                style: theme.textTheme.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AudioPlayerBar(
                key: const Key('tone-audio-player'),
                assetPath: package.audioAssetPathForItem(target.id),
                showLabel: false,
              ),
            ],
          ),
        ),
        if (step.text != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(step.text!, style: theme.textTheme.muted),
        ],
        const SizedBox(height: AppSpacing.md),
        for (final (index, option) in step.optionTexts.indexed) ...[
          LessonChoiceButton(
            key: Key('tone-option-$index'),
            selected: selectedOptionId == option,
            correct: option == target.pinyin,
            revealResult: selectedOptionId != null,
            onPressed: () => onSelected(option),
            child: Text(option),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (selectedOptionId != null)
          LessonChoiceFeedback(
            key: const Key('tone-choice-result'),
            correct: selectedIsCorrect,
            correctText: 'wǒ yào matches the tones you heard.',
            incorrectText: 'Listen again and match both tone marks.',
          ),
      ],
    );
  }
}
