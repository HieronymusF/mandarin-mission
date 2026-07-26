import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/app_leading_row.dart';

class SceneIntroStep extends StatelessWidget {
  const SceneIntroStep({
    required this.step,
    required this.locationTitle,
    super.key,
  });

  final CourseLessonStep step;
  final String locationTitle;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  icon: LucideIcons.mapPin,
                  backgroundColor: theme.colorScheme.card,
                  foregroundColor: theme.colorScheme.accentForeground,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ShadBadge.secondary(
                    child: Text(locationTitle.toUpperCase()),
                  ),
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
                          Text(step.text ?? '', style: theme.textTheme.muted),
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
      ],
    );
  }
}
