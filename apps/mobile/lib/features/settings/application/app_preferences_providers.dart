import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_preferences_store.dart';

final appPreferencesStoreProvider = Provider<AppPreferencesStore>(
  (ref) => SharedPreferencesAppPreferencesStore(),
);

final appPreferencesControllerProvider =
    AsyncNotifierProvider.autoDispose<AppPreferencesController, AppPreferences>(
      AppPreferencesController.new,
    );

final class AppPreferencesController extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() {
    return ref.read(appPreferencesStoreProvider).load();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = state.value;
    if (current == null || state.isLoading) return;
    state = const AsyncLoading<AppPreferences>();
    try {
      await ref
          .read(appPreferencesStoreProvider)
          .setNotificationsEnabled(enabled);
      state = AsyncData(current.copyWith(notificationsEnabled: enabled));
    } on Object catch (error, stackTrace) {
      state = AsyncError<AppPreferences>(error, stackTrace);
    }
  }

  Future<void> setDiagnosticsEnabled(bool enabled) async {
    final current = state.value;
    if (current == null || state.isLoading) return;
    state = const AsyncLoading<AppPreferences>();
    try {
      await ref
          .read(appPreferencesStoreProvider)
          .setDiagnosticsEnabled(enabled);
      state = AsyncData(current.copyWith(diagnosticsEnabled: enabled));
    } on Object catch (error, stackTrace) {
      state = AsyncError<AppPreferences>(error, stackTrace);
    }
  }
}
