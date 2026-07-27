import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OnboardingStatusStore {
  Future<bool> isCompleted();

  Future<void> markCompleted();
}

final class SharedPreferencesOnboardingStatusStore
    implements OnboardingStatusStore {
  SharedPreferencesOnboardingStatusStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const completionKey = 'onboarding.completed.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> isCompleted() async {
    return await _preferences.getBool(completionKey) ?? false;
  }

  @override
  Future<void> markCompleted() {
    return _preferences.setBool(completionKey, true);
  }
}

Future<bool> loadInitialOnboardingCompleted(OnboardingStatusStore store) async {
  try {
    return await store.isCompleted();
  } on Object {
    return true;
  }
}
