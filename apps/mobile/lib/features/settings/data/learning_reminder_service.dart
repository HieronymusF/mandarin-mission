final class DailyReminderTime {
  const DailyReminderTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour <= 23),
      assert(minute >= 0 && minute <= 59);

  factory DailyReminderTime.fromMinutesSinceMidnight(int minutes) {
    RangeError.checkValueInInterval(minutes, 0, 1439, 'minutes');
    return DailyReminderTime(hour: minutes ~/ 60, minute: minutes % 60);
  }

  final int hour;
  final int minute;

  int get minutesSinceMidnight => hour * 60 + minute;
}

enum LearningReminderPermission {
  granted,
  denied,
  permanentlyDenied,
  unavailable,
}

abstract interface class LearningReminderService {
  Future<bool> isBackgroundRestricted();

  Future<LearningReminderPermission> permissionStatus();

  Future<LearningReminderPermission> requestPermission();

  Future<void> scheduleDaily(DailyReminderTime time);

  Future<void> cancelDaily();

  Future<void> openSystemSettings();
}
