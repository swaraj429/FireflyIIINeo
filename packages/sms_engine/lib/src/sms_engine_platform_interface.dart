// lib/src/sms_engine_platform_interface.dart
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/raw_sms_event.dart';
import 'sms_engine_method_channel.dart';

/// The interface that implementations of neo_sms_engine must implement.
///
/// Platform implementations must extend this class rather than implement it
/// so that new methods can be added without breaking existing implementations.
abstract class SmsEnginePlatformInterface extends PlatformInterface {
  SmsEnginePlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static SmsEnginePlatformInterface _instance = SmsEngineMethodChannel();

  /// The default instance of [SmsEnginePlatformInterface] to use.
  static SmsEnginePlatformInterface get instance => _instance;

  static set instance(SmsEnginePlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Request runtime SMS permissions.
  /// Returns true if permissions were granted.
  Future<bool> requestPermissions() {
    throw UnimplementedError('requestPermissions() has not been implemented.');
  }

  /// Check if SMS permissions are currently granted.
  Future<bool> hasPermission() {
    throw UnimplementedError('hasPermission() has not been implemented.');
  }

  /// Start the SMS listening foreground service.
  Future<void> startListening() {
    throw UnimplementedError('startListening() has not been implemented.');
  }

  /// Stop the SMS listening foreground service.
  Future<void> stopListening() {
    throw UnimplementedError('stopListening() has not been implemented.');
  }

  /// Stream of real-time [RawSmsEvent]s as they arrive.
  Stream<RawSmsEvent> get onSmsReceived {
    throw UnimplementedError('onSmsReceived has not been implemented.');
  }

  /// Retrieve SMS messages from the last [days] days from system inbox.
  Future<List<RawSmsEvent>> getRecentSms({int days = 30}) {
    throw UnimplementedError('getRecentSms() has not been implemented.');
  }

  /// Import SMS events from a local file path (.txt or .csv).
  Future<List<RawSmsEvent>> importFromFile(String path) {
    throw UnimplementedError('importFromFile() has not been implemented.');
  }
}
