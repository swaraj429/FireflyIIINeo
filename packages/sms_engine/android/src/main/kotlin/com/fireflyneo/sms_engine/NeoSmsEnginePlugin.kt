package com.fireflyneo.sms_engine

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/**
 * NeoSmsEnginePlugin
 *
 * Main Flutter plugin entry-point.  Handles:
 *  - MethodChannel: requestPermissions, hasPermission, startListening,
 *                   stopListening, getRecentSms
 *  - EventChannel:  real-time SMS events streamed from SmsReceiver
 */
class NeoSmsEnginePlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    companion object {
        private const val METHOD_CHANNEL = "com.fireflyneo/sms_engine"
        private const val EVENT_CHANNEL  = "com.fireflyneo/sms_stream"
        private const val SMS_PERMISSION_REQUEST_CODE = 9090

        private val SMS_PERMISSIONS = buildList {
            add(Manifest.permission.RECEIVE_SMS)
            add(Manifest.permission.READ_SMS)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }.toTypedArray()
    }

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var pendingPermissionResult: Result? = null

    // EventChannel sink managed by SmsStreamHandler
    private val streamHandler = SmsStreamHandler()

    // ── FlutterPlugin ────────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(streamHandler)

        // Make the stream handler accessible to SmsReceiver so it can push events.
        SmsReceiver.setStreamHandler(streamHandler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        SmsReceiver.setStreamHandler(null)
    }

    // ── ActivityAware ────────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    // ── MethodCallHandler ────────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "requestPermissions" -> handleRequestPermissions(result)
            "hasPermission"      -> result.success(checkAllPermissionsGranted())
            "startListening"     -> handleStartListening(result)
            "stopListening"      -> handleStopListening(result)
            "getRecentSms"       -> handleGetRecentSms(call, result)
            else                 -> result.notImplemented()
        }
    }

    private fun handleRequestPermissions(result: Result) {
        val act = activity ?: run {
            result.error("NO_ACTIVITY", "Activity is not attached", null)
            return
        }
        if (checkAllPermissionsGranted()) {
            result.success(true)
            return
        }
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(act, SMS_PERMISSIONS, SMS_PERMISSION_REQUEST_CODE)
    }

    private fun handleStartListening(result: Result) {
        if (!checkAllPermissionsGranted()) {
            result.error("PERMISSION_DENIED", "SMS permissions not granted", null)
            return
        }
        val intent = Intent(context, SmsService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
        result.success(null)
    }

    private fun handleStopListening(result: Result) {
        val intent = Intent(context, SmsService::class.java)
        context.stopService(intent)
        result.success(null)
    }

    private fun handleGetRecentSms(call: MethodCall, result: Result) {
        if (!checkAllPermissionsGranted()) {
            result.error("PERMISSION_DENIED", "SMS permissions not granted", null)
            return
        }
        val days = call.argument<Int>("days") ?: 30
        try {
            val messages = SmsRepository(context).getRecentMessages(days)
            result.success(messages)
        } catch (e: Exception) {
            result.error("SMS_QUERY_FAILED", e.message, e.stackTraceToString())
        }
    }

    // ── Permission result ────────────────────────────────────────────────────

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != SMS_PERMISSION_REQUEST_CODE) return false
        val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        pendingPermissionResult?.success(allGranted)
        pendingPermissionResult = null
        return true
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private fun checkAllPermissionsGranted(): Boolean {
        return SMS_PERMISSIONS.all { perm ->
            ContextCompat.checkSelfPermission(context, perm) == PackageManager.PERMISSION_GRANTED
        }
    }
}
