// lib/src/sms_engine_method_channel.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'models/raw_sms_event.dart';
import 'sms_engine_platform_interface.dart';

/// Android MethodChannel + EventChannel implementation of [SmsEnginePlatformInterface].
class SmsEngineMethodChannel extends SmsEnginePlatformInterface {
  static const MethodChannel _methodChannel =
      MethodChannel('com.fireflyneo/sms_engine');
  static const EventChannel _eventChannel =
      EventChannel('com.fireflyneo/sms_stream');

  /// Cached broadcast stream for [onSmsReceived].
  Stream<RawSmsEvent>? _smsStream;

  @override
  Future<bool> requestPermissions() async {
    final result =
        await _methodChannel.invokeMethod<bool>('requestPermissions');
    return result ?? false;
  }

  @override
  Future<bool> hasPermission() async {
    final result = await _methodChannel.invokeMethod<bool>('hasPermission');
    return result ?? false;
  }

  @override
  Future<void> startListening() async {
    await _methodChannel.invokeMethod<void>('startListening');
  }

  @override
  Future<void> stopListening() async {
    await _methodChannel.invokeMethod<void>('stopListening');
  }

  @override
  Stream<RawSmsEvent> get onSmsReceived {
    _smsStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          if (event is Map) {
            return RawSmsEvent.fromMap(event);
          }
          if (event is String) {
            final map = jsonDecode(event) as Map<dynamic, dynamic>;
            return RawSmsEvent.fromMap(map);
          }
          throw FormatException('Unexpected SMS event type: ${event.runtimeType}');
        })
        .handleError((dynamic error) {
          // Log but don't crash the stream on individual errors.
          // ignore: avoid_print
          print('[SmsEngine] Stream error: $error');
        })
        .asBroadcastStream();
    return _smsStream!;
  }

  @override
  Future<List<RawSmsEvent>> getRecentSms({int days = 30}) async {
    final result = await _methodChannel.invokeMethod<List<dynamic>>(
      'getRecentSms',
      {'days': days},
    );
    if (result == null) return [];
    return result.map((dynamic e) => RawSmsEvent.fromMap(e as Map)).toList();
  }

  @override
  Future<List<RawSmsEvent>> importFromFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('File not found', path);
    }
    final contents = await file.readAsString();
    return _parseFileContents(contents, path);
  }

  /// Parse .csv or .txt file contents into [RawSmsEvent]s.
  List<RawSmsEvent> _parseFileContents(String contents, String path) {
    final events = <RawSmsEvent>[];
    final lines = const LineSplitter().convert(contents);

    if (path.endsWith('.csv')) {
      // Expected CSV columns: sender,timestamp,body
      bool isFirst = true;
      for (final line in lines) {
        if (isFirst) {
          isFirst = false;
          continue; // skip header
        }
        if (line.trim().isEmpty) continue;
        final parts = _splitCsvLine(line);
        if (parts.length >= 3) {
          events.add(RawSmsEvent(
            sender: parts[0].trim(),
            body: parts.sublist(2).join(',').trim(),
            timestamp: _parseDateFlexibly(parts[1].trim()),
            platform: 'desktop',
          ));
        }
      }
    } else {
      // Plain text: each SMS separated by blank line or prefixed with sender/date
      // Format: [SENDER] [DATE]\n[BODY]\n
      final buffer = StringBuffer();
      String currentSender = '';
      DateTime currentTime = DateTime.now();

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty && buffer.isNotEmpty) {
          events.add(RawSmsEvent(
            sender: currentSender,
            body: buffer.toString().trim(),
            timestamp: currentTime,
            platform: 'desktop',
          ));
          buffer.clear();
          currentSender = '';
          currentTime = DateTime.now();
          continue;
        }

        // Try to detect a header line: "From: SENDER Date: ..."
        final headerMatch = RegExp(
          r'^(?:From|Sender):\s*(.+?)\s+(?:Date|Time):\s*(.+)$',
          caseSensitive: false,
        ).firstMatch(trimmed);

        if (headerMatch != null) {
          currentSender = headerMatch.group(1)!.trim();
          currentTime =
              _parseDateFlexibly(headerMatch.group(2)!.trim());
        } else {
          buffer.writeln(line);
        }
      }
      // Handle last block
      if (buffer.isNotEmpty) {
        events.add(RawSmsEvent(
          sender: currentSender,
          body: buffer.toString().trim(),
          timestamp: currentTime,
          platform: 'desktop',
        ));
      }
    }
    return events;
  }

  /// Rudimentary CSV splitter respecting double-quoted fields.
  List<String> _splitCsvLine(String line) {
    final parts = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        parts.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    parts.add(buffer.toString());
    return parts;
  }

  DateTime _parseDateFlexibly(String raw) {
    // Try ISO 8601 first
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;
    // Try milliseconds epoch
    final ms = int.tryParse(raw);
    if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime.now();
  }
}
