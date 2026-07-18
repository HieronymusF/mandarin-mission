import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_core/learning_core.dart';

import '../../../data/content/course_content_models.dart';
import '../../../data/content/course_content_provider.dart';
import '../../../data/local/app_database_provider.dart';
import '../../../data/progress/lesson_progress_repository.dart';
import '../../../data/review/review_queue_repository.dart';

const reviewSessionLimit = 8;

typedef UtcNow = DateTime Function();

final reviewNowProvider = Provider<UtcNow>(
  (ref) =>
      () => DateTime.now().toUtc(),
);

final reviewSchedulerProvider = Provider<ReviewScheduler>(
  (ref) => const ReviewScheduler(),
);

final reviewQueueRepositoryProvider = Provider<ReviewQueueDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ReviewQueueRepository(database, LessonProgressRepository(database));
});

final dueReviewSummaryProvider = FutureProvider.autoDispose<ReviewQueueSummary>(
  (ref) async {
    final dueItems = await ref
        .read(reviewQueueRepositoryProvider)
        .dueItems(now: ref.read(reviewNowProvider)(), limit: 100);
    return ReviewQueueSummary(dueCount: dueItems.length);
  },
);

final reviewSessionControllerProvider =
    AsyncNotifierProvider.autoDispose<
      ReviewSessionController,
      ReviewSessionState
    >(ReviewSessionController.new);

final class ReviewQueueSummary {
  const ReviewQueueSummary({required this.dueCount});

  final int dueCount;

  int get requiredCount => math.min(dueCount, reviewSessionLimit);
  int get extraCount => math.max(0, dueCount - reviewSessionLimit);
  bool get hasDueItems => dueCount > 0;
}

final class ReviewSessionEntry {
  const ReviewSessionEntry({
    required this.queueItem,
    required this.knowledgeItem,
    required this.options,
    required this.audioAvailable,
  });

  final ReviewQueueItem queueItem;
  final CourseKnowledgeItem knowledgeItem;
  final List<CourseKnowledgeItem> options;
  final bool audioAvailable;

  ReviewSessionEntry retry() {
    return ReviewSessionEntry(
      queueItem: queueItem.copyWith(
        sameDayRetryCount: queueItem.sameDayRetryCount + 1,
      ),
      knowledgeItem: knowledgeItem,
      options: options,
      audioAvailable: audioAvailable,
    );
  }
}

final class ReviewSubmissionDraft {
  const ReviewSubmissionDraft({
    required this.rating,
    required this.correct,
    required this.usedHint,
    required this.latencyMs,
    required this.answeredAt,
  });

  final ReviewRating rating;
  final bool correct;
  final bool usedHint;
  final int latencyMs;
  final DateTime answeredAt;
}

final class ReviewSessionState {
  ReviewSessionState({
    required this.contentVersion,
    required this.items,
    required this.hasExtra,
    required this.promptStartedAt,
    this.currentIndex = 0,
    this.selectedOptionId,
    this.isAnswerRevealed = false,
    this.usedHint = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.pendingSubmission,
    this.loadErrorMessage,
    this.forgottenCount = 0,
    this.vagueCount = 0,
    this.rememberedCount = 0,
  });

  final String contentVersion;
  final List<ReviewSessionEntry> items;
  final bool hasExtra;
  final int currentIndex;
  final String? selectedOptionId;
  final bool isAnswerRevealed;
  final bool usedHint;
  final bool isSubmitting;
  final String? errorMessage;
  final ReviewSubmissionDraft? pendingSubmission;
  final String? loadErrorMessage;
  final DateTime promptStartedAt;
  final int forgottenCount;
  final int vagueCount;
  final int rememberedCount;

  static const _unset = Object();

  ReviewSessionEntry? get current =>
      currentIndex < items.length ? items[currentIndex] : null;
  bool get isEmpty => items.isEmpty;
  bool get hasLoadError => loadErrorMessage != null;
  bool get isComplete => items.isNotEmpty && currentIndex >= items.length;
  int get completedCount => math.min(currentIndex, items.length);
  bool get canRate => isAnswerRevealed && !isSubmitting;

  ReviewSessionState copyWith({
    List<ReviewSessionEntry>? items,
    int? currentIndex,
    Object? selectedOptionId = _unset,
    bool? isAnswerRevealed,
    bool? usedHint,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    Object? pendingSubmission = _unset,
    Object? loadErrorMessage = _unset,
    DateTime? promptStartedAt,
    int? forgottenCount,
    int? vagueCount,
    int? rememberedCount,
  }) {
    return ReviewSessionState(
      contentVersion: contentVersion,
      items: items ?? this.items,
      hasExtra: hasExtra,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOptionId: identical(selectedOptionId, _unset)
          ? this.selectedOptionId
          : selectedOptionId as String?,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      usedHint: usedHint ?? this.usedHint,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      pendingSubmission: identical(pendingSubmission, _unset)
          ? this.pendingSubmission
          : pendingSubmission as ReviewSubmissionDraft?,
      loadErrorMessage: identical(loadErrorMessage, _unset)
          ? this.loadErrorMessage
          : loadErrorMessage as String?,
      promptStartedAt: promptStartedAt ?? this.promptStartedAt,
      forgottenCount: forgottenCount ?? this.forgottenCount,
      vagueCount: vagueCount ?? this.vagueCount,
      rememberedCount: rememberedCount ?? this.rememberedCount,
    );
  }
}

