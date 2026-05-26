// lib/src/models/raw_sms_event.dart

/// Represents a single raw SMS event from any supported platform.
class RawSmsEvent {
  final String sender;
  final String body;
  final DateTime timestamp;

  /// Platform identifier: 'android', 'web', or 'desktop'.
  final String platform;

  const RawSmsEvent({
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.platform,
  });

  factory RawSmsEvent.fromMap(Map<dynamic, dynamic> map) {
    return RawSmsEvent(
      sender: (map['sender'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      platform: (map['platform'] as String?) ?? 'android',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'body': body,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'platform': platform,
    };
  }

  @override
  String toString() =>
      'RawSmsEvent(sender: $sender, timestamp: $timestamp, platform: $platform)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawSmsEvent &&
          runtimeType == other.runtimeType &&
          sender == other.sender &&
          body == other.body &&
          timestamp == other.timestamp &&
          platform == other.platform;

  @override
  int get hashCode =>
      sender.hashCode ^ body.hashCode ^ timestamp.hashCode ^ platform.hashCode;
}
