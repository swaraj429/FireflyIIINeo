// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$AccountTypeEnumMap, json['type']),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'INR',
      iban: json['iban'] as String?,
      accountNumber: json['accountNumber'] as String?,
      bankName: json['bankName'] as String?,
      notes: json['notes'] as String?,
      active: json['active'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'currentBalance': instance.currentBalance,
      'currencyCode': instance.currencyCode,
      'iban': instance.iban,
      'accountNumber': instance.accountNumber,
      'bankName': instance.bankName,
      'notes': instance.notes,
      'active': instance.active,
      'order': instance.order,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AccountTypeEnumMap = {
  AccountType.asset: 'asset',
  AccountType.expense: 'expense',
  AccountType.revenue: 'revenue',
  AccountType.liability: 'liability',
  AccountType.cash: 'cash',
};
