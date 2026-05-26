import 'package:freezed_annotation/freezed_annotation.dart';

part 'sms_message.freezed.dart';
part 'sms_message.g.dart';

enum SmsStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('processed')
  processed,
}

enum SmsParseResult {
  @JsonValue('success')
  success,
  @JsonValue('failed')
  failed,
  @JsonValue('ambiguous')
  ambiguous,
  @JsonValue('not_financial')
  notFinancial,
}

@freezed
class SmsMessage with _$SmsMessage {
  const factory SmsMessage({
    required String id,
    required String sender,
    required String body,
    required DateTime receivedAt,
    required SmsStatus status,
    SmsParseResult? parseResult,
    String? parsedTransactionId,
    double? parsedAmount,
    String? parsedMerchant,
    String? parsedAccountLast4,
    String? parsedType,
    String? parseError,
    Map<String, dynamic>? rawMetadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SmsMessage;

  factory SmsMessage.fromJson(Map<String, dynamic> json) =>
      _$SmsMessageFromJson(json);
}

class SmsIngestRequest {
  final String sender;
  final String body;
  final DateTime receivedAt;

  const SmsIngestRequest({
    required this.sender,
    required this.body,
    required this.receivedAt,
  });

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'body': body,
        'received_at': receivedAt.toIso8601String(),
      };
}
