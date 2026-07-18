import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_layout.dart';
import '../../../shared/presentation/app_leading_row.dart';

class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('journey-content'),
            constraints: const BoxConstraints(
              maxWidth: AppLayout.contentMaxWidth,
            ),
            child: ListView(
              padding: AppLayout.pagePadding,
              children: [
                Row(
                  children: [
                    const ShadBadge.secondary(child: Text('DAY 1')),
                    const Spacer(),
                    Icon(
                      LucideIcons.flame,
                      size: AppLayout.noticeIconSlot,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Start your streak', style: theme.textTheme.small),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Your Mandarin journey', style: theme.textTheme.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'One useful mission at a time. Today starts at the café.',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: AppSpacing.xl),
                const _TodayCard(),
                const SizedBox(height: AppSpacing.xxl),
                Text('City stops', style: theme.textTheme.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Complete each real-world mission to unlock the next stop.',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                const _CafeStopCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      key: const Key('journey-today-card'),
      width: double.infinity,
      backgroundColor: theme.colorScheme.primary,
      border: ShadBorder.none,
      padding: AppLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLeadingRow(
            key: const Key('today-card-header'),
            leading: AppIconTile(
              icon: LucideIcons.route,
              backgroundColor: theme.colorScheme.primaryForeground.withValues(
                alpha: .14,
              ),
              foregroundColor: theme.colorScheme.primaryForeground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's mission",
                  style: theme.textTheme.large.copyWith(
                    color: theme.colorScheme.primaryForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '1 short lesson · about 10 minutes',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.primaryForeground.withValues(
                      alpha: .78,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            key: const Key('today-task-row'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _TaskStatus(
                  icon: LucideIcons.bookOpen,
                  label: 'Learn',
                  foreground: theme.colorScheme.primaryForeground,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _TaskStatus(
                  icon: LucideIcons.rotateCcw,
                  label: 'Review',
                  foreground: theme.colorScheme.primaryForeground,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _TaskStatus(
                  icon: LucideIcons.mic,
                  label: 'Speak',
                  foreground: theme.colorScheme.primaryForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskStatus extends StatelessWidget {
  const _TaskStatus({
    required this.icon,
    required this.label,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: foreground),
        const SizedBox(width: AppSpacing.xxs),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CafeStopCard extends StatelessWidget {
  const _CafeStopCard();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      key: const Key('journey-cafe-card'),
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: Column(
        key: const Key('cafe-card-body'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLeadingRow(
            key: const Key('cafe-card-header'),
            leading: AppIconTile(
              icon: LucideIcons.coffee,
              backgroundColor: theme.colorScheme.accent,
              foregroundColor: theme.colorScheme.accentForeground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order one coffee', style: theme.textTheme.h3),
                const SizedBox(height: AppSpacing.xxs),
                Text('Stop 1 · Café', style: theme.textTheme.muted),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              const ShadBadge.outline(child: Text('Meaning')),
              const ShadBadge.outline(child: Text('Listening')),
              const ShadBadge.outline(child: Text('Speaking')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text('7 short steps', style: theme.textTheme.small),
              ),
              Text('Ready to start', style: theme.textTheme.muted),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const ShadProgress(
            value: 0,
            minHeight: 6,
            semanticsLabel: 'Café lesson progress',
            semanticsValue: 'Not started',
          ),
          const SizedBox(height: AppSpacing.lg),
          ShadButton(
            key: const Key('open-cafe-lesson'),
            onPressed: () => context.goNamed(
              'lesson',
              pathParameters: const {'lessonId': 'cafe-01'},
            ),
            width: double.infinity,
            height: AppLayout.controlHeight,
            leading: const Icon(LucideIcons.play, size: 16),
            child: const Text('Start lesson'),
          ),
        ],
      ),
    );
  }
}
