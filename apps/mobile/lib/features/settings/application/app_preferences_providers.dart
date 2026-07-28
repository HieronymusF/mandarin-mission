import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_preferences_store.dart';
import '../data/learning_reminder_service.dart';
import '../data/local_learning_reminder_service.dart';

final appPreferencesStoreProvider = Provider<AppPreferencesStore>(
  (ref) => SharedPreferencesAppPreferencesStore(),
);

final learningReminderServiceProvider = Provider<LearningReminderService>(
  (ref) => LocalLearningReminderService(),
);

final appPreferencesControllerProvider =
    AsyncNotifierProvider.autoDispose<AppPreferencesController, AppPreferences>(
      AppPreferencesController.new,
    );

final class AppPreferencesController extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() async {
    final preferences = await ref.read(appPreferencesStoreProvider).load();
    if (!preferences.notificationsEnabled) return preferences;
    final permission = await ref
        .read(learningReminderServiceProvider)
        .permissionStatus();
    return permission == LearningReminderPermission.granted
        ? preferences
        : preferences.copyWith(notificationsEnabled: false);
  }

  Future<LearningReminderUpdate> enableNotifications(
    DailyReminderTime time,
  ) async {
    final current = state.value;
    if (current == null || state.isLoading) {
      return LearningReminderUpdate.failed;
    }
    final service = ref.read(learningReminderServiceProvider);
    try {
      if (await service.isBackgroundRestricted()) {
        return LearningReminderUpdate.backgroundRestricted;
      }
      var permission = await service.permissionStatus();
      if (permission == LearningReminderPermission.denied) {
        permission = await service.requestPermission();
      }
      switch (permission) {
        case LearningReminderPermission.denied:
          return LearningReminderUpdate.permissionDenied;
        case LearningReminderPermission.permanentlyDenied:
          return LearningReminderUpdate.permissionPermanentlyDenied;
        case LearningReminderPermission.unavailable:
          return LearningReminderUpdate.unavailable;
        case LearningReminderPermission.granted:
          break;
      }
      await service.scheduleDaily(time);
      try {
        await ref
            .read(appPreferencesStoreProvider)
            .setNotificationReminder(
              enabled: true,
              minutesSinceMidnight: time.minutesSinceMidnight,
            );
      } on Object {
        await service.cancelDaily();
        rethrow;
      }
      state = AsyncData(
        current.copyWith(
          notificationsEnabled: true,
          notificationReminderMinutes: time.minutesSinceMidnight,
        ),
      );
      return LearningReminderUpdate.enabled;
    } on Object {
      state = AsyncData(current);
      return LearningReminderUpdate.failed;
    }
  }

  Future<LearningReminderUpdate> disableNotifications() async {
    final current = state.value;
    if (current == null || state.isLoading) {
      return LearningReminderUpdate.failed;
    }
    final service = ref.read(learningReminderServiceProvider);
    try {
      await service.cancelDaily();
      try {
        await ref
            .read(appPreferencesStoreProvider)
            .setNotificationReminder(enabled: false);
      } on Object {
        final minutes = current.notificationReminderMinutes;
        if (current.notificationsEnabled && minutes != null) {
          await service.scheduleDaily(
            DailyReminderTime.fromMinutesSinceMidnight(minutes),
          );
        }
        rethrow;
      }
      state = AsyncData(current.copyWith(notificationsEnabled: false));
      return LearningReminderUpdate.disabled;
    } on Object {
      state = AsyncData(current);
      return LearningReminderUpdate.failed;
    }
  }

  Future<void> openNotificationSettings() {
    return ref.read(learningReminderServiceProvider).openSystemSettings();
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

enum LearningReminderUpdate {
  enabled,
  disabled,
  permissionDenied,
  permissionPermanentlyDenied,
  backgroundRestricted,
  unavailable,
  failed,
}
