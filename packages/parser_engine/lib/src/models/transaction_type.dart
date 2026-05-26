// lib/src/models/transaction_type.dart

/// Whether an SMS represents money leaving or entering an account.
enum TransactionType {
  /// Money debited / sent from account.
  debit,

  /// Money credited / received into account.
  credit,
}
