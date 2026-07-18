import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_core/learning_core.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_layout.dart';
import '../../../shared/presentation/app_leading_row.dart';
import '../application/review_providers.dart';
import 'review_prompt_card.dart';
import 'review_rating_actions.dart';

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(reviewSessionControllerProvider);
    final controller = ref.read(reviewSessionControllerProvider.notifier);
    return Scaffold(
      key: const Key('review-page'),
      body: SafeArea(
        child: Column(
          children: [
            _ReviewHeader(
              session: session.value,
              onBack: () => context.go('/'),
            ),
            Expanded(
              child: session.when(
                loading: () => const _ReviewLoading(),
                error: (error, stackTrace) =>
                    _ReviewLoadError(onRetry: controller.reload),
                data: (value) {
                  if (value.hasLoadError) {
                    return _ReviewLoadError(onRetry: controller.reload);
                  }
                  if (value.isEmpty) {
                    return _ReviewEmpty(onDone: () => context.go('/'));
                  }
                  if (value.isComplete) {
                    return _ReviewComplete(
                      session: value,
                      onDone: () => context.go('/'),
                    );
                  }
                  return _ReviewBody(
                    session: value,
                    onSelectOption: controller.selectOption,
                    onRevealAnswer: controller.revealAnswer,
                    onRating: controller.submitRating,
                    onRetrySave: controller.retrySubmission,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.session, required this.onBack});

  final ReviewSessionState? session;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final current = session?.current;
    final currentNumber = session == null || session!.isEmpty
        ? 0
        : session!.isComplete
        ? session!.items.length
        : session!.currentIndex + 1;
    final total = session?.items.length ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppLayout.controlHeight,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadButton.outline(
                  key: const Key('review-back-action'),
                  width: AppLayout.minimumTouchTarget,
                  height: AppLayout.minimumTouchTarget,
                  padding: EdgeInsets.zero,
                  onPressed: onBack,
                  child: const Icon(LucideIcons.chevronLeft, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY REVIEW',
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        current == null
                            ? 'Your due practice'
                            : _dimensionLabel(current.queueItem.dimension),
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
                if (total > 0)
                  Text('$currentNumber / $total', style: theme.textTheme.small),
              ],
            ),
          ),
          if (total > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            ShadProgress(
              value: currentNumber / total,
              minHeight: 6,
              semanticsLabel: 'Review progress',
              semanticsValue: '$currentNumber of $total',
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewBody extends StatelessWidget {
  const _ReviewBody({
    required this.session,
    required this.onSelectOption,
    required this.onRevealAnswer,
    required this.onRating,
    required this.onRetrySave,
  });

  final ReviewSessionState session;
  final ValueChanged<String> onSelectOption;
  final VoidCallback onRevealAnswer;
  final ValueChanged<ReviewRating> onRating;
  final VoidCallback onRetrySave;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final current = session.current!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
        child: SizedBox(
          key: const Key('review-content'),
          width: double.infinity,
          child: ListView(
            padding: AppLayout.pagePadding,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  ShadBadge.secondary(
                    child: Text(
                      _dimensionLabel(
                        current.queueItem.dimension,
                      ).toUpperCase(),
                    ),
                  ),
                  Text(
                    '${session.items.length - session.currentIndex} left',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _promptTitle(current.queueItem.dimension),
                style: theme.textTheme.h2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _promptInstruction(current.queueItem.dimension),
                style: theme.textTheme.muted,
              ),
              if (session.hasExtra && session.currentIndex == 0) ...[
                const SizedBox(height: AppSpacing.md),
                ShadCard(
                  key: const Key('review-extra-notice'),
                  width: double.infinity,
                  padding: AppLayout.compactCardPadding,
                  backgroundColor: theme.colorScheme.accent,
                  border: ShadBorder.none,
                  child: AppLeadingRow(
                    leadingWidth: AppLayout.noticeIconSlot,
                    gap: AppSpacing.sm,
                    leading: Icon(
                      LucideIcons.layers,
                      size: 20,
                      color: theme.colorScheme.accentForeground,
                    ),
                    child: Text(
                      'This session covers today’s must-do items. Extra practice stays available afterward.',
                      style: theme.textTheme.small,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              ReviewPromptCard(
                session: session,
                onSelectOption: onSelectOption,
                onRevealAnswer: onRevealAnswer,
              ),
              if (session.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ReviewSaveError(
                  message: session.errorMessage!,
                  onRetry: onRetrySave,
                ),
              ] else if (session.isAnswerRevealed) ...[
                const SizedBox(height: AppSpacing.xl),
                ReviewRatingActions(
                  isSubmitting: session.isSubmitting,
                  onRating: onRating,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewLoading extends StatelessWidget {
  const _ReviewLoading();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.loadingMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Checking what is due…',
              textAlign: TextAlign.center,
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewLoadError extends StatelessWidget {
  const _ReviewLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      key: const Key('review-load-error'),
      icon: LucideIcons.circleAlert,
      title: 'Reviews could not be loaded',
      message:
          'Your saved progress is still on this device. Try loading the queue again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

class _ReviewEmpty extends StatelessWidget {
  const _ReviewEmpty({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      key: const Key('review-empty'),
      icon: LucideIcons.circleCheckBig,
      title: 'You are all caught up',
      message: 'No memory anchors are due right now. Continue your journey.',
      actionLabel: 'Done',
      onAction: onDone,
    );
  }
}

class _ReviewComplete extends StatelessWidget {
  const _ReviewComplete({required this.session, required this.onDone});

  final ReviewSessionState session;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final message = session.hasExtra
        ? 'Today’s must-do review is saved. Extra practice is still available.'
        : '${session.rememberedCount} remembered · ${session.vagueCount} unsure · ${session.forgottenCount} forgotten';
    return _CenteredState(
      key: const Key('review-complete'),
      icon: LucideIcons.badgeCheck,
      title: 'Review saved',
      message: message,
      actionLabel: 'Done',
      onAction: onDone,
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: AppLayout.pagePadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.errorMaxWidth),
          child: ShadCard(
            width: double.infinity,
            padding: AppLayout.cardPadding,
            child: Column(
              children: [
                Icon(
                  icon,
                  size: AppLayout.iconTileSize,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.h3,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: AppSpacing.lg),
                ShadButton(
                  width: double.infinity,
                  height: AppLayout.controlHeight,
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _dimensionLabel(LearningDimension dimension) {
  return switch (dimension) {
    LearningDimension.meaning => 'Meaning',
    LearningDimension.listening => 'Listening',
    LearningDimension.tone => 'Tone',
    LearningDimension.hanzi => 'Hanzi',
  };
}

String _promptTitle(LearningDimension dimension) {
  return switch (dimension) {
    LearningDimension.meaning => 'Connect meaning to Chinese',
    LearningDimension.listening => 'Recognize the sound',
    LearningDimension.tone => 'Recall the tones',
    LearningDimension.hanzi => 'Recognize the characters',
  };
}

String _promptInstruction(LearningDimension dimension) {
  return switch (dimension) {
    LearningDimension.meaning =>
      'Choose first, then rate how clearly you remembered.',
    LearningDimension.listening => 'Listen before revealing the phrase.',
    LearningDimension.tone => 'Say the expression aloud before checking it.',
    LearningDimension.hanzi => 'Read the characters before showing the answer.',
  };
}
