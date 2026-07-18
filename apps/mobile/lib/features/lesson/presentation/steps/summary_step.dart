import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
          width: double.infinity,
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              LucideIcons.badgeCheck,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          title: const Text('Café stamp earned'),
          description: const Text('You handled your first real-world order.'),
        ),
        const SizedBox(height: 20),
        Text("Today's stars", style: theme.textTheme.h4),
        const SizedBox(height: 10),
        const _StarCard(
          title: 'Understanding',
          description: 'You chose the right meaning.',
          earned: true,
        ),
        const SizedBox(height: 10),
        const _StarCard(
          title: 'Speaking',
          description: 'You completed the café reply.',
          earned: true,
        ),
        const SizedBox(height: 10),
        const _StarCard(
          title: 'Memory',
          description: "Available after tomorrow's review.",
          earned: false,
        ),
        if ((supportText ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(supportText!, style: theme.textTheme.muted),
        ],
      ],
    );
  }
}

class _StarCard extends StatelessWidget {
  const _StarCard({
    required this.title,
    required this.description,
    required this.earned,
  });

  final String title;
  final String description;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      backgroundColor: earned
          ? theme.colorScheme.card
          : theme.colorScheme.muted,
      leading: Icon(
        LucideIcons.star,
        color: earned
            ? const Color(0xFFE6A220)
            : theme.colorScheme.mutedForeground,
        size: 24,
      ),
      title: Text(title),
      description: Text(description),
    );
  }
}
