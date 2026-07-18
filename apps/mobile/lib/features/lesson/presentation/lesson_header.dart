import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_layout.dart';
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        children: [
          SizedBox(
            height: AppLayout.controlHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShadButton.outline(
                  key: const Key('lesson-back-action'),
                  width: AppLayout.minimumTouchTarget,
                  height: AppLayout.minimumTouchTarget,
                  padding: EdgeInsets.zero,
                  onPressed: onBack,
                  child: const Icon(LucideIcons.chevronLeft, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
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
                      const SizedBox(height: AppSpacing.xxs),
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
          const SizedBox(height: AppSpacing.sm),
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
