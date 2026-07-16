import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/content/course_content_models.dart';
import '../application/lesson_providers.dart';
import 'hanzi_pinyin_text.dart';

class LessonOverviewPage extends ConsumerWidget {
  const LessonOverviewPage({required this.lessonId, super.key});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(lessonContentProvider(lessonId));
    return content.when(
      loading: () => const _LessonLoadingPage(),
      error: (error, stackTrace) => _LessonErrorPage(
        onRetry: () => ref.invalidate(lessonContentProvider(lessonId)),
      ),
      data: (content) =>
          _LessonPlayerPage(lessonId: lessonId, content: content),
    );
  }
}

class _LessonLoadingPage extends StatelessWidget {
  const _LessonLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('lesson-loading-page'),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Preparing your café mission…'),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonErrorPage extends StatelessWidget {
  const _LessonErrorPage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('lesson-error-page'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  'This lesson could not be opened.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your journey is still safe. Try loading the bundled lesson again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonPlayerPage extends ConsumerWidget {
  const _LessonPlayerPage({required this.lessonId, required this.content});

  final String lessonId;
  final LessonContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = lessonPlayerControllerProvider(lessonId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final lesson = content.lesson;
    final step = lesson.steps[state.stepIndex];
    final presentation = _presentationFor(
      context,
      content.package,
      lesson,
      step,
      state,
      controller,
    );

    return Scaffold(
      key: const Key('lesson-overview-page'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                _LessonHeader(
                  lesson: lesson,
                  stepIndex: state.stepIndex,
                  onBack: () {
                    if (state.stepIndex == 0) {
                      context.go('/');
                    } else {
                      controller.previous();
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          presentation.eyebrow,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: presentation.eyebrowColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          presentation.title ?? step.title ?? lesson.title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        presentation.body,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: FilledButton(
                    key: const Key('lesson-primary-action'),
                    onPressed: presentation.onPrimary,
                    child: Text(presentation.primaryLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StepPresentation _presentationFor(
    BuildContext context,
    CoursePackage package,
    CourseLesson lesson,
    CourseLessonStep step,
    LessonPlayerState state,
    LessonPlayerController controller,
  ) {
    void next() => controller.next(lesson.steps.length);
    switch (step.type) {
      case 'scene_intro':
        return _StepPresentation(
          eyebrow: 'YOUR MISSION',
          body: _SceneIntro(step: step),
          primaryLabel: "I'm ready",
          onPrimary: next,
        );
      case 'teach_card':
        final item = package.knowledgeItem(step.itemId!);
        return _StepPresentation(
          eyebrow: (step.dimension ?? 'meaning').toUpperCase(),
          body: _TeachCard(
            item: item,
            lessonItems: lesson.itemIds
                .take(2)
                .map(package.knowledgeItem)
                .toList(growable: false),
            supportText: step.text,
          ),
          primaryLabel: 'Got it',
          onPrimary: next,
        );
      case 'listen_choice':
        final selected = state.selectedOptionId;
        final correct = selected == step.itemId;
        return _StepPresentation(
          eyebrow: 'LISTENING',
          body: _ListenChoice(
            package: package,
            step: step,
            selectedOptionId: selected,
            onSelected: controller.selectOption,
          ),
          primaryLabel: selected == null
              ? 'Choose an answer'
              : correct
              ? 'Continue'
              : 'Try again',
          onPrimary: selected == null
              ? null
              : correct
              ? next
              : controller.retryChoice,
        );
      case 'repeat':
        final item = package.knowledgeItem(step.itemId!);
        if (state.showSpeakingFallback) {
          return _StepPresentation(
            eyebrow: 'SPEAKING SUPPORT',
            title: 'Speech check is unavailable',
            eyebrowColor: const Color(0xFFE68A00),
            body: _SpeakingFallback(
              item: item,
              selected: state.selfCheck,
              onSelected: controller.selectSelfCheck,
            ),
            primaryLabel: 'Continue with self-check',
            onPrimary: state.selfCheck == null ? null : next,
          );
        }
        return _StepPresentation(
          eyebrow: 'TONE · SPEAKING',
          body: _RepeatStep(item: item, tip: step.text),
          primaryLabel: '●  Start recording',
          onPrimary: controller.useSpeakingFallback,
        );
      case 'dialogue_turn':
        final dialogue = package.dialogue(step.dialogueId!);
        return _StepPresentation(
          eyebrow: 'THE CHALLENGE',
          body: _DialogueStep(
            package: package,
            dialogue: dialogue,
            supportText: step.text,
          ),
          primaryLabel: 'Send reply',
          onPrimary: next,
        );
      case 'summary':
        return _StepPresentation(
          eyebrow: 'MISSION COMPLETE',
          body: _SummaryStep(supportText: step.text),
          primaryLabel: 'Back to journey',
          onPrimary: () => context.go('/'),
        );
      default:
        return _StepPresentation(
          eyebrow: 'LESSON',
          body: Text('Unsupported lesson step: ${step.type}'),
          primaryLabel: 'Continue',
          onPrimary: next,
        );
    }
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.lesson,
    required this.stepIndex,
    required this.onBack,
  });

  final CourseLesson lesson;
  final int stepIndex;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.outlined(
                  key: const Key('lesson-back-action'),
                  onPressed: onBack,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  'LESSON 1 · ${lesson.locationId.toUpperCase()}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Text('${stepIndex + 1} / ${lesson.steps.length}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  for (var index = 0; index < lesson.steps.length; index++) ...[
                    Expanded(
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: index <= stepIndex ? 12 : 8,
                          height: index <= stepIndex ? 12 : 8,
                          decoration: BoxDecoration(
                            color: index <= stepIndex
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFFE0DBCF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneIntro extends StatelessWidget {
  const _SceneIntro({required this.step});

  final CourseLessonStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.text ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8E2A7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 24,
                child: Chip(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  label: const Text(
                    'CAFÉ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Positioned(
                top: 80,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 52, vertical: 20),
                    child: Text(
                      '你好！',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 56,
                child: Text('☕', style: TextStyle(fontSize: 42)),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFF956139),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Tap continue to learn what to say.'),
      ],
    );
  }
}

class _TeachCard extends StatelessWidget {
  const _TeachCard({
    required this.item,
    required this.lessonItems,
    required this.supportText,
  });

  final CourseKnowledgeItem item;
  final List<CourseKnowledgeItem> lessonItems;
  final String? supportText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(item.kind == 'phrase' ? 'PHRASE 1' : 'WORD 1'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: HanziPinyinText(
                    hanzi: item.hanzi,
                    pinyinSyllables: item.pinyinSyllables,
                    hanziFontSize: 54,
                    pinyinFontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(item.english),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filled(
                    tooltip: 'Play example',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Course audio will be added in the audio module.',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F0D6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            lessonItems.map((entry) => entry.hanzi).join('  +  '),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 14),
        Text(supportText ?? ''),
      ],
    );
  }
}

class _ListenChoice extends StatelessWidget {
  const _ListenChoice({
    required this.package,
    required this.step,
    required this.selectedOptionId,
    required this.onSelected,
  });

  final CoursePackage package;
  final CourseLessonStep step;
  final String? selectedOptionId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIsCorrect = selectedOptionId == step.itemId;
    return Column(
      children: [
        Material(
          color: const Color(0xFFC7EEDD),
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            key: const Key('replay-order-action'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Course audio will be added in the audio module.',
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(22),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(child: Icon(Icons.play_arrow_rounded)),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Replay the order',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text('Played once'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final itemId in step.optionItemIds) ...[
          _AnswerCard(
            item: package.knowledgeItem(itemId),
            selected: selectedOptionId == itemId,
            correct: itemId == step.itemId,
            revealResult: selectedOptionId != null,
            onTap: () => onSelected(itemId),
          ),
          const SizedBox(height: 12),
        ],
        if (selectedOptionId != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: selectedIsCorrect
                  ? const Color(0xFFC7EEDD)
                  : const Color(0xFFFFE4E1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              selectedIsCorrect
                  ? 'That is the complete café order.'
                  : 'Not quite — you heard a full order, not only “I want.”',
            ),
          ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.item,
    required this.selected,
    required this.correct,
    required this.revealResult,
    required this.onTap,
  });

  final CourseKnowledgeItem item;
  final bool selected;
  final bool correct;
  final bool revealResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final resultColor = selected && revealResult
        ? correct
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error
        : const Color(0xFFE0DBCF);
    return Material(
      color: selected && revealResult && !correct
          ? const Color(0xFFFFE9E6)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: resultColor, width: selected ? 2 : 1),
      ),
      child: InkWell(
        key: Key('listen-option-${item.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Center(
            child: HanziPinyinText(
              hanzi: item.hanzi,
              pinyinSyllables: item.pinyinSyllables,
              hanziFontSize: 20,
              pinyinFontSize: 11,
              pinyinColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _RepeatStep extends StatelessWidget {
  const _RepeatStep({required this.item, required this.tip});

  final CourseKnowledgeItem item;
  final String? tip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Center(
                  child: HanziPinyinText(
                    hanzi: item.hanzi,
                    pinyinSyllables: item.pinyinSyllables,
                    hanziFontSize: 30,
                  ),
                ),
                const SizedBox(height: 18),
                Text(item.english),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 86,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFC7EEDD),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.graphic_eq_rounded, size: 58),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F0D6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tone tip',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(tip ?? ''),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Microphone is used only for this practice.'),
      ],
    );
  }
}

class _SpeakingFallback extends StatelessWidget {
  const _SpeakingFallback({
    required this.item,
    required this.selected,
    required this.onSelected,
  });

  final CourseKnowledgeItem item;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8B6),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Text(
            'You can still finish this lesson.\nListen, record locally, then judge your own attempt.',
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                HanziPinyinText(
                  hanzi: item.hanzi,
                  pinyinSyllables: item.pinyinSyllables,
                  hanziFontSize: 28,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Course audio will be added in the audio module.',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play example'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F0D6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How did that sound?',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('self-check-needs-practice'),
                      onPressed: () => onSelected('needs-practice'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selected == 'needs-practice'
                            ? const Color(0xFFC7EEDD)
                            : Colors.white,
                      ),
                      child: const Text('Needs practice'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('self-check-sounded-close'),
                      onPressed: () => onSelected('sounded-close'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selected == 'sounded-close'
                            ? const Color(0xFFC7EEDD)
                            : Colors.white,
                      ),
                      child: const Text('Sounded close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogueStep extends StatelessWidget {
  const _DialogueStep({
    required this.package,
    required this.dialogue,
    required this.supportText,
  });

  final CoursePackage package;
  final CourseDialogue dialogue;
  final String? supportText;

  @override
  Widget build(BuildContext context) {
    final prompt = dialogue.node(dialogue.startNodeId);
    final learnerNode = dialogue.node(prompt.nextNodeId!);
    final answer = package.knowledgeItem(learnerNode.itemId!);
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Row(
                  children: [
                    CircleAvatar(child: Text('☕')),
                    SizedBox(width: 14),
                    Text(
                      'BARISTA',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                HanziPinyinText(
                  hanzi: prompt.text!,
                  pinyinSyllables: prompt.pinyinSyllables,
                  hanziFontSize: 21,
                  pinyinFontSize: 10,
                  pinyinColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 14),
                const Text('Hello, what would you like to drink?'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F0D6),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR ORDER',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Center(
                child: HanziPinyinText(
                  hanzi: answer.hanzi,
                  pinyinSyllables: answer.pinyinSyllables,
                  hanziFontSize: 27,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.circle,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFC7EEDD),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(supportText ?? ''),
        ),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.supportText});

  final String? supportText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFC7EEDD),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 38,
                child: Text('☕', style: TextStyle(fontSize: 30)),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAFÉ STAMP',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    Text('You handled your first real-world order.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "TODAY'S STARS",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const _StarCard(
          title: 'Understanding',
          description: 'You chose the right meaning.',
          earned: true,
        ),
        const _StarCard(
          title: 'Speaking',
          description: 'You completed the café reply.',
          earned: true,
        ),
        const _StarCard(
          title: 'Memory',
          description: "Available after tomorrow's review.",
          earned: false,
        ),
        const SizedBox(height: 8),
        Text(supportText ?? ''),
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
    return Card(
      color: earned ? Colors.white : const Color(0xFFF7F0D6),
      child: ListTile(
        leading: Icon(
          earned ? Icons.star_rounded : Icons.star_border_rounded,
          color: earned ? const Color(0xFFF5AF3D) : const Color(0xFFD8D3C8),
          size: 34,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(description),
      ),
    );
  }
}

final class _StepPresentation {
  const _StepPresentation({
    required this.eyebrow,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.title,
    this.eyebrowColor = const Color(0xFF1F6B55),
  });

  final String eyebrow;
  final String? title;
  final Color eyebrowColor;
  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
}
