// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BillImpl _$$BillImplFromJson(Map<String, dynamic> json) => _$BillImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      amountMin: (json['amountMin'] as num).toDouble(),
      amountMax: (json['amountMax'] as num).toDouble(),
      frequency: $enumDecode(_$BillFrequencyEnumMap, json['frequency']),
      dayOfPeriod: (json['dayOfPeriod'] as num).toInt(),
      currencyCode: json['currencyCode'] as String? ?? 'INR',
      accountId: json['accountId'] as String?,
      notes: json['notes'] as String?,
      active: json['active'] as bool? ?? true,
      nextDueDate: json['nextDueDate'] == null
          ? null
          : DateTime.parse(json['nextDueDate'] as String),
      lastPaidDate: json['lastPaidDate'] == null
          ? null
          : DateTime.parse(json['lastPaidDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BillImplToJson(_$BillImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amountMin': instance.amountMin,
      'amountMax': instance.amountMax,
      'frequency': _$BillFrequencyEnumMap[instance.frequency]!,
      'dayOfPeriod': instance.dayOfPeriod,
      'currencyCode': instance.currencyCode,
      'accountId': instance.accountId,
      'notes': instance.notes,
      'active': instance.active,
      'nextDueDate': instance.nextDueDate?.toIso8601String(),
      'lastPaidDate': instance.lastPaidDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$BillFrequencyEnumMap = {
  BillFrequency.weekly: 'weekly',
  BillFrequency.monthly: 'monthly',
  BillFrequency.quarterly: 'quarterly',
  BillFrequency.yearly: 'yearly',
};
