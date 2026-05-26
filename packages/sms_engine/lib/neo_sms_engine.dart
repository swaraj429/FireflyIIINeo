/// neo_sms_engine
/// Platform-native SMS reading for FireflyIII Neo.
///
/// Provides a unified API across Android (native foreground service),
/// Web (clipboard / file import), and Desktop (file import).
library neo_sms_engine;

export 'src/models/raw_sms_event.dart';
export 'src/sms_engine_platform_interface.dart' show SmsEnginePlatformInterface;
export 'src/neo_sms_engine_impl.dart';
