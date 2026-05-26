// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'INR',
      foreignAmount: (json['foreignAmount'] as num?)?.toDouble(),
      foreignCurrency: json['foreignCurrency'] as String?,
      sourceAccountId: json['sourceAccountId'] as String,
      destAccountId: json['destAccountId'] as String?,
      categoryId: json['categoryId'] as String?,
      budgetId: json['budgetId'] as String?,
      merchantName: json['merchantName'] as String?,
      notes: json['notes'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      reconciled: json['reconciled'] as bool? ?? false,
      smsSource: json['smsSource'] as String?,
      smsSender: json['smsSender'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'currencyCode': instance.currencyCode,
      'foreignAmount': instance.foreignAmount,
      'foreignCurrency': instance.foreignCurrency,
      'sourceAccountId': instance.sourceAccountId,
      'destAccountId': instance.destAccountId,
      'categoryId': instance.categoryId,
      'budgetId': instance.budgetId,
      'merchantName': instance.merchantName,
      'notes': instance.notes,
      'tags': instance.tags,
      'reconciled': instance.reconciled,
      'smsSource': instance.smsSource,
      'smsSender': instance.smsSender,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.withdrawal: 'withdrawal',
  TransactionType.deposit: 'deposit',
  TransactionType.transfer: 'transfer',
};
