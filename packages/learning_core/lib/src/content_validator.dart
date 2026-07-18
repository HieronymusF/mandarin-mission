/// A content problem that must be fixed before a package can ship.
final class ContentValidationIssue {
  const ContentValidationIssue(this.path, this.message);

  final String path;
  final String message;

  @override
  String toString() => '$path: $message';
}

/// Validates the cross-reference rules that JSON Schema cannot express.
final class ContentValidator {
  const ContentValidator();

  static final RegExp _stableId = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  List<ContentValidationIssue> validate(
    Map<String, Object?> package, {
    String source = '<memory>',
  }) {
    final issues = <ContentValidationIssue>[];
    if (package['schemaVersion'] != 1) {
      issues.add(ContentValidationIssue(source, 'schemaVersion must be 1'));
    }

    final status = package['status'];
    if (status != 'draft' && status != 'release') {
      issues.add(
        ContentValidationIssue(source, 'status must be draft or release'),
      );
    }

    final locations = _entries(package, 'locations', source, issues);
    final items = _entries(package, 'knowledgeItems', source, issues);
    final lessons = _entries(package, 'lessons', source, issues);
    final dialogues = _entries(package, 'dialogues', source, issues);
    final assets = _entries(package, 'assets', source, issues);

    final allIds = <String>{};
    final locationIds = _registerIds(
      locations,
      'locations',
      source,
      issues,
      allIds,
    );
    final itemIds = _registerIds(
      items,
      'knowledgeItems',
      source,
      issues,
      allIds,
    );
    final lessonIds = _registerIds(lessons, 'lessons', source, issues, allIds);
    final dialogueIds = _registerIds(
      dialogues,
      'dialogues',
      source,
      issues,
      allIds,
    );
    final assetIds = _registerIds(assets, 'assets', source, issues, allIds);

    _validateLocations(locations, lessonIds, dialogueIds, source, issues);
    _validateItems(items, assetIds, source, issues);
    _validateLessons(
      lessons,
      locationIds,
      itemIds,
      lessonIds,
      dialogueIds,
      assetIds,
      source,
      issues,
    );
    _validateDialogues(dialogues, locationIds, itemIds, source, issues);
    _validateAssets(assets, status == 'release', source, issues);

    return issues;
  }

  List<Map<String, Object?>> _entries(
    Map<String, Object?> package,
    String key,
    String source,
    List<ContentValidationIssue> issues,
  ) {
    final value = package[key];
    if (value is! List) {
      issues.add(ContentValidationIssue('$source.$key', 'must be a list'));
      return const [];
    }

    final result = <Map<String, Object?>>[];
    for (var index = 0; index < value.length; index++) {
      final entry = value[index];
      if (entry is Map<String, Object?>) {
        result.add(entry);
      } else {
        issues.add(
          ContentValidationIssue('$source.$key[$index]', 'must be an object'),
        );
      }
    }
    return result;
  }

  Set<String> _registerIds(
    List<Map<String, Object?>> entries,
    String collection,
    String source,
    List<ContentValidationIssue> issues,
    Set<String> allIds,
  ) {
    final ids = <String>{};
    for (var index = 0; index < entries.length; index++) {
      final path = '$source.$collection[$index].id';
      final id = entries[index]['id'];
      if (id is! String || !_stableId.hasMatch(id)) {
        issues.add(
          ContentValidationIssue(path, 'must be a stable kebab-case id'),
        );
        continue;
      }
      if (!ids.add(id)) {
        issues.add(
          ContentValidationIssue(path, 'duplicates $id in $collection'),
        );
      }
      if (!allIds.add(id)) {
        issues.add(ContentValidationIssue(path, 'duplicates global id $id'));
      }
    }
    return ids;
  }

  void _validateLocations(
    List<Map<String, Object?>> locations,
    Set<String> lessonIds,
    Set<String> dialogueIds,
    String source,
    List<ContentValidationIssue> issues,
  ) {
    for (var index = 0; index < locations.length; index++) {
      final path = '$source.locations[$index]';
      for (final lessonId in _stringList(
        locations[index]['lessonIds'],
        '$path.lessonIds',
        issues,
      )) {
        if (!lessonIds.contains(lessonId)) {
          issues.add(
            ContentValidationIssue(
              '$path.lessonIds',
              'unknown lesson $lessonId',
            ),
          );
        }
      }

      final challengeId = locations[index]['challengeId'];
      if (challengeId is! String || !dialogueIds.contains(challengeId)) {
        issues.add(
          ContentValidationIssue(
            '$path.challengeId',
            'must reference a known dialogue',
          ),
        );
      }
    }
  }

