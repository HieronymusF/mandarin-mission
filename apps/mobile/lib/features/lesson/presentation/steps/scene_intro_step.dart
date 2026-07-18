import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../data/content/course_content_models.dart';

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
        const SizedBox(height: 24),
        ShadCard(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.coffee,
                      color: theme.colorScheme.accentForeground,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShadBadge.secondary(child: Text('CAFÉ')),
                        const SizedBox(height: 8),
                        Text('At the café counter', style: theme.textTheme.h3),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ShadCard(
                width: double.infinity,
                title: const Text('你好！'),
                description: const Text('Nǐ hǎo! · Hello!'),
                trailing: Icon(
                  LucideIcons.messageCircle,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 17,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
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
