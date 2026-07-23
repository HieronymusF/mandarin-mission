import 'package:flutter/material.dart';
import 'package:learning_core/learning_core.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_layout.dart';
import '../../../data/content/course_content_models.dart';
import '../../../shared/presentation/app_leading_row.dart';
import '../../../shared/presentation/audio_player_bar.dart';
import '../../../shared/presentation/hanzi_pinyin_text.dart';
import '../application/review_providers.dart';

class ReviewPromptCard extends StatelessWidget {
  const ReviewPromptCard({
    required this.session,
    required this.onSelectOption,
    required this.onRevealAnswer,
    super.key,
  });

  final ReviewSessionState session;
  final ValueChanged<String> onSelectOption;
  final VoidCallback onRevealAnswer;

  @override
  Widget build(BuildContext context) {
    final entry = session.current!;
    return switch (entry.queueItem.dimension) {
      LearningDimension.meaning => _MeaningPrompt(
        session: session,
        onSelectOption: onSelectOption,
      ),
      LearningDimension.listening => _ListeningPrompt(
        session: session,
        onRevealAnswer: onRevealAnswer,
      ),
      LearningDimension.tone => _TonePrompt(
        session: session,
        onRevealAnswer: onRevealAnswer,
      ),
      LearningDimension.hanzi => _HanziPrompt(
        session: session,
        onRevealAnswer: onRevealAnswer,
      ),
    };
  }
}

class _MeaningPrompt extends StatelessWidget {
  const _MeaningPrompt({required this.session, required this.onSelectOption});

  final ReviewSessionState session;
  final ValueChanged<String> onSelectOption;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final entry = session.current!;
    return Column(
      key: const Key('review-prompt-meaning'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          width: double.infinity,
          padding: AppLayout.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose the Chinese expression', style: theme.textTheme.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '“${entry.knowledgeItem.english}”',
                style: theme.textTheme.large,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final option in entry.options) ...[
          _MeaningOption(
            optionId: option.id,
            hanzi: option.hanzi,
            pinyinSyllables: option.pinyinSyllables,
            selected: session.selectedOptionId == option.id,
            correct: option.id == entry.knowledgeItem.id,
            revealed: session.isAnswerRevealed,
            onPressed: session.isAnswerRevealed
                ? null
                : () => onSelectOption(option.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (session.isAnswerRevealed)
          _ObjectiveFeedback(
            correct: session.selectedOptionId == entry.knowledgeItem.id,
          ),
      ],
    );
  }
}

class _MeaningOption extends StatelessWidget {
  const _MeaningOption({
    required this.optionId,
    required this.hanzi,
    required this.pinyinSyllables,
    required this.selected,
    required this.correct,
    required this.revealed,
    required this.onPressed,
  });

  final String optionId;
  final String hanzi;
  final List<String> pinyinSyllables;
  final bool selected;
  final bool correct;
  final bool revealed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final selectedCorrect = selected && revealed && correct;
    final selectedWrong = selected && revealed && !correct;
    return ShadButton.outline(
      key: Key('review-answer-$optionId'),
      width: double.infinity,
      height: AppLayout.answerControlHeight,
      onPressed: onPressed,
      backgroundColor: selectedCorrect
          ? theme.colorScheme.custom['success']
          : selectedWrong
          ? theme.colorScheme.destructive.withValues(alpha: .10)
          : theme.colorScheme.card,
      foregroundColor: selectedWrong
          ? theme.colorScheme.destructive
          : theme.colorScheme.foreground,
      child: HanziPinyinText(
        hanzi: hanzi,
        pinyinSyllables: pinyinSyllables,
        hanziFontSize: 20,
        pinyinFontSize: 12,
        pinyinColor: theme.colorScheme.mutedForeground,
      ),
    );
  }
}

class _ObjectiveFeedback extends StatelessWidget {
  const _ObjectiveFeedback({required this.correct});

  final bool correct;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      key: const Key('review-objective-feedback'),
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
          correct
              ? 'Correct. How clearly did you remember it?'
              : 'Not this time. Use your memory check to schedule the retry.',
          style: theme.textTheme.small,
        ),
      ),
    );
  }
}