  void _validateItems(
    List<Map<String, Object?>> items,
    Set<String> assetIds,
    String source,
    List<ContentValidationIssue> issues,
  ) {
    for (var index = 0; index < items.length; index++) {
      final path = '$source.knowledgeItems[$index]';
      for (final field in ['hanzi', 'pinyin', 'english']) {
        if (items[index][field] is! String ||
            (items[index][field] as String).trim().isEmpty) {
          issues.add(ContentValidationIssue('$path.$field', 'is required'));
        }
      }
      final hanzi = items[index]['hanzi'];
      final syllables = _stringList(
        items[index]['pinyinSyllables'],
        '$path.pinyinSyllables',
        issues,
      );
      if (hanzi is String && syllables.length != _hanziCount(hanzi)) {
        issues.add(
          ContentValidationIssue(
            '$path.pinyinSyllables',
            'must contain one syllable for each Hanzi character',
          ),
        );
      }
      final audioAssetId = items[index]['audioAssetId'];
      if (audioAssetId is! String || !assetIds.contains(audioAssetId)) {
        issues.add(
          ContentValidationIssue(
            '$path.audioAssetId',
            'must reference a known asset',
          ),
        );
      }
    }
  }

  void _validateLessons(
    List<Map<String, Object?>> lessons,
    Set<String> locationIds,
    Set<String> itemIds,
    Set<String> lessonIds,
    Set<String> dialogueIds,
    Set<String> assetIds,
    String source,
    List<ContentValidationIssue> issues,
  ) {
    for (var index = 0; index < lessons.length; index++) {
      final lesson = lessons[index];
      final path = '$source.lessons[$index]';
      if (!locationIds.contains(lesson['locationId'])) {
        issues.add(
          ContentValidationIssue('$path.locationId', 'unknown location'),
        );
      }
      for (final itemId in _stringList(
        lesson['itemIds'],
        '$path.itemIds',
        issues,
      )) {
        if (!itemIds.contains(itemId)) {
          issues.add(
            ContentValidationIssue('$path.itemIds', 'unknown item $itemId'),
          );
        }
      }
      for (final prerequisite in _stringList(
        lesson['prerequisites'],
        '$path.prerequisites',
        issues,
      )) {
        if (!lessonIds.contains(prerequisite)) {
          issues.add(
            ContentValidationIssue(
              '$path.prerequisites',
              'unknown lesson $prerequisite',
            ),
          );
        }
      }

      final steps = _mapList(lesson['steps'], '$path.steps', issues);
      final stepIds = <String>{};
      for (var stepIndex = 0; stepIndex < steps.length; stepIndex++) {
        final step = steps[stepIndex];
        final stepPath = '$path.steps[$stepIndex]';
        final stepId = step['id'];
        if (stepId is! String || !_stableId.hasMatch(stepId)) {
          issues.add(
            ContentValidationIssue('$stepPath.id', 'must be a stable id'),
          );
        } else if (!stepIds.add(stepId)) {
          issues.add(
            ContentValidationIssue(
              '$stepPath.id',
              'duplicates step id $stepId',
            ),
          );
        }

        final itemId = step['itemId'];
        if (step['type'] == 'hanzi_trace') {
          if (itemId == null) {
            issues.add(
              ContentValidationIssue(
                '$stepPath.itemId',
                'hanzi_trace requires itemId',
              ),
            );
          }
          if (step['dimension'] != 'hanzi') {
            issues.add(
              ContentValidationIssue(
                '$stepPath.dimension',
                'hanzi_trace requires hanzi dimension',
              ),
            );
          }
        }
        if (itemId != null && !itemIds.contains(itemId)) {
          issues.add(
            ContentValidationIssue('$stepPath.itemId', 'unknown item $itemId'),
          );
        }
        for (final optionItemId in _stringListIfPresent(
          step['optionItemIds'],
          '$stepPath.optionItemIds',
          issues,
        )) {
          if (!itemIds.contains(optionItemId)) {
            issues.add(
              ContentValidationIssue(
                '$stepPath.optionItemIds',
                'unknown item $optionItemId',
              ),
            );
          }
        }
        final dialogueId = step['dialogueId'];
        if (dialogueId != null && !dialogueIds.contains(dialogueId)) {
          issues.add(
            ContentValidationIssue(
              '$stepPath.dialogueId',
              'unknown dialogue $dialogueId',
            ),
          );
        }
        final assetId = step['assetId'];
        if (assetId != null && !assetIds.contains(assetId)) {
          issues.add(
            ContentValidationIssue(
              '$stepPath.assetId',
              'unknown asset $assetId',
            ),
          );
        }
      }
    }
  }

