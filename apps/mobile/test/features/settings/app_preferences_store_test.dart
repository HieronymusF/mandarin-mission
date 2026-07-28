import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/features/settings/data/app_preferences_store.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'does not treat a legacy consent flag as a scheduled reminder',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            SharedPreferencesAppPreferencesStore.notificationsKey: true,
          });
      final preferences = await SharedPreferencesAppPreferencesStore().load();

      expect(preferences.notificationsEnabled, isFalse);
      expect(preferences.notificationReminderMinutes, isNull);
    },
  );

  test(
    'persists reminder time and preserves it when reminders are disabled',
    () async {
      final store = SharedPreferencesAppPreferencesStore();

      await store.setNotificationReminder(
        enabled: true,
        minutesSinceMidnight: 8 * 60 + 45,
      );
      final enabled = await store.load();
      expect(enabled.notificationsEnabled, isTrue);
      expect(enabled.notificationReminderMinutes, 8 * 60 + 45);

      await store.setNotificationReminder(enabled: false);
      final disabled = await store.load();
      expect(disabled.notificationsEnabled, isFalse);
      expect(disabled.notificationReminderMinutes, 8 * 60 + 45);
    },
  );
}
