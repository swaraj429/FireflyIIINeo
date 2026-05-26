import '../base_parser.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

class UpiParser extends BankParser {
  @override
  bool canHandle(String sender) {
    // UPI apps often send from generic IDs like VPA, UPI, BHIM, etc.
    final s = sender.toUpperCase();
    return s.contains('UPI') || s.contains('BHIM') || s.contains('PAYTM') || s.contains('PHONEPE') || s.contains('GPAY');
  }

  @override
  ParsedTransaction? parse(RawSmsInput sms) {
    final body = sms.body;
    
    // Common UPI format: Sent Rs. 500.00 to Merchant Name via UPI...
    final sentPattern = RegExp(r'(?i)(?:sent|paid)\s*(?:rs\.?|inr)\s*([\d,]+\.?\d*)\s*(?:to)\s*([a-z0-9\s@\.\-]+?)\s*(?:via|on|upi|ref|txn)');
    final receivedPattern = RegExp(r'(?i)(?:received)\s*(?:rs\.?|inr)\s*([\d,]+\.?\d*)\s*(?:from)\s*([a-z0-9\s@\.\-]+?)\s*(?:via|on|upi|ref|txn)');
    
    // Check Sent
    var match = sentPattern.firstMatch(body);
    if (match != null) {
      return ParsedTransaction(
        amount: parseAmount(match.group(1)),
        type: TransactionType.credit, // Because it's an expense/withdrawal, mapped as debit usually. Wait, in Firefly 'withdrawal' is out. The model uses 'debit'/'credit'. Let's stick to debit for expense.
        merchant: match.group(2)?.trim(),
        accountId: null,
      )..type = TransactionType.debit;
    }

    // Check Received
    match = receivedPattern.firstMatch(body);
    if (match != null) {
      return ParsedTransaction(
        amount: parseAmount(match.group(1)),
        type: TransactionType.credit,
        merchant: match.group(2)?.trim(),
        accountId: null,
      );
    }
    
    return null;
  }
}
