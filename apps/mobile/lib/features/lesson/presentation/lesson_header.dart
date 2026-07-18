import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/content/course_content_models.dart';

class LessonHeader extends StatelessWidget {
  const LessonHeader({
    required this.lesson,
    required this.stepIndex,
    required this.onBack,
    super.key,
  });

  final CourseLesson lesson;
  final int stepIndex;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final currentStep = stepIndex + 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                ShadButton.outline(
                  key: const Key('lesson-back-action'),
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.zero,
                  onPressed: onBack,
                  child: const Icon(LucideIcons.chevronLeft, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CAFÉ MISSION',
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Step $currentStep of ${lesson.steps.length}',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$currentStep / ${lesson.steps.length}',
                  style: theme.textTheme.small,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ShadProgress(
            value: currentStep / lesson.steps.length,
            minHeight: 6,
            semanticsLabel: 'Lesson progress',
            semanticsValue: '$currentStep of ${lesson.steps.length}',
          ),
        ],
      ),
    );
  }
}
