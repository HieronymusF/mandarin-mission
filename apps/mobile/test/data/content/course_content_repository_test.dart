import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/data/content/course_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CourseContentRepository', () {
    test('uses the bundled M2 release as the default asset', () async {
      final repository = CourseContentRepository();
      final package = await repository.loadPackage();

      expect(
        repository.assetPath,
        CourseContentRepository.bundledM2CourseAsset,
      );
      expect(package.status, 'release');
      expect(package.version, '0.2.7');
      expect(package.locations, hasLength(3));
      expect(package.lessonsById, hasLength(12));
    });

    test('loads and indexes the legacy bundled café fixture', () async {
      final package = await CourseContentRepository(
        assetPath: CourseContentRepository.bundledCafeCourseAsset,
      ).loadPackage();

      expect(package.schemaVersion, 1);
      expect(package.status, 'release');
      expect(package.version, '0.1.7');
      expect(package.locations, hasLength(1));
      expect(package.locations.single.id, 'cafe');
      expect(package.locations.single.title, 'Café');
      expect(package.locations.single.order, 1);
      expect(package.locations.single.lessonIds, ['cafe-01']);
      expect(package.locations.single.challengeId, 'cafe-challenge');
      expect(package.hasStandaloneChallenge(package.locations.single), isFalse);
      expect(package.lessonsById.keys, ['cafe-01']);
      expect(
        package.lesson('cafe-01').steps.map((step) => step.type),
        containsAllInOrder([
          'scene_intro',
          'teach_card',
          'teach_card',
          'image_choice',
          'hanzi_trace',
          'tone_contrast',
          'listen_choice',
          'order_tokens',
          'repeat',
          'dialogue_turn',
          'summary',
        ]),
      );
      expect(
        package
            .lesson('cafe-01')
            .steps
            .singleWhere((step) => step.type == 'order_tokens')
            .tokens,
        ['我', '要', '一杯', '咖啡'],
      );
      expect(
        package.knowledgeItem('sentence-wo-yao-yi-bei-kafei').hanzi,
        '我要一杯咖啡。',
      );
      expect(
        package.knowledgeItem('sentence-wo-yao-yi-bei-kafei').pinyinSyllables,
        ['wǒ', 'yào', 'yì', 'bēi', 'kā', 'fēi'],
      );
      expect(
        package.dialogue('cafe-challenge').node('shopkeeper-question').text,
        '您好，您想喝什么？',
      );
      expect(package.assetsById.keys, contains('audio-kafei'));
      expect(
        package.audioAssetPathForItem('noun-kafei'),
        'assets/audio/cosyvoice/kafei.wav',
      );
      final audioBytes = await rootBundle.load(
        package.audioAssetPathForItem('noun-kafei')!,
      );
      expect(audioBytes.lengthInBytes, greaterThan(44));
    });

    test('resolves only ready audio assets to their bundled path', () async {
      final source = await rootBundle.loadString(
        CourseContentRepository.bundledCafeCourseAsset,
      );
      final content = jsonDecode(source) as Map<String, Object?>;
      final assets = content['assets']! as List<Object?>;
      final coffeeAudio =
          assets.cast<Map<String, Object?>>().singleWhere(
              (asset) => asset['id'] == 'audio-kafei',
            )
            ..['status'] = 'ready'
            ..['path'] = 'assets/audio/kafei.mp3'
            ..['sha256'] = List.filled(64, '0').join();
      expect(coffeeAudio['kind'], 'audio');

      final package = await CourseContentRepository(
        bundle: _StringAssetBundle(jsonEncode(content)),
      ).loadPackage();

      expect(
        package.audioAssetPathForItem('noun-kafei'),
        'assets/audio/kafei.mp3',
      );
    });

    test('loads the bundled M2 release when explicitly selected', () async {
      final package = await CourseContentRepository(
        assetPath: CourseContentRepository.bundledM2CourseAsset,
      ).loadPackage();

      expect(package.status, 'release');
      expect(package.version, '0.2.7');
      expect(package.locations, hasLength(3));
      expect(package.lessonsById, hasLength(12));
      expect(package.dialoguesById, hasLength(15));
      expect(package.assetsById, hasLength(53));
      expect(
        package.assetsById.values.where((asset) => asset.status == 'ready'),
        hasLength(53),
      );
      for (final location in package.locations) {
        expect(package.hasStandaloneChallenge(location), isTrue);
        final challenge = package.lessonOrChallenge(location.challengeId);
        expect(challenge.locationId, location.id);
        expect(challenge.prerequisites, location.lessonIds);
        expect(challenge.steps.map((step) => step.type), [
          'dialogue_turn',
          'summary',
        ]);
        expect(challenge.steps.first.dialogueId, location.challengeId);
      }

      final newItems = package.knowledgeItemsById.values.where(
        (item) => !const {
          'phrase-wo-yao',
          'noun-kafei',
          'sentence-wo-yao-yi-bei-kafei',
        }.contains(item.id),
      );
      final paths = newItems
          .map((item) => package.audioAssetPathForItem(item.id))
          .toList();

      expect(paths, hasLength(49));
      expect(paths, everyElement(isNotNull));
      expect(paths.toSet(), hasLength(49));
      for (final path in paths.cast<String>()) {
        final audioBytes = await rootBundle.load(path);
        final wave = audioBytes.buffer.asUint8List(
          audioBytes.offsetInBytes,
          audioBytes.lengthInBytes,
        );
        expect(wave.length, greaterThan(44), reason: path);
        expect(ascii.decode(wave.sublist(0, 4)), 'RIFF', reason: path);
        expect(ascii.decode(wave.sublist(8, 12)), 'WAVE', reason: path);
      }
    });

    test('resolves only ready image assets to their bundled path', () async {
      final source = await rootBundle.loadString(
        CourseContentRepository.bundledCafeCourseAsset,
      );
      final content = jsonDecode(source) as Map<String, Object?>;
      final assets = content['assets']! as List<Object?>;
      final cafeImage = assets.cast<Map<String, Object?>>().singleWhere(
        (asset) => asset['id'] == 'image-cafe-counter',
      );
      expect(cafeImage['status'], 'ready');

      final readyPackage = await CourseContentRepository(
        bundle: _StringAssetBundle(jsonEncode(content)),
      ).loadPackage();
      expect(
        readyPackage.imageAssetPath('image-cafe-counter'),
        'assets/images/cafe-counter.png',
      );
      final imageBytes = await rootBundle.load(
        readyPackage.imageAssetPath('image-cafe-counter')!,
      );
      expect(imageBytes.lengthInBytes, greaterThan(0));

      cafeImage
        ..['status'] = 'planned'
        ..remove('path')
        ..remove('sha256');
      content['status'] = 'draft';
      final draftPackage = await CourseContentRepository(
        bundle: _StringAssetBundle(jsonEncode(content)),
      ).loadPackage();
      expect(draftPackage.imageAssetPath('image-cafe-counter'), isNull);
    });

    test('returns a typed lesson by stable id', () async {
      final lesson = await CourseContentRepository().loadLesson('cafe-01');

      expect(lesson.title, 'Order one coffee');
      expect(lesson.estimatedMinutes, 9);
      expect(lesson.steps.first.type, 'scene_intro');
      expect(lesson.steps.last.type, 'summary');
    });

    test('rejects a missing lesson id', () async {
      final repository = CourseContentRepository();

      await expectLater(
        repository.loadLesson('missing-lesson'),
        throwsA(
          isA<CourseContentException>().having(
            (error) => error.message,
            'message',
            contains('Lesson missing-lesson does not exist'),
          ),
        ),
      );
    });

    test('rejects a package that fails content validation', () async {
      final source = await rootBundle.loadString(
        CourseContentRepository.bundledCafeCourseAsset,
      );
      final invalid = jsonDecode(source) as Map<String, Object?>
        ..['schemaVersion'] = 2;
      final repository = CourseContentRepository(
        bundle: _StringAssetBundle(jsonEncode(invalid)),
      );

      await expectLater(
        repository.loadPackage(),
        throwsA(
          isA<CourseContentException>().having(
            (error) => error.message,
            'message',
            contains('schemaVersion must be 1'),
          ),
        ),
      );
    });

    test('rejects malformed JSON', () async {
      final repository = CourseContentRepository(
        bundle: _StringAssetBundle('{not-json'),
      );

      await expectLater(
        repository.loadPackage(),
        throwsA(
          isA<CourseContentException>().having(
            (error) => error.message,
            'message',
            contains('is not valid JSON'),
          ),
        ),
      );
    });
  });
}

final class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.source);

  final String source;

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}
