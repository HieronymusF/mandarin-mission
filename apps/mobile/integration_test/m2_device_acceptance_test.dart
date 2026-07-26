import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learning_core/learning_core.dart';
import 'package:mandarin_mission/data/audio/audio_service.dart';
import 'package:mandarin_mission/data/audio/audio_service_impl.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/content/course_content_repository.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';
import 'package:mandarin_mission/data/review/review_queue_repository.dart';
import 'package:mandarin_mission/features/journey/application/journey_progress.dart';
import 'package:mandarin_mission/features/lesson/application/lesson_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'plays all 49 new M2 audio assets to completion',
    (_) async {
      final legacyCafePackage = await CourseContentRepository(
        assetPath: CourseContentRepository.bundledCafeCourseAsset,
      ).loadPackage();
      final m2Package = await CourseContentRepository(
        assetPath: CourseContentRepository.bundledM2CourseAsset,
      ).loadPackage();
      final legacyCafeAudioIds = {
        for (final item in legacyCafePackage.knowledgeItemsById.values)
          item.audioAssetId,
      };
      final newItems = m2Package.knowledgeItemsById.values
          .where((item) => !legacyCafeAudioIds.contains(item.audioAssetId))
          .toList(growable: false);
      final paths = {
        for (final item in newItems) m2Package.audioAssetPathForItem(item.id),
      };

      expect(newItems, hasLength(49));
      expect(paths, hasLength(49));
      expect(paths, isNot(contains(null)));

      final audioService = AudioServiceImpl();
      try {
        expect(await audioService.isAvailable, isTrue);
        await audioService.setVolume(0);
        for (final (index, item) in newItems.indexed) {
          final path = m2Package.audioAssetPathForItem(item.id)!;
          await _playToCompletion(audioService, path);
          debugPrint('M2_AUDIO_PASS ${index + 1}/49 ${item.id} $path');
        }
      } finally {
        await audioService.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'completes the actual 12 lessons, 3 challenges, and one due review',
    (_) async {
      final package = await CourseContentRepository(
        assetPath: CourseContentRepository.bundledM2CourseAsset,
      ).loadPackage();
      final database = AppDatabase(NativeDatabase.memory());
      var container = _containerFor(package, database);

      try {
        for (final (locationIndex, location) in package.locations.indexed) {
          var progress = await _readJourneyProgress(package, database);
          expect(progress.isLocationUnlocked(location), isTrue);
          if (locationIndex + 1 < package.locations.length) {
            expect(
              progress.isLocationUnlocked(package.locations[locationIndex + 1]),
              isFalse,
            );
          }

          for (final lessonId in location.lessonIds) {
            final lesson = package.lesson(lessonId);
            progress = await _readJourneyProgress(package, database);
            expect(progress.isLessonUnlocked(location, lesson), isTrue);
            await _completeThroughController(container, package, lesson);
          }

          progress = await _readJourneyProgress(package, database);
          expect(progress.isChallengeUnlocked(location), isTrue);
          if (locationIndex + 1 < package.locations.length) {
            expect(
              progress.isLocationUnlocked(package.locations[locationIndex + 1]),
              isFalse,
            );
          }

          final challenge = package.locationChallenge(location);
          await _completeThroughController(container, package, challenge);
          progress = await _readJourneyProgress(package, database);
          expect(progress.isCompleted(challenge.id), isTrue);
          if (locationIndex + 1 < package.locations.length) {
            expect(
              progress.isLocationUnlocked(package.locations[locationIndex + 1]),
              isTrue,
            );
          }
          debugPrint('M2_LOCATION_PASS ${location.id}');
        }

        final progressRows = await database
            .select(database.lessonProgressEntries)
            .get();
        expect(progressRows, hasLength(15));
        expect(
          progressRows.every((entry) => entry.status == 'completed'),
          isTrue,
        );

        final taughtItemIds = {
          for (final lesson in package.lessonsById.values) ...lesson.itemIds,
        };
        expect(taughtItemIds, hasLength(52));
        final masteryRows = await database.select(database.masteryStates).get();
        expect(taughtItemIds, equals(package.knowledgeItemsById.keys.toSet()));
        expect(
          masteryRows,
          hasLength(taughtItemIds.length * LearningDimension.values.length),
        );

        final progressRepository = container.read(
          lessonProgressRepositoryProvider,
        );
        final reviewRepository = ReviewQueueRepository(
          database,
          progressRepository,
        );
        final reviewAt = DateTime.now().toUtc().add(const Duration(days: 31));
        final dueItems = await reviewRepository.dueItems(
          now: reviewAt,
          limit: 100,
        );
        expect(dueItems, isNotEmpty);
        final attemptCountBefore = await database
            .select(database.reviewAttempts)
            .get()
            .then((rows) => rows.length);
        await reviewRepository.submitAttempt(
          item: dueItems.first,
          contentVersion: package.version,
          rating: ReviewRating.remembered,
          correct: true,
          usedHint: false,
          latencyMs: 1,
          answeredAt: reviewAt,
        );
        final attemptCountAfter = await database
            .select(database.reviewAttempts)
            .get()
            .then((rows) => rows.length);
        expect(attemptCountAfter, attemptCountBefore + 1);

        container.dispose();
        container = _containerFor(package, database);
        final restored = await container.read(journeyProgressProvider.future);
        for (final location in package.locations) {
          expect(restored.isLocationUnlocked(location), isTrue);
          expect(restored.isChallengeUnlocked(location), isTrue);
          expect(restored.isCompleted(location.challengeId), isTrue);
          for (final lessonId in location.lessonIds) {
            expect(restored.isCompleted(lessonId), isTrue);
          }
        }
        debugPrint(
          'M2_FLOW_PASS 12 lessons, 3 challenges, '
          '${masteryRows.length} mastery states, and 1 due review',
        );
      } finally {
        container.dispose();
        await database.close();
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

ProviderContainer _containerFor(CoursePackage package, AppDatabase database) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      coursePackageProvider.overrideWith((ref) async => package),
    ],
  );
}

Future<JourneyProgress> _readJourneyProgress(
  CoursePackage package,
  AppDatabase database,
) async {
  final progressById = <String, LessonProgressEntry?>{};
  final progressIds = <String>{
    ...package.lessonsById.keys,
    for (final location in package.locations)
      if (package.hasStandaloneChallenge(location)) location.challengeId,
  };
  for (final id in progressIds) {
    progressById[id] = await (database.select(
      database.lessonProgressEntries,
    )..where((entry) => entry.lessonId.equals(id))).getSingleOrNull();
  }
  return JourneyProgress(package: package, progressById: progressById);
}

Future<void> _completeThroughController(
  ProviderContainer container,
  CoursePackage package,
  CourseLesson lesson,
) async {
  final content = await container.read(lessonContentProvider(lesson.id).future);
  expect(content.lesson.id, lesson.id);
  final provider = lessonPlayerControllerProvider(lesson.id);
  final subscription = container.listen<LessonPlayerState>(
    provider,
    (previous, next) {},
    fireImmediately: true,
  );
  final controller = container.read(provider.notifier);

  try {
    for (var actionCount = 0; actionCount < 100; actionCount++) {
      final state = container.read(provider);
      expect(state.errorMessage, isNull);
      final step = lesson.steps[state.stepIndex];
      switch (step.type) {
        case 'scene_intro':
        case 'teach_card':
          controller.next(lesson.steps.length);
          continue;
        case 'image_choice':
        case 'listen_choice':
          controller.selectOption(step.itemId!);
          expect(
            await controller.submitChoice(
              package: package,
              lesson: lesson,
              step: step,
              markListeningHintUsedOnRetry: step.type == 'listen_choice',
            ),
            isTrue,
          );
          continue;
        case 'hanzi_trace':
          controller.selectWritingSelfCheck('looks-close', usedHint: false);
          expect(
            await controller.submitWritingSelfCheck(
              package: package,
              lesson: lesson,
              step: step,
            ),
            isTrue,
          );
          continue;
        case 'tone_contrast':
          final targetPinyin = package.knowledgeItem(step.itemId!).pinyin;
          controller.selectOption(targetPinyin);
          expect(
            await controller.submitChoice(
              package: package,
              lesson: lesson,
              step: step,
              correctOption: targetPinyin,
            ),
            isTrue,
          );
          continue;
        case 'order_tokens':
          for (final index in step.tokens.indexed.map((entry) => entry.$1)) {
            controller.toggleOrderToken(index);
          }
          expect(
            await controller.submitOrderTokens(
              package: package,
              lesson: lesson,
              step: step,
            ),
            isTrue,
          );
          continue;
        case 'repeat':
          controller.useSpeakingFallback();
          controller.selectSelfCheck('sounded-close');
          expect(
            await controller.submitSpeakingSelfCheck(
              package: package,
              lesson: lesson,
              step: step,
            ),
            isTrue,
          );
          continue;
        case 'dialogue_turn':
          final dialogue = package.dialogue(step.dialogueId!);
          final turn = dialogue.turnFrom(
            state.dialogueNodeId ?? dialogue.startNodeId,
          );
          if (turn.learnerNode == null) {
            controller.next(lesson.steps.length);
          } else {
            controller.selectDialogueReplyMethod('said-aloud');
            controller.advanceDialogue(
              dialogue: dialogue,
              stepCount: lesson.steps.length,
            );
          }
          continue;
        case 'summary':
          expect(
            await controller.completeLesson(package: package, lesson: lesson),
            isTrue,
          );
          final completed = await container
              .read(lessonProgressRepositoryProvider)
              .getLesson(lesson.id);
          expect(completed?.status, 'completed');
          return;
        default:
          fail('Unsupported M2 step type ${step.type} in ${lesson.id}.');
      }
    }
    fail('Lesson ${lesson.id} did not complete within 100 actions.');
  } finally {
    subscription.close();
  }
}

Future<void> _playToCompletion(
  AudioService audioService,
  String assetPath,
) async {
  final terminalState = Completer<AudioState>();
  final observed = <AudioState>[];
  var started = false;
  final subscription = audioService.audioState.listen((state) {
    observed.add(state);
    if (state == AudioState.playing) {
      started = true;
    }
    if (!terminalState.isCompleted &&
        (state == AudioState.error || state == AudioState.unavailable)) {
      terminalState.complete(state);
    }
    if (!terminalState.isCompleted && started && state == AudioState.stopped) {
      terminalState.complete(state);
    }
  });

  try {
    await audioService.playAudio(assetPath);
    final result = await terminalState.future.timeout(
      const Duration(seconds: 15),
    );
    expect(
      result,
      AudioState.stopped,
      reason: '$assetPath emitted ${observed.join(', ')}',
    );
    expect(started, isTrue, reason: '$assetPath never started playback.');
  } finally {
    await audioService.stopAudio();
    await subscription.cancel();
  }
}
