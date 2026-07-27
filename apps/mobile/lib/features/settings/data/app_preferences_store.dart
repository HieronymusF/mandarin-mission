import 'package:shared_preferences/shared_preferences.dart';

final class AppPreferences {
  const AppPreferences({
    this.notificationsEnabled = false,
    this.diagnosticsEnabled = false,
  });

  final bool notificationsEnabled;
  final bool diagnosticsEnabled;

  AppPreferences copyWith({
    bool? notificationsEnabled,
    bool? diagnosticsEnabled,
  }) {
    return AppPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      diagnosticsEnabled: diagnosticsEnabled ?? this.diagnosticsEnabled,
    );
  }
}

abstract interface class AppPreferencesStore {
  Future<AppPreferences> load();

  Future<void> setNotificationsEnabled(bool enabled);

  Future<void> setDiagnosticsEnabled(bool enabled);
}

final class SharedPreferencesAppPreferencesStore
    implements AppPreferencesStore {
  SharedPreferencesAppPreferencesStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const notificationsKey = 'preferences.notifications.enabled.v1';
  static const diagnosticsKey = 'preferences.diagnostics.enabled.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppPreferences> load() async {
    return AppPreferences(
      notificationsEnabled:
          await _preferences.getBool(notificationsKey) ?? false,
      diagnosticsEnabled: await _preferences.getBool(diagnosticsKey) ?? false,
    );
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) {
    return _preferences.setBool(notificationsKey, enabled);
  }

  @override
  Future<void> setDiagnosticsEnabled(bool enabled) {
    return _preferences.setBool(diagnosticsKey, enabled);
  }
}
