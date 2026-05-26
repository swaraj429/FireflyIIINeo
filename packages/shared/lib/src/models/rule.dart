import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule.freezed.dart';
part 'rule.g.dart';

enum RuleTriggerType {
  @JsonValue('store_transaction')
  storeTransaction,
  @JsonValue('update_transaction')
  updateTransaction,
  @JsonValue('destroy_transaction')
  destroyTransaction,
  @JsonValue('sms_received')
  smsReceived,
}

enum RuleTriggerCondition {
  @JsonValue('description_contains')
  descriptionContains,
  @JsonValue('description_starts_with')
  descriptionStartsWith,
  @JsonValue('description_ends_with')
  descriptionEndsWith,
  @JsonValue('description_is')
  descriptionIs,
  @JsonValue('amount_less_than')
  amountLessThan,
  @JsonValue('amount_greater_than')
  amountGreaterThan,
  @JsonValue('amount_is')
  amountIs,
  @JsonValue('from_account_is')
  fromAccountIs,
  @JsonValue('to_account_is')
  toAccountIs,
  @JsonValue('category_is')
  categoryIs,
  @JsonValue('budget_is')
  budgetIs,
  @JsonValue('tag_is')
  tagIs,
  @JsonValue('sender_contains')
  senderContains,
}

enum RuleActionType {
  @JsonValue('set_category')
  setCategory,
  @JsonValue('set_budget')
  setBudget,
  @JsonValue('add_tag')
  addTag,
  @JsonValue('remove_tag')
  removeTag,
  @JsonValue('set_description')
  setDescription,
  @JsonValue('set_notes')
  setNotes,
  @JsonValue('append_notes')
  appendNotes,
  @JsonValue('set_source_account')
  setSourceAccount,
  @JsonValue('set_destination_account')
  setDestinationAccount,
  @JsonValue('convert_currency')
  convertCurrency,
  @JsonValue('mark_reconciled')
  markReconciled,
}

@freezed
class RuleTrigger with _$RuleTrigger {
  const factory RuleTrigger({
    required String id,
    required RuleTriggerCondition condition,
    required String value,
    @Default(false) bool stopProcessing,
    @Default(false) bool negate,
    @Default(0) int order,
  }) = _RuleTrigger;

  factory RuleTrigger.fromJson(Map<String, dynamic> json) =>
      _$RuleTriggerFromJson(json);
}

@freezed
class RuleAction with _$RuleAction {
  const factory RuleAction({
    required String id,
    required RuleActionType action,
    required String value,
    @Default(false) bool stopProcessing,
    @Default(0) int order,
  }) = _RuleAction;

  factory RuleAction.fromJson(Map<String, dynamic> json) =>
      _$RuleActionFromJson(json);
}

@freezed
class Rule with _$Rule {
  const factory Rule({
    required String id,
    required String title,
    required RuleTriggerType trigger,
    required List<RuleTrigger> conditions,
    required List<RuleAction> actions,
    @Default(true) bool active,
    @Default(false) bool strict,
    @Default(false) bool stopProcessing,
    @Default(0) int order,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Rule;

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);
}

class CreateRuleRequest {
  final String title;
  final RuleTriggerType trigger;
  final List<Map<String, dynamic>> conditions;
  final List<Map<String, dynamic>> actions;
  final bool strict;
  final bool stopProcessing;
  final String? description;

  const CreateRuleRequest({
    required this.title,
    required this.trigger,
    required this.conditions,
    required this.actions,
    this.strict = false,
    this.stopProcessing = false,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'trigger': trigger.name,
        'conditions': conditions,
        'actions': actions,
        'strict': strict,
        'stop_processing': stopProcessing,
        if (description != null) 'description': description,
      };
}
