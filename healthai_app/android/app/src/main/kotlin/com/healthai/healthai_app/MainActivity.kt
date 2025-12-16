package com.healthai.healthai_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.healthai.healthai_app/health_connect"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openHealthConnectPermissions" -> {
                    val success = openHealthConnectPermissions()
                    result.success(success)
                }
                "openHealthConnectApp" -> {
                    val success = openHealthConnectApp()
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openHealthConnectPermissions(): Boolean {
        return try {
            // Health Connect 권한 관리 화면 열기
            val intent = Intent("androidx.health.ACTION_MANAGE_HEALTH_PERMISSIONS")
            intent.putExtra("android.intent.extra.PACKAGE_NAME", packageName)
            startActivity(intent)
            true
        } catch (e: Exception) {
            // 실패시 Health Connect 앱 자체를 열어봄
            try {
                val intent = Intent("android.health.connect.action.HEALTH_HOME_SETTINGS")
                startActivity(intent)
                true
            } catch (e2: Exception) {
                // 그것도 실패하면 Play Store의 Health Connect 페이지 열기
                try {
                    val intent = Intent(Intent.ACTION_VIEW)
                    intent.data = Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata")
                    startActivity(intent)
                    true
                } catch (e3: Exception) {
                    false
                }
            }
        }
    }

    private fun openHealthConnectApp(): Boolean {
        return try {
            // Health Connect 앱 열기 시도
            val intent = packageManager.getLaunchIntentForPackage("com.google.android.apps.healthdata")
            if (intent != null) {
                startActivity(intent)
                true
            } else {
                // Samsung Health Connect 시도
                val samsungIntent = packageManager.getLaunchIntentForPackage("com.samsung.android.health.connect")
                if (samsungIntent != null) {
                    startActivity(samsungIntent)
                    true
                } else {
                    false
                }
            }
        } catch (e: Exception) {
            false
        }
    }
}
