import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Row(
                  children: [
                    const ShadBadge.secondary(child: Text('DAY 1')),
                    const Spacer(),
                    Icon(
                      LucideIcons.flame,
                      size: 18,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text('Start your streak', style: theme.textTheme.small),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Your Mandarin journey', style: theme.textTheme.h2),
                const SizedBox(height: 8),
                Text(
                  'One useful mission at a time. Today starts at the café.',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 24),
                const _TodayCard(),
                const SizedBox(height: 28),
                Text('City stops', style: theme.textTheme.h3),
                const SizedBox(height: 6),
                Text(
                  'Complete each real-world mission to unlock the next stop.',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 14),
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
      width: double.infinity,
      backgroundColor: theme.colorScheme.primary,
      border: ShadBorder.none,
      padding: const EdgeInsets.all(20),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryForeground.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          LucideIcons.route,
          color: theme.colorScheme.primaryForeground,
          size: 23,
        ),
      ),
      title: Text(
        "Today's mission",
        style: theme.textTheme.large.copyWith(
          color: theme.colorScheme.primaryForeground,
        ),
      ),
      description: Text(
        '1 short lesson · about 10 minutes',
        style: theme.textTheme.small.copyWith(
          color: theme.colorScheme.primaryForeground.withValues(alpha: .78),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Row(
          children: [
            Expanded(
              child: _TaskStatus(
                icon: LucideIcons.bookOpen,
                label: 'Learn',
                foreground: theme.colorScheme.primaryForeground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TaskStatus(
                icon: LucideIcons.rotateCcw,
                label: 'Review',
                foreground: theme.colorScheme.primaryForeground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TaskStatus(
                icon: LucideIcons.mic,
                label: 'Speak',
                foreground: theme.colorScheme.primaryForeground,
              ),
            ),
          ],
        ),
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
      children: [
        Icon(icon, size: 15, color: foreground),
        const SizedBox(width: 5),
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          LucideIcons.coffee,
          color: theme.colorScheme.accentForeground,
          size: 25,
        ),
      ),
      title: const Text('Order one coffee'),
      description: const Text('Stop 1 · Café'),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const ShadBadge.outline(child: Text('Meaning')),
                const ShadBadge.outline(child: Text('Listening')),
                const ShadBadge.outline(child: Text('Speaking')),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text('7 short steps', style: theme.textTheme.small),
                ),
                Text('Ready to start', style: theme.textTheme.muted),
              ],
            ),
            const SizedBox(height: 8),
            const ShadProgress(
              value: 0,
              minHeight: 6,
              semanticsLabel: 'Café lesson progress',
              semanticsValue: 'Not started',
            ),
            const SizedBox(height: 20),
            ShadButton(
              key: const Key('open-cafe-lesson'),
              onPressed: () => context.goNamed(
                'lesson',
                pathParameters: const {'lessonId': 'cafe-01'},
              ),
              width: double.infinity,
              leading: const Icon(LucideIcons.play, size: 17),
              child: const Text('Start lesson'),
            ),
          ],
        ),
      ),
    );
  }
}
