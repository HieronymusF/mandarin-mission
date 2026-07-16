import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/data/content/course_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CourseContentRepository', () {
    test('loads and indexes the bundled café fixture', () async {
      final package = await CourseContentRepository().loadPackage();

      expect(package.schemaVersion, 1);
      expect(package.status, 'draft');
      expect(package.version, '0.1.0');
      expect(package.lessonsById.keys, ['cafe-01']);
      expect(package.lesson('cafe-01').steps, hasLength(7));
      expect(
        package.knowledgeItem('sentence-wo-yao-yi-bei-kafei').hanzi,
        '我要一杯咖啡。',
      );
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
