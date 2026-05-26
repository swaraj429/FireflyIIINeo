import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType {
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('deposit')
  deposit,
  @JsonValue('transfer')
  transfer,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  bool get isExpense => this == TransactionType.withdrawal;
  bool get isIncome => this == TransactionType.deposit;
  bool get isTransfer => this == TransactionType.transfer;
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required TransactionType type,
    required String description,
    required DateTime date,
    required double amount,
    @Default('INR') String currencyCode,
    double? foreignAmount,
    String? foreignCurrency,
    required String sourceAccountId,
    String? destAccountId,
    String? categoryId,
    String? budgetId,
    String? merchantName,
    String? notes,
    @Default([]) List<String> tags,
    @Default(false) bool reconciled,
    String? smsSource,
    String? smsSender,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

/// Request object for creating a new transaction
class CreateTransactionRequest {
  final TransactionType type;
  final String description;
  final DateTime date;
  final double amount;
  final String currencyCode;
  final double? foreignAmount;
  final String? foreignCurrency;
  final String sourceAccountId;
  final String? destAccountId;
  final String? categoryId;
  final String? budgetId;
  final String? merchantName;
  final String? notes;
  final List<String> tags;
  final String? smsSource;
  final String? smsSender;

  const CreateTransactionRequest({
    required this.type,
    required this.description,
    required this.date,
    required this.amount,
    this.currencyCode = 'INR',
    this.foreignAmount,
    this.foreignCurrency,
    required this.sourceAccountId,
    this.destAccountId,
    this.categoryId,
    this.budgetId,
    this.merchantName,
    this.notes,
    this.tags = const [],
    this.smsSource,
    this.smsSender,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'description': description,
        'date': date.toIso8601String(),
        'amount': amount,
        'currency_code': currencyCode,
        if (foreignAmount != null) 'foreign_amount': foreignAmount,
        if (foreignCurrency != null) 'foreign_currency': foreignCurrency,
        'source_account_id': sourceAccountId,
        if (destAccountId != null) 'dest_account_id': destAccountId,
        if (categoryId != null) 'category_id': categoryId,
        if (budgetId != null) 'budget_id': budgetId,
        if (merchantName != null) 'merchant_name': merchantName,
        if (notes != null) 'notes': notes,
        'tags': tags,
        if (smsSource != null) 'sms_source': smsSource,
        if (smsSender != null) 'sms_sender': smsSender,
      };
}

/// Request object for updating a transaction
class UpdateTransactionRequest {
  final TransactionType? type;
  final String? description;
  final DateTime? date;
  final double? amount;
  final String? currencyCode;
  final double? foreignAmount;
  final String? foreignCurrency;
  final String? sourceAccountId;
  final String? destAccountId;
  final String? categoryId;
  final String? budgetId;
  final String? merchantName;
  final String? notes;
  final List<String>? tags;
  final bool? reconciled;

  const UpdateTransactionRequest({
    this.type,
    this.description,
    this.date,
    this.amount,
    this.currencyCode,
    this.foreignAmount,
    this.foreignCurrency,
    this.sourceAccountId,
    this.destAccountId,
    this.categoryId,
    this.budgetId,
    this.merchantName,
    this.notes,
    this.tags,
    this.reconciled,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (type != null) map['type'] = type!.name;
    if (description != null) map['description'] = description;
    if (date != null) map['date'] = date!.toIso8601String();
    if (amount != null) map['amount'] = amount;
    if (currencyCode != null) map['currency_code'] = currencyCode;
    if (foreignAmount != null) map['foreign_amount'] = foreignAmount;
    if (foreignCurrency != null) map['foreign_currency'] = foreignCurrency;
    if (sourceAccountId != null) map['source_account_id'] = sourceAccountId;
    if (destAccountId != null) map['dest_account_id'] = destAccountId;
    if (categoryId != null) map['category_id'] = categoryId;
    if (budgetId != null) map['budget_id'] = budgetId;
    if (merchantName != null) map['merchant_name'] = merchantName;
    if (notes != null) map['notes'] = notes;
    if (tags != null) map['tags'] = tags;
    if (reconciled != null) map['reconciled'] = reconciled;
    return map;
  }
}

/// Filter parameters for transaction queries
class TransactionFilter {
  final String? accountId;
  final String? categoryId;
  final String? budgetId;
  final TransactionType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;
  final List<String>? tags;
  final int page;
  final int pageSize;

  const TransactionFilter({
    this.accountId,
    this.categoryId,
    this.budgetId,
    this.type,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
    this.tags,
    this.page = 1,
    this.pageSize = 50,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (accountId != null) params['account_id'] = accountId;
    if (categoryId != null) params['category_id'] = categoryId;
    if (budgetId != null) params['budget_id'] = budgetId;
    if (type != null) params['type'] = type!.name;
    if (startDate != null) params['start_date'] = startDate!.toIso8601String();
    if (endDate != null) params['end_date'] = endDate!.toIso8601String();
    if (minAmount != null) params['min_amount'] = minAmount;
    if (maxAmount != null) params['max_amount'] = maxAmount;
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['q'] = searchQuery;
    }
    if (tags != null && tags!.isNotEmpty) params['tags'] = tags!.join(',');
    return params;
  }

  TransactionFilter copyWith({
    String? accountId,
    String? categoryId,
    String? budgetId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    List<String>? tags,
    int? page,
    int? pageSize,
  }) {
    return TransactionFilter(
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchQuery: searchQuery ?? this.searchQuery,
      tags: tags ?? this.tags,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
