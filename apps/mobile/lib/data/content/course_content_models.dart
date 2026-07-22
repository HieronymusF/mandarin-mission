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
    required this.dialoguesById,
    required this.assetsById,
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
    final dialogues = _objects(json, 'dialogues', source).indexed.map(
      (entry) =>
          CourseDialogue.fromJson(entry.$2, '$source.dialogues[${entry.$1}]'),
    );
    final assets = _objects(json, 'assets', source, required: false).indexed
        .map(
          (entry) =>
              CourseAsset.fromJson(entry.$2, '$source.assets[${entry.$1}]'),
        );

    return CoursePackage._(
      schemaVersion: _requiredInt(json, 'schemaVersion', source),
      status: _requiredString(json, 'status', source),
      version: _requiredString(json, 'version', source),
      knowledgeItemsById: _indexById(knowledgeItems, (item) => item.id),
      lessonsById: _indexById(lessons, (lesson) => lesson.id),
      dialoguesById: _indexById(dialogues, (dialogue) => dialogue.id),
      assetsById: _indexById(assets, (asset) => asset.id),
    );
  }

  final int schemaVersion;
  final String status;
  final String version;
  final Map<String, CourseKnowledgeItem> knowledgeItemsById;
  final Map<String, CourseLesson> lessonsById;
  final Map<String, CourseDialogue> dialoguesById;
  final Map<String, CourseAsset> assetsById;

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

  CourseDialogue dialogue(String dialogueId) {
    final dialogue = dialoguesById[dialogueId];
    if (dialogue == null) {
      throw CourseContentException(
        'Dialogue $dialogueId does not exist in content version $version.',
      );
    }
    return dialogue;
  }

  String? audioAssetPathForItem(String itemId) {
    final item = knowledgeItem(itemId);
    final asset = assetsById[item.audioAssetId];
    if (asset == null || asset.kind != 'audio' || asset.status != 'ready') {
      return null;
    }
    return asset.path;
  }
}

final class CourseKnowledgeItem {
  const CourseKnowledgeItem({
    required this.id,
    required this.kind,
    required this.hanzi,
    required this.pinyin,
    required this.pinyinSyllables,
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
      pinyinSyllables: _strings(json, 'pinyinSyllables', path),
      english: _requiredString(json, 'english', path),
      audioAssetId: _requiredString(json, 'audioAssetId', path),
      tags: _strings(json, 'tags', path, required: false),
    );
  }

  final String id;
  final String kind;
  final String hanzi;
  final String pinyin;
  final List<String> pinyinSyllables;
  final String english;
  final String audioAssetId;
  final List<String> tags;
}

final class CourseAsset {
  const CourseAsset({
    required this.id,
    required this.kind,
    required this.status,
    required this.path,
    required this.license,
    required this.credit,
  });

  factory CourseAsset.fromJson(Map<String, Object?> json, String path) {
    return CourseAsset(
      id: _requiredString(json, 'id', path),
      kind: _requiredString(json, 'kind', path),
      status: _requiredString(json, 'status', path),
      path: _optionalString(json, 'path', path),
      license: _requiredString(json, 'license', path),
      credit: _requiredString(json, 'credit', path),
    );
  }

  final String id;
  final String kind;
  final String status;
  final String? path;
  final String license;
  final String credit;
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
    this.title,
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
      title: _optionalString(json, 'title', path),
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
  final String? title;
  final String? dimension;
  final String? itemId;
  final String? dialogueId;
  final String? assetId;
  final String? text;
  final List<String> optionItemIds;
}

final class CourseDialogue {
  const CourseDialogue({
    required this.id,
    required this.startNodeId,
    required this.nodesById,
  });

  factory CourseDialogue.fromJson(Map<String, Object?> json, String path) {
    final nodes = _objects(json, 'nodes', path).indexed.map(
      (entry) =>
          CourseDialogueNode.fromJson(entry.$2, '$path.nodes[${entry.$1}]'),
    );
    return CourseDialogue(
      id: _requiredString(json, 'id', path),
      startNodeId: _requiredString(json, 'startNodeId', path),
      nodesById: _indexById(nodes, (node) => node.id),
    );
  }

  final String id;
  final String startNodeId;
  final Map<String, CourseDialogueNode> nodesById;

  CourseDialogueNode node(String nodeId) {
    final node = nodesById[nodeId];
    if (node == null) {
      throw CourseContentException(
        'Dialogue node $nodeId does not exist in dialogue $id.',
      );
    }
    return node;
  }
}

final class CourseDialogueNode {
  const CourseDialogueNode({
    required this.id,
    required this.speaker,
    required this.pinyinSyllables,
    required this.terminal,
    this.text,
    this.itemId,
    this.nextNodeId,
  });

  factory CourseDialogueNode.fromJson(Map<String, Object?> json, String path) {
    return CourseDialogueNode(
      id: _requiredString(json, 'id', path),
      speaker: _requiredString(json, 'speaker', path),
      text: _optionalString(json, 'text', path),
      pinyinSyllables: _strings(json, 'pinyinSyllables', path, required: false),
      itemId: _optionalString(json, 'itemId', path),
      nextNodeId: _optionalString(json, 'nextNodeId', path),
      terminal: json['terminal'] == true,
    );
  }

  final String id;
  final String speaker;
  final String? text;
  final List<String> pinyinSyllables;
  final String? itemId;
  final String? nextNodeId;
  final bool terminal;
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
