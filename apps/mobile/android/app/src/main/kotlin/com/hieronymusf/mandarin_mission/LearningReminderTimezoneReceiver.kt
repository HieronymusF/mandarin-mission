package com.hieronymusf.mandarin_mission

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
import java.time.LocalDateTime
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import org.json.JSONArray

class LearningReminderTimezoneReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_TIMEZONE_CHANGED) return

        val preferences =
            context.getSharedPreferences(scheduledNotificationsStore, Context.MODE_PRIVATE)
        val cachedNotifications =
            preferences.getString(scheduledNotificationsKey, null) ?: return
        val notifications = runCatching { JSONArray(cachedNotifications) }.getOrNull() ?: return
        val now = ZonedDateTime.now()
        var reminderUpdated = false

        for (index in 0 until notifications.length()) {
            val notification = notifications.optJSONObject(index) ?: continue
            if (notification.optInt("id") != learningReminderNotificationId) continue
            val scheduledDateTime =
                runCatching {
                    LocalDateTime.parse(notification.getString("scheduledDateTime"))
                }.getOrNull() ?: continue
            var nextReminder = now.toLocalDate().atTime(scheduledDateTime.toLocalTime()).atZone(now.zone)
            if (!nextReminder.isAfter(now)) nextReminder = nextReminder.plusDays(1)

            notification.put("timeZoneName", now.zone.id)
            notification.put(
                "scheduledDateTime",
                nextReminder.toLocalDateTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
            )
            reminderUpdated = true
        }

        if (!reminderUpdated) return
        val saved =
            preferences
                .edit()
                .putString(scheduledNotificationsKey, notifications.toString())
                .commit()
        if (!saved) return

        ScheduledNotificationBootReceiver().onReceive(
            context,
            Intent(Intent.ACTION_MY_PACKAGE_REPLACED),
        )
    }

    private companion object {
        const val learningReminderNotificationId = 41001
        const val scheduledNotificationsStore = "scheduled_notifications"
        const val scheduledNotificationsKey = "scheduled_notifications"
    }
}
