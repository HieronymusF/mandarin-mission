final class CourseContentException implements Exception {
  const CourseContentException(this.message);

  final String message;

  @override
  String toString() => 'CourseContentException: $message';
}

final class CoursePackage {
  CoursePackage._({
    required this.schemaVersion,
    required this.status,
    required this.version,
    required this.knowledgeItemsById,
    required this.lessonsById,
  });

  factory CoursePackage.fromJson(
    Map<String, Object?> json, {
    required String source,
  }) {
    final knowledgeItems = _objects(json, 'knowledgeItems', source).indexed.map(
      (entry) => CourseKnowledgeItem.fromJson(
        entry.$2,
        '$source.knowledgeItems[${entry.$1}]',
      ),
    );
    final lessons = _objects(json, 'lessons', source).indexed.map(
      (entry) =>
          CourseLesson.fromJson(entry.$2, '$source.lessons[${entry.$1}]'),
    );

    return CoursePackage._(
      schemaVersion: _requiredInt(json, 'schemaVersion', source),
      status: _requiredString(json, 'status', source),
      version: _requiredString(json, 'version', source),
      knowledgeItemsById: _indexById(knowledgeItems, (item) => item.id),
      lessonsById: _indexById(lessons, (lesson) => lesson.id),
    );
  }

  final int schemaVersion;
  final String status;
  final String version;
  final Map<String, CourseKnowledgeItem> knowledgeItemsById;
  final Map<String, CourseLesson> lessonsById;

  CourseLesson lesson(String lessonId) {
    final lesson = lessonsById[lessonId];
    if (lesson == null) {
      throw CourseContentException(
        'Lesson $lessonId does not exist in content version $version.',
      );
    }
    return lesson;
  }

  CourseKnowledgeItem knowledgeItem(String itemId) {
    final item = knowledgeItemsById[itemId];
    if (item == null) {
      throw CourseContentException(
        'Knowledge item $itemId does not exist in content version $version.',
      );
    }
    return item;
  }
}

final class CourseKnowledgeItem {
  const CourseKnowledgeItem({
    required this.id,
    required this.kind,
    required this.hanzi,
    required this.pinyin,
    required this.english,
    required this.audioAssetId,
    required this.tags,
  });

  factory CourseKnowledgeItem.fromJson(Map<String, Object?> json, String path) {
    return CourseKnowledgeItem(
      id: _requiredString(json, 'id', path),
      kind: _requiredString(json, 'kind', path),
      hanzi: _requiredString(json, 'hanzi', path),
      pinyin: _requiredString(json, 'pinyin', path),
      english: _requiredString(json, 'english', path),
      audioAssetId: _requiredString(json, 'audioAssetId', path),
      tags: _strings(json, 'tags', path, required: false),
    );
  }

  final String id;
  final String kind;
  final String hanzi;
  final String pinyin;
  final String english;
  final String audioAssetId;
  final List<String> tags;
}

final class CourseLesson {
  const CourseLesson({
    required this.id,
    required this.locationId,
    required this.title,
    required this.estimatedMinutes,
    required this.prerequisites,
    required this.itemIds,
    required this.steps,
  });

  factory CourseLesson.fromJson(Map<String, Object?> json, String path) {
    final steps = _objects(json, 'steps', path).indexed.map(
      (entry) =>
          CourseLessonStep.fromJson(entry.$2, '$path.steps[${entry.$1}]'),
    );

    return CourseLesson(
      id: _requiredString(json, 'id', path),
      locationId: _requiredString(json, 'locationId', path),
      title: _requiredString(json, 'title', path),
      estimatedMinutes: _requiredInt(json, 'estimatedMinutes', path),
      prerequisites: _strings(json, 'prerequisites', path),
      itemIds: _strings(json, 'itemIds', path),
      steps: List.unmodifiable(steps),
    );
  }

  final String id;
  final String locationId;
  final String title;
  final int estimatedMinutes;
  final List<String> prerequisites;
  final List<String> itemIds;
  final List<CourseLessonStep> steps;
}

final class CourseLessonStep {
  const CourseLessonStep({
    required this.id,
    required this.type,
    this.dimension,
    this.itemId,
    this.dialogueId,
    this.assetId,
    this.text,
    this.optionItemIds = const [],
  });

  factory CourseLessonStep.fromJson(Map<String, Object?> json, String path) {
    return CourseLessonStep(
      id: _requiredString(json, 'id', path),
      type: _requiredString(json, 'type', path),
      dimension: _optionalString(json, 'dimension', path),
      itemId: _optionalString(json, 'itemId', path),
      dialogueId: _optionalString(json, 'dialogueId', path),
      assetId: _optionalString(json, 'assetId', path),
      text: _optionalString(json, 'text', path),
      optionItemIds: _strings(json, 'optionItemIds', path, required: false),
    );
  }

  final String id;
  final String type;
  final String? dimension;
  final String? itemId;
  final String? dialogueId;
  final String? assetId;
  final String? text;
  final List<String> optionItemIds;
}

Map<String, T> _indexById<T>(
  Iterable<T> values,
  String Function(T value) idOf,
) {
  return Map.unmodifiable({for (final value in values) idOf(value): value});
}

List<Map<String, Object?>> _objects(
  Map<String, Object?> json,
  String key,
  String path,
) {
  final value = json[key];
  if (value is! List) {
    throw CourseContentException('$path.$key must be a list.');
  }
  return List.unmodifiable(
    value.indexed.map((entry) {
      final value = entry.$2;
      if (value is! Map<String, Object?>) {
        throw CourseContentException(
          '$path.$key[${entry.$1}] must be an object.',
        );
      }
      return value;
    }),
  );
}

List<String> _strings(
  Map<String, Object?> json,
  String key,
  String path, {
  bool required = true,
}) {
  final value = json[key];
  if (value == null && !required) {
    return const [];
  }
  if (value is! List) {
    throw CourseContentException('$path.$key must be a list.');
  }
  return List.unmodifiable(
    value.indexed.map((entry) {
      final value = entry.$2;
      if (value is! String) {
        throw CourseContentException(
          '$path.$key[${entry.$1}] must be a string.',
        );
      }
      return value;
    }),
  );
}

String _requiredString(Map<String, Object?> json, String key, String path) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw CourseContentException('$path.$key must be a non-empty string.');
  }
  return value;
}

String? _optionalString(Map<String, Object?> json, String key, String path) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String || value.trim().isEmpty) {
    throw CourseContentException('$path.$key must be a non-empty string.');
  }
  return value;
}

int _requiredInt(Map<String, Object?> json, String key, String path) {
  final value = json[key];
  if (value is! int) {
    throw CourseContentException('$path.$key must be an integer.');
  }
  return value;
}
