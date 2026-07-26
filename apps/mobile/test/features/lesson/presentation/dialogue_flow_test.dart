import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/app/router.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';
import 'package:mandarin_mission/features/lesson/application/lesson_providers.dart';

void main() {
  test(
    'advances every M2 final challenge to its terminal learner turn',
    () async {
      final source = await File(
        '../../content/fixtures/m2-course.json',
      ).readAsString();
      final package = CoursePackage.fromJson(
        jsonDecode(source) as Map<String, Object?>,
        source: 'content/fixtures/m2-course.json',
      );
      final expectedLearnerTurns = {
        'cafe-final-challenge': 5,
        'market-final-challenge': 6,
        'metro-final-challenge': 8,
      };
      final container = ProviderContainer();
      addTearDown(container.dispose);

      for (final location in package.locations) {
        final dialogue = package.dialogue(location.challengeId);
        final provider = lessonPlayerControllerProvider(dialogue.id);
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);
        final controller = container.read(provider.notifier);
        var learnerTurns = 0;

        while (container.read(provider).stepIndex == 0) {
          final state = container.read(provider);
          final turn = dialogue.turnFrom(
            state.dialogueNodeId ?? dialogue.startNodeId,
          );
          expect(turn.systemNodes, isNotEmpty);
          final learner = turn.learnerNode!;
          expect(learner.speaker, 'learner');

          controller.selectDialogueReplyMethod('said-aloud');
          controller.advanceDialogue(dialogue: dialogue, stepCount: 2);
          learnerTurns += 1;
        }

        expect(
          learnerTurns,
          expectedLearnerTurns[dialogue.id],
          reason: dialogue.id,
        );
        expect(container.read(provider).dialogueNodeId, isNull);
        expect(container.read(provider).dialogueReplyMethod, isNull);
      }
    },
  );

  testWidgets(
    'plays dialogue nodes in order and clears the turn after page exit',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      final package = CoursePackage.fromJson(
        _dialoguePackage,
        source: 'dialogue-flow-test',
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          coursePackageProvider.overrideWith((ref) async => package),
        ],
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await database.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MandarinMissionApp(),
        ),
      );
      await tester.pumpAndSettle();
      await _openLesson(tester);

      expect(find.text('甲'), findsOneWidget);
      expect(find.text('附'), findsOneWidget);
      expect(find.text('乙'), findsNothing);
      expect(find.text('Read, then take your turn.'), findsOneWidget);
      expect(find.text('Complete both learner turns.'), findsOneWidget);
      expect(find.text('Choose how to reply'), findsOneWidget);
      await _tapPrimary(tester);
      expect(find.text('甲'), findsOneWidget);

      await _chooseReply(tester, const Key('dialogue-said-aloud'));
      expect(find.text('Send reply'), findsOneWidget);

      container.read(appRouterProvider).go('/');
      await tester.pumpAndSettle();
      await _openLesson(tester);

      expect(find.text('甲'), findsOneWidget);
      expect(find.text('Reply ready'), findsNothing);
      expect(find.text('Choose how to reply'), findsOneWidget);

      await _chooseReply(tester, const Key('dialogue-said-aloud'));
      await _tapPrimary(tester);

      expect(find.text('甲'), findsNothing);
      expect(find.text('乙'), findsOneWidget);
      expect(find.text('Choose how to reply'), findsOneWidget);
      expect(find.text('Reply ready'), findsNothing);

      await _chooseReply(tester, const Key('dialogue-use-ticket'));
      expect(find.text('冰'), findsOneWidget);
      expect(
        find.text('Say the phrase aloud, then send your reply.'),
        findsOneWidget,
      );
      expect(find.text('Complete both learner turns.'), findsNothing);
      await _tapPrimary(tester);

      expect(find.text('丙'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
      await _chooseReply(tester, const Key('dialogue-said-aloud'));
      await _tapPrimary(tester);

      expect(find.text('完'), findsOneWidget);
      expect(find.text('Complete both learner turns.'), findsNothing);
      expect(find.byKey(const Key('dialogue-said-aloud')), findsNothing);
      expect(find.byKey(const Key('dialogue-use-ticket')), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
      await _tapPrimary(tester);

      expect(find.text('Dialogue complete'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
    },
  );
}

Future<void> _openLesson(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('open-lesson-test-01')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('open-lesson-test-01')));
  await tester.pumpAndSettle();
}