final class ReviewSessionController extends AsyncNotifier<ReviewSessionState> {
  @override
  Future<ReviewSessionState> build() async {
    final now = ref.read(reviewNowProvider)();
    try {
      final contentFuture = ref
          .read(courseContentRepositoryProvider)
          .loadPackage();
      final dueFuture = ref
          .read(reviewQueueRepositoryProvider)
          .dueItems(now: now, limit: reviewSessionLimit + 1);
      final results = await Future.wait<Object>([contentFuture, dueFuture]);
      final package = results[0] as CoursePackage;
      final dueItems = results[1] as List<ReviewQueueItem>;
      final sessionItems = dueItems
          .take(reviewSessionLimit)
          .map((item) => _entryFor(package, item))
          .toList(growable: true);

      return ReviewSessionState(
        contentVersion: package.version,
        items: sessionItems,
        hasExtra: dueItems.length > reviewSessionLimit,
        promptStartedAt: now,
      );
    } on Object {
      return ReviewSessionState(
        contentVersion: '',
        items: const [],
        hasExtra: false,
        promptStartedAt: now,
        loadErrorMessage: 'Reviews could not be loaded.',
      );
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  void selectOption(String itemId) {
    final session = state.value;
    final current = session?.current;
    if (session == null ||
        current == null ||
        session.isSubmitting ||
        session.isAnswerRevealed ||
        current.queueItem.dimension != LearningDimension.meaning) {
      return;
    }
    state = AsyncData(
      session.copyWith(
        selectedOptionId: itemId,
        isAnswerRevealed: true,
        errorMessage: null,
        pendingSubmission: null,
      ),
    );
  }

  void revealAnswer() {
    final session = state.value;
    final current = session?.current;
    if (session == null ||
        current == null ||
        session.isSubmitting ||
        session.isAnswerRevealed) {
      return;
    }
    state = AsyncData(
      session.copyWith(
        isAnswerRevealed: true,
        usedHint:
            current.queueItem.dimension == LearningDimension.listening &&
            !current.audioAvailable,
        errorMessage: null,
        pendingSubmission: null,
      ),
    );
  }

  Future<void> submitRating(ReviewRating rating) async {
    final session = state.value;
    final current = session?.current;
    if (session == null ||
        current == null ||
        !session.canRate ||
        session.pendingSubmission != null) {
      return;
    }

    final answeredAt = ref.read(reviewNowProvider)();
    final objectiveCorrect =
        current.queueItem.dimension != LearningDimension.meaning ||
        session.selectedOptionId == current.knowledgeItem.id;
    final draft = ReviewSubmissionDraft(
      rating: rating,
      correct: rating != ReviewRating.forgotten && objectiveCorrect,
      usedHint: session.usedHint,
      latencyMs: math.max(
        0,
        answeredAt.difference(session.promptStartedAt).inMilliseconds,
      ),
      answeredAt: answeredAt,
    );
    await _submitDraft(draft);
  }

  Future<void> retrySubmission() async {
    final session = state.value;
    final draft = session?.pendingSubmission;
    if (session == null || draft == null || session.isSubmitting) {
      return;
    }
    await _submitDraft(draft);
  }

  Future<void> _submitDraft(ReviewSubmissionDraft draft) async {
    final session = state.value;
    final current = session?.current;
    if (session == null || current == null || session.isSubmitting) {
      return;
    }

    state = AsyncData(
      session.copyWith(
        isSubmitting: true,
        errorMessage: null,
        pendingSubmission: draft,
      ),
    );
    try {
      await ref
          .read(reviewQueueRepositoryProvider)
          .submitAttempt(
            item: current.queueItem,
            contentVersion: session.contentVersion,
            rating: draft.rating,
            correct: draft.correct,
            usedHint: draft.usedHint,
            latencyMs: draft.latencyMs,
            answeredAt: draft.answeredAt,
          );

      final updatedItems = List<ReviewSessionEntry>.of(session.items);
      if (draft.rating == ReviewRating.forgotten &&
          current.queueItem.sameDayRetryCount < 2) {
        updatedItems.add(current.retry());
      }
      state = AsyncData(
        ReviewSessionState(
          contentVersion: session.contentVersion,
          items: updatedItems,
          hasExtra: session.hasExtra,
          currentIndex: session.currentIndex + 1,
          promptStartedAt: ref.read(reviewNowProvider)(),
          forgottenCount:
              session.forgottenCount +
              (draft.rating == ReviewRating.forgotten ? 1 : 0),
          vagueCount:
              session.vagueCount + (draft.rating == ReviewRating.vague ? 1 : 0),
          rememberedCount:
              session.rememberedCount +
              (draft.rating == ReviewRating.remembered ? 1 : 0),
        ),
      );
      ref.invalidate(dueReviewSummaryProvider);
    } on Object {
      state = AsyncData(
        session.copyWith(
          isSubmitting: false,
          errorMessage: 'Your review was not saved. Try again.',
          pendingSubmission: draft,
        ),
      );
    }
  }

  ReviewSessionEntry _entryFor(
    CoursePackage package,
    ReviewQueueItem queueItem,
  ) {
    final knowledgeItem = package.knowledgeItem(queueItem.itemId);
    final options = <CourseKnowledgeItem>[knowledgeItem];
    for (final candidate in package.knowledgeItemsById.values) {
      if (candidate.id != knowledgeItem.id && options.length < 3) {
        options.add(candidate);
      }
    }
    if (options.length > 1) {
      final shift = package.knowledgeItemsById.keys.toList().indexOf(
        knowledgeItem.id,
      );
      if (shift.isOdd) {
        options.add(options.removeAt(0));
      }
    }
    return ReviewSessionEntry(
      queueItem: queueItem,
      knowledgeItem: knowledgeItem,
      options: List.unmodifiable(options),
      audioAvailable: false,
    );
  }
}
