import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'course_content_repository.dart';

final courseContentRepositoryProvider = Provider<CourseContentRepository>(
  (ref) => CourseContentRepository(),
);
