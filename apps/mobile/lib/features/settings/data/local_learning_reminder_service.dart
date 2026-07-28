import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import 'learning_reminder_service.dart';

final class LocalLearningReminderService implements LearningReminderService {
  LocalLearningReminderService({FlutterLocalNotificationsPlugin? notifications})
    : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  static const notificationId = 41001;
  static const channelId = 'daily_learning_reminders_v1';
  static const _platform = MethodChannel(
    'com.hieronymusf.mandarinmission/learning_reminders',
  );

  final FlutterLocalNotificationsPlugin _notifications;
  Future<void>? _initialization;

  @override
  Future<bool> isBackgroundRestricted() async {
    if (!Platform.isAndroid) return false;
    return await _platform.invokeMethod<bool>('isBackgroundRestricted') ?? true;
  }

  @override
  Future<LearningReminderPermission> permissionStatus() async {
    if (!Platform.isAndroid) return LearningReminderPermission.unavailable;
    return _mapPermission(await permissions.Permission.notification.status);
  }

  @override
  Future<LearningReminderPermission> requestPermission() async {
    if (!Platform.isAndroid) return LearningReminderPermission.unavailable;
    return _mapPermission(await permissions.Permission.notification.request());
  }

  @override
  Future<void> scheduleDaily(DailyReminderTime time) async {
    await _ensureInitialized();
    await _notifications.zonedSchedule(
      id: notificationId,
      title: 'Time for Mandarin',
      body: 'A short lesson or review is ready when you are.',
      scheduledDate: nextDailyReminder(
        time,
        timezone.TZDateTime.now(timezone.local),
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Daily learning reminders',
          channelDescription:
              'Optional reminders to return for a short lesson or review.',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelDaily() async {
    await _ensureInitialized();
    await _notifications.cancel(id: notificationId);
  }

  @override
  Future<void> openSystemSettings() async {
    await permissions.openAppSettings();
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Local learning reminders require Android.');
    }
    timezone_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(
      resolveTimezoneLocation(localTimezone.identifier),
    );
    final initialized = await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('notification_bell'),
      ),
    );
    if (initialized == false) {
      throw StateError('Local notifications could not be initialized.');
    }
  }

  LearningReminderPermission _mapPermission(
    permissions.PermissionStatus status,
  ) {
    if (status.isGranted) return LearningReminderPermission.granted;
    if (status.isPermanentlyDenied) {
      return LearningReminderPermission.permanentlyDenied;
    }
    if (status.isDenied) return LearningReminderPermission.denied;
    return LearningReminderPermission.unavailable;
  }
}

timezone.Location resolveTimezoneLocation(String identifier) {
  if (identifier == 'GMT' || identifier == 'UTC') return timezone.UTC;
  return timezone.getLocation(identifier);
}

timezone.TZDateTime nextDailyReminder(
  DailyReminderTime time,
  timezone.TZDateTime now,
) {
  var scheduled = timezone.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  if (!scheduled.isAfter(now)) {
    scheduled = timezone.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day + 1,
      time.hour,
      time.minute,
    );
  }
  return scheduled;
}
