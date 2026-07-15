import 'dart:convert';
import 'dart:io';

import 'package:learning_core/learning_core.dart';

void main(List<String> arguments) {
  final inputPath = arguments.isEmpty ? '../../content/fixtures' : arguments[0];
  final input = Directory(inputPath);
  if (!input.existsSync()) {
    stderr.writeln('Content directory does not exist: ${input.absolute.path}');
    exitCode = 64;
    return;
  }

  final files =
      input
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.json'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  if (files.isEmpty) {
    stderr.writeln('No JSON content packages found in ${input.absolute.path}');
    exitCode = 64;
    return;
  }

  final validator = ContentValidator();
  final issues = <ContentValidationIssue>[];
  for (final file in files) {
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map<String, Object?>) {
        issues.add(ContentValidationIssue(file.path, 'root must be an object'));
        continue;
      }
      issues.addAll(validator.validate(decoded, source: file.path));
    } on FormatException catch (error) {
      issues.add(ContentValidationIssue(file.path, 'invalid JSON: $error'));
    }
  }

  if (issues.isNotEmpty) {
    for (final issue in issues) {
      stderr.writeln(issue);
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Validated ${files.length} content package(s).');
}
