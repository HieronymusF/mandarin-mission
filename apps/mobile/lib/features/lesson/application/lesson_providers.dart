import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_core/learning_core.dart';

import '../../../data/content/course_content_models.dart';
import '../../../data/content/course_content_provider.dart';
import '../../../data/local/app_database_provider.dart';
import '../../../data/progress/lesson_progress_repository.dart';

final lessonProgressRepositoryProvider = Provider<LessonProgressRepository>(
  (ref) => LessonProgressRepository(ref.watch(appDatabaseProvider)),
);

final lessonContentProvider = FutureProvider.family<LessonContent, String>((
  ref,
  lessonId,
) async {
  final package = await ref.read(courseContentRepositoryProvider).loadPackage();
  final lesson = package.lesson(lessonId);
  await ref
      .read(lessonProgressRepositoryProvider)
      .startLesson(
        lessonId: lessonId,
        contentVersion: package.version,
        startedAt: DateTime.now().toUtc(),
      );
  return LessonContent(package: package, lesson: lesson);
});

final lessonPlayerControllerProvider = NotifierProvider.autoDispose
    .family<LessonPlayerController, LessonPlayerState, String>(
      LessonPlayerController.new,
    );

final class LessonContent {
  const LessonContent({required this.package, required this.lesson});

  final CoursePackage package;
  final CourseLesson lesson;
}

final class LessonPlayerState {
  LessonPlayerState({
    this.stepIndex = 0,
    this.selectedOptionId,
    this.showSpeakingFallback = false,
    this.selfCheck,
    this.incorrectAttempts = 0,
    this.usedListeningHint = false,
    this.speakingNeedsPractice = false,
    this.isSubmitting = false,
    this.errorMessage,
    DateTime? stepEnteredAt,
  }) : stepEnteredAt = stepEnteredAt ?? DateTime.now().toUtc();

  final int stepIndex;
  final String? selectedOptionId;
  final bool showSpeakingFallback;
  final String? selfCheck;
  final int incorrectAttempts;
  final bool usedListeningHint;
  final bool speakingNeedsPractice;
  final bool isSubmitting;
  final String? errorMessage;
  final DateTime stepEnteredAt;

  static const _unset = Object();

  LessonPlayerState copyWith({
    int? stepIndex,
    Object? selectedOptionId = _unset,
    bool? showSpeakingFallback,
    Object? selfCheck = _unset,
    int? incorrectAttempts,
    bool? usedListeningHint,
    bool? speakingNeedsPractice,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    DateTime? stepEnteredAt,
  }) {
    return LessonPlayerState(
      stepIndex: stepIndex ?? this.stepIndex,
      selectedOptionId: identical(selectedOptionId, _unset)
          ? this.selectedOptionId
          : selectedOptionId as String?,
      showSpeakingFallback: showSpeakingFallback ?? this.showSpeakingFallback,
      selfCheck: identical(selfCheck, _unset)
          ? this.selfCheck
          : selfCheck as String?,
      incorrectAttempts: incorrectAttempts ?? this.incorrectAttempts,
      usedListeningHint: usedListeningHint ?? this.usedListeningHint,
      speakingNeedsPractice:
          speakingNeedsPractice ?? this.speakingNeedsPractice,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      stepEnteredAt: stepEnteredAt ?? this.stepEnteredAt,
    );
  }

  int latencyMs(DateTime answeredAt) {
    return math.max(0, answeredAt.difference(stepEnteredAt).inMilliseconds);
  }

  int get score {
    final speakingPenalty = speakingNeedsPractice ? 20 : 0;
    return (100 - (incorrectAttempts * 20) - speakingPenalty).clamp(0, 100);
  }
}

final class LessonPlayerController extends Notifier<LessonPlayerState> {
  LessonPlayerController(this.lessonId);

  final String lessonId;

  @override
  LessonPlayerState build() => LessonPlayerState();

