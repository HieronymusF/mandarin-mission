import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../shared/presentation/app_leading_row.dart';

class SummaryStep extends StatelessWidget {
  const SummaryStep({required this.supportText, super.key});

  final String? supportText;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          key: const Key('summary-stamp-card'),
          width: double.infinity,
          padding: AppLayout.cardPadding,
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          child: AppLeadingRow(
            leading: AppIconTile(
              icon: LucideIcons.badgeCheck,
              backgroundColor: theme.colorScheme.card,
              foregroundColor: theme.colorScheme.primary,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Café stamp earned', style: theme.textTheme.h3),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'You handled your first real-world order.',
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text("Today's stars", style: theme.textTheme.h4),
        const SizedBox(height: AppSpacing.sm),
        const _StarCard(
          id: 'understanding',
          title: 'Understanding',
          description: 'You chose the right meaning.',
          earned: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        const _StarCard(
          id: 'speaking',
          title: 'Speaking',
          description: 'You completed the café reply.',
          earned: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        const _StarCard(
          id: 'memory',
          title: 'Memory',
          description: "Available after tomorrow's review.",
          earned: false,
        ),
        if ((supportText ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(supportText!, style: theme.textTheme.muted),
        ],
      ],
    );
  }
}

class _StarCard extends StatelessWidget {
  const _StarCard({
    required this.id,
    required this.title,
    required this.description,
    required this.earned,
  });

  final String id;
  final String title;
  final String description;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      key: Key('summary-star-$id-card'),
      width: double.infinity,
      padding: AppLayout.compactCardPadding,
      backgroundColor: earned
          ? theme.colorScheme.card
          : theme.colorScheme.muted,
      child: AppLeadingRow(
        key: Key('summary-star-$id-row'),
        leadingWidth: AppLayout.listIconSlot,
        gap: AppSpacing.sm,
        leading: Icon(
          LucideIcons.star,
          color: earned
              ? const Color(0xFFE6A220)
              : theme.colorScheme.mutedForeground,
          size: AppLayout.noticeIconSlot,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.h3),
            const SizedBox(height: AppSpacing.xxs),
            Text(description, style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }
}
