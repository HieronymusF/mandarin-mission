import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'course_content_models.dart';
import 'course_content_repository.dart';

final courseContentRepositoryProvider = Provider<CourseContentRepository>(
  (ref) => CourseContentRepository(),
);

final coursePackageProvider = FutureProvider<CoursePackage>(
  (ref) => ref.watch(courseContentRepositoryProvider).loadPackage(),
);
