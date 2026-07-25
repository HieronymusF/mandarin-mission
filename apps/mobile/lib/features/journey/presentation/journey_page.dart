import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_layout.dart';
import '../../../data/content/course_content_models.dart';
import '../../../data/content/course_content_provider.dart';
import '../../lesson/application/lesson_providers.dart';
import '../../review/application/review_providers.dart';
import '../../../shared/presentation/app_leading_row.dart';

class JourneyPage extends ConsumerWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final reviewSummary = ref.watch(dueReviewSummaryProvider);
    final coursePackage = ref.watch(coursePackageProvider);

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
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            LucideIcons.flame,
                            size: AppLayout.noticeIconSlot,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              'Start your streak',
                              textAlign: TextAlign.end,
                              style: theme.textTheme.small,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                _TodayCard(
                  reviewSummary: reviewSummary,
                  onOpenReview: () => context.goNamed('review'),
                  onRetryReview: () => ref.invalidate(dueReviewSummaryProvider),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('City stops', style: theme.textTheme.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Complete each real-world mission to unlock the next stop.',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                coursePackage.when(
                  loading: () => const _JourneyContentStatus(
                    key: Key('journey-content-loading'),
                    icon: LucideIcons.loaderCircle,
                    title: 'Loading city stops…',
                    message: 'Your bundled lessons stay available offline.',
                  ),
                  error: (_, _) => _JourneyContentStatus(
                    key: const Key('journey-content-error'),
                    icon: LucideIcons.circleAlert,
                    title: 'Lessons unavailable',
                    message: 'Try loading the bundled course again.',
                    actionLabel: 'Retry',
                    onAction: () => ref.invalidate(coursePackageProvider),
                  ),
                  data: (package) => _LocationLessonCards(package: package),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.reviewSummary,
    required this.onOpenReview,
    required this.onRetryReview,
  });

  final AsyncValue<ReviewQueueSummary> reviewSummary;
  final VoidCallback onOpenReview;
  final VoidCallback onRetryReview;

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
                  label: reviewSummary.maybeWhen(
                    data: (summary) => summary.hasDueItems
                        ? 'Review ${summary.requiredCount}'
                        : 'Review done',
                    orElse: () => 'Review',
                  ),
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
          const SizedBox(height: AppSpacing.lg),
          Divider(
            height: 1,
            color: theme.colorScheme.primaryForeground.withValues(alpha: .24),
          ),
          const SizedBox(height: AppSpacing.md),
          reviewSummary.when(
            loading: () => _ReviewStatus(
              icon: LucideIcons.loaderCircle,
              title: 'Checking your review queue…',
              message: 'Your saved progress stays on this device.',
              foreground: theme.colorScheme.primaryForeground,
            ),
            error: (error, stackTrace) => _ReviewStatus(
              key: const Key('journey-review-error'),
              icon: LucideIcons.circleAlert,
              title: 'Review status unavailable',
              message: 'Your progress is safe. Try the local check again.',
              foreground: theme.colorScheme.primaryForeground,
              actionLabel: 'Retry',
              onAction: onRetryReview,
            ),
            data: (summary) {
              if (!summary.hasDueItems) {
                return _ReviewStatus(
                  key: const Key('journey-review-empty'),
                  icon: LucideIcons.circleCheckBig,
                  title: 'Review is up to date',
                  message: 'New memory anchors appear here when they are due.',
                  foreground: theme.colorScheme.primaryForeground,
                );
              }
              final extraMessage = summary.extraCount > 0
                  ? 'Start with ${summary.requiredCount} must-do items; ${summary.extraCount} more stay optional.'
                  : '${summary.requiredCount} memory ${summary.requiredCount == 1 ? 'anchor is' : 'anchors are'} ready.';
              return _ReviewStatus(
                key: const Key('journey-review-due'),
                icon: LucideIcons.rotateCcw,
                title:
                    '${summary.requiredCount} due ${summary.requiredCount == 1 ? 'review' : 'reviews'}',
                message: extraMessage,
                foreground: theme.colorScheme.primaryForeground,
                actionLabel: 'Start',
                onAction: onOpenReview,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReviewStatus extends StatelessWidget {
  const _ReviewStatus({
    required this.icon,
    required this.title,
    required this.message,
    required this.foreground,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color foreground;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppLeadingRow(
          leadingWidth: AppLayout.noticeIconSlot,
          gap: AppSpacing.sm,
          leading: Icon(icon, size: 20, color: foreground),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                message,
                style: TextStyle(
                  color: foreground.withValues(alpha: .78),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.md),
          ShadButton.secondary(
            key: actionLabel == 'Start'
                ? const Key('open-review')
                : const Key('retry-review-summary'),
            width: double.infinity,
            height: AppLayout.controlHeight,
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
        ],
      ],
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: foreground),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _JourneyContentStatus extends StatelessWidget {
  const _JourneyContentStatus({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLeadingRow(
            leading: AppIconTile(
              icon: icon,
              backgroundColor: theme.colorScheme.muted,
              foregroundColor: theme.colorScheme.mutedForeground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.h3),
                const SizedBox(height: AppSpacing.xxs),
                Text(message, style: theme.textTheme.muted),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            ShadButton.outline(
              width: double.infinity,
              height: AppLayout.controlHeight,
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationLessonCards extends StatelessWidget {
  const _LocationLessonCards({required this.package});

  final CoursePackage package;

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final location in package.locations)
        for (final lessonId in location.lessonIds)
          (location: location, lesson: package.lesson(lessonId)),
    ];

    return Column(
      children: [
        for (final entry in entries.indexed) ...[
          if (entry.$1 > 0) const SizedBox(height: AppSpacing.md),
          _LessonStopCard(location: entry.$2.location, lesson: entry.$2.lesson),
        ],
      ],
    );
  }
}

class _LessonStopCard extends ConsumerWidget {
  const _LessonStopCard({required this.location, required this.lesson});

  final CourseLocation location;
  final CourseLesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final progress = ref.watch(lessonProgressProvider(lesson.id));
    final status = progress.when(
      data: (entry) => entry?.status,
      loading: () => null,
      error: (_, _) => null,
    );
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';
    final statusLabel = switch (status) {
      'completed' => 'Completed',
      'in_progress' => 'In progress',
      _ when progress.isLoading => 'Loading progress',
      _ => 'Ready to start',
    };
    final actionLabel = switch (status) {
      'completed' => 'Practice again',
      'in_progress' => 'Start again',
      _ => 'Start',
    };
    final stepCountLabel = '${lesson.steps.length} short steps';
    return ShadCard(
      key: Key('journey-lesson-${lesson.id}-card'),
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: Column(
        key: Key('journey-lesson-${lesson.id}-body'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLeadingRow(
            key: Key('journey-lesson-${lesson.id}-header'),
            leading: AppIconTile(
              icon: LucideIcons.mapPin,
              backgroundColor: theme.colorScheme.accent,
              foregroundColor: theme.colorScheme.accentForeground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.title, style: theme.textTheme.h3),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Stop ${location.order} · ${location.title}',
                  style: theme.textTheme.muted,
                ),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xxs,
            children: [
              Text(stepCountLabel, style: theme.textTheme.small),
              Text(statusLabel, style: theme.textTheme.muted),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ShadProgress(
            value: isCompleted ? 1 : 0,
            minHeight: 6,
            semanticsLabel: '${lesson.title} progress',
            semanticsValue: isCompleted
                ? 'Completed'
                : isInProgress
                ? 'In progress'
                : 'Not started',
          ),
          const SizedBox(height: AppSpacing.lg),
          ShadButton(
            key: Key('open-lesson-${lesson.id}'),
            onPressed: () => context.goNamed(
              'lesson',
              pathParameters: {'lessonId': lesson.id},
            ),
            width: double.infinity,
            height: AppLayout.controlHeight,
            leading: const Icon(LucideIcons.play, size: 16),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
