import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/theme/app_theme.dart';
import '../features/onboarding/application/onboarding_providers.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import 'router.dart';

class MandarinMissionApp extends ConsumerWidget {
  const MandarinMissionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shadTheme = buildAppShadTheme();
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    return ShadApp.custom(
      theme: shadTheme,
      appBuilder: (context) {
        return MaterialApp.router(
          title: 'Mandarin Mission',
          debugShowCheckedModeBanner: false,
          theme: buildAppMaterialTheme(Theme.of(context), shadTheme),
          routerConfig: ref.watch(appRouterProvider),
          localizationsDelegates: const [GlobalShadLocalizations.delegate],
          builder: (context, child) {
            return ShadAppBuilder(
              child: onboardingCompleted
                  ? child ?? const SizedBox.shrink()
                  : const OnboardingPage(),
            );
          },
        );
      },
    );
  }
}
