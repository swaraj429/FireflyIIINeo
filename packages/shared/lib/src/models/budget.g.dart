// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetImpl _$$BudgetImplFromJson(Map<String, dynamic> json) => _$BudgetImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      limit: (json['limit'] as num).toDouble(),
      period: $enumDecode(_$BudgetPeriodEnumMap, json['period']),
      currencyCode: json['currencyCode'] as String? ?? 'INR',
      categoryId: json['categoryId'] as String?,
      active: json['active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BudgetImplToJson(_$BudgetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'limit': instance.limit,
      'period': _$BudgetPeriodEnumMap[instance.period]!,
      'currencyCode': instance.currencyCode,
      'categoryId': instance.categoryId,
      'active': instance.active,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$BudgetPeriodEnumMap = {
  BudgetPeriod.weekly: 'weekly',
  BudgetPeriod.monthly: 'monthly',
  BudgetPeriod.quarterly: 'quarterly',
  BudgetPeriod.yearly: 'yearly',
};
