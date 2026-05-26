import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics.freezed.dart';
part 'analytics.g.dart';

@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required double netWorth,
    required double totalAssets,
    required double totalLiabilities,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double monthlySavingsRate,
    @Default('INR') String currencyCode,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);

  static DashboardSummary empty() => const DashboardSummary(
        netWorth: 0,
        totalAssets: 0,
        totalLiabilities: 0,
        monthlyIncome: 0,
        monthlyExpenses: 0,
        monthlySavingsRate: 0,
      );
}

@freezed
class CashflowEntry with _$CashflowEntry {
  const factory CashflowEntry({
    required DateTime month,
    required double income,
    required double expenses,
    required double savings,
  }) = _CashflowEntry;

  factory CashflowEntry.fromJson(Map<String, dynamic> json) =>
      _$CashflowEntryFromJson(json);
}

@freezed
class CategorySpending with _$CategorySpending {
  const factory CategorySpending({
    required String categoryId,
    required String categoryName,
    required String color,
    required double amount,
    required double percentage,
  }) = _CategorySpending;

  factory CategorySpending.fromJson(Map<String, dynamic> json) =>
      _$CategorySpendingFromJson(json);
}

@freezed
class MerchantInsight with _$MerchantInsight {
  const factory MerchantInsight({
    required String merchantName,
    required double totalSpend,
    required int transactionCount,
    required DateTime lastSeen,
    @Default('INR') String currencyCode,
  }) = _MerchantInsight;

  factory MerchantInsight.fromJson(Map<String, dynamic> json) =>
      _$MerchantInsightFromJson(json);
}

@freezed
class BudgetProgress with _$BudgetProgress {
  const factory BudgetProgress({
    required String budgetId,
    required String name,
    required double limit,
    required double spent,
    required double remaining,
    required double percentage,
    @Default('INR') String currencyCode,
  }) = _BudgetProgress;

  factory BudgetProgress.fromJson(Map<String, dynamic> json) =>
      _$BudgetProgressFromJson(json);
}

@freezed
class SpendingHeatmapEntry with _$SpendingHeatmapEntry {
  const factory SpendingHeatmapEntry({
    required DateTime date,
    required double amount,
    @Default(0) int transactionCount,
  }) = _SpendingHeatmapEntry;

  factory SpendingHeatmapEntry.fromJson(Map<String, dynamic> json) =>
      _$SpendingHeatmapEntryFromJson(json);
}

@freezed
class NetWorthEntry with _$NetWorthEntry {
  const factory NetWorthEntry({
    required DateTime date,
    required double netWorth,
    required double assets,
    required double liabilities,
  }) = _NetWorthEntry;

  factory NetWorthEntry.fromJson(Map<String, dynamic> json) =>
      _$NetWorthEntryFromJson(json);
}

@freezed
class IncomeVsExpensesEntry with _$IncomeVsExpensesEntry {
  const factory IncomeVsExpensesEntry({
    required DateTime period,
    required double income,
    required double expenses,
    required String label,
  }) = _IncomeVsExpensesEntry;

  factory IncomeVsExpensesEntry.fromJson(Map<String, dynamic> json) =>
      _$IncomeVsExpensesEntryFromJson(json);
}
