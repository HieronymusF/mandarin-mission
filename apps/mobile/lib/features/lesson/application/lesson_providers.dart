import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/content/course_content_models.dart';
import '../../../data/content/course_content_repository.dart';

final courseContentRepositoryProvider = Provider<CourseContentRepository>(
  (ref) => CourseContentRepository(),
);

final lessonContentProvider = FutureProvider.family<LessonContent, String>((
  ref,
  lessonId,
) async {
  final package = await ref.read(courseContentRepositoryProvider).loadPackage();
  return LessonContent(package: package, lesson: package.lesson(lessonId));
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
  const LessonPlayerState({
    this.stepIndex = 0,
    this.selectedOptionId,
    this.showSpeakingFallback = false,
    this.selfCheck,
  });

  final int stepIndex;
  final String? selectedOptionId;
  final bool showSpeakingFallback;
  final String? selfCheck;
}

final class LessonPlayerController extends Notifier<LessonPlayerState> {
  @override
  LessonPlayerState build() => const LessonPlayerState();

  void next(int stepCount) {
    state = LessonPlayerState(
      stepIndex: math.min(state.stepIndex + 1, stepCount - 1),
    );
  }

  void previous() {
    state = LessonPlayerState(stepIndex: math.max(state.stepIndex - 1, 0));
  }

  void selectOption(String itemId) {
    state = LessonPlayerState(
      stepIndex: state.stepIndex,
      selectedOptionId: itemId,
    );
  }

  void retryChoice() {
    state = LessonPlayerState(stepIndex: state.stepIndex);
  }

  void useSpeakingFallback() {
    state = LessonPlayerState(
      stepIndex: state.stepIndex,
      showSpeakingFallback: true,
    );
  }

  void selectSelfCheck(String value) {
    state = LessonPlayerState(
      stepIndex: state.stepIndex,
      showSpeakingFallback: true,
      selfCheck: value,
    );
  }
}