  void next(int stepCount) {
    state = LessonPlayerState(
      stepIndex: math.min(state.stepIndex + 1, stepCount - 1),
      incorrectAttempts: state.incorrectAttempts,
      speakingNeedsPractice:
          state.speakingNeedsPractice || state.selfCheck == 'needs-practice',
    );
  }

  void previous() {
    state = LessonPlayerState(
      stepIndex: math.max(state.stepIndex - 1, 0),
      incorrectAttempts: state.incorrectAttempts,
      speakingNeedsPractice: state.speakingNeedsPractice,
    );
  }

  void selectOption(String itemId) {
    if (state.isSubmitting) return;
    state = state.copyWith(selectedOptionId: itemId, errorMessage: null);
  }

  void _retryChoice() {
    state = state.copyWith(
      selectedOptionId: null,
      incorrectAttempts: state.incorrectAttempts + 1,
      usedListeningHint: true,
      isSubmitting: false,
      errorMessage: null,
      stepEnteredAt: DateTime.now().toUtc(),
    );
  }

  void useSpeakingFallback() {
    state = state.copyWith(showSpeakingFallback: true, errorMessage: null);
  }

  void selectSelfCheck(String value) {
    if (state.isSubmitting) return;
    state = state.copyWith(
      showSpeakingFallback: true,
      selfCheck: value,
      errorMessage: null,
    );
  }

  Future<bool> submitListenChoice({
    required CoursePackage package,
    required CourseLesson lesson,
    required CourseLessonStep step,
  }) async {
    final selectedOptionId = state.selectedOptionId;
    if (selectedOptionId == null || state.isSubmitting) return false;

    final answeredAt = DateTime.now().toUtc();
    final correct = selectedOptionId == step.itemId;
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref
          .read(lessonProgressRepositoryProvider)
          .recordExerciseAttempt(
            lessonId: lesson.id,
            stepId: step.id,
            contentVersion: package.version,
            itemId: step.itemId!,
            dimension: lessonDimension(step.dimension!),
            rating: correct ? ReviewRating.remembered : ReviewRating.forgotten,
            correct: correct,
            usedHint: state.usedListeningHint,
            latencyMs: state.latencyMs(answeredAt),
            answeredAt: answeredAt,
          );
      if (correct) {
        next(lesson.steps.length);
      } else {
        _retryChoice();
      }
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Your answer was not saved. Try again.',
      );
      return false;
    }
  }

  Future<bool> submitSpeakingSelfCheck({
    required CoursePackage package,
    required CourseLesson lesson,
    required CourseLessonStep step,
  }) async {
    final selfCheck = state.selfCheck;
    if (selfCheck == null || state.isSubmitting) return false;

    final answeredAt = DateTime.now().toUtc();
    final soundedClose = selfCheck == 'sounded-close';
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref
          .read(lessonProgressRepositoryProvider)
          .recordSpeakingAttempt(
            lessonId: lesson.id,
            stepId: step.id,
            contentVersion: package.version,
            targetId: step.itemId!,
            rating: soundedClose
                ? ReviewRating.remembered
                : ReviewRating.forgotten,
            correct: soundedClose,
            localScore: soundedClose ? 1 : 0,
            latencyMs: state.latencyMs(answeredAt),
            answeredAt: answeredAt,
          );
      next(lesson.steps.length);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Your self-check was not saved. Try again.',
      );
      return false;
    }
  }

  Future<bool> completeLesson({
    required CoursePackage package,
    required CourseLesson lesson,
  }) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref
          .read(lessonProgressRepositoryProvider)
          .completeLesson(
            lessonId: lesson.id,
            itemIds: lesson.itemIds,
            contentVersion: package.version,
            score: state.score,
            completedAt: DateTime.now().toUtc(),
          );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'The lesson could not be finished. Try again.',
      );
      return false;
    }
  }
}

LearningDimension lessonDimension(String value) {
  return LearningDimension.values.byName(value);
}