  void _validateDialogues(
    List<Map<String, Object?>> dialogues,
    Set<String> locationIds,
    Set<String> itemIds,
    String source,
    List<ContentValidationIssue> issues,
  ) {
    for (var index = 0; index < dialogues.length; index++) {
      final dialogue = dialogues[index];
      final path = '$source.dialogues[$index]';
      if (!locationIds.contains(dialogue['locationId'])) {
        issues.add(
          ContentValidationIssue('$path.locationId', 'unknown location'),
        );
      }

      final nodes = _mapList(dialogue['nodes'], '$path.nodes', issues);
      final nodesById = <String, Map<String, Object?>>{};
      for (var nodeIndex = 0; nodeIndex < nodes.length; nodeIndex++) {
        final node = nodes[nodeIndex];
        final nodeId = node['id'];
        final nodePath = '$path.nodes[$nodeIndex]';
        if (nodeId is! String || !_stableId.hasMatch(nodeId)) {
          issues.add(
            ContentValidationIssue('$nodePath.id', 'must be a stable id'),
          );
          continue;
        }
        if (nodesById.containsKey(nodeId)) {
          issues.add(
            ContentValidationIssue(
              '$nodePath.id',
              'duplicates node id $nodeId',
            ),
          );
        }
        nodesById[nodeId] = node;

        final itemId = node['itemId'];
        if (itemId != null && !itemIds.contains(itemId)) {
          issues.add(
            ContentValidationIssue('$nodePath.itemId', 'unknown item $itemId'),
          );
        }
        if (node['speaker'] == 'system') {
          final text = node['text'];
          final syllables = _stringList(
            node['pinyinSyllables'],
            '$nodePath.pinyinSyllables',
            issues,
          );
          if (text is String && syllables.length != _hanziCount(text)) {
            issues.add(
              ContentValidationIssue(
                '$nodePath.pinyinSyllables',
                'must contain one syllable for each Hanzi character',
              ),
            );
          }
        }
      }

      final startNodeId = dialogue['startNodeId'];
      if (startNodeId is! String || !nodesById.containsKey(startNodeId)) {
        issues.add(
          ContentValidationIssue(
            '$path.startNodeId',
            'must reference a known node',
          ),
        );
        continue;
      }

      final reachable = <String>{};
      String? current = startNodeId;
      while (current != null && reachable.add(current)) {
        final node = nodesById[current];
        if (node == null) {
          issues.add(
            ContentValidationIssue('$path.nodes', 'unknown next node $current'),
          );
          break;
        }
        final terminal = node['terminal'] == true;
        final next = node['nextNodeId'];
        if (terminal) {
          current = null;
        } else if (next is String) {
          current = next;
        } else {
          issues.add(
            ContentValidationIssue(
              '$path.nodes',
              'non-terminal node ${node['id']} needs nextNodeId',
            ),
          );
          current = null;
        }
      }
      if (current != null) {
        issues.add(
          ContentValidationIssue(
            '$path.nodes',
            'dialogue contains a cycle at $current',
          ),
        );
      }

      for (final nodeId in nodesById.keys) {
        if (!reachable.contains(nodeId)) {
          issues.add(
            ContentValidationIssue(
              '$path.nodes',
              'node $nodeId is unreachable',
            ),
          );
        }
      }
    }
  }

  void _validateAssets(
    List<Map<String, Object?>> assets,
    bool release,
    String source,
    List<ContentValidationIssue> issues,
  ) {
    for (var index = 0; index < assets.length; index++) {
      final asset = assets[index];
      final path = '$source.assets[$index]';
      final status = asset['status'];
      if (status != 'planned' && status != 'ready') {
        issues.add(
          ContentValidationIssue('$path.status', 'must be planned or ready'),
        );
      }
      if (release && status != 'ready') {
        issues.add(
          ContentValidationIssue(
            '$path.status',
            'release assets must be ready',
          ),
        );
      }
      if (status == 'ready' &&
          (asset['path'] is! String ||
              (asset['path'] as String).trim().isEmpty)) {
        issues.add(
          ContentValidationIssue('$path.path', 'is required when ready'),
        );
      }
      for (final field in ['license', 'credit']) {
        if (asset[field] is! String ||
            (asset[field] as String).trim().isEmpty) {
          issues.add(ContentValidationIssue('$path.$field', 'is required'));
        }
      }
    }
  }

  List<String> _stringList(
    Object? value,
    String path,
    List<ContentValidationIssue> issues,
  ) {
    if (value is! List) {
      issues.add(ContentValidationIssue(path, 'must be a list'));
      return const [];
    }
    final result = <String>[];
    for (var index = 0; index < value.length; index++) {
      final entry = value[index];
      if (entry is String) {
        result.add(entry);
      } else {
        issues.add(ContentValidationIssue('$path[$index]', 'must be a string'));
      }
    }
    return result;
  }

  int _hanziCount(String value) {
    return value.runes.where((rune) {
      return (rune >= 0x3400 && rune <= 0x4DBF) ||
          (rune >= 0x4E00 && rune <= 0x9FFF);
    }).length;
  }

  List<String> _stringListIfPresent(
    Object? value,
    String path,
    List<ContentValidationIssue> issues,
  ) {
    if (value == null) {
      return const [];
    }
    return _stringList(value, path, issues);
  }

  List<Map<String, Object?>> _mapList(
    Object? value,
    String path,
    List<ContentValidationIssue> issues,
  ) {
    if (value is! List) {
      issues.add(ContentValidationIssue(path, 'must be a list'));
      return const [];
    }
    final result = <Map<String, Object?>>[];
    for (var index = 0; index < value.length; index++) {
      final entry = value[index];
      if (entry is Map<String, Object?>) {
        result.add(entry);
      } else {
        issues.add(
          ContentValidationIssue('$path[$index]', 'must be an object'),
        );
      }
    }
    return result;
  }
}
