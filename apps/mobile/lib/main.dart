import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/onboarding/application/onboarding_providers.dart';
import 'features/onboarding/data/onboarding_status_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final onboardingStore = SharedPreferencesOnboardingStatusStore();
  final onboardingCompleted = await loadInitialOnboardingCompleted(
    onboardingStore,
  );
  runApp(
    ProviderScope(
      overrides: [
        onboardingStatusStoreProvider.overrideWithValue(onboardingStore),
        initialOnboardingCompletedProvider.overrideWithValue(
          onboardingCompleted,
        ),
      ],
      child: const MandarinMissionApp(),
    ),
  );
}
