import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/content/course_content_models.dart';
import '../../../data/content/course_content_provider.dart';
import '../../../data/local/app_database.dart';
import '../../lesson/application/lesson_providers.dart';

final journeyProgressProvider = FutureProvider.autoDispose<JourneyProgress>((
  ref,
) async {
  final package = await ref.watch(coursePackageProvider.future);
  final progressIds = <String>{
    ...package.lessonsById.keys,
    for (final location in package.locations)
      if (package.hasStandaloneChallenge(location)) location.challengeId,
  };
  final progressFutures = {
    for (final id in progressIds)
      id: ref.watch(lessonProgressProvider(id).future),
  };
  final progress = <String, LessonProgressEntry?>{};
  for (final entry in progressFutures.entries) {
    progress[entry.key] = await entry.value;
  }
  return JourneyProgress(package: package, progressById: progress);
});

final class JourneyProgress {
  const JourneyProgress({required this.package, required this.progressById});

  final CoursePackage package;
  final Map<String, LessonProgressEntry?> progressById;

  String? statusFor(String id) => progressById[id]?.status;

  bool isCompleted(String id) => statusFor(id) == 'completed';

  bool isLessonUnlocked(CourseLocation location, CourseLesson lesson) {
    if (isCompleted(lesson.id)) {
      return true;
    }
    return isLocationUnlocked(location) &&
        lesson.prerequisites.every(isCompleted);
  }

  bool isChallengeUnlocked(CourseLocation location) {
    if (isCompleted(location.challengeId)) {
      return true;
    }
    return isLocationUnlocked(location) &&
        location.lessonIds.every(isCompleted);
  }

  bool isLocationUnlocked(CourseLocation location) {
    final index = package.locations.indexWhere(
      (candidate) => candidate.id == location.id,
    );
    if (index <= 0) {
      return index == 0;
    }
    final previous = package.locations[index - 1];
    if (package.hasStandaloneChallenge(previous)) {
      return isCompleted(previous.challengeId);
    }
    return previous.lessonIds.every(isCompleted);
  }
}
