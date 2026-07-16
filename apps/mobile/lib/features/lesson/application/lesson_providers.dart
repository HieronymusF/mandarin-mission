import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_core/learning_core.dart';

import '../../../data/content/course_content_models.dart';
import '../../../data/content/course_content_repository.dart';
import '../../../data/local/app_database_provider.dart';
import '../../../data/progress/lesson_progress_repository.dart';

final courseContentRepositoryProvider = Provider<CourseContentRepository>(
  (ref) => CourseContentRepository(),
);

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
      (lessonId) => LessonPlayerController(),
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
    DateTime? stepEnteredAt,
  }) : stepEnteredAt = stepEnteredAt ?? DateTime.now().toUtc();

  final int stepIndex;
  final String? selectedOptionId;
  final bool showSpeakingFallback;
  final String? selfCheck;
  final int incorrectAttempts;
  final bool usedListeningHint;
  final bool speakingNeedsPractice;
  final DateTime stepEnteredAt;

  int latencyMs(DateTime answeredAt) {
    return math.max(0, answeredAt.difference(stepEnteredAt).inMilliseconds);
  }

  int get score {
    final speakingPenalty = speakingNeedsPractice ? 20 : 0;
    return (100 - (incorrectAttempts * 20) - speakingPenalty).clamp(0, 100);
  }
}

final class LessonPlayerController extends Notifier<LessonPlayerState> {
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
    state = LessonPlayerState(
      stepIndex: state.stepIndex,
      selectedOptionId: itemId,
      selfCheck: state.selfCheck,
      incorrectAttempts: state.incorrectAttempts,
      usedListeningHint: state.usedListeningHint,
      speakingNeedsPractice: state.speakingNeedsPractice,
      stepEnteredAt: state.stepEnteredAt,
    );
  }

  void retryChoice() {
    state = LessonPlayerState(
      stepIndex: state.stepIndex,
      selfCheck: state.selfCheck,
      incorrectAttempts: state.incorrectAttempts + 1,
      usedListeningHint: true,
      speakingNeedsPractice: state.speakingNeedsPractice,
    );
  }

  void useSpeakingFallback() {
    state = LessonPlayerState(
      stepIndex: state.stepIndex,
      showSpeakingFallback: true,
      selfCheck: state.selfCheck,
      incorrectAttempts: state.incorrectAttempts,
      usedListeningHint: state.usedListeningHint,
      speakingNeedsPractice: state.speakingNeedsPractice,
      stepEnteredAt: state.stepEnteredAt,
    );
  }

  void selectSelfCheck(String value) {
    state = LessonPlayerState(
      stepIndex: state.stepIndex,
      showSpeakingFallback: true,
      selfCheck: value,
      incorrectAttempts: state.incorrectAttempts,
      usedListeningHint: state.usedListeningHint,
      speakingNeedsPractice: state.speakingNeedsPractice,
      stepEnteredAt: state.stepEnteredAt,
    );
  }
}

LearningDimension lessonDimension(String value) {
  return LearningDimension.values.byName(value);
}
