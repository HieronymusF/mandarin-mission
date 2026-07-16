import 'package:learning_core/learning_core.dart';
import 'package:test/test.dart';

void main() {
  const validator = ContentValidator();

  Map<String, Object?> validPackage() => {
    'schemaVersion': 1,
    'status': 'draft',
    'version': '0.1.0',
    'locations': [
      {
        'id': 'cafe',
        'title': 'Café',
        'lessonIds': ['cafe-01'],
        'challengeId': 'cafe-challenge',
      },
    ],
    'knowledgeItems': [
      {
        'id': 'phrase-wo-yao',
        'hanzi': '我要',
        'pinyin': 'wǒ yào',
        'pinyinSyllables': ['wǒ', 'yào'],
        'english': 'I want',
        'audioAssetId': 'audio-wo-yao',
      },
    ],
    'lessons': [
      {
        'id': 'cafe-01',
        'locationId': 'cafe',
        'prerequisites': <String>[],
        'itemIds': ['phrase-wo-yao'],
        'steps': <Map<String, Object?>>[
          {'id': 'cafe-intro', 'type': 'scene_intro'},
          {'id': 'cafe-repeat', 'type': 'repeat', 'itemId': 'phrase-wo-yao'},
          {
            'id': 'cafe-dialogue',
            'type': 'dialogue_turn',
            'dialogueId': 'cafe-challenge',
          },
        ],
      },
    ],
    'dialogues': [
      {
        'id': 'cafe-challenge',
        'locationId': 'cafe',
        'startNodeId': 'shopkeeper-question',
        'nodes': [
          {
            'id': 'shopkeeper-question',
            'speaker': 'system',
            'text': '您好',
            'pinyinSyllables': ['nín', 'hǎo'],
            'nextNodeId': 'learner-answer',
          },
          {
            'id': 'learner-answer',
            'speaker': 'learner',
            'itemId': 'phrase-wo-yao',
            'nextNodeId': 'challenge-end',
          },
          {
            'id': 'challenge-end',
            'speaker': 'system',
            'text': '好的',
            'pinyinSyllables': ['hǎo', 'de'],
            'terminal': true,
          },
        ],
      },
    ],
    'assets': [
      {
        'id': 'audio-wo-yao',
        'kind': 'audio',
        'status': 'planned',
        'license': 'internal',
        'credit': 'Mandarin Mission',
      },
    ],
  };

  test('accepts a valid draft package', () {
    expect(validator.validate(validPackage()), isEmpty);
  });

  test('rejects a missing item reference', () {
    final package = validPackage();
    final lesson = (package['lessons'] as List).single as Map<String, Object?>;
    lesson['itemIds'] = ['missing-item'];

    expect(
      validator.validate(package).map((issue) => issue.message),
      contains('unknown item missing-item'),
    );
  });

  test('rejects pinyin syllables that do not match the Hanzi count', () {
    final package = validPackage();
    final item =
        (package['knowledgeItems'] as List).single as Map<String, Object?>;
    item['pinyinSyllables'] = ['wǒ'];

    expect(
      validator.validate(package).map((issue) => issue.message),
      contains('must contain one syllable for each Hanzi character'),
    );
  });

  test('rejects misaligned pinyin on system dialogue text', () {
    final package = validPackage();
    final dialogue =
        (package['dialogues'] as List).single as Map<String, Object?>;
    final node = (dialogue['nodes'] as List).first as Map<String, Object?>;
    node['pinyinSyllables'] = ['nín'];

    expect(
      validator.validate(package).map((issue) => issue.message),
      contains('must contain one syllable for each Hanzi character'),
    );
  });

  test('rejects duplicate global ids', () {
    final package = validPackage();
    final assets = package['assets'] as List;
    assets.add({
      'id': 'cafe',
      'kind': 'image',
      'status': 'planned',
      'license': 'internal',
      'credit': 'Mandarin Mission',
    });

    expect(
      validator.validate(package).map((issue) => issue.message),
      contains('duplicates global id cafe'),
    );
  });

  test('rejects unreachable dialogue nodes', () {
    final package = validPackage();
    final dialogue =
        (package['dialogues'] as List).single as Map<String, Object?>;
    final nodes = dialogue['nodes'] as List;
    nodes.add({'id': 'orphan-node', 'terminal': true});

    expect(
      validator.validate(package).map((issue) => issue.message),
      contains('node orphan-node is unreachable'),
    );
  });

  test('rejects unknown option and asset references', () {
    final package = validPackage();
    final lesson = (package['lessons'] as List).single as Map<String, Object?>;
    final steps = lesson['steps'] as List<Map<String, Object?>>;
    final step = steps.first;
    step['optionItemIds'] = ['missing-option'];
    step['assetId'] = 'missing-asset';

    final messages = validator
        .validate(package)
        .map((issue) => issue.message)
        .toList();
    expect(messages, contains('unknown item missing-option'));
    expect(messages, contains('unknown asset missing-asset'));
  });

  test('rejects a dialogue cycle without a terminal node', () {
    final package = validPackage();
    final dialogue =
        (package['dialogues'] as List).single as Map<String, Object?>;
    final nodes = dialogue['nodes'] as List;
    final terminal = nodes.last as Map<String, Object?>;
    terminal
      ..remove('terminal')
      ..['nextNodeId'] = 'shopkeeper-question';

    expect(
      validator.validate(package).map((issue) => issue.message),
      contains('dialogue contains a cycle at shopkeeper-question'),
    );
  });

  test('requires all release assets to be ready', () {
    final package = validPackage()..['status'] = 'release';

    expect(
      validator.validate(package).map((issue) => issue.message),
      contains('release assets must be ready'),
    );
  });
}
