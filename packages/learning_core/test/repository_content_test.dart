import 'dart:convert';
import 'dart:io';

import 'package:learning_core/learning_core.dart';
import 'package:test/test.dart';

void main() {
  test('repository schema and café fixture are valid JSON', () {
    final schema = File('../../content/schema/course-package.schema.json');
    final fixture = File('../../content/fixtures/cafe-course.json');

    expect(jsonDecode(schema.readAsStringSync()), isA<Map<String, Object?>>());
    final package = jsonDecode(fixture.readAsStringSync());
    expect(package, isA<Map<String, Object?>>());
    expect(
      const ContentValidator().validate(package as Map<String, Object?>),
      isEmpty,
    );
  });
}
