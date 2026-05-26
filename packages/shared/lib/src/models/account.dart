import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

enum AccountType {
  @JsonValue('asset')
  asset,
  @JsonValue('expense')
  expense,
  @JsonValue('revenue')
  revenue,
  @JsonValue('liability')
  liability,
  @JsonValue('cash')
  cash,
}

extension AccountTypeExtension on AccountType {
  String get displayName {
    switch (this) {
      case AccountType.asset:
        return 'Asset';
      case AccountType.expense:
        return 'Expense';
      case AccountType.revenue:
        return 'Revenue';
      case AccountType.liability:
        return 'Liability';
      case AccountType.cash:
        return 'Cash';
    }
  }

  bool get isDebit => this == AccountType.asset || this == AccountType.cash;
}

@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required AccountType type,
    required double currentBalance,
    @Default('INR') String currencyCode,
    String? iban,
    String? accountNumber,
    String? bankName,
    String? notes,
    @Default(true) bool active,
    @Default(0) int order,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
