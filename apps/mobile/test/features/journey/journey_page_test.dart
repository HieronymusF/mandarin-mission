import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';
import 'package:mandarin_mission/data/progress/lesson_progress_repository.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  testWidgets('renders locations and lessons from the content package', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final package = CoursePackage.fromJson(
      _multiLocationPackage,
      source: 'test',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          coursePackageProvider.overrideWith((ref) async => package),
        ],
        child: const MandarinMissionApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stop 1 · Café'), findsOneWidget);
    expect(find.text('Order one coffee'), findsOneWidget);
    expect(find.text('Stop 2 · Market'), findsOneWidget);
    expect(find.text('Buy fruit'), findsOneWidget);
    expect(
      find.byKey(const Key('journey-lesson-market-01-card')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('Order one coffee')).dy,
      lessThan(tester.getTopLeft(find.text('Buy fruit')).dy),
    );
    expect(
      find.byKey(const Key('journey-challenge-cafe-challenge-card')),
      findsNothing,
    );
  });

  testWidgets(
    'unlocks a location challenge after four lessons and persists the next stop',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 5000);
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await database.close();
      });
      final package = CoursePackage.fromJson(
        _unlockPackage,
        source: 'journey-unlock-test',
      );
      final progressRepository = LessonProgressRepository(database);

      Future<void> pumpJourney(int stage) async {
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey(stage),
            overrides: [
              appDatabaseProvider.overrideWithValue(database),
              coursePackageProvider.overrideWith((ref) async => package),
            ],
            child: const MandarinMissionApp(),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<ShadButton> revealButton(String key) async {
        final finder = find.byKey(Key(key));
        expect(finder, findsOneWidget);
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        return tester.widget<ShadButton>(finder);
      }

      await pumpJourney(0);

      expect((await revealButton('open-lesson-cafe-01')).enabled, isTrue);
      expect((await revealButton('open-lesson-cafe-02')).enabled, isFalse);
      expect(
        (await revealButton('open-challenge-cafe-final-challenge')).enabled,
        isFalse,
      );
      expect((await revealButton('open-lesson-market-01')).enabled, isFalse);

      for (final lessonId in package.locations.first.lessonIds) {
        final lesson = package.lesson(lessonId);
        await progressRepository.completeLesson(
          lessonId: lesson.id,
          itemIds: lesson.itemIds,
          contentVersion: package.version,
          score: 100,
          completedAt: DateTime.utc(2026, 7, 26),
        );
      }
      await pumpJourney(1);

      final challengeButton = await revealButton(
        'open-challenge-cafe-final-challenge',
      );
      expect(challengeButton.enabled, isTrue);
      expect((await revealButton('open-lesson-market-01')).enabled, isFalse);

      await revealButton('open-challenge-cafe-final-challenge');
      await tester.tap(
        find.byKey(const Key('open-challenge-cafe-final-challenge')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Café final challenge'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('dialogue-said-aloud')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dialogue-said-aloud')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lesson-primary-action')));
      await tester.pumpAndSettle();

      expect(find.text('Café challenge complete'), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);
      await tester.tap(find.byKey(const Key('lesson-primary-action')));
      await tester.pumpAndSettle();

      expect((await revealButton('open-lesson-market-01')).enabled, isTrue);
      final challengeProgress =
          await (database.select(database.lessonProgressEntries)..where(
                (entry) => entry.lessonId.equals('cafe-final-challenge'),
              ))
              .getSingle();
      expect(challengeProgress.status, 'completed');

      await pumpJourney(2);
      expect((await revealButton('open-lesson-market-01')).enabled, isTrue);
      expect(
        (await revealButton('open-challenge-cafe-final-challenge')).enabled,
        isTrue,
      );
      expect(find.text('Practice challenge again'), findsOneWidget);
    },
  );
}

final Map<String, Object?> _unlockPackage = {
  'schemaVersion': 1,
  'status': 'draft',
  'version': '0.2.0',
  'locations': [
    {
      'id': 'cafe',
      'title': 'Café',
      'order': 1,
      'lessonIds': ['cafe-01', 'cafe-02', 'cafe-03', 'cafe-04'],
      'challengeId': 'cafe-final-challenge',
    },
    {
      'id': 'market',
      'title': 'Market',
      'order': 2,
      'lessonIds': ['market-01'],
      'challengeId': 'market-final-challenge',
    },
  ],
  'knowledgeItems': [
    {
      'id': 'challenge-answer',
      'kind': 'phrase',
      'hanzi': '好的',
      'pinyin': 'hǎo de',
      'pinyinSyllables': ['hǎo', 'de'],
      'english': 'Okay',
      'audioAssetId': 'challenge-audio',
      'tags': <Object?>[],
    },
  ],
  'lessons': [
    for (var index = 1; index <= 4; index++)
      {
        'id': 'cafe-0$index',
        'locationId': 'cafe',
        'title': 'Café lesson $index',
        'estimatedMinutes': 8,
        'prerequisites': index == 1 ? <Object?>[] : ['cafe-0${index - 1}'],
        'itemIds': <Object?>[],
        'steps': <Object?>[],
      },
    {
      'id': 'market-01',
      'locationId': 'market',
      'title': 'Market lesson 1',
      'estimatedMinutes': 8,
      'prerequisites': ['cafe-04'],
      'itemIds': <Object?>[],
      'steps': <Object?>[],
    },
  ],
  'dialogues': [
    {
      'id': 'cafe-final-challenge',
      'startNodeId': 'cafe-system',
      'nodes': [
        {
          'id': 'cafe-system',
          'speaker': 'system',
          'text': '您好。',
          'pinyinSyllables': ['nín', 'hǎo'],
          'nextNodeId': 'cafe-learner',
        },
        {
          'id': 'cafe-learner',
          'speaker': 'learner',
          'itemId': 'challenge-answer',
          'terminal': true,
        },
      ],
    },
  ],
  'assets': <Object?>[],
};

final Map<String, Object?> _multiLocationPackage = {
  'schemaVersion': 1,
  'status': 'draft',
  'version': '0.2.0',
  'locations': [
    {
      'id': 'market',
      'title': 'Market',
      'order': 2,
      'lessonIds': ['market-01'],
      'challengeId': 'market-challenge',
    },
    {
      'id': 'cafe',
      'title': 'Café',
      'order': 1,
      'lessonIds': ['cafe-01'],
      'challengeId': 'cafe-challenge',
    },
  ],
  'knowledgeItems': <Object?>[],
  'lessons': [
    {
      'id': 'market-01',
      'locationId': 'market',
      'title': 'Buy fruit',
      'estimatedMinutes': 8,
      'prerequisites': <Object?>[],
      'itemIds': <Object?>[],
      'steps': <Object?>[],
    },
    {
      'id': 'cafe-01',
      'locationId': 'cafe',
      'title': 'Order one coffee',
      'estimatedMinutes': 9,
      'prerequisites': <Object?>[],
      'itemIds': <Object?>[],
      'steps': <Object?>[],
    },
  ],
  'dialogues': <Object?>[],
  'assets': <Object?>[],
};
