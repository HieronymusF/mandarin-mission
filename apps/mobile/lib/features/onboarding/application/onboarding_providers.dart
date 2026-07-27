import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/onboarding_status_store.dart';

final initialOnboardingCompletedProvider = Provider<bool>((ref) => true);

final onboardingStatusStoreProvider = Provider<OnboardingStatusStore>(
  (ref) => SharedPreferencesOnboardingStatusStore(),
);

final onboardingCompletedProvider =
    NotifierProvider<OnboardingStatusController, bool>(
      OnboardingStatusController.new,
    );

final class OnboardingStatusController extends Notifier<bool> {
  @override
  bool build() => ref.watch(initialOnboardingCompletedProvider);

  Future<void> complete() async {
    if (state) return;
    await ref.read(onboardingStatusStoreProvider).markCompleted();
    state = true;
  }
}
