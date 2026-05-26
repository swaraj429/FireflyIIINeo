// lib/neo_sms_engine_web.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/models/raw_sms_event.dart';
import 'src/sms_engine_platform_interface.dart';

/// Web implementation of [SmsEnginePlatformInterface].
///
/// Web browsers have no SMS API. This implementation provides:
/// - [importFromClipboard]: parse pasted raw SMS text from clipboard.
/// - [importFromFile]:      read a .txt or .csv file the user selects.
///
/// All background-service methods are no-ops that return immediately.
class NeoSmsEnginePluginWeb extends SmsEnginePlatformInterface {
  NeoSmsEnginePluginWeb();

  static void registerWith(Registrar registrar) {
    SmsEnginePlatformInterface.instance = NeoSmsEnginePluginWeb();
  }

  // ── No-op / unsupported ────────────────────────────────────────────────

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> startListening() async {
    // Browsers have no SMS access; silently succeed.
  }

  @override
  Future<void> stopListening() async {}

  @override
  Stream<RawSmsEvent> get onSmsReceived =>
      const Stream.empty(); // No real-time SMS on web.

  @override
  Future<List<RawSmsEvent>> getRecentSms({int days = 30}) async =>
      []; // Cannot query SMS inbox on web.

  // ── Web-specific ──────────────────────────────────────────────────────

  /// Parse SMS messages from [text] pasted from clipboard.
  ///
  /// Supports two formats:
  /// 1. JSON array: `[{"sender":"...", "body":"...", "timestamp":"..."}]`
  /// 2. Plain text blocks (same as desktop .txt import).
  Future<List<RawSmsEvent>> importFromClipboard(String text) async {
    final trimmed = text.trim();
    if (trimmed.startsWith('[')) {
      try {
        final list = jsonDecode(trimmed) as List<dynamic>;
        return list.map((dynamic e) {
          final m = e as Map<String, dynamic>;
          return RawSmsEvent(
            sender: m['sender'] as String? ?? '',
            body: m['body'] as String? ?? '',
            timestamp: m['timestamp'] != null
                ? DateTime.tryParse(m['timestamp'] as String) ?? DateTime.now()
                : DateTime.now(),
            platform: 'web',
          );
        }).toList();
      } catch (_) {
        // Fall through to plain-text parsing.
      }
    }
    return _parsePlainText(trimmed);
  }

  @override
  Future<List<RawSmsEvent>> importFromFile(String path) async {
    // On web, `path` is the raw file content (passed via JS bridge / file picker).
    // The caller should pass the file's text content directly as the "path" when
    // the platform is web, OR use the JavaScript interop layer to read the blob.
    // For now, treat the argument as raw text content.
    return _parsePlainText(path);
  }

  // ─────────────────────────────────────────────────────────────────────────

  List<RawSmsEvent> _parsePlainText(String contents) {
    final events = <RawSmsEvent>[];
    final lines = const LineSplitter().convert(contents);
    final buffer = StringBuffer();
    String currentSender = 'Unknown';
    DateTime currentTime = DateTime.now();

    void flush() {
      final body = buffer.toString().trim();
      if (body.isNotEmpty) {
        events.add(RawSmsEvent(
          sender: currentSender,
          body: body,
          timestamp: currentTime,
          platform: 'web',
        ));
      }
      buffer.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        flush();
        currentSender = 'Unknown';
        currentTime = DateTime.now();
        continue;
      }

      final headerMatch = RegExp(
        r'^(?:From|Sender):\s*(.+?)\s+(?:Date|Time):\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(trimmed);

      if (headerMatch != null) {
        flush();
        currentSender = headerMatch.group(1)!.trim();
        currentTime =
            DateTime.tryParse(headerMatch.group(2)!.trim()) ?? DateTime.now();
      } else {
        buffer.writeln(line);
      }
    }
    flush();
    return events;
  }
}
