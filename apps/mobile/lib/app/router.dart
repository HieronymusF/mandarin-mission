import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/journey/presentation/journey_page.dart';
import '../features/lesson/presentation/lesson_overview_page.dart';
import '../features/review/presentation/review_page.dart';
import '../features/settings/presentation/data_management_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/trust_info_page.dart';
import 'main_navigation_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            MainNavigationShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const JourneyPage()),
          GoRoute(
            name: 'review',
            path: '/review',
            builder: (context, state) => const ReviewPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'help',
                builder: (context, state) =>
                    const TrustInfoPage(kind: TrustInfoPageKind.help),
              ),
              GoRoute(
                path: 'privacy',
                builder: (context, state) =>
                    const TrustInfoPage(kind: TrustInfoPageKind.privacy),
              ),
              GoRoute(
                path: 'terms',
                builder: (context, state) =>
                    const TrustInfoPage(kind: TrustInfoPageKind.terms),
              ),
              GoRoute(
                path: 'data',
                builder: (context, state) => const DataManagementPage(),
              ),
            ],
          ),
        ],
      ),
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
