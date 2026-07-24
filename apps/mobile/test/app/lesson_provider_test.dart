import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/progress/lesson_progress_repository.dart';
import 'package:mandarin_mission/features/lesson/application/lesson_providers.dart';
import 'package:learning_core/learning_core.dart';

void main() {
  test('records an incorrect token order before allowing the retry', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = LessonProgressRepository(database);
    final container = ProviderContainer(
      overrides: [
        lessonProgressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final package = CoursePackage.fromJson({
      'schemaVersion': 1,
      'status': 'draft',
      'version': '0.1.0',
      'knowledgeItems': [
        {
          'id': 'phrase-wo-yao',
          'kind': 'phrase',
          'hanzi': '我要',
          'pinyin': 'wǒ yào',
          'pinyinSyllables': ['wǒ', 'yào'],
          'english': 'I want',
          'audioAssetId': 'audio-wo-yao',
          'tags': <String>[],
        },
      ],
      'lessons': [
        {
          'id': 'cafe-01',
          'locationId': 'cafe',
          'title': 'Order coffee',
          'estimatedMinutes': 1,
          'prerequisites': <String>[],
          'itemIds': ['phrase-wo-yao'],
          'steps': [
            {
              'id': 'cafe-order',
              'type': 'order_tokens',
              'dimension': 'meaning',
              'itemId': 'phrase-wo-yao',
              'tokens': ['我', '要'],
            },
            {'id': 'cafe-summary', 'type': 'summary'},
          ],
        },
      ],
      'dialogues': <Object?>[],
    }, source: 'test');
    final lesson = package.lesson('cafe-01');
    final step = lesson.steps.first;
    final provider = lessonPlayerControllerProvider(lesson.id);
    final controller = container.read(provider.notifier);

    controller.toggleOrderToken(1);
    controller.toggleOrderToken(0);
    expect(
      await controller.submitOrderTokens(
        package: package,
        lesson: lesson,
        step: step,
      ),
      isTrue,
    );
    expect(container.read(provider).stepIndex, 0);
    expect(container.read(provider).orderedTokenIndexes, isEmpty);
    expect(container.read(provider).incorrectAttempts, 1);

    controller.toggleOrderToken(0);
    controller.toggleOrderToken(1);
    expect(
      await controller.submitOrderTokens(
        package: package,
        lesson: lesson,
        step: step,
      ),
      isTrue,
    );
    expect(container.read(provider).stepIndex, 1);
    final attempts = await database.select(database.reviewAttempts).get();
    expect(attempts.map((attempt) => attempt.correct), [false, true]);
    expect(
      attempts.map((attempt) => attempt.dimension),
      everyElement('meaning'),
    );
  });

  test('retains the writing self-check when local saving fails', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = LessonProgressRepository(
      database,
      idFactory: () => 'duplicate-id',
    );
    await repository.recordExerciseAttempt(
      lessonId: 'seed-lesson',
      stepId: 'seed-step',
      contentVersion: '0.1.0',
      itemId: 'noun-kafei',
      dimension: LearningDimension.hanzi,
      rating: ReviewRating.remembered,
      correct: true,
      usedHint: false,
      latencyMs: 0,
      answeredAt: DateTime.utc(2026),
    );
    final container = ProviderContainer(
      overrides: [
        lessonProgressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final package = CoursePackage.fromJson({
      'schemaVersion': 1,
      'status': 'draft',
      'version': '0.1.0',
      'knowledgeItems': [
        {
          'id': 'noun-kafei',
          'kind': 'word',
          'hanzi': '咖啡',
          'pinyin': 'kāfēi',
          'pinyinSyllables': ['kā', 'fēi'],
          'english': 'coffee',
          'audioAssetId': 'audio-kafei',
          'tags': <String>[],
        },
      ],
      'lessons': [
        {
          'id': 'cafe-01',
          'locationId': 'cafe',
          'title': 'Order coffee',
          'estimatedMinutes': 1,
          'prerequisites': <String>[],
          'itemIds': ['noun-kafei'],
          'steps': [
            {
              'id': 'cafe-write',
              'type': 'hanzi_trace',
              'dimension': 'hanzi',
              'itemId': 'noun-kafei',
            },
          ],
        },
      ],
      'dialogues': <Object?>[],
    }, source: 'test');
    final lesson = package.lesson('cafe-01');
    final step = lesson.steps.single;
    final provider = lessonPlayerControllerProvider(lesson.id);
    final controller = container.read(provider.notifier);

    controller.selectWritingSelfCheck('looks-close', usedHint: true);
    final saved = await controller.submitWritingSelfCheck(
      package: package,
      lesson: lesson,
      step: step,
    );

    final state = container.read(provider);
    expect(saved, isFalse);
    expect(state.writingSelfCheck, 'looks-close');
    expect(state.usedWritingHint, isTrue);
    expect(state.errorMessage, 'Your writing check was not saved. Try again.');
  });
}
