// lib/src/base_parser.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'models/parsed_transaction.dart';
import 'models/raw_sms_input.dart';
import 'models/transaction_type.dart';

/// Abstract base class that every bank-specific parser extends.
///
/// Subclasses must:
///  1. Declare [bankName] and [senderPatterns].
///  2. Override [parse] to return a [ParsedTransaction] or `null`.
abstract class BankParser {
  /// Human-readable bank name, e.g. 'SBI'.
  String get bankName;

  /// List of regex patterns that match the SMS sender IDs for this bank.
  /// Patterns are matched case-insensitively.
  List<String> get senderPatterns;

  /// Returns `true` if this parser can handle an SMS from [sender].
  bool canHandle(String sender) {
    return senderPatterns.any(
      (p) => RegExp(p, caseSensitive: false).hasMatch(sender),
    );
  }

  /// Attempt to parse [sms] into a [ParsedTransaction].
  /// Returns `null` if the SMS doesn't match any known pattern for this bank.
  ParsedTransaction? parse(RawSmsInput sms);

  // ── Shared extraction helpers ─────────────────────────────────────────────

  /// Extract a monetary amount from [text].
  ///
  /// Tries multiple real-world patterns found in Indian bank SMS messages.
  double? extractAmount(String text) {
    final patterns = [
      // Rs./INR/₹ followed by amount
      r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)',
      // Amount followed by Rs./INR/₹
      r'([\d,]+(?:\.\d{1,2})?)\s*(?:Rs\.?|INR|₹)',
      // "debited/credited/spent/paid Rs/INR/₹? AMOUNT"
      r'(?:debited|credited|spent|paid|withdrawn|received)\s+(?:(?:Rs\.?|INR|₹)\s*)?([\d,]+(?:\.\d{1,2})?)',
      // "AMOUNT debited/credited"
      r'([\d,]+(?:\.\d{1,2})?)\s+(?:debited|credited)',
    ];

    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
      if (match != null) {
        final raw = match.group(1)!.replaceAll(',', '');
        final value = double.tryParse(raw);
        if (value != null && value > 0) return value;
      }
    }
    return null;
  }

  /// Detect transaction direction from [text].
  TransactionType? detectTransactionType(String text) {
    final lower = text.toLowerCase();
    const debitKeywords = [
      'debited', 'debit', 'spent', 'paid', 'withdrawn', 'withdrawal',
      'payment', 'purchase', 'sent', 'transferred to', 'mandate executed',
    ];
    const creditKeywords = [
      'credited', 'credit', 'received', 'deposited', 'refund',
      'transferred to your', 'salary', 'cashback', 'added',
    ];
    final isDebit = debitKeywords.any((k) => lower.contains(k));
    final isCredit = creditKeywords.any((k) => lower.contains(k));

    if (isDebit && !isCredit) return TransactionType.debit;
    if (isCredit && !isDebit) return TransactionType.credit;
    if (isCredit && isDebit) {
      // If both match, prefer credit only for specific patterns
      if (lower.contains('credited')) return TransactionType.credit;
      return TransactionType.debit;
    }
    return null;
  }

  /// Extract last 4 digits of account/card from [text].
  String? extractAccountLast4(String text) {
    final patterns = [
      r'[Xx*]{1,4}(\d{4})',                        // XX1234, **1234
      r'(?:a/c|acct?|account|card)\s*(?:no\.?)?\s*(?:[xX*]+)?(\d{4})',
      r'ending\s+(?:with\s+)?(?:\d+)?(\d{4})',    // ending 1234
      r'(?:last|ending)\s+4\s+digits?\s+(\d{4})',
    ];
    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
      if (match != null) return match.group(1);
    }
    return null;
  }

  /// Extract available balance from [text].
  double? extractAvailableBalance(String text) {
    final patterns = [
      r'(?:avl?\.?\s*bal\.?|available\s+bal(?:ance)?|bal\.?)\s*(?:is\s*)?(?:Rs\.?|INR|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
      r'(?:avl?\.?\s+limit)\s*(?:Rs\.?|INR|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
    ];
    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
      if (match != null) {
        final raw = match.group(1)!.replaceAll(',', '');
        return double.tryParse(raw);
      }
    }
    return null;
  }

  /// Extract UPI reference ID from [text].
  String? extractUpiRef(String text) {
    final patterns = [
      r'UPI\s*[Rr]ef(?:erence)?(?:\s*[Nn]o\.?)?\s*[:\-]?\s*(\w+)',
      r'UPI\s*/\s*(\d{10,})',
      r'Ref\s*[Nn]o\.?\s*[:\-]?\s*(\w{8,})',
      r'Ref\s*[:\-]\s*(\d{8,})',
      r'(?:transaction|txn)\s*(?:id|no)\.?\s*[:\-]?\s*(\w{8,})',
    ];
    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
      if (match != null) return match.group(1);
    }
    return null;
  }

  /// Extract UPI VPA from [text], e.g. `merchant@upi`.
  String? extractUpiId(String text) {
    final match = RegExp(r'([\w.\-]+@[\w.\-]+)').firstMatch(text);
    return match?.group(1);
  }

  /// Generate a short deduplication hash for a transaction.
  ///
  /// Uses amount + merchant + minute-level timestamp bucket to catch
  /// duplicate notifications within a 60-second window.
  String generateHash({
    required double amount,
    required String? merchant,
    required DateTime timestamp,
  }) {
    final minuteBucket = timestamp.millisecondsSinceEpoch ~/ 60000;
    final input = '$amount|${merchant ?? ""}|$minuteBucket';
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  // ── Protected builder helper ──────────────────────────────────────────────

  /// Convenience builder that requires the minimum fields and fills defaults.
  ParsedTransaction buildTransaction({
    required TransactionType type,
    required double amount,
    required RawSmsInput sms,
    required double confidence,
    String currencyCode = 'INR',
    String? merchant,
    String? upiId,
    String? accountLast4,
    String? referenceNumber,
    String? bankName,
    double? availableBalance,
  }) {
    final hash = generateHash(
      amount: amount,
      merchant: merchant,
      timestamp: sms.timestamp,
    );
    return ParsedTransaction(
      type: type,
      amount: amount,
      currencyCode: currencyCode,
      merchant: merchant,
      upiId: upiId,
      accountLast4: accountLast4,
      referenceNumber: referenceNumber,
      bankName: bankName ?? this.bankName,
      availableBalance: availableBalance,
      timestamp: sms.timestamp,
      rawSms: sms.body,
      sender: sms.sender,
      duplicateHash: hash,
      confidence: confidence,
    );
  }
}
