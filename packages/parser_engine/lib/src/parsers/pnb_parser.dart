// lib/src/parsers/pnb_parser.dart
import '../base_parser.dart';
import '../merchant_normalizer.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

/// Parser for Punjab National Bank (PNB) SMS alerts.
class PnbParser extends BankParser {
  @override
  String get bankName => 'PNB';

  @override
  List<String> get senderPatterns => [r'PNBSMS', r'\bPNB\b', r'PNB-'];

  @override
  ParsedTransaction? parse(RawSmsInput sms) {
    final body = sms.body;

    // Debit: "Your A/c No XX1234 has been debited with Rs.XXX on DD-MM-YYYY"
    final debitPattern = RegExp(
      r'[Aa]/c\s+(?:[Nn]o\.?\s*)?(?:[xX*]+)?(\d{4})\s+has\s+been\s+debited\s+with\s+'
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)'
      r'(?:.*?(?:toward|Info|for)[:\s]+(.+?)(?:\.|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final dm = debitPattern.firstMatch(body);
    if (dm != null) {
      final amount = double.tryParse(dm.group(2)!.replaceAll(',', ''));
      if (amount != null) {
        return buildTransaction(
          type: TransactionType.debit,
          amount: amount,
          sms: sms,
          confidence: 0.87,
          accountLast4: dm.group(1),
          merchant: dm.group(3) != null
              ? MerchantNormalizer.normalize(dm.group(3)!.trim())
              : null,
          upiId: extractUpiId(body),
          referenceNumber: extractUpiRef(body),
          availableBalance: extractAvailableBalance(body),
        );
      }
    }

    // Credit: "Your A/c No XX1234 has been credited with Rs.XXX"
    final creditPattern = RegExp(
      r'[Aa]/c\s+(?:[Nn]o\.?\s*)?(?:[xX*]+)?(\d{4})\s+has\s+been\s+credited\s+with\s+'
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
      dotAll: true,
    );
    final cm = creditPattern.firstMatch(body);
    if (cm != null) {
      final amount = double.tryParse(cm.group(2)!.replaceAll(',', ''));
      if (amount != null) {
        return buildTransaction(
          type: TransactionType.credit,
          amount: amount,
          sms: sms,
          confidence: 0.87,
          accountLast4: cm.group(1),
          upiId: extractUpiId(body),
          referenceNumber: extractUpiRef(body),
          availableBalance: extractAvailableBalance(body),
        );
      }
    }

    return null;
  }
}
