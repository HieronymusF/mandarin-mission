import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text(
                  'Your Mandarin journey',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'One useful mission at a time.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                const _TodayCard(),
                const SizedBox(height: 28),
                Text(
                  'City stops',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
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
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.route_rounded),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's mission",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text('About 10 minutes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CafeStopCard extends StatelessWidget {
  const _CafeStopCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7C2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_cafe_rounded, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stop 1 · Café'),
                      SizedBox(height: 4),
                      Text(
                        'Order one coffee',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Meaning')),
                Chip(label: Text('Listening')),
                Chip(label: Text('Speaking')),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('open-cafe-lesson'),
              onPressed: () => context.goNamed(
                'lesson',
                pathParameters: const {'lessonId': 'cafe-01'},
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start lesson'),
            ),
          ],
        ),
      ),
    );
  }
}
