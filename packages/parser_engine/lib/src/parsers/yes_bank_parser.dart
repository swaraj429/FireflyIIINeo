// lib/src/parsers/yes_bank_parser.dart
import '../base_parser.dart';
import '../merchant_normalizer.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

/// Parser for Yes Bank SMS alerts.
class YesBankParser extends BankParser {
  @override
  String get bankName => 'Yes Bank';

  @override
  List<String> get senderPatterns => [r'YESBNK', r'YESBK', r'YESB-'];

  @override
  ParsedTransaction? parse(RawSmsInput sms) {
    final body = sms.body;

    // Debit
    final debitPattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+(?:has\s+been\s+)?debited\s+'
      r'(?:from|in)\s+(?:your\s+)?(?:Yes\s+Bank\s+)?(?:A/c|account|acct?)\s+(?:[xX*]+)?(\d{4})'
      r'(?:.*?(?:Info|Merchant)[:\s]+(.+?)(?:\.|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final dm = debitPattern.firstMatch(body);
    if (dm != null) {
      final amount = double.tryParse(dm.group(1)!.replaceAll(',', ''));
      if (amount != null) {
        return buildTransaction(
          type: TransactionType.debit,
          amount: amount,
          sms: sms,
          confidence: 0.88,
          accountLast4: dm.group(2),
          merchant: dm.group(3) != null
              ? MerchantNormalizer.normalize(dm.group(3)!.trim())
              : null,
          upiId: extractUpiId(body),
          referenceNumber: extractUpiRef(body),
          availableBalance: extractAvailableBalance(body),
        );
      }
    }

    // Credit
    final creditPattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+(?:has\s+been\s+)?credited\s+'
      r'(?:to|in)\s+(?:your\s+)?(?:Yes\s+Bank\s+)?(?:A/c|account|acct?)\s+(?:[xX*]+)?(\d{4})',
      caseSensitive: false,
      dotAll: true,
    );
    final cm = creditPattern.firstMatch(body);
    if (cm != null) {
      final amount = double.tryParse(cm.group(1)!.replaceAll(',', ''));
      if (amount != null) {
        return buildTransaction(
          type: TransactionType.credit,
          amount: amount,
          sms: sms,
          confidence: 0.88,
          accountLast4: cm.group(2),
          upiId: extractUpiId(body),
          referenceNumber: extractUpiRef(body),
          availableBalance: extractAvailableBalance(body),
        );
      }
    }

    return null;
  }
}
