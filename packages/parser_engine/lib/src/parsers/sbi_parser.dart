// lib/src/parsers/sbi_parser.dart
import '../base_parser.dart';
import '../merchant_normalizer.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

/// Parser for State Bank of India (SBI) SMS alerts.
///
/// Handles: debit/credit via UPI, ATM withdrawals, card transactions,
/// NEFT/RTGS, and salary credits.
class SbiParser extends BankParser {
  @override
  String get bankName => 'SBI';

  @override
  List<String> get senderPatterns =>
      [r'SBIINB', r'SBIPSG', r'\bSBI\b', r'SBIATM', r'SBIUPI', r'SBICARD', r'SBI-'];

  // ──────────────────────────────────────────────────────────────────────────

  @override
  ParsedTransaction? parse(RawSmsInput sms) {
    final body = sms.body;

    // 1. UPI Debit
    // "Dear SBI User, Rs. 500.00 Debited from A/c XX1234 on 25-05-26.
    //  UPI Ref:123456789. To:merchant@upi. Avl Bal: Rs.49500"
    final upiDebit = _parseUpiDebit(body, sms);
    if (upiDebit != null) return upiDebit;

    // 2. UPI Credit
    // "Your A/c XX1234 Credited with Rs.5000 on 25/05/26 by UPI/REF/MERCHANT"
    final upiCredit = _parseUpiCredit(body, sms);
    if (upiCredit != null) return upiCredit;

    // 3. General debit (NEFT/IMPS/SI)
    // "Your A/c XX1234 is debited for Rs. 5,000.00 on 25-05-26. Info: UPI/XXXXXXXXXX/MERCHANT. Avl Bal: Rs. 50,000.00"
    final genericDebit = _parseGenericDebit(body, sms);
    if (genericDebit != null) return genericDebit;

    // 4. ATM withdrawal
    // "Rs.5000.00 withdrawn from your SBI ATM Card ending 1234 at ATM BRANCH on 25-05-26. Avl Bal:Rs.50000"
    final atm = _parseAtmWithdrawal(body, sms);
    if (atm != null) return atm;

    // 5. Credit Card
    // "Rs 1000.00 spent on SBI Credit Card ending 1234 at AMAZON INDIA on 25-05-26. Avl Limit:Rs.99000"
    final card = _parseCreditCard(body, sms);
    if (card != null) return card;

    return null;
  }

  // ── Pattern implementations ───────────────────────────────────────────────

  ParsedTransaction? _parseUpiDebit(String body, RawSmsInput sms) {
    // Pattern: "Debited from A/c XX1234" + "UPI Ref" + "To:merchant@upi"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+Debited\s+from\s+A/c\s+(?:[Xx*]+)?(\d{4})'
      r'.*?UPI\s*Ref[:\s]*(\w+)'
      r'.*?To[:\s]*([\w.\-@]+)',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount  = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    final acct4   = m.group(2);
    final ref     = m.group(3);
    final upiRaw  = m.group(4) ?? '';
    final upiId   = upiRaw.contains('@') ? upiRaw : null;
    final merchant = MerchantNormalizer.normalize(upiRaw);
    final balance  = extractAvailableBalance(body);

    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.95,
      merchant: merchant,
      upiId: upiId,
      accountLast4: acct4,
      referenceNumber: ref,
      availableBalance: balance,
    );
  }

  ParsedTransaction? _parseUpiCredit(String body, RawSmsInput sms) {
    // Pattern 1: "A/c XX1234 Credited with Rs.5000 on ... by UPI/REF/MERCHANT"
    final pattern1 = RegExp(
      r'A/c\s+(?:[Xx*]+)?(\d{4})\s+Credited\s+with\s+(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)'
      r'(?:.*?by\s+UPI/(\w+)/(.+))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m1 = pattern1.firstMatch(body);
    if (m1 != null) {
      final amount = double.tryParse(m1.group(2)!.replaceAll(',', ''));
      if (amount != null) {
        final ref      = m1.group(3);
        final merchant = m1.group(4) != null
            ? MerchantNormalizer.normalize(m1.group(4)!)
            : null;
        return buildTransaction(
          type: TransactionType.credit,
          amount: amount,
          sms: sms,
          confidence: 0.93,
          merchant: merchant,
          accountLast4: m1.group(1),
          referenceNumber: ref,
          availableBalance: extractAvailableBalance(body),
        );
      }
    }

    // Pattern 2: "credited ... Rs X via UPI"
    final pattern2 = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+(?:is\s+)?credited\s+to\s+(?:your\s+)?'
      r'(?:SBI\s+)?(?:A/c|account)\s+(?:[Xx*]+)?(\d{4})',
      caseSensitive: false,
      dotAll: true,
    );
    final m2 = pattern2.firstMatch(body);
    if (m2 != null) {
      final amount = double.tryParse(m2.group(1)!.replaceAll(',', ''));
      if (amount != null) {
        return buildTransaction(
          type: TransactionType.credit,
          amount: amount,
          sms: sms,
          confidence: 0.88,
          accountLast4: m2.group(2),
          upiId: extractUpiId(body),
          referenceNumber: extractUpiRef(body),
          availableBalance: extractAvailableBalance(body),
        );
      }
    }
    return null;
  }

  ParsedTransaction? _parseGenericDebit(String body, RawSmsInput sms) {
    // "Your A/c XX1234 is debited for Rs. 5,000.00 on 25-05-26. Info: UPI/.../MERCHANT"
    final pattern = RegExp(
      r'A/c\s+(?:[Xx*]+)?(\d{4})\s+is\s+debited\s+for\s+(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)'
      r'(?:.*?Info[:\s]+(.+?)(?:\.\s*Avl|\s*Avl|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(2)!.replaceAll(',', ''));
    if (amount == null) return null;

    String? merchant;
    String? ref;
    final info = m.group(3)?.trim();
    if (info != null) {
      // Info field often looks like "UPI/123456789/MERCHANT NAME"
      final parts = info.split('/');
      if (parts.length >= 3) {
        ref = parts[1].trim();
        merchant = MerchantNormalizer.normalize(parts.sublist(2).join('/').trim());
      } else {
        merchant = MerchantNormalizer.normalize(info);
      }
    }

    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.90,
      merchant: merchant,
      accountLast4: m.group(1),
      referenceNumber: ref ?? extractUpiRef(body),
      upiId: extractUpiId(body),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseAtmWithdrawal(String body, RawSmsInput sms) {
    // "Rs.5000.00 withdrawn from your SBI ATM Card ending 1234 at ATM BRANCH"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+withdrawn\s+from\s+your\s+SBI\s+ATM\s+Card\s+ending\s+(\d{4})'
      r'(?:\s+at\s+(.+?)(?:\s+on\s+|\.\s+Avl|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    final location = m.group(3)?.trim();
    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.95,
      merchant: location != null ? 'ATM – ${MerchantNormalizer.normalize(location)}' : 'ATM Withdrawal',
      accountLast4: m.group(2),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseCreditCard(String body, RawSmsInput sms) {
    // "Rs 1000.00 spent on SBI Credit Card ending 1234 at AMAZON INDIA on 25-05-26"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+spent\s+on\s+SBI\s+Credit\s+Card\s+ending\s+(\d{4})'
      r'\s+at\s+(.+?)\s+on\s+\d',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    final merchant = MerchantNormalizer.normalize(m.group(3)?.trim() ?? '');
    final balance  = extractAvailableBalance(body);

    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.95,
      merchant: merchant,
      accountLast4: m.group(2),
      availableBalance: balance,
    );
  }
}
