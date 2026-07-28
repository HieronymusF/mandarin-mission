import 'package:shared_preferences/shared_preferences.dart';

final class AppPreferences {
  const AppPreferences({
    this.notificationsEnabled = false,
    this.notificationReminderMinutes,
    this.diagnosticsEnabled = false,
  });

  final bool notificationsEnabled;
  final int? notificationReminderMinutes;
  final bool diagnosticsEnabled;

  static const _unset = Object();

  AppPreferences copyWith({
    bool? notificationsEnabled,
    Object? notificationReminderMinutes = _unset,
    bool? diagnosticsEnabled,
  }) {
    return AppPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationReminderMinutes:
          identical(notificationReminderMinutes, _unset)
          ? this.notificationReminderMinutes
          : notificationReminderMinutes as int?,
      diagnosticsEnabled: diagnosticsEnabled ?? this.diagnosticsEnabled,
    );
  }
}

abstract interface class AppPreferencesStore {
  Future<AppPreferences> load();

  Future<void> setNotificationReminder({
    required bool enabled,
    int? minutesSinceMidnight,
  });

  Future<void> setDiagnosticsEnabled(bool enabled);
}

final class SharedPreferencesAppPreferencesStore
    implements AppPreferencesStore {
  SharedPreferencesAppPreferencesStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const notificationsKey = 'preferences.notifications.enabled.v1';
  static const notificationReminderMinutesKey =
      'preferences.notifications.reminder_minutes.v1';
  static const diagnosticsKey = 'preferences.diagnostics.enabled.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppPreferences> load() async {
    final reminderMinutes = await _preferences.getInt(
      notificationReminderMinutesKey,
    );
    final validReminderMinutes =
        reminderMinutes != null &&
            reminderMinutes >= 0 &&
            reminderMinutes < 1440
        ? reminderMinutes
        : null;
    return AppPreferences(
      notificationsEnabled:
          (await _preferences.getBool(notificationsKey) ?? false) &&
          validReminderMinutes != null,
      notificationReminderMinutes: validReminderMinutes,
      diagnosticsEnabled: await _preferences.getBool(diagnosticsKey) ?? false,
    );
  }

  @override
  Future<void> setNotificationReminder({
    required bool enabled,
    int? minutesSinceMidnight,
  }) async {
    if (enabled) {
      if (minutesSinceMidnight == null) {
        throw ArgumentError.notNull('minutesSinceMidnight');
      }
      final minutes = RangeError.checkValueInInterval(
        minutesSinceMidnight,
        0,
        1439,
        'minutesSinceMidnight',
      );
      await _preferences.setInt(notificationReminderMinutesKey, minutes);
    }
    await _preferences.setBool(notificationsKey, enabled);
  }

  @override
  Future<void> setDiagnosticsEnabled(bool enabled) {
    return _preferences.setBool(diagnosticsKey, enabled);
  }
}
