// lib/src/parsers/axis_parser.dart
import '../base_parser.dart';
import '../merchant_normalizer.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

/// Parser for Axis Bank SMS alerts.
class AxisParser extends BankParser {
  @override
  String get bankName => 'Axis';

  @override
  List<String> get senderPatterns =>
      [r'AXISBK', r'AXISBN', r'UTIBK', r'AXISB', r'AXIS-'];

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
    // "INR 5000.00 debited from Axis Bank Account XX1234 on 25May26.
    //  Info:UPI/XXXX/MERCHANT. Avl Bal INR 20000.00"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+debited\s+from\s+'
      r'(?:Axis\s+Bank\s+)?(?:account|a/c|acct?)\s+(?:[xX*]+)?(\d{4})'
      r'(?:.*?Info[:\s]+(.+?)(?:\.?\s*Avl|$))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m != null) {
      final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (amount != null) {
        final info = m.group(3)?.trim();
        String? merchant;
        String? ref;
        if (info != null) {
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
          confidence: 0.93,
          accountLast4: m.group(2),
          merchant: merchant,
          referenceNumber: ref ?? extractUpiRef(body),
          upiId: extractUpiId(body),
          availableBalance: extractAvailableBalance(body),
        );
      }
    }
    return null;
  }

  ParsedTransaction? _parseCredit(String body, RawSmsInput sms) {
    // "INR 500.00 credited to Axis Acct XX1234 on 25May26 via UPI
    //  from merchant@upi UPI Ref 123456"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+credited\s+to\s+'
      r'(?:Axis\s+(?:Bank\s+)?)?(?:Acct|account|a/c)\s+(?:[xX*]+)?(\d{4})'
      r'(?:.*?from\s+([\w.\-@]+))?',
      caseSensitive: false,
      dotAll: true,
    );
    final m = pattern.firstMatch(body);
    if (m == null) return null;

    final amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (amount == null) return null;

    final fromRaw = m.group(3)?.trim();
    final upiId   = fromRaw != null && fromRaw.contains('@') ? fromRaw : null;
    final merchant = fromRaw != null ? MerchantNormalizer.normalize(fromRaw) : null;

    return buildTransaction(
      type: TransactionType.credit,
      amount: amount,
      sms: sms,
      confidence: 0.92,
      accountLast4: m.group(2),
      merchant: merchant,
      upiId: upiId,
      referenceNumber: extractUpiRef(body),
      availableBalance: extractAvailableBalance(body),
    );
  }

  ParsedTransaction? _parseCreditCard(String body, RawSmsInput sms) {
    // "INR XXXX spent on Axis Bank Credit Card ending XXXX at MERCHANT on DD-MMM-YY"
    final pattern = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)\s+(?:spent|used)\s+on\s+'
      r'Axis\s+(?:Bank\s+)?Credit\s+Card\s+ending\s+(\d{4})'
      r'(?:\s+at\s+(.+?)\s+on\s+\d)?',
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
