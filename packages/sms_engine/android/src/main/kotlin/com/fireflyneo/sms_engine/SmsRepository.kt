package com.fireflyneo.sms_engine

import android.content.Context
import android.net.Uri
import android.provider.Telephony
import android.util.Log
import java.util.concurrent.TimeUnit

/**
 * SmsRepository
 *
 * Reads historical SMS messages from the Android system SMS ContentProvider.
 * Filters by date range and returns a list of maps compatible with Flutter's
 * StandardMessageCodec (keys are Strings, values are primitives).
 */
class SmsRepository(private val context: Context) {

    companion object {
        private const val TAG = "NeoSmsRepository"

        /** URI for the SMS inbox. */
        private val SMS_INBOX_URI: Uri = Uri.parse("content://sms/inbox")

        /** Columns we care about. */
        private val PROJECTION = arrayOf(
            Telephony.Sms._ID,
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE,
        )
    }

    /**
     * Returns SMS messages from the system inbox for the past [days] days.
     *
     * Each message is returned as a [Map] with keys:
     *  - `sender`    (String)
     *  - `body`      (String)
     *  - `timestamp` (Long, milliseconds since epoch)
     *  - `platform`  (String, always "android")
     */
    fun getRecentMessages(days: Int): List<Map<String, Any>> {
        val cutoff = System.currentTimeMillis() - TimeUnit.DAYS.toMillis(days.toLong())
        val results = mutableListOf<Map<String, Any>>()

        val cursor = context.contentResolver.query(
            SMS_INBOX_URI,
            PROJECTION,
            "${Telephony.Sms.DATE} >= ?",
            arrayOf(cutoff.toString()),
            "${Telephony.Sms.DATE} DESC"
        )

        cursor?.use { c ->
            val idxAddress = c.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
            val idxBody    = c.getColumnIndexOrThrow(Telephony.Sms.BODY)
            val idxDate    = c.getColumnIndexOrThrow(Telephony.Sms.DATE)

            Log.d(TAG, "Found ${c.count} SMS messages in last $days days")

            while (c.moveToNext()) {
                val sender    = c.getString(idxAddress)  ?: continue
                val body      = c.getString(idxBody)     ?: continue
                val timestamp = c.getLong(idxDate)

                results.add(
                    mapOf(
                        "sender"    to sender,
                        "body"      to body,
                        "timestamp" to timestamp,
                        "platform"  to "android",
                    )
                )
            }
        } ?: Log.w(TAG, "ContentResolver returned null cursor for SMS inbox")

        return results
    }

    /**
     * Returns all SMS messages from a specific sender (partial match, case-insensitive)
     * within the past [days] days.
     */
    fun getMessagesFromSender(sender: String, days: Int = 30): List<Map<String, Any>> {
        val cutoff = System.currentTimeMillis() - TimeUnit.DAYS.toMillis(days.toLong())
        val results = mutableListOf<Map<String, Any>>()

        val cursor = context.contentResolver.query(
            SMS_INBOX_URI,
            PROJECTION,
            "${Telephony.Sms.DATE} >= ? AND ${Telephony.Sms.ADDRESS} LIKE ?",
            arrayOf(cutoff.toString(), "%$sender%"),
            "${Telephony.Sms.DATE} DESC"
        )

        cursor?.use { c ->
            val idxAddress = c.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
            val idxBody    = c.getColumnIndexOrThrow(Telephony.Sms.BODY)
            val idxDate    = c.getColumnIndexOrThrow(Telephony.Sms.DATE)

            while (c.moveToNext()) {
                val senderVal = c.getString(idxAddress) ?: continue
                val body      = c.getString(idxBody)    ?: continue
                val timestamp = c.getLong(idxDate)

                results.add(
                    mapOf(
                        "sender"    to senderVal,
                        "body"      to body,
                        "timestamp" to timestamp,
                        "platform"  to "android",
                    )
                )
            }
        }

        return results
    }
}
