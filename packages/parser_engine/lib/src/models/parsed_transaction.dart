// lib/src/models/parsed_transaction.dart
import 'transaction_type.dart';

/// The result of parsing a bank SMS.
///
/// All fields except [type], [amount], [timestamp], [rawSms], [sender],
/// [duplicateHash], and [confidence] are nullable because not all SMS formats
/// contain all information.
class ParsedTransaction {
  /// Whether money was sent (debit) or received (credit).
  final TransactionType type;

  /// The transaction amount in [currencyCode].
  final double amount;

  /// ISO 4217 currency code, e.g. 'INR'.
  final String currencyCode;

  /// Merchant or payee name (normalized via [MerchantNormalizer]).
  final String? merchant;

  /// UPI virtual payment address, e.g. `merchant@upi`.
  final String? upiId;

  /// Last 4 digits of the account / card.
  final String? accountLast4;

  /// Bank / UPI reference / transaction ID.
  final String? referenceNumber;

  /// Canonical bank name, e.g. 'SBI', 'HDFC', 'ICICI'.
  final String? bankName;

  /// Available account balance after the transaction.
  final double? availableBalance;

  /// Timestamp of the originating SMS.
  final DateTime timestamp;

  /// The raw SMS body that was parsed.
  final String rawSms;

  /// Originating sender ID, e.g. 'SBIINB', 'HDFCBK'.
  final String sender;

  /// Short hash used for duplicate detection.
  final String duplicateHash;

  /// Parser confidence score 0.0 – 1.0.
  final double confidence;

  /// Suggested category (populated by [CategorySuggester] post-parse).
  final String? suggestedCategory;

  const ParsedTransaction({
    required this.type,
    required this.amount,
    required this.currencyCode,
    required this.timestamp,
    required this.rawSms,
    required this.sender,
    required this.duplicateHash,
    required this.confidence,
    this.merchant,
    this.upiId,
    this.accountLast4,
    this.referenceNumber,
    this.bankName,
    this.availableBalance,
    this.suggestedCategory,
  });

  ParsedTransaction copyWith({
    TransactionType? type,
    double? amount,
    String? currencyCode,
    String? merchant,
    String? upiId,
    String? accountLast4,
    String? referenceNumber,
    String? bankName,
    double? availableBalance,
    DateTime? timestamp,
    String? rawSms,
    String? sender,
    String? duplicateHash,
    double? confidence,
    String? suggestedCategory,
  }) {
    return ParsedTransaction(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      merchant: merchant ?? this.merchant,
      upiId: upiId ?? this.upiId,
      accountLast4: accountLast4 ?? this.accountLast4,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      bankName: bankName ?? this.bankName,
      availableBalance: availableBalance ?? this.availableBalance,
      timestamp: timestamp ?? this.timestamp,
      rawSms: rawSms ?? this.rawSms,
      sender: sender ?? this.sender,
      duplicateHash: duplicateHash ?? this.duplicateHash,
      confidence: confidence ?? this.confidence,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'amount': amount,
        'currencyCode': currencyCode,
        'merchant': merchant,
        'upiId': upiId,
        'accountLast4': accountLast4,
        'referenceNumber': referenceNumber,
        'bankName': bankName,
        'availableBalance': availableBalance,
        'timestamp': timestamp.toIso8601String(),
        'rawSms': rawSms,
        'sender': sender,
        'duplicateHash': duplicateHash,
        'confidence': confidence,
        'suggestedCategory': suggestedCategory,
      };

  @override
  String toString() =>
      'ParsedTransaction(${type.name} ₹$amount from $sender '
      'merchant=$merchant confidence=$confidence)';
}
