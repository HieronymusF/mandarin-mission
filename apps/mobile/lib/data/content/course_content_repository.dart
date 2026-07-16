import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:learning_core/learning_core.dart';
import 'package:mandarin_mission_content/mandarin_mission_content.dart';

import 'course_content_models.dart';

final class CourseContentRepository {
  CourseContentRepository({
    AssetBundle? bundle,
    this.assetPath = bundledCafeCourseAsset,
  }) : _bundle = bundle ?? rootBundle;

  static const bundledCafeCourseAsset = MandarinMissionContentAssets.cafeCourse;

  final AssetBundle _bundle;
  final String assetPath;
  Future<CoursePackage>? _package;

  Future<CoursePackage> loadPackage() => _package ??= _loadPackage();

  Future<CourseLesson> loadLesson(String lessonId) async {
    return (await loadPackage()).lesson(lessonId);
  }

  Future<CoursePackage> _loadPackage() async {
    final String source;
    try {
      source = await _bundle.loadString(assetPath);
    } on Object catch (error) {
      throw CourseContentException(
        'Could not load course asset $assetPath: $error',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw CourseContentException(
        'Course asset $assetPath is not valid JSON: ${error.message}',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw CourseContentException(
        'Course asset $assetPath must contain a JSON object.',
      );
    }

    final issues = const ContentValidator().validate(
      decoded,
      source: assetPath,
    );
    if (issues.isNotEmpty) {
      throw CourseContentException(
        'Course asset $assetPath failed validation:\n${issues.join('\n')}',
      );
    }

    return CoursePackage.fromJson(decoded, source: assetPath);
  }
}
