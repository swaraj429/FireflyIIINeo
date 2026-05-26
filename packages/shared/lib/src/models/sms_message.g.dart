// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmsMessageImpl _$$SmsMessageImplFromJson(Map<String, dynamic> json) =>
    _$SmsMessageImpl(
      id: json['id'] as String,
      sender: json['sender'] as String,
      body: json['body'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      status: $enumDecode(_$SmsStatusEnumMap, json['status']),
      parseResult:
          $enumDecodeNullable(_$SmsParseResultEnumMap, json['parseResult']),
      parsedTransactionId: json['parsedTransactionId'] as String?,
      parsedAmount: (json['parsedAmount'] as num?)?.toDouble(),
      parsedMerchant: json['parsedMerchant'] as String?,
      parsedAccountLast4: json['parsedAccountLast4'] as String?,
      parsedType: json['parsedType'] as String?,
      parseError: json['parseError'] as String?,
      rawMetadata: json['rawMetadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SmsMessageImplToJson(_$SmsMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'body': instance.body,
      'receivedAt': instance.receivedAt.toIso8601String(),
      'status': _$SmsStatusEnumMap[instance.status]!,
      'parseResult': _$SmsParseResultEnumMap[instance.parseResult],
      'parsedTransactionId': instance.parsedTransactionId,
      'parsedAmount': instance.parsedAmount,
      'parsedMerchant': instance.parsedMerchant,
      'parsedAccountLast4': instance.parsedAccountLast4,
      'parsedType': instance.parsedType,
      'parseError': instance.parseError,
      'rawMetadata': instance.rawMetadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SmsStatusEnumMap = {
  SmsStatus.pending: 'pending',
  SmsStatus.approved: 'approved',
  SmsStatus.rejected: 'rejected',
  SmsStatus.processed: 'processed',
};

const _$SmsParseResultEnumMap = {
  SmsParseResult.success: 'success',
  SmsParseResult.failed: 'failed',
  SmsParseResult.ambiguous: 'ambiguous',
  SmsParseResult.notFinancial: 'not_financial',
};
