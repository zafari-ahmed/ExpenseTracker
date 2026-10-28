package com.theexpensetracker.app

import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

/**
 * Reads bank app alerts for cards with parseSource=notification.
 * Only forwards notifications when Flutter has enabled listening
 * (at least one active notification-based card).
 */
class BankNotificationListenerService : NotificationListenerService() {

    override fun onListenerConnected() {
        super.onListenerConnected()
        instance = this
        if (!isListeningEnabled(this)) return
        try {
            val active = activeNotifications ?: emptyArray()
            for (sbn in active) {
                forwardNotification(sbn, fromActiveScan = true)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Active notification scan failed", e)
        }
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        if (instance === this) {
            instance = null
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return
        if (!isListeningEnabled(this)) return
        forwardNotification(sbn, fromActiveScan = false)
    }

    private fun forwardNotification(
        sbn: StatusBarNotification,
        fromActiveScan: Boolean,
    ) {
        val packageName = sbn.packageName ?: return
        if (packageName == OUR_PACKAGE) return

        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString().orEmpty()

        val bodyParts = linkedSetOf<String>()
        if (title.isNotBlank()) bodyParts.add(title.trim())
        if (text.isNotBlank()) bodyParts.add(text.trim())
        if (bigText.isNotBlank() && bigText.trim() != text.trim()) {
            bodyParts.add(bigText.trim())
        }
        val combined = bodyParts.joinToString("\n").trim()
        if (combined.isEmpty()) return

        val payload = mapOf(
            "packageName" to packageName,
            "title" to title,
            "text" to combined,
            "postedAtMillis" to sbn.postTime,
            "fromActiveScan" to fromActiveScan,
            "key" to (sbn.key ?: "$packageName:${sbn.id}:${sbn.postTime}"),
        )

        val delivered = NotificationBridge.emit(payload)
        if (!delivered) {
            enqueuePending(this, payload)
        }
    }

    companion object {
        private const val TAG = "BankNotifListener"
        const val OUR_PACKAGE = "com.theexpensetracker.app"
        private const val PREFS = "notification_ingest_prefs"
        private const val KEY_ENABLED = "listening_enabled"
        private const val KEY_PENDING = "pending_notifications"
        private const val MAX_PENDING = 40

        @Volatile
        private var instance: BankNotificationListenerService? = null

        fun isListeningEnabled(context: Context): Boolean {
            return prefs(context).getBoolean(KEY_ENABLED, false)
        }

        fun setListeningEnabled(context: Context, enabled: Boolean) {
            prefs(context).edit().putBoolean(KEY_ENABLED, enabled).apply()
        }

        fun isAccessGranted(context: Context): Boolean {
            val flat = Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners",
            ) ?: return false
            val cn = ComponentName(context, BankNotificationListenerService::class.java)
            val flatFull = cn.flattenToString()
            val flatShort = cn.flattenToShortString()
            if (flat.contains(flatFull) || flat.contains(flatShort)) return true
            return flat.split(':').any { enabled ->
                val parsed = ComponentName.unflattenFromString(enabled) ?: return@any false
                parsed.packageName == cn.packageName && parsed.className == cn.className
            }
        }

        fun openAccessSettings(context: Context) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }

        fun drainPending(context: Context): List<Map<String, Any?>> {
            val prefs = prefs(context)
            val raw = prefs.getString(KEY_PENDING, null) ?: return emptyList()
            prefs.edit().remove(KEY_PENDING).apply()
            return try {
                val arr = JSONArray(raw)
                val out = ArrayList<Map<String, Any?>>(arr.length())
                for (i in 0 until arr.length()) {
                    val obj = arr.getJSONObject(i)
                    out.add(
                        mapOf(
                            "packageName" to obj.optString("packageName"),
                            "title" to obj.optString("title"),
                            "text" to obj.optString("text"),
                            "postedAtMillis" to obj.optLong("postedAtMillis"),
                            "fromActiveScan" to obj.optBoolean("fromActiveScan"),
                            "key" to obj.optString("key"),
                        ),
                    )
                }
                out
            } catch (_: Exception) {
                emptyList()
            }
        }

        fun readActiveNotifications(): List<Map<String, Any?>> {
            val service = instance ?: return emptyList()
            if (!isListeningEnabled(service)) return emptyList()
            return try {
                val active = service.activeNotifications ?: return emptyList()
                active.mapNotNull { sbn ->
                    val packageName = sbn.packageName ?: return@mapNotNull null
                    if (packageName == OUR_PACKAGE) return@mapNotNull null
                    val extras = sbn.notification?.extras ?: return@mapNotNull null
                    val title =
                        extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
                    val text =
                        extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
                    val bigText =
                        extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString().orEmpty()
                    val bodyParts = linkedSetOf<String>()
                    if (title.isNotBlank()) bodyParts.add(title.trim())
                    if (text.isNotBlank()) bodyParts.add(text.trim())
                    if (bigText.isNotBlank() && bigText.trim() != text.trim()) {
                        bodyParts.add(bigText.trim())
                    }
                    val combined = bodyParts.joinToString("\n").trim()
                    if (combined.isEmpty()) return@mapNotNull null
                    mapOf(
                        "packageName" to packageName,
                        "title" to title,
                        "text" to combined,
                        "postedAtMillis" to sbn.postTime,
                        "fromActiveScan" to true,
                        "key" to (sbn.key ?: "$packageName:${sbn.id}:${sbn.postTime}"),
                    )
                }
            } catch (e: Exception) {
                Log.w(TAG, "readActiveNotifications failed", e)
                emptyList()
            }
        }

        private fun enqueuePending(context: Context, payload: Map<String, Any?>) {
            try {
                val prefs = prefs(context)
                val existing = prefs.getString(KEY_PENDING, null)
                val arr = if (existing.isNullOrBlank()) JSONArray() else JSONArray(existing)
                val obj = JSONObject()
                obj.put("packageName", payload["packageName"])
                obj.put("title", payload["title"])
                obj.put("text", payload["text"])
                obj.put("postedAtMillis", payload["postedAtMillis"])
                obj.put("fromActiveScan", payload["fromActiveScan"])
                obj.put("key", payload["key"])
                arr.put(obj)
                while (arr.length() > MAX_PENDING) {
                    arr.remove(0)
                }
                prefs.edit().putString(KEY_PENDING, arr.toString()).apply()
            } catch (e: Exception) {
                Log.w(TAG, "enqueuePending failed", e)
            }
        }

        private fun prefs(context: Context): SharedPreferences {
            return context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        }
    }
}
