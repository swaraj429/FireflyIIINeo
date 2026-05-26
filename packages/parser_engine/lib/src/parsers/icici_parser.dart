// lib/src/parsers/icici_parser.dart
import '../base_parser.dart';
import '../merchant_normalizer.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

/// Parser for ICICI Bank SMS alerts.
class IciciParser extends BankParser {
  @override
  String get bankName => 'ICICI';

  @override
  List<String> get senderPatterns =>
      [r'ICICIB', r'ICICIBB', r'ICICIBK', r'iMobile', r'ICICI-'];

  @override
  ParsedTransaction? parse(RawSmsInput sms) {
    final body = sms.body;

    final debit = _parseDebit(body, sms);
    if (debit != null) return debit;

    final credit = _parseCredit(body, sms);
    if (credit != null) return credit;

    final card = _parseCreditCard(body, sms);
    if (card != null) return card;

    return null;
  }

  ParsedTransaction? _parseDebit(String body, RawSmsInput sms) {
    // "ICICI Bank Acct XX1234 debited for Rs.5000.00 on 25-May-26;
    //  merchant AMAZON; UPI Ref 123456789"
    final pattern = RegExp(
      r'(?:ICICI\s+Bank\s+)?Acct\s+(?:[Xx*]+)?(\d{4})\s+debited\s+for\s+'
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)'
      r'(?:.*?merchant\s+(.+?)(?:;|\.|$))?'
      r'(?:.*?UPI\s+Ref\s+(\w+))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m != null) {
      final amount = double.tryParse(m.group(2)!.replaceAll(',', ''));
      if (amount != null) {
        return buildTransaction(
          type: TransactionType.debit,
          amount: amount,
          sms: sms,
          confidence: 0.93,
          accountLast4: m.group(1),
          merchant: m.group(3) != null
              ? MerchantNormalizer.normalize(m.group(3)!.trim())
              : null,
          referenceNumber: m.group(4),
          upiId: extractUpiId(body),
          availableBalance: extractAvailableBalance(body),
        );
      }
    }

    // Fallback: "INR X.XX debited from Acct XX1234"
    final fallback = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+debited\s+from\s+'
      r'(?:Acct|A/c|account)\s+(?:[Xx*]+)?(\d{4})',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    if (fallback != null) {
      final amount = double.tryParse(fallback.group(1)!.replaceAll(',', ''));
      if (amount != null) {
        return buildTransaction(
          type: TransactionType.debit,
          amount: amount,
          sms: sms,
          confidence: 0.85,
          accountLast4: fallback.group(2),
          upiId: extractUpiId(body),
          referenceNumber: extractUpiRef(body),
          availableBalance: extractAvailableBalance(body),
        );
      }
    }

    return null;
  }

  ParsedTransaction? _parseCredit(String body, RawSmsInput sms) {
    // "Your ICICI Bank Account XX1234 has been credited with Rs.10000.00 on 25-May-26. Info: SALARY"
    final pattern = RegExp(
      r'(?:ICICI\s+Bank\s+)?[Aa]ccount\s+(?:[Xx*]+)?(\d{4})\s+has\s+been\s+credited\s+with\s+'
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)'
      r'(?:.*?Info[:\s]+(.+?)(?:\.|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(2)!.replaceAll(',', ''));
    if (amount == null) return null;

    final info = m.group(3)?.trim();
    return buildTransaction(
      type: TransactionType.credit,
      amount: amount,
      sms: sms,
      confidence: 0.93,
      accountLast4: m.group(1),
      merchant: info != null ? MerchantNormalizer.normalize(info) : null,
      upiId: extractUpiId(body),
      referenceNumber: extractUpiRef(body),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseCreditCard(String body, RawSmsInput sms) {
    // "Alert : INR 2,000.00 spent on ICICI Bank Credit Card ending 1234.
    //  Merchant: ZOMATO. Avl Limit: INR 48,000.00"
    final pattern = RegExp(
      r'(?:Alert\s*:?\s*)?(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+'
      r'(?:spent|debited)\s+on\s+ICICI\s+Bank\s+Credit\s+Card\s+ending\s+(\d{4})'
      r'(?:.*?[Mm]erchant[:\s]+(.+?)(?:\.|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.95,
      accountLast4: m.group(2),
      merchant: m.group(3) != null
          ? MerchantNormalizer.normalize(m.group(3)!.trim())
          : null,
      availableBalance: extractAvailableBalance(body),
    );
  }
}
