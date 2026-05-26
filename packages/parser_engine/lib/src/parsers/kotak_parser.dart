// lib/src/parsers/kotak_parser.dart
import '../base_parser.dart';
import '../merchant_normalizer.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

/// Parser for Kotak Mahindra Bank SMS alerts.
class KotakParser extends BankParser {
  @override
  String get bankName => 'Kotak';

  @override
  List<String> get senderPatterns =>
      [r'KOTAKB', r'KMBANK', r'\bKMB\b', r'KOTAK-'];

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
    // "Kotak Bank: INR 5,000 debited from Acct 1234 on 25-05-26.
    //  Info: UPI-merchant. Avl Bal INR 15,000"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+debited\s+from\s+'
      r'(?:Kotak\s+(?:Mahindra\s+)?(?:Bank\s+)?)?'
      r'(?:Acct|A/c|account)\s+(?:[xX*]+)?(\d{4})'
      r'(?:.*?(?:Info|Description)[:\s]+(.+?)(?:\.?\s*Avl|$))?',
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
        upiId = infoRaw.replaceFirst(RegExp(r'^UPI[-:]?\s*'), '').trim();
        merchant = MerchantNormalizer.normalize(upiId);
      } else {
        merchant = MerchantNormalizer.normalize(
            infoRaw.replaceFirst(RegExp(r'^UPI[-:]?\s*'), '').trim());
      }
    }

    return buildTransaction(
      type: TransactionType.debit,
      amount: amount,
      sms: sms,
      confidence: 0.91,
      accountLast4: m.group(2),
      merchant: merchant,
      upiId: upiId,
      referenceNumber: extractUpiRef(body),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseCredit(String body, RawSmsInput sms) {
    // "INR 10,000 credited to Kotak Acct 1234 on 25-05-26. Description: SALARY"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+credited\s+to\s+'
      r'(?:Kotak\s+(?:Mahindra\s+)?(?:Bank\s+)?)?'
      r'(?:Acct|A/c|account)\s+(?:[xX*]+)?(\d{4})'
      r'(?:.*?(?:Description|Info)[:\s]+(.+?)(?:\.|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    final desc = m.group(3)?.trim();
    return buildTransaction(
      type: TransactionType.credit,
      amount: amount,
      sms: sms,
      confidence: 0.91,
      accountLast4: m.group(2),
      merchant: desc != null ? MerchantNormalizer.normalize(desc) : null,
      upiId: extractUpiId(body),
      referenceNumber: extractUpiRef(body),
      availableBalance: extractAvailableBalance(body),
    );
  }
}
