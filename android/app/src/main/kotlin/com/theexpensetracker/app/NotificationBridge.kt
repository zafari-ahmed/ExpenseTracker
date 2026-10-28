package com.theexpensetracker.app

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

object NotificationBridge {
    const val METHODS = "com.theexpensetracker.app/notification_access"
    const val EVENTS = "com.theexpensetracker.app/notification_events"

    @Volatile
    private var eventSink: EventChannel.EventSink? = null

    fun attach(context: Context, messenger: io.flutter.plugin.common.BinaryMessenger) {
        MethodChannel(messenger, METHODS).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessGranted" -> {
                    result.success(BankNotificationListenerService.isAccessGranted(context))
                }
                "openAccessSettings" -> {
                    BankNotificationListenerService.openAccessSettings(context)
                    result.success(null)
                }
                "setListeningEnabled" -> {
                    val enabled = call.arguments as? Boolean ?: false
                    BankNotificationListenerService.setListeningEnabled(context, enabled)
                    result.success(null)
                }
                "isListeningEnabled" -> {
                    result.success(BankNotificationListenerService.isListeningEnabled(context))
                }
                "drainPending" -> {
                    result.success(BankNotificationListenerService.drainPending(context))
                }
                "getActiveNotifications" -> {
                    result.success(BankNotificationListenerService.readActiveNotifications())
                }
                "getInstalledApps" -> {
                    result.success(listInstalledApps(context))
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, EVENTS).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    fun emit(payload: Map<String, Any?>): Boolean {
        val sink = eventSink ?: return false
        return try {
            // EventChannel must be called on the main thread.
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                try {
                    eventSink?.success(payload)
                } catch (_: Exception) {
                    // Ignore if sink closed mid-post.
                }
            }
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun listInstalledApps(context: Context): List<Map<String, Any?>> {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN, null).addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfos = if (android.os.Build.VERSION.SDK_INT >= 33) {
            pm.queryIntentActivities(
                intent,
                PackageManager.ResolveInfoFlags.of(0),
            )
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(intent, 0)
        }

        val apps = ArrayList<Map<String, Any?>>()
        val seen = HashSet<String>()
        for (info in resolveInfos) {
            val packageName = info.activityInfo?.packageName ?: continue
            if (!seen.add(packageName)) continue
            if (packageName == BankNotificationListenerService.OUR_PACKAGE) continue

            val label = try {
                info.loadLabel(pm)?.toString()?.trim().orEmpty()
            } catch (_: Exception) {
                packageName
            }
            if (label.isEmpty()) continue

            var iconBase64: String? = null
            try {
                val drawable = info.loadIcon(pm)
                iconBase64 = drawableToBase64(drawable)
            } catch (_: Exception) {
                // Icon optional.
            }

            apps.add(
                mapOf(
                    "packageName" to packageName,
                    "label" to label,
                    "iconBase64" to iconBase64,
                ),
            )
        }

        apps.sortBy { (it["label"] as? String)?.lowercase() ?: "" }
        return apps
    }

    private fun drawableToBase64(drawable: Drawable): String? {
        val bitmap = when (drawable) {
            is BitmapDrawable -> drawable.bitmap
            else -> {
                val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
                val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
                val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }
        } ?: return null

        val scaled = if (bitmap.width > 96 || bitmap.height > 96) {
            Bitmap.createScaledBitmap(bitmap, 96, 96, true)
        } else {
            bitmap
        }

        val stream = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.PNG, 85, stream)
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }
}
