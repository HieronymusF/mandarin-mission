import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/app_leading_row.dart';
import 'lesson_choice_widgets.dart';

class ImageChoiceStep extends StatelessWidget {
  const ImageChoiceStep({
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
    final imagePath = step.assetId == null
        ? null
        : package.imageAssetPath(step.assetId!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imagePath == null)
          ShadCard(
            key: const Key('image-choice-fallback'),
            width: double.infinity,
            padding: AppLayout.compactCardPadding,
            backgroundColor: theme.colorScheme.custom['warning'],
            border: ShadBorder.none,
            child: AppLeadingRow(
              leadingWidth: AppLayout.noticeIconSlot,
              gap: AppSpacing.sm,
              leading: Icon(
                LucideIcons.imageOff,
                size: 20,
                color: theme.colorScheme.foreground,
              ),
              child: Text(
                'The café illustration is not in this draft yet. Use the text choices to continue.',
                style: theme.textTheme.small,
              ),
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: theme.colorScheme.muted,
                  child: Center(
                    child: Text(
                      'Illustration unavailable',
                      style: theme.textTheme.muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (step.text != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(step.text!, style: theme.textTheme.muted),
        ],
        const SizedBox(height: AppSpacing.md),
        for (final itemId in step.optionItemIds) ...[
          Builder(
            builder: (context) {
              final item = package.knowledgeItem(itemId);
              return LessonChoiceButton(
                key: Key('image-option-$itemId'),
                selected: selectedOptionId == itemId,
                correct: itemId == step.itemId,
                revealResult: selectedOptionId != null,
                onPressed: () => onSelected(itemId),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.hanzi,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.pinyin,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (selectedOptionId != null)
          LessonChoiceFeedback(
            key: const Key('image-choice-result'),
            correct: selectedIsCorrect,
            correctText: 'Coffee is the café item you need.',
            incorrectText: 'That is not the item that means coffee.',
          ),
      ],
    );
  }
}
