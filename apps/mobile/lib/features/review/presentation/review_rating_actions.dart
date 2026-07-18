import 'package:flutter/material.dart';
import 'package:learning_core/learning_core.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_layout.dart';
import '../../../shared/presentation/app_leading_row.dart';

class ReviewRatingActions extends StatelessWidget {
  const ReviewRatingActions({
    required this.isSubmitting,
    required this.onRating,
    super.key,
  });

  final bool isSubmitting;
  final ValueChanged<ReviewRating> onRating;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final showIcons = MediaQuery.textScalerOf(context).scale(1) <= 1.5;
    return Column(
      key: const Key('review-rating-actions'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('How clearly did you remember?', style: theme.textTheme.h4),
        const SizedBox(height: AppSpacing.sm),
        ShadButton.outline(
          key: const Key('review-rating-forgotten'),
          width: double.infinity,
          height: AppLayout.controlHeight,
          onPressed: isSubmitting
              ? null
              : () => onRating(ReviewRating.forgotten),
          foregroundColor: theme.colorScheme.destructive,
          leading: showIcons
              ? const Icon(LucideIcons.rotateCcw, size: 16)
              : null,
          child: const Text('Forgotten'),
        ),
        const SizedBox(height: AppSpacing.xs),
        ShadButton.secondary(
          key: const Key('review-rating-vague'),
          width: double.infinity,
          height: AppLayout.controlHeight,
          onPressed: isSubmitting ? null : () => onRating(ReviewRating.vague),
          leading: showIcons ? const Icon(LucideIcons.cloudy, size: 16) : null,
          child: const Text('Unsure'),
        ),
        const SizedBox(height: AppSpacing.xs),
        ShadButton(
          key: const Key('review-rating-remembered'),
          width: double.infinity,
          height: AppLayout.controlHeight,
          onPressed: isSubmitting
              ? null
              : () => onRating(ReviewRating.remembered),
          leading: isSubmitting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : showIcons
              ? const Icon(LucideIcons.check, size: 16)
              : null,
          child: Text(isSubmitting ? 'Saving…' : 'Remembered'),
        ),
      ],
    );
  }
}

class ReviewSaveError extends StatelessWidget {
  const ReviewSaveError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      key: const Key('review-save-error'),
      width: double.infinity,
      padding: AppLayout.compactCardPadding,
      backgroundColor: theme.colorScheme.destructive.withValues(alpha: .10),
      border: ShadBorder.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLeadingRow(
            leadingWidth: AppLayout.noticeIconSlot,
            gap: AppSpacing.sm,
            leading: Icon(
              LucideIcons.circleAlert,
              size: 20,
              color: theme.colorScheme.destructive,
            ),
            child: Text(message, style: theme.textTheme.small),
          ),
          const SizedBox(height: AppSpacing.sm),
          ShadButton.outline(
            key: const Key('review-save-retry'),
            width: double.infinity,
            height: AppLayout.controlHeight,
            onPressed: onRetry,
            child: const Text('Retry save'),
          ),
        ],
      ),
    );
  }
}
