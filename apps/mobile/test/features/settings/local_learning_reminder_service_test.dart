import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/features/settings/data/learning_reminder_service.dart';
import 'package:mandarin_mission/features/settings/data/local_learning_reminder_service.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

void main() {
  setUpAll(() {
    timezone_data.initializeTimeZones();
    timezone.setLocalLocation(timezone.UTC);
  });

  test('uses the requested time later on the same day', () {
    final now = timezone.TZDateTime(timezone.local, 2026, 7, 27, 8, 30);

    expect(
      nextDailyReminder(const DailyReminderTime(hour: 19, minute: 15), now),
      timezone.TZDateTime(timezone.local, 2026, 7, 27, 19, 15),
    );
  });

  test(
    'maps platform GMT and UTC identifiers to the timezone UTC location',
    () {
      expect(resolveTimezoneLocation('GMT'), same(timezone.UTC));
      expect(resolveTimezoneLocation('UTC'), same(timezone.UTC));
    },
  );

  test('moves the requested time to tomorrow after it has passed', () {
    final now = timezone.TZDateTime(timezone.local, 2026, 7, 27, 20);

    expect(
      nextDailyReminder(const DailyReminderTime(hour: 19, minute: 15), now),
      timezone.TZDateTime(timezone.local, 2026, 7, 28, 19, 15),
    );
  });
}
