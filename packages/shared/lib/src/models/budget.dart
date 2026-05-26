import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

enum BudgetPeriod {
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly,
}

extension BudgetPeriodExtension on BudgetPeriod {
  String get displayName {
    switch (this) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.quarterly:
        return 'Quarterly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }
}

@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String name,
    required double limit,
    required BudgetPeriod period,
    @Default('INR') String currencyCode,
    String? categoryId,
    @Default(true) bool active,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
}

class CreateBudgetRequest {
  final String name;
  final double limit;
  final BudgetPeriod period;
  final String currencyCode;
  final String? categoryId;
  final String? notes;

  const CreateBudgetRequest({
    required this.name,
    required this.limit,
    this.period = BudgetPeriod.monthly,
    this.currencyCode = 'INR',
    this.categoryId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'limit': limit,
        'period': period.name,
        'currency_code': currencyCode,
        if (categoryId != null) 'category_id': categoryId,
        if (notes != null) 'notes': notes,
      };
}

class UpdateBudgetRequest {
  final String? name;
  final double? limit;
  final BudgetPeriod? period;
  final String? currencyCode;
  final String? categoryId;
  final bool? active;
  final String? notes;

  const UpdateBudgetRequest({
    this.name,
    this.limit,
    this.period,
    this.currencyCode,
    this.categoryId,
    this.active,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (limit != null) map['limit'] = limit;
    if (period != null) map['period'] = period!.name;
    if (currencyCode != null) map['currency_code'] = currencyCode;
    if (categoryId != null) map['category_id'] = categoryId;
    if (active != null) map['active'] = active;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}
