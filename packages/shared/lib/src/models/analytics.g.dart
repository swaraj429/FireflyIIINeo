// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardSummaryImpl _$$DashboardSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardSummaryImpl(
      netWorth: (json['netWorth'] as num).toDouble(),
      totalAssets: (json['totalAssets'] as num).toDouble(),
      totalLiabilities: (json['totalLiabilities'] as num).toDouble(),
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] as num).toDouble(),
      monthlySavingsRate: (json['monthlySavingsRate'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'INR',
    );

Map<String, dynamic> _$$DashboardSummaryImplToJson(
        _$DashboardSummaryImpl instance) =>
    <String, dynamic>{
      'netWorth': instance.netWorth,
      'totalAssets': instance.totalAssets,
      'totalLiabilities': instance.totalLiabilities,
      'monthlyIncome': instance.monthlyIncome,
      'monthlyExpenses': instance.monthlyExpenses,
      'monthlySavingsRate': instance.monthlySavingsRate,
      'currencyCode': instance.currencyCode,
    };

_$CashflowEntryImpl _$$CashflowEntryImplFromJson(Map<String, dynamic> json) =>
    _$CashflowEntryImpl(
      month: DateTime.parse(json['month'] as String),
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      savings: (json['savings'] as num).toDouble(),
    );

Map<String, dynamic> _$$CashflowEntryImplToJson(_$CashflowEntryImpl instance) =>
    <String, dynamic>{
      'month': instance.month.toIso8601String(),
      'income': instance.income,
      'expenses': instance.expenses,
      'savings': instance.savings,
    };

_$CategorySpendingImpl _$$CategorySpendingImplFromJson(
        Map<String, dynamic> json) =>
    _$CategorySpendingImpl(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      color: json['color'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$CategorySpendingImplToJson(
        _$CategorySpendingImpl instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'color': instance.color,
      'amount': instance.amount,
      'percentage': instance.percentage,
    };

_$MerchantInsightImpl _$$MerchantInsightImplFromJson(
        Map<String, dynamic> json) =>
    _$MerchantInsightImpl(
      merchantName: json['merchantName'] as String,
      totalSpend: (json['totalSpend'] as num).toDouble(),
      transactionCount: (json['transactionCount'] as num).toInt(),
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      currencyCode: json['currencyCode'] as String? ?? 'INR',
    );

Map<String, dynamic> _$$MerchantInsightImplToJson(
        _$MerchantInsightImpl instance) =>
    <String, dynamic>{
      'merchantName': instance.merchantName,
      'totalSpend': instance.totalSpend,
      'transactionCount': instance.transactionCount,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'currencyCode': instance.currencyCode,
    };

_$BudgetProgressImpl _$$BudgetProgressImplFromJson(Map<String, dynamic> json) =>
    _$BudgetProgressImpl(
      budgetId: json['budgetId'] as String,
      name: json['name'] as String,
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'INR',
    );

Map<String, dynamic> _$$BudgetProgressImplToJson(
        _$BudgetProgressImpl instance) =>
    <String, dynamic>{
      'budgetId': instance.budgetId,
      'name': instance.name,
      'limit': instance.limit,
      'spent': instance.spent,
      'remaining': instance.remaining,
      'percentage': instance.percentage,
      'currencyCode': instance.currencyCode,
    };

_$SpendingHeatmapEntryImpl _$$SpendingHeatmapEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$SpendingHeatmapEntryImpl(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SpendingHeatmapEntryImplToJson(
        _$SpendingHeatmapEntryImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'transactionCount': instance.transactionCount,
    };

_$NetWorthEntryImpl _$$NetWorthEntryImplFromJson(Map<String, dynamic> json) =>
    _$NetWorthEntryImpl(
      date: DateTime.parse(json['date'] as String),
      netWorth: (json['netWorth'] as num).toDouble(),
      assets: (json['assets'] as num).toDouble(),
      liabilities: (json['liabilities'] as num).toDouble(),
    );

Map<String, dynamic> _$$NetWorthEntryImplToJson(_$NetWorthEntryImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'netWorth': instance.netWorth,
      'assets': instance.assets,
      'liabilities': instance.liabilities,
    };

_$IncomeVsExpensesEntryImpl _$$IncomeVsExpensesEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$IncomeVsExpensesEntryImpl(
      period: DateTime.parse(json['period'] as String),
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      label: json['label'] as String,
    );

Map<String, dynamic> _$$IncomeVsExpensesEntryImplToJson(
        _$IncomeVsExpensesEntryImpl instance) =>
    <String, dynamic>{
      'period': instance.period.toIso8601String(),
      'income': instance.income,
      'expenses': instance.expenses,
      'label': instance.label,
    };
