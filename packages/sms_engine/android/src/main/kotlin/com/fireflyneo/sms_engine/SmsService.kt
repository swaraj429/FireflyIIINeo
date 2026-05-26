package com.fireflyneo.sms_engine

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * SmsService
 *
 * A foreground [Service] that registers a [BroadcastReceiver] to monitor
 * incoming SMS messages and pipes them into the Flutter EventChannel via
 * [SmsStreamHandler].
 *
 * The foreground notification keeps Android from killing the process while
 * the user has SMS monitoring enabled.
 */
class SmsService : Service() {

    companion object {
        const val CHANNEL_ID       = "neo_sms_channel"
        const val CHANNEL_NAME     = "FireflyIII Neo – SMS Monitor"
        const val NOTIFICATION_ID  = 1001

        // Internal action used by receiver to push events without a context ref
        const val ACTION_SMS_PUSH  = "com.fireflyneo.sms_engine.SMS_PUSH"
    }

    private lateinit var smsReceiver: SmsReceiver

    // ── Lifecycle ────────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        smsReceiver = SmsReceiver()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, buildNotification())

        // Register the SMS broadcast receiver dynamically so it can push events
        // to the active EventChannel sink.
        val filter = IntentFilter("android.provider.Telephony.SMS_RECEIVED").apply {
            priority = IntentFilter.SYSTEM_HIGH_PRIORITY
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(smsReceiver, filter, RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(smsReceiver, filter)
        }

        // START_STICKY: system restarts the service if killed, with a null intent.
        return START_STICKY
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(smsReceiver)
        } catch (_: IllegalArgumentException) {
            // Receiver was never registered – ignore.
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ── Notification ─────────────────────────────────────────────────────────

    private fun buildNotification(): Notification {
        // Tap the notification to open the app (requires a launcher intent).
        val launchIntent = packageManager
            .getLaunchIntentForPackage(packageName)
            ?.apply { flags = Intent.FLAG_ACTIVITY_SINGLE_TOP }

        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = launchIntent?.let {
            PendingIntent.getActivity(this, 0, it, pendingFlags)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("FireflyIII Neo")
            .setContentText("Monitoring transactions via SMS…")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps FireflyIII Neo running to capture bank SMS alerts"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }
}
