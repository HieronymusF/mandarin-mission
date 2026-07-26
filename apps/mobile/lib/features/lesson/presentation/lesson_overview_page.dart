import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_layout.dart';
import '../../../data/audio/audio_providers.dart';
import '../../../data/content/course_content_models.dart';
import '../../../shared/presentation/app_leading_row.dart';
import '../application/lesson_providers.dart';
import 'lesson_header.dart';
import 'steps/dialogue_step.dart';
import 'steps/hanzi_writing_step.dart';
import 'steps/image_choice_step.dart';
import 'steps/listen_choice_step.dart';
import 'steps/order_tokens_step.dart';
import 'steps/repeat_step.dart';
import 'steps/scene_intro_step.dart';
import 'steps/summary_step.dart';
import 'steps/teach_card_step.dart';
import 'steps/tone_contrast_step.dart';

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
    final theme = ShadTheme.of(context);
    return Scaffold(
      key: const Key('lesson-loading-page'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.loadingMaxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShadProgress(
                  semanticsLabel: 'Preparing lesson',
                  minHeight: 6,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Preparing your café mission…',
                  style: theme.textTheme.muted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
    final theme = ShadTheme.of(context);
    return Scaffold(
      key: const Key('lesson-error-page'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.errorMaxWidth,
              ),
              child: ShadCard(
                width: double.infinity,
                padding: AppLayout.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppLeadingRow(
                      leadingWidth: AppLayout.listIconSlot,
                      gap: AppSpacing.sm,
                      leading: Icon(
                        LucideIcons.cloudOff,
                        size: AppLayout.noticeIconSlot,
                        color: theme.colorScheme.destructive,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This lesson could not be opened.',
                            style: theme.textTheme.h3,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Your journey is still safe. Try loading the bundled lesson again.',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ShadButton(
                      height: AppLayout.controlHeight,
                      onPressed: onRetry,
                      leading: const Icon(LucideIcons.rotateCcw, size: 16),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonPlayerPage extends ConsumerStatefulWidget {
  const _LessonPlayerPage({required this.lessonId, required this.content});

  final String lessonId;
  final LessonContent content;

  @override
  ConsumerState<_LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends ConsumerState<_LessonPlayerPage>
    with WidgetsBindingObserver {
  Future<void>? _mediaCleanup;
  late final Future<void> Function() _endMediaSessionAction;
  late final Future<void> Function() _refreshRecordingPermissionAction;

  @override
  void initState() {
    super.initState();
    _endMediaSessionAction = ref
        .read(recordingControllerProvider.notifier)
        .endSession;
    _refreshRecordingPermissionAction = ref
        .read(recordingControllerProvider.notifier)
        .refreshPermissionState;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshRecordingPermissionAction());
      return;
    }
    unawaited(_endMediaSession());
  }

  Future<void> _endMediaSession() {
    if (_mediaCleanup != null) return _mediaCleanup!;

    final cleanup = _endMediaSessionAction();
    _mediaCleanup = cleanup;
    unawaited(
      cleanup.whenComplete(() {
        if (identical(_mediaCleanup, cleanup)) {
          _mediaCleanup = null;
        }
      }),
    );
    return cleanup;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_endMediaSession());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final provider = lessonPlayerControllerProvider(widget.lessonId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final lesson = widget.content.lesson;
    final step = lesson.steps[state.stepIndex];
    final presentation = _presentationFor(
      context,
      widget.content.package,
      lesson,
      step,
      state,
      controller,
    );
    final primaryEnabled =
        presentation.onPrimary != null && !state.isSubmitting;

    return Scaffold(
      key: const Key('lesson-overview-page'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('lesson-content-frame'),
            constraints: const BoxConstraints(
              maxWidth: AppLayout.contentMaxWidth,
            ),
            child: Column(
              children: [
                LessonHeader(
                  lesson: lesson,
                  locationTitle: widget.content.package
                      .location(lesson.locationId)
                      .title,
                  stepIndex: state.stepIndex,
                  onBack: () async {
                    await _endMediaSession();
                    if (!context.mounted) return;
                    if (state.stepIndex == 0) {
                      context.go('/');
                    } else {
                      controller.previous();
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppLayout.lessonBodyPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShadBadge.secondary(child: Text(presentation.eyebrow)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          presentation.title ?? step.title ?? lesson.title,
                          style: theme.textTheme.h2,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        presentation.body,
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          ShadCard(
                            width: double.infinity,
                            padding: AppLayout.compactCardPadding,
                            backgroundColor: theme.colorScheme.destructive
                                .withValues(alpha: .10),
                            border: ShadBorder.none,
                            child: AppLeadingRow(
                              leadingWidth: AppLayout.noticeIconSlot,
                              gap: AppSpacing.sm,
                              leading: Icon(
                                LucideIcons.circleAlert,
                                color: theme.colorScheme.destructive,
                                size: 20,
                              ),
                              child: Text(
                                state.errorMessage!,
                                style: theme.textTheme.small,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: AppLayout.lessonActionPadding,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    border: Border(
                      top: BorderSide(color: theme.colorScheme.border),
                    ),
                  ),
                  child: ShadButton(
                    key: const Key('lesson-primary-action'),
                    width: double.infinity,
                    height: AppLayout.controlHeight,
                    enabled: primaryEnabled,
                    onPressed: primaryEnabled
                        ? () async => presentation.onPrimary!()
                        : null,
                    leading: state.isSubmitting
                        ? SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primaryForeground,
                            ),
                          )
                        : null,
                    child: Text(
                      state.isSubmitting
                          ? 'Saving…'
                          : presentation.primaryLabel,
                    ),
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
          body: SceneIntroStep(
            step: step,
            locationTitle: package.location(lesson.locationId).title,
          ),
          primaryLabel: "I'm ready",
          onPrimary: () async => next(),
        );
      case 'teach_card':
        final item = package.knowledgeItem(step.itemId!);
        return _StepPresentation(
          eyebrow: (step.dimension ?? 'meaning').toUpperCase(),
          body: TeachCardStep(
            item: item,
            audioAssetPath: package.audioAssetPathForItem(item.id),
            supportText: step.text,
          ),
          primaryLabel: 'Got it',
          onPrimary: () async => next(),
        );
      case 'image_choice':
        final selected = state.selectedOptionId;
        final correct = selected == step.itemId;
        return _StepPresentation(
          eyebrow: 'MEANING',
          body: ImageChoiceStep(
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
              : () async {
                  await controller.submitChoice(
                    package: package,
                    lesson: lesson,
                    step: step,
                  );
                },
        );
      case 'hanzi_trace':
        final item = package.knowledgeItem(step.itemId!);
        final selected = state.writingSelfCheck;
        return _StepPresentation(
          eyebrow: 'HANZI · WRITING',
          body: HanziWritingStep(
            key: ValueKey(step.id),
            item: item,
            supportText: step.text,
            selectedSelfCheck: selected,
            onSelfCheckChanged: (value, {required usedHint}) =>
                controller.selectWritingSelfCheck(value, usedHint: usedHint),
          ),
          primaryLabel: selected == null ? 'Write first' : 'Save',
          onPrimary: selected == null
              ? null
              : () async {
                  await controller.submitWritingSelfCheck(
                    package: package,
                    lesson: lesson,
                    step: step,
                  );
                },
        );
      case 'tone_contrast':
        final selected = state.selectedOptionId;
        final targetPinyin = package.knowledgeItem(step.itemId!).pinyin;
        final correct = selected == targetPinyin;
        return _StepPresentation(
          eyebrow: 'TONE · LISTENING',
          body: ToneContrastStep(
            package: package,
            step: step,
            selectedOptionId: selected,
            onSelected: controller.selectOption,
          ),
          primaryLabel: selected == null
              ? 'Choose the tones'
              : correct
              ? 'Continue'
              : 'Try again',
          onPrimary: selected == null
              ? null
              : () async {
                  await controller.submitChoice(
                    package: package,
                    lesson: lesson,
                    step: step,
                    correctOption: targetPinyin,
                  );
                },
        );
      case 'listen_choice':
        final selected = state.selectedOptionId;
        final correct = selected == step.itemId;
        return _StepPresentation(
          eyebrow: 'LISTENING',
          body: ListenChoiceStep(
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
              : () async {
                  await controller.submitChoice(
                    package: package,
                    lesson: lesson,
                    step: step,
                    markListeningHintUsedOnRetry: true,
                  );
                },
        );
      case 'order_tokens':
        final selected = state.orderedTokenIndexes;
        final complete = selected.length == step.tokens.length;
        final correct =
            complete && selected.indexed.every((entry) => entry.$1 == entry.$2);
        return _StepPresentation(
          eyebrow: 'BUILD THE PHRASE',
          body: OrderTokensStep(
            step: step,
            orderedTokenIndexes: selected,
            onToggleToken: controller.toggleOrderToken,
          ),
          primaryLabel: !complete
              ? 'Build the sentence'
              : correct
              ? 'Continue'
              : 'Try again',
          onPrimary: !complete
              ? null
              : () async {
                  await controller.submitOrderTokens(
                    package: package,
                    lesson: lesson,
                    step: step,
                  );
                },
        );
      case 'repeat':
        final item = package.knowledgeItem(step.itemId!);
        if (state.showSpeakingFallback) {
          return _StepPresentation(
            eyebrow: 'SPEAKING SUPPORT',
            title: 'Speech check is unavailable',
            body: SpeakingFallback(
              item: item,
              audioAssetPath: package.audioAssetPathForItem(item.id),
              selected: state.selfCheck,
              onSelected: controller.selectSelfCheck,
            ),
            primaryLabel: 'Continue with self-check',
            onPrimary: state.selfCheck == null
                ? null
                : () async {
                    await controller.submitSpeakingSelfCheck(
                      package: package,
                      lesson: lesson,
                      step: step,
                    );
                  },
          );
        }
        return _StepPresentation(
          eyebrow: 'TONE · SPEAKING',
          body: RepeatStep(
            item: item,
            tip: step.text,
            audioAssetPath: package.audioAssetPathForItem(item.id),
            onRecordingComplete: (_) => controller.useSpeakingFallback(),
          ),
          primaryLabel: 'Continue without recording',
          onPrimary: () async => controller.useSpeakingFallback(),
        );
      case 'dialogue_turn':
        final dialogue = package.dialogue(step.dialogueId!);
        final dialogueNodeId = state.dialogueNodeId ?? dialogue.startNodeId;
        final dialogueComplete =
            dialogue.turnFrom(dialogueNodeId).learnerNode == null;
        final replyMethod = state.dialogueReplyMethod;
        return _StepPresentation(
          eyebrow: 'THE CHALLENGE',
          body: DialogueStep(
            package: package,
            dialogue: dialogue,
            currentNodeId: dialogueNodeId,
            supportText: step.text,
            selectedReplyMethod: replyMethod,
            onReplyMethodChanged: controller.selectDialogueReplyMethod,
          ),
          primaryLabel: dialogueComplete
              ? 'Continue'
              : replyMethod == null
              ? 'Choose how to reply'
              : 'Send reply',
          onPrimary: dialogueComplete
              ? () async => next()
              : replyMethod == null
              ? null
              : () async {
                  controller.advanceDialogue(
                    dialogue: dialogue,
                    stepCount: lesson.steps.length,
                  );
                },
        );
      case 'summary':
        return _StepPresentation(
          eyebrow: 'MISSION COMPLETE',
          body: SummaryStep(supportText: step.text),
          primaryLabel: 'Back to journey',
          onPrimary: () async {
            final completed = await controller.completeLesson(
              package: package,
              lesson: lesson,
            );
            if (completed && context.mounted) {
              ref.invalidate(lessonProgressProvider(lesson.id));
              context.go('/');
            }
          },
        );
      default:
        return _StepPresentation(
          eyebrow: 'LESSON',
          body: Text('Unsupported lesson step: ${step.type}'),
          primaryLabel: 'Continue',
          onPrimary: () async => next(),
        );
    }
  }
}

final class _StepPresentation {
  const _StepPresentation({
    required this.eyebrow,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.title,
  });

  final String eyebrow;
  final String? title;
  final Widget body;
  final String primaryLabel;
  final Future<void> Function()? onPrimary;
}
