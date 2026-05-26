package com.fireflyneo.sms_engine

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * SmsStreamHandler
 *
 * Bridges the Android [BroadcastReceiver] world with the Flutter EventChannel.
 * It holds the active [EventChannel.EventSink] and provides a thread-safe
 * [sendEvent] method that marshals onto the main (UI) thread.
 */
class SmsStreamHandler : EventChannel.StreamHandler {

    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    private var eventSink: EventChannel.EventSink? = null

    // ── StreamHandler ────────────────────────────────────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // ── Public API ───────────────────────────────────────────────────────────

    /**
     * Send [event] to Flutter.  Safe to call from any thread.
     * [event] must be a type supported by Flutter's StandardMessageCodec
     * (e.g. Map<String, Any?>).
     */
    fun sendEvent(event: Any) {
        mainHandler.post {
            eventSink?.success(event)
        }
    }

    /**
     * Forward an error to Flutter.  Safe to call from any thread.
     */
    fun sendError(code: String, message: String?, details: Any?) {
        mainHandler.post {
            eventSink?.error(code, message, details)
        }
    }
}
