// lib/src/neo_sms_engine_impl.dart
import 'dart:async';

import 'models/raw_sms_event.dart';
import 'sms_engine_platform_interface.dart';

/// Public entry-point for the SMS Engine package.
///
/// All methods delegate to the active platform implementation via
/// [SmsEnginePlatformInterface].
class NeoSmsEngine {
  NeoSmsEngine._();

  /// Request runtime permissions necessary to read/receive SMS.
  ///
  /// On Android this triggers the RECEIVE_SMS + READ_SMS permission dialog.
  /// On other platforms returns `true` immediately (no permission needed).
  static Future<bool> requestPermissions() =>
      SmsEnginePlatformInterface.instance.requestPermissions();

  /// Returns `true` if all required SMS permissions are currently granted.
  static Future<bool> hasPermission() =>
      SmsEnginePlatformInterface.instance.hasPermission();

  /// Start the background SMS listening service.
  ///
  /// On Android this launches a foreground [Service] with a persistent
  /// notification and registers a [BroadcastReceiver] for incoming SMS.
  static Future<void> startListening() =>
      SmsEnginePlatformInterface.instance.startListening();

  /// Stop the background SMS listening service.
  static Future<void> stopListening() =>
      SmsEnginePlatformInterface.instance.stopListening();

  /// Broadcast stream of real-time SMS events.
  ///
  /// Events arrive as the user receives SMS messages while the service is
  /// active. The stream is a broadcast stream and can have multiple listeners.
  static Stream<RawSmsEvent> get onSmsReceived =>
      SmsEnginePlatformInterface.instance.onSmsReceived;

  /// Retrieve historical SMS messages from the past [days] days.
  ///
  /// On Android this queries the system SMS ContentProvider.
  /// On Web / Desktop this returns an empty list (use [importFromFile] instead).
  static Future<List<RawSmsEvent>> getRecentSms({int days = 30}) =>
      SmsEnginePlatformInterface.instance.getRecentSms(days: days);

  /// Import SMS events from a local file (`.txt` or `.csv`).
  ///
  /// CSV format: `sender,timestamp_iso,body`
  /// TXT format: blocks separated by blank lines,
  ///   optionally with `From: SENDER Date: YYYY-MM-DD` headers.
  static Future<List<RawSmsEvent>> importFromFile(String path) =>
      SmsEnginePlatformInterface.instance.importFromFile(path);
}
