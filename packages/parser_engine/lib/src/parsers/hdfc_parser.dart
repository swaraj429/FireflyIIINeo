// lib/src/parsers/hdfc_parser.dart
import '../base_parser.dart';
import '../merchant_normalizer.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

/// Parser for HDFC Bank SMS alerts.
///
/// Handles: account debit/credit via UPI, credit card transactions,
/// salary credits, and NEFT/IMPS.
class HdfcParser extends BankParser {
  @override
  String get bankName => 'HDFC';

  @override
  List<String> get senderPatterns =>
      [r'HDFCBK', r'\bHDFC\b', r'HDFCUPI', r'HDFCCC', r'HDFC-'];

  @override
  ParsedTransaction? parse(RawSmsInput sms) {
    final body = sms.body;

    final debit = _parseAccountDebit(body, sms);
    if (debit != null) return debit;

    final credit = _parseAccountCredit(body, sms);
    if (credit != null) return credit;

    final card = _parseCreditCard(body, sms);
    if (card != null) return card;

    final salary = _parseSalaryCredit(body, sms);
    if (salary != null) return salary;

    return null;
  }

  // ── Patterns ──────────────────────────────────────────────────────────────

  ParsedTransaction? _parseAccountDebit(String body, RawSmsInput sms) {
    // "HDFC Bank: Rs.5,000.00 debited from account **1234 on 25-05-2026 15:30:00 IST.
    //  Info: UPI-merchant@upi. Avl Bal: Rs.45000.00"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+debited\s+from\s+(?:account|a/c|acct?)\s+'
      r'(?:[*xX]+)?(\d{4})'
      r'(?:.*?Info[:\s]+(.+?)(?:\.?\s*Avl|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    final infoRaw = m.group(3)?.trim();
    String? merchant;
    String? upiId;
    if (infoRaw != null) {
      if (infoRaw.contains('@')) {
        upiId = infoRaw.replaceFirst(RegExp(r'^UPI[-:]?\s*', caseSensitive: false), '').trim();
        merchant = MerchantNormalizer.normalize(upiId);
      } else {
        merchant = MerchantNormalizer.normalize(infoRaw.replaceFirst(
          RegExp(r'^UPI[-:]?\s*', caseSensitive: false), ''));
      }
    }

    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.93,
      merchant: merchant,
      upiId: upiId,
      accountLast4: m.group(2),
      referenceNumber: extractUpiRef(body),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseAccountCredit(String body, RawSmsInput sms) {
    // "Rs.500.00 is credited to your HDFC Bank A/C X1234 on 25/05/26 by UPI. UPI Ref:123456"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+(?:is\s+)?credited\s+to\s+(?:your\s+)?'
      r'(?:HDFC\s+Bank\s+)?(?:A/C?|account|acct?)\s+(?:[xX*]+)?(\d{4})',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    // Try to find a by-info clause for merchant
    final byMatch = RegExp(r'by\s+(.+?)(?:\s*\.|$)', caseSensitive: false).firstMatch(body);
    final merchant = byMatch?.group(1) != null
        ? MerchantNormalizer.normalize(byMatch!.group(1)!.trim())
        : null;

    return buildTransaction(
      type: TransactionType.credit,
      amount: amount,
      sms: sms,
      confidence: 0.92,
      merchant: merchant,
      accountLast4: m.group(2),
      upiId: extractUpiId(body),
      referenceNumber: extractUpiRef(body),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseCreditCard(String body, RawSmsInput sms) {
    // "Dear Customer, Your HDFC Bank Credit Card ending 1234 has been used for
    //  Rs 2500.00 at SWIGGY on 25/05/2026"
    final pattern = RegExp(
      r'(?:HDFC\s+Bank\s+)?Credit\s+Card\s+ending\s+(\d{4})\s+has\s+been\s+used\s+for\s+'
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)'
      r'\s+at\s+(.+?)\s+on\s+\d',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(2)!.replaceAll(',', ''));
    if (amount == null) return null;

    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.95,
      merchant: MerchantNormalizer.normalize(m.group(3)?.trim() ?? ''),
      accountLast4: m.group(1),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseSalaryCredit(String body, RawSmsInput sms) {
    // "Salary of Rs.XX,XXX.00 has been credited to your HDFC Bank Account ****1234"
    final pattern = RegExp(
      r'[Ss]alary\s+(?:of\s+)?(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+'
      r'(?:has\s+been\s+)?credited\s+to\s+(?:your\s+)?(?:HDFC\s+Bank\s+)?'
      r'(?:account|a/c)\s+(?:[*xX]+)?(\d{4})',
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
      confidence: 0.95,
      merchant: 'Salary',
      accountLast4: m.group(2),
      availableBalance: extractAvailableBalance(body),
    );
  }
}
