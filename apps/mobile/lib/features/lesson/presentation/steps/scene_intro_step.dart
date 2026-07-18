import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/app_leading_row.dart';

class SceneIntroStep extends StatelessWidget {
  const SceneIntroStep({required this.step, super.key});

  final CourseLessonStep step;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step.text ?? '', style: theme.textTheme.muted),
        const SizedBox(height: AppSpacing.xl),
        ShadCard(
          key: const Key('scene-intro-card'),
          width: double.infinity,
          padding: AppLayout.cardPadding,
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppLeadingRow(
                leading: AppIconTile(
                  icon: LucideIcons.coffee,
                  backgroundColor: theme.colorScheme.card,
                  foregroundColor: theme.colorScheme.accentForeground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShadBadge.secondary(child: Text('CAFÉ')),
                    const SizedBox(height: AppSpacing.xs),
                    Text('At the café counter', style: theme.textTheme.h3),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ShadCard(
                key: const Key('scene-intro-greeting-card'),
                width: double.infinity,
                padding: AppLayout.cardPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('你好！', style: theme.textTheme.h3),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Nǐ hǎo! · Hello!',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      LucideIcons.messageCircle,
                      size: AppLayout.noticeIconSlot,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'You will learn one complete order, then use it yourself.',
                style: theme.textTheme.small,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
