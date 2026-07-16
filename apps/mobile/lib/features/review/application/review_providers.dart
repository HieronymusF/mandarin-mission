import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_core/learning_core.dart';

import '../../../data/local/app_database_provider.dart';
import '../../../data/progress/lesson_progress_repository.dart';
import '../../../data/review/review_queue_repository.dart';

final reviewSchedulerProvider = Provider<ReviewScheduler>(
  (ref) => const ReviewScheduler(),
);

final reviewQueueRepositoryProvider = Provider<ReviewQueueRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ReviewQueueRepository(database, LessonProgressRepository(database));
});