Future<void> _chooseReply(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> _tapPrimary(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('lesson-primary-action')));
  await tester.pumpAndSettle();
}

final Map<String, Object?> _dialoguePackage = {
  'schemaVersion': 1,
  'status': 'draft',
  'version': '0.1.0',
  'locations': [
    {
      'id': 'test-location',
      'title': 'Test stop',
      'order': 1,
      'lessonIds': ['test-01'],
      'challengeId': 'multi-turn-dialogue',
    },
  ],
  'knowledgeItems': [
    {
      'id': 'reply-one',
      'kind': 'phrase',
      'hanzi': '第一答',
      'pinyin': 'dì yī dá',
      'pinyinSyllables': ['dì', 'yī', 'dá'],
      'english': 'First answer',
      'audioAssetId': 'audio-one',
      'tags': <Object?>[],
    },
    {
      'id': 'reply-two',
      'kind': 'phrase',
      'hanzi': '冰的',
      'pinyin': 'bīng de',
      'pinyinSyllables': ['bīng', 'de'],
      'english': 'Cold',
      'audioAssetId': 'audio-two',
      'tags': <Object?>[],
    },
    {
      'id': 'reply-three',
      'kind': 'phrase',
      'hanzi': '谢谢',
      'pinyin': 'xiè xie',
      'pinyinSyllables': ['xiè', 'xie'],
      'english': 'Thanks',
      'audioAssetId': 'audio-three',
      'tags': <Object?>[],
    },
  ],
  'lessons': [
    {
      'id': 'test-01',
      'locationId': 'test-location',
      'title': 'Dialogue test',
      'estimatedMinutes': 1,
      'prerequisites': <Object?>[],
      'itemIds': ['reply-one', 'reply-two', 'reply-three'],
      'steps': [
        {
          'id': 'multi-turn-step',
          'type': 'dialogue_turn',
          'title': 'Multi-turn challenge',
          'dialogueId': 'multi-turn-dialogue',
          'text': 'Complete both learner turns.',
        },
        {
          'id': 'system-terminal-step',
          'type': 'dialogue_turn',
          'title': 'System terminal challenge',
          'dialogueId': 'system-terminal-dialogue',
          'text': 'Listen for the closing response.',
        },
        {
          'id': 'summary',
          'type': 'summary',
          'title': 'Dialogue complete',
          'text': 'All turns completed.',
        },
      ],
    },
  ],
  'dialogues': [
    {
      'id': 'multi-turn-dialogue',
      'startNodeId': 'system-one',
      'nodes': [
        {
          'id': 'system-one',
          'speaker': 'system',
          'text': '甲问。',
          'pinyinSyllables': ['jiǎ', 'wèn'],
          'nextNodeId': 'system-one-detail',
        },
        {
          'id': 'system-one-detail',
          'speaker': 'system',
          'text': '附问。',
          'pinyinSyllables': ['fù', 'wèn'],
          'nextNodeId': 'learner-one',
        },
        {
          'id': 'learner-one',
          'speaker': 'learner',
          'itemId': 'reply-one',
          'nextNodeId': 'system-two',
        },
        {
          'id': 'system-two',
          'speaker': 'system',
          'text': '乙问。',
          'pinyinSyllables': ['yǐ', 'wèn'],
          'nextNodeId': 'learner-two',
        },
        {
          'id': 'learner-two',
          'speaker': 'learner',
          'itemId': 'reply-two',
          'terminal': true,
        },
      ],
    },
    {
      'id': 'system-terminal-dialogue',
      'startNodeId': 'system-before-close',
      'nodes': [
        {
          'id': 'system-before-close',
          'speaker': 'system',
          'text': '丙问。',
          'pinyinSyllables': ['bǐng', 'wèn'],
          'nextNodeId': 'learner-before-close',
        },
        {
          'id': 'learner-before-close',
          'speaker': 'learner',
          'itemId': 'reply-three',
          'nextNodeId': 'system-close',
        },
        {
          'id': 'system-close',
          'speaker': 'system',
          'text': '完成。',
          'pinyinSyllables': ['wán', 'chéng'],
          'terminal': true,
        },
      ],
    },
  ],
  'assets': <Object?>[],
};
