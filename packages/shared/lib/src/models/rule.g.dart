// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RuleTriggerImpl _$$RuleTriggerImplFromJson(Map<String, dynamic> json) =>
    _$RuleTriggerImpl(
      id: json['id'] as String,
      condition: $enumDecode(_$RuleTriggerConditionEnumMap, json['condition']),
      value: json['value'] as String,
      stopProcessing: json['stopProcessing'] as bool? ?? false,
      negate: json['negate'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RuleTriggerImplToJson(_$RuleTriggerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'condition': _$RuleTriggerConditionEnumMap[instance.condition]!,
      'value': instance.value,
      'stopProcessing': instance.stopProcessing,
      'negate': instance.negate,
      'order': instance.order,
    };

const _$RuleTriggerConditionEnumMap = {
  RuleTriggerCondition.descriptionContains: 'description_contains',
  RuleTriggerCondition.descriptionStartsWith: 'description_starts_with',
  RuleTriggerCondition.descriptionEndsWith: 'description_ends_with',
  RuleTriggerCondition.descriptionIs: 'description_is',
  RuleTriggerCondition.amountLessThan: 'amount_less_than',
  RuleTriggerCondition.amountGreaterThan: 'amount_greater_than',
  RuleTriggerCondition.amountIs: 'amount_is',
  RuleTriggerCondition.fromAccountIs: 'from_account_is',
  RuleTriggerCondition.toAccountIs: 'to_account_is',
  RuleTriggerCondition.categoryIs: 'category_is',
  RuleTriggerCondition.budgetIs: 'budget_is',
  RuleTriggerCondition.tagIs: 'tag_is',
  RuleTriggerCondition.senderContains: 'sender_contains',
};

_$RuleActionImpl _$$RuleActionImplFromJson(Map<String, dynamic> json) =>
    _$RuleActionImpl(
      id: json['id'] as String,
      action: $enumDecode(_$RuleActionTypeEnumMap, json['action']),
      value: json['value'] as String,
      stopProcessing: json['stopProcessing'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RuleActionImplToJson(_$RuleActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': _$RuleActionTypeEnumMap[instance.action]!,
      'value': instance.value,
      'stopProcessing': instance.stopProcessing,
      'order': instance.order,
    };

const _$RuleActionTypeEnumMap = {
  RuleActionType.setCategory: 'set_category',
  RuleActionType.setBudget: 'set_budget',
  RuleActionType.addTag: 'add_tag',
  RuleActionType.removeTag: 'remove_tag',
  RuleActionType.setDescription: 'set_description',
  RuleActionType.setNotes: 'set_notes',
  RuleActionType.appendNotes: 'append_notes',
  RuleActionType.setSourceAccount: 'set_source_account',
  RuleActionType.setDestinationAccount: 'set_destination_account',
  RuleActionType.convertCurrency: 'convert_currency',
  RuleActionType.markReconciled: 'mark_reconciled',
};

_$RuleImpl _$$RuleImplFromJson(Map<String, dynamic> json) => _$RuleImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      trigger: $enumDecode(_$RuleTriggerTypeEnumMap, json['trigger']),
      conditions: (json['conditions'] as List<dynamic>)
          .map((e) => RuleTrigger.fromJson(e as Map<String, dynamic>))
          .toList(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => RuleAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      active: json['active'] as bool? ?? true,
      strict: json['strict'] as bool? ?? false,
      stopProcessing: json['stopProcessing'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RuleImplToJson(_$RuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'trigger': _$RuleTriggerTypeEnumMap[instance.trigger]!,
      'conditions': instance.conditions,
      'actions': instance.actions,
      'active': instance.active,
      'strict': instance.strict,
      'stopProcessing': instance.stopProcessing,
      'order': instance.order,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RuleTriggerTypeEnumMap = {
  RuleTriggerType.storeTransaction: 'store_transaction',
  RuleTriggerType.updateTransaction: 'update_transaction',
  RuleTriggerType.destroyTransaction: 'destroy_transaction',
  RuleTriggerType.smsReceived: 'sms_received',
};
