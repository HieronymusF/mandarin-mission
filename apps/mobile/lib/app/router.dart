import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/journey/presentation/journey_page.dart';
import '../features/lesson/presentation/lesson_overview_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const JourneyPage()),
      GoRoute(
        name: 'lesson',
        path: '/lessons/:lessonId',
        builder: (context, state) =>
            LessonOverviewPage(lessonId: state.pathParameters['lessonId']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
