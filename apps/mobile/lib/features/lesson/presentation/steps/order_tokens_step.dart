import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import 'lesson_choice_widgets.dart';

class OrderTokensStep extends StatefulWidget {
  const OrderTokensStep({
    required this.step,
    required this.orderedTokenIndexes,
    required this.onToggleToken,
    super.key,
  });

  final CourseLessonStep step;
  final List<int> orderedTokenIndexes;
  final ValueChanged<int> onToggleToken;

  @override
  State<OrderTokensStep> createState() => _OrderTokensStepState();
}

class _OrderTokensStepState extends State<OrderTokensStep> {
  late List<int> _bankIndexes;

  @override
  void initState() {
    super.initState();
    _bankIndexes = _shuffledTokenIndexes(widget.step.tokens.length);
  }

  @override
  void didUpdateWidget(covariant OrderTokensStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _bankIndexes = _shuffledTokenIndexes(widget.step.tokens.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final orderedTokenIndexes = widget.orderedTokenIndexes;
    final onToggleToken = widget.onToggleToken;
    final theme = ShadTheme.of(context);
    final complete = orderedTokenIndexes.length == step.tokens.length;
    final correct =
        complete &&
        orderedTokenIndexes.indexed.every((entry) => entry.$1 == entry.$2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (step.text != null) ...[
          Text(step.text!, style: theme.textTheme.muted),
          const SizedBox(height: AppSpacing.md),
        ],
        ShadCard(
          key: const Key('order-answer-card'),
          width: double.infinity,
          padding: AppLayout.compactCardPadding,
          child: orderedTokenIndexes.isEmpty
              ? Text(
                  'Your sentence will appear here.',
                  style: theme.textTheme.muted,
                  textAlign: TextAlign.center,
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final index in orderedTokenIndexes)
                      ShadButton.secondary(
                        key: Key('ordered-token-$index'),
                        height: AppLayout.controlHeight,
                        onPressed: () => onToggleToken(index),
                        child: Text(step.tokens[index]),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final index in _bankIndexes)
              if (!orderedTokenIndexes.contains(index))
                ShadButton.outline(
                  key: Key('order-token-$index'),
                  height: AppLayout.controlHeight,
                  onPressed: () => onToggleToken(index),
                  child: Text(step.tokens[index]),
                ),
          ],
        ),
        if (complete) ...[
          const SizedBox(height: AppSpacing.md),
          LessonChoiceFeedback(
            key: const Key('order-result'),
            correct: correct,
            correctText: 'Correct — that’s the right order.',
            incorrectText: 'Not quite — try a different order.',
          ),
        ],
      ],
    );
  }
}

List<int> _shuffledTokenIndexes(int length) {
  final indexes = List<int>.generate(length, (index) => index)..shuffle();
  if (length < 2) {
    return indexes;
  }

  final isCorrectOrder = indexes.indexed.every((entry) => entry.$1 == entry.$2);
  if (isCorrectOrder) {
    indexes.add(indexes.removeAt(0));
  }

  final isReverseOrder = indexes.indexed.every(
    (entry) => entry.$2 == length - entry.$1 - 1,
  );
  if (length > 2 && isReverseOrder) {
    final first = indexes[0];
    indexes[0] = indexes[1];
    indexes[1] = first;
  }
  return indexes;
}
