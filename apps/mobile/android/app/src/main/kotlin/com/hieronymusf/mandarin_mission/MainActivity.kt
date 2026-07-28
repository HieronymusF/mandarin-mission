package com.hieronymusf.mandarin_mission

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.hieronymusf.mandarinmission/learning_reminders",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isBackgroundRestricted" -> {
                    val activityManager =
                        getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    result.success(
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.P &&
                            activityManager.isBackgroundRestricted,
                    )
                }
                else -> result.notImplemented()
            }
        }
    }
}
