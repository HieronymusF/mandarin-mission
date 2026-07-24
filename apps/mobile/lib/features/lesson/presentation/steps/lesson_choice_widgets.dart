import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../shared/presentation/app_leading_row.dart';

class LessonChoiceButton extends StatelessWidget {
  const LessonChoiceButton({
    required this.selected,
    required this.correct,
    required this.revealResult,
    required this.onPressed,
    required this.child,
    super.key,
  });

  final bool selected;
  final bool correct;
  final bool revealResult;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final selectedCorrect = selected && revealResult && correct;
    final selectedWrong = selected && revealResult && !correct;
    return ShadButton.outline(
      width: double.infinity,
      height: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      expands: true,
      onPressed: onPressed,
      backgroundColor: selectedCorrect
          ? theme.colorScheme.custom['success']
          : selectedWrong
          ? theme.colorScheme.destructive.withValues(alpha: .10)
          : theme.colorScheme.card,
      foregroundColor: selectedWrong
          ? theme.colorScheme.destructive
          : theme.colorScheme.foreground,
      mainAxisAlignment: MainAxisAlignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppLayout.answerControlHeight - (AppSpacing.md * 2),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class LessonChoiceFeedback extends StatelessWidget {
  const LessonChoiceFeedback({
    required this.correct,
    required this.correctText,
    required this.incorrectText,
    super.key,
  });

  final bool correct;
  final String correctText;
  final String incorrectText;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      width: double.infinity,
      padding: AppLayout.compactCardPadding,
      backgroundColor: correct
          ? theme.colorScheme.custom['success']
          : theme.colorScheme.destructive.withValues(alpha: .10),
      border: ShadBorder.none,
      child: AppLeadingRow(
        leadingWidth: AppLayout.noticeIconSlot,
        gap: AppSpacing.sm,
        leading: Icon(
          correct ? LucideIcons.badgeCheck : LucideIcons.circleAlert,
          size: 20,
          color: correct
              ? theme.colorScheme.custom['successForeground']
              : theme.colorScheme.destructive,
        ),
        child: Text(
          correct ? correctText : incorrectText,
          style: theme.textTheme.small,
        ),
      ),
    );
  }
}