class _ListeningPrompt extends StatelessWidget {
  const _ListeningPrompt({required this.session, required this.onRevealAnswer});

  final ReviewSessionState session;
  final VoidCallback onRevealAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final entry = session.current!;
    final item = entry.knowledgeItem;
    return ShadCard(
      key: const Key('review-prompt-listening'),
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Listen and identify the phrase', style: theme.textTheme.h3),
          const SizedBox(height: AppSpacing.md),
          if (entry.audioAssetPath != null)
            AudioPlayerBar(
              key: const Key('review-audio-player'),
              assetPath: entry.audioAssetPath,
              label: 'Play prompt',
            )
          else
            ShadCard(
              key: const Key('review-audio-unavailable'),
              width: double.infinity,
              padding: AppLayout.compactCardPadding,
              backgroundColor: theme.colorScheme.custom['warning'],
              border: ShadBorder.none,
              child: AppLeadingRow(
                leadingWidth: AppLayout.noticeIconSlot,
                gap: AppSpacing.sm,
                leading: Icon(
                  LucideIcons.volumeX,
                  size: 20,
                  color: theme.colorScheme.custom['warningForeground'],
                ),
                child: Text(
                  'Audio is not available in this content build. Use the written fallback; this counts as a hint.',
                  style: theme.textTheme.small,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (!session.isAnswerRevealed)
            ShadButton.secondary(
              key: const Key('review-reveal-answer'),
              width: double.infinity,
              height: AppLayout.controlHeight,
              onPressed: onRevealAnswer,
              child: const Text('Reveal'),
            )
          else
            _RevealedPhrase(item: item),
        ],
      ),
    );
  }
}

class _TonePrompt extends StatelessWidget {
  const _TonePrompt({required this.session, required this.onRevealAnswer});

  final ReviewSessionState session;
  final VoidCallback onRevealAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final item = session.current!.knowledgeItem;
    return ShadCard(
      key: const Key('review-prompt-tone'),
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLeadingRow(
            leading: AppIconTile(
              icon: LucideIcons.mic,
              backgroundColor: theme.colorScheme.accent,
              foregroundColor: theme.colorScheme.accentForeground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Say it with the tones', style: theme.textTheme.h3),
                const SizedBox(height: AppSpacing.xxs),
                Text(item.english, style: theme.textTheme.muted),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!session.isAnswerRevealed)
            ShadButton.secondary(
              key: const Key('review-reveal-answer'),
              width: double.infinity,
              height: AppLayout.controlHeight,
              onPressed: onRevealAnswer,
              leading: const Icon(LucideIcons.rotateCcw, size: 16),
              child: const Text('Reveal'),
            )
          else
            _RevealedPhrase(item: item),
        ],
      ),
    );
  }
}

class _HanziPrompt extends StatelessWidget {
  const _HanziPrompt({required this.session, required this.onRevealAnswer});

  final ReviewSessionState session;
  final VoidCallback onRevealAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final item = session.current!.knowledgeItem;
    return ShadCard(
      key: const Key('review-prompt-hanzi'),
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Read this in Chinese', style: theme.textTheme.h3),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              item.hanzi,
              key: const Key('review-hanzi-question'),
              textAlign: TextAlign.center,
              style: theme.textTheme.h1.copyWith(fontSize: 38),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!session.isAnswerRevealed)
            ShadButton.secondary(
              key: const Key('review-reveal-answer'),
              width: double.infinity,
              height: AppLayout.controlHeight,
              onPressed: onRevealAnswer,
              leading: const Icon(LucideIcons.eye, size: 16),
              child: const Text('Reveal'),
            )
          else ...[
            const ShadSeparator.horizontal(),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Column(
                children: [
                  Text(item.pinyin, style: theme.textTheme.large),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.english, style: theme.textTheme.muted),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevealedPhrase extends StatelessWidget {
  const _RevealedPhrase({required this.item});

  final CourseKnowledgeItem item;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      children: [
        HanziPinyinText(
          key: const Key('review-revealed-phrase'),
          hanzi: item.hanzi,
          pinyinSyllables: item.pinyinSyllables,
          pinyinColor: theme.colorScheme.mutedForeground,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(item.english, style: theme.textTheme.muted),
      ],
    );
  }
}
