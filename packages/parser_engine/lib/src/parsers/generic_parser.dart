import '../base_parser.dart';
import '../models/parsed_transaction.dart';
import '../models/raw_sms_input.dart';
import '../models/transaction_type.dart';

class GenericParser extends BankParser {
  @override
  bool canHandle(String sender) => true; // Catch-all

  @override
  ParsedTransaction? parse(RawSmsInput sms) {
    final body = sms.body.toLowerCase();
    
    // Must contain some money indicator
    if (!body.contains('rs') && !body.contains('inr') && !body.contains('₹')) return null;

    final debitKeywords = ['debited', 'spent', 'paid', 'deducted', 'withdrawn', 'purchase', 'sent'];
    final creditKeywords = ['credited', 'received', 'added', 'deposited', 'refunded'];
    
    bool isDebit = debitKeywords.any((k) => body.contains(k));
    bool isCredit = creditKeywords.any((k) => body.contains(k));
    
    if (isDebit == isCredit) return null; // Ambiguous or neither
    
    // Extremely generic amount extraction (first currency match)
    final amountPattern = RegExp(r'(?:rs\.?|inr|₹)\s*([\d,]+\.?\d*)');
    final match = amountPattern.firstMatch(body);
    if (match == null) return null;

    // Extremely generic merchant extraction (looks for "to/from/at XXXXX")
    String? merchant;
    final merchantPattern = isDebit 
        ? RegExp(r'(?:to|at)\s+([a-z0-9\s@\.\-]+?)(?:\s+(?:on|via|ref|bal|available|txn|using|card|upi|net banking)|\.)') 
        : RegExp(r'(?:from)\s+([a-z0-9\s@\.\-]+?)(?:\s+(?:on|via|ref|bal|available|txn|using|card|upi|net banking)|\.)');
        
    final mMatch = merchantPattern.firstMatch(body);
    if (mMatch != null && mMatch.groupCount >= 1) {
      merchant = mMatch.group(1)?.trim();
    }

    return ParsedTransaction(
      amount: parseAmount(match.group(1)),
      type: isDebit ? TransactionType.debit : TransactionType.credit,
      merchant: merchant,
      accountId: null,
    );
  }
}
