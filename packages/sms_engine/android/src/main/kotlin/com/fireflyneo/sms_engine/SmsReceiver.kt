package com.fireflyneo.sms_engine

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telephony.SmsMessage
import android.util.Log

/**
 * SmsReceiver
 *
 * Receives the `android.provider.Telephony.SMS_RECEIVED` broadcast, extracts
 * each [SmsMessage], and forwards the data to the active Flutter EventChannel
 * sink via [SmsStreamHandler].
 */
class SmsReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "NeoSmsReceiver"
        private const val SMS_RECEIVED_ACTION = "android.provider.Telephony.SMS_RECEIVED"

        /** Weak reference to the active event sink — managed by the plugin. */
        @Volatile
        private var streamHandler: SmsStreamHandler? = null

        fun setStreamHandler(handler: SmsStreamHandler?) {
            streamHandler = handler
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != SMS_RECEIVED_ACTION) return

        val bundle = intent.extras ?: run {
            Log.w(TAG, "SMS_RECEIVED intent has no extras")
            return
        }

        val pdus = bundle.get("pdus") as? Array<*> ?: run {
            Log.w(TAG, "No PDUs in SMS_RECEIVED extras")
            return
        }

        val format = bundle.getString("format") ?: "3gpp"
        val now = System.currentTimeMillis()

        for (pdu in pdus) {
            val pduBytes = pdu as? ByteArray ?: continue

            val smsMessage: SmsMessage = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                SmsMessage.createFromPdu(pduBytes, format)
            } else {
                @Suppress("DEPRECATION")
                SmsMessage.createFromPdu(pduBytes)
            } ?: continue

            val sender    = smsMessage.displayOriginatingAddress ?: smsMessage.originatingAddress ?: ""
            val body      = smsMessage.displayMessageBody ?: smsMessage.messageBody ?: ""
            // Use the SMS timestamp if valid, otherwise fall back to current time.
            val rawTs     = smsMessage.timestampMillis
            val timestamp = if (rawTs > 0) rawTs else now

            Log.d(TAG, "SMS received from $sender at $timestamp")

            val event = mapOf(
                "sender"    to sender,
                "body"      to body,
                "timestamp" to timestamp,
                "platform"  to "android",
            )

            // Push to Flutter on the main thread.
            streamHandler?.sendEvent(event) ?: Log.w(TAG, "No active stream handler – event dropped")
        }
    }
}
