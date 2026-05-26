// lib/src/parsers/idfc_parser.dart
import '../base_parser.dart';
import '../merchant_normalizer.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

/// Parser for IDFC FIRST Bank SMS alerts.
class IdfcParser extends BankParser {
  @override
  String get bankName => 'IDFC FIRST';

  @override
  List<String> get senderPatterns =>
      [r'IDFCFB', r'IDFCBK', r'IDFCFIRSTB', r'IDFC-'];

  @override
  ParsedTransaction? parse(RawSmsInput sms) {
    final body = sms.body;

    final debit = _parseDebit(body, sms);
    if (debit != null) return debit;

    final credit = _parseCredit(body, sms);
    if (credit != null) return credit;

    return null;
  }

  ParsedTransaction? _parseDebit(String body, RawSmsInput sms) {
    // "IDFC FIRST Bank: Rs.500.00 debited from A/c XX1234 on 25-May-2026 via UPI.
    //  Merchant: SWIGGY. Avl bal Rs.5000"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+debited\s+from\s+'
      r'(?:A/c|account|acct?)\s+(?:[xX*]+)?(\d{4})'
      r'(?:.*?(?:Merchant|Info)[:\s]+(.+?)(?:\.|\s*Avl|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    final merchantRaw = m.group(3)?.trim();
    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.92,
      accountLast4: m.group(2),
      merchant: merchantRaw != null ? MerchantNormalizer.normalize(merchantRaw) : null,
      upiId: extractUpiId(body),
      referenceNumber: extractUpiRef(body),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseCredit(String body, RawSmsInput sms) {
    // "IDFC FIRST Bank: Rs.XX credited to A/c XX1234 via UPI. Ref: XXXX"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+credited\s+to\s+'
      r'(?:A/c|account|acct?)\s+(?:[xX*]+)?(\d{4})',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    return buildTransaction(
      type: TransactionType.credit,
      amount: amount,
      sms: sms,
      confidence: 0.90,
      accountLast4: m.group(2),
      upiId: extractUpiId(body),
      referenceNumber: extractUpiRef(body),
      availableBalance: extractAvailableBalance(body),
    );
  }
}
