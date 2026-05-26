import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

enum BillFrequency {
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly,
}

extension BillFrequencyExtension on BillFrequency {
  String get displayName {
    switch (this) {
      case BillFrequency.weekly:
        return 'Weekly';
      case BillFrequency.monthly:
        return 'Monthly';
      case BillFrequency.quarterly:
        return 'Quarterly';
      case BillFrequency.yearly:
        return 'Yearly';
    }
  }
}

@freezed
class Bill with _$Bill {
  const factory Bill({
    required String id,
    required String name,
    required double amountMin,
    required double amountMax,
    required BillFrequency frequency,
    required int dayOfPeriod,
    @Default('INR') String currencyCode,
    String? accountId,
    String? notes,
    @Default(true) bool active,
    DateTime? nextDueDate,
    DateTime? lastPaidDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Bill;

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
}

class CreateBillRequest {
  final String name;
  final double amountMin;
  final double amountMax;
  final BillFrequency frequency;
  final int dayOfPeriod;
  final String currencyCode;
  final String? accountId;
  final String? notes;

  const CreateBillRequest({
    required this.name,
    required this.amountMin,
    required this.amountMax,
    this.frequency = BillFrequency.monthly,
    this.dayOfPeriod = 1,
    this.currencyCode = 'INR',
    this.accountId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount_min': amountMin,
        'amount_max': amountMax,
        'frequency': frequency.name,
        'day_of_period': dayOfPeriod,
        'currency_code': currencyCode,
        if (accountId != null) 'account_id': accountId,
        if (notes != null) 'notes': notes,
      };
}
