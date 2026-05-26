// lib/src/models/raw_sms_input.dart

/// A raw SMS as ingested from the SMS Engine or any other source.
class RawSmsInput {
  final String sender;
  final String body;
  final DateTime timestamp;

  const RawSmsInput({
    required this.sender,
    required this.body,
    required this.timestamp,
  });

  @override
  String toString() =>
      'RawSmsInput(sender: $sender, timestamp: $timestamp, body: ${body.length > 60 ? '${body.substring(0, 60)}…' : body})';
}
