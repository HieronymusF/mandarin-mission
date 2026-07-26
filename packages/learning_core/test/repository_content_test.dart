import 'dart:convert';
import 'dart:io';

import 'package:learning_core/learning_core.dart';
import 'package:test/test.dart';

void main() {
  test('repository schema and all content fixtures are valid JSON', () {
    final schema = File('../../content/schema/course-package.schema.json');
    final fixtures = [
      File('../../content/fixtures/cafe-course.json'),
      File('../../content/fixtures/m2-course.json'),
    ];

    expect(jsonDecode(schema.readAsStringSync()), isA<Map<String, Object?>>());
    for (final fixture in fixtures) {
      final package = jsonDecode(fixture.readAsStringSync());
      expect(package, isA<Map<String, Object?>>());
      expect(
        const ContentValidator().validate(package as Map<String, Object?>),
        isEmpty,
        reason: fixture.path,
      );
    }
  });

  test('M2 release keeps the approved curriculum scope', () {
    final fixture = File('../../content/fixtures/m2-course.json');
    final package =
        jsonDecode(fixture.readAsStringSync()) as Map<String, Object?>;
    final locations = package['locations']! as List<Object?>;
    final lessons = package['lessons']! as List<Object?>;
    final knowledgeItems = package['knowledgeItems']! as List<Object?>;
    final dialogues = package['dialogues']! as List<Object?>;
    final assets = package['assets']! as List<Object?>;

    expect(package['status'], 'release');
    expect(package['version'], '0.2.7');
    expect(locations.map((entry) => (entry! as Map<String, Object?>)['id']), [
      'cafe',
      'market',
      'metro',
    ]);
    expect(lessons, hasLength(12));
    expect(knowledgeItems, hasLength(52));
    expect(dialogues, hasLength(15));
    expect(assets, hasLength(53));
    expect(
      assets.where(
        (entry) => (entry! as Map<String, Object?>)['status'] == 'planned',
      ),
      isEmpty,
    );
    final newAudioAssets = assets
        .cast<Map<String, Object?>>()
        .where(
          (asset) =>
              asset['kind'] == 'audio' &&
              !const {
                'audio-wo-yao',
                'audio-kafei',
                'audio-wo-yao-yi-bei-kafei',
              }.contains(asset['id']),
        )
        .toList();
    expect(newAudioAssets, hasLength(49));
    for (final asset in newAudioAssets) {
      expect(asset['status'], 'ready', reason: asset['id']! as String);
      expect(
        asset['path'],
        startsWith('assets/audio/cosyvoice/'),
        reason: asset['id']! as String,
      );
      expect(
        asset['sha256'],
        matches(RegExp(r'^[0-9a-f]{64}$')),
        reason: asset['id']! as String,
      );
      expect(
        asset['license'],
        'Apache-2.0 model and tooling; generated TTS audio',
        reason: asset['id']! as String,
      );
      expect(
        asset['credit'],
        contains('user listening approval recorded 2026-07-26'),
        reason: asset['id']! as String,
      );
    }

    const prerequisites = <String, List<String>>{
      'cafe-01': [],
      'cafe-02': ['cafe-01'],
      'cafe-03': ['cafe-02'],
      'cafe-04': ['cafe-03'],
      'market-01': ['cafe-04'],
      'market-02': ['market-01'],
      'market-03': ['market-02'],
      'market-04': ['market-03'],
      'metro-01': ['market-04'],
      'metro-02': ['metro-01'],
      'metro-03': ['metro-02'],
      'metro-04': ['metro-03'],
    };
    for (final entry in lessons) {
      final lesson = entry! as Map<String, Object?>;
      expect(
        lesson['prerequisites'],
        prerequisites[lesson['id']],
        reason: lesson['id']! as String,
      );
    }
  });

  test('reviewed M2 lessons fit the current dialogue player', () {
    final fixture = File('../../content/fixtures/m2-course.json');
    final package =
        jsonDecode(fixture.readAsStringSync()) as Map<String, Object?>;
    final lessons = (package['lessons']! as List<Object?>)
        .cast<Map<String, Object?>>();
    final dialogues = {
      for (final entry
          in (package['dialogues']! as List<Object?>)
              .cast<Map<String, Object?>>())
        entry['id']! as String: entry,
    };

    for (final lessonId in [
      'cafe-02',
      'cafe-03',
      'cafe-04',
      'market-01',
      'market-02',
      'market-03',
      'market-04',
      'metro-01',
      'metro-02',
      'metro-03',
      'metro-04',
    ]) {
      final lesson = lessons.singleWhere((entry) => entry['id'] == lessonId);
      final dialogueStep = (lesson['steps']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .singleWhere((entry) => entry['type'] == 'dialogue_turn');
      final dialogue = dialogues[dialogueStep['dialogueId']]!;
      final nodes = {
        for (final entry
            in (dialogue['nodes']! as List<Object?>)
                .cast<Map<String, Object?>>())
          entry['id']! as String: entry,
      };
      final prompt = nodes[dialogue['startNodeId']]!;
      final learner = nodes[prompt['nextNodeId']]!;

      expect(prompt['speaker'], 'system', reason: lessonId);
      expect(prompt['text'], isA<String>(), reason: lessonId);
      expect(learner['speaker'], 'learner', reason: lessonId);
      expect(learner['itemId'], isA<String>(), reason: lessonId);
    }
  });
}
