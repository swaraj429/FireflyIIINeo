import 'models/parsed_transaction.dart';
import 'models/transaction_type.dart';

class CategorySuggester {
  static const Map<String, String> _merchantToCategory = {
    'Swiggy': 'Food & Dining',
    'Zomato': 'Food & Dining',
    'Blinkit': 'Groceries',
    'Amazon': 'Shopping',
    'Flipkart': 'Shopping',
    'Uber': 'Transport',
    'Ola': 'Transport',
    'Rapido': 'Transport',
    'Netflix': 'Entertainment',
    'Spotify': 'Entertainment',
    'Airtel': 'Bills & Utilities',
    'Jio': 'Bills & Utilities',
    'IRCTC': 'Travel',
    'MakeMyTrip': 'Travel',
    'HPCL': 'Fuel',
    'BPCL': 'Fuel',
    'Indian Oil': 'Fuel',
    'Apollo': 'Healthcare',
    'PharmEasy': 'Healthcare',
    'BigBasket': 'Groceries',
    'Zepto': 'Groceries',
    'DMart': 'Groceries',
    'SALARY': 'Income',
    'INTEREST': 'Income',
    'ATM': 'Cash Withdrawal',
  };

  static String? suggest(ParsedTransaction tx) {
    if (tx.merchant == null || tx.merchant!.isEmpty) {
       if (tx.type == TransactionType.credit) return 'Income';
       return null;
    }

    final merchantUpper = tx.merchant!.toUpperCase();
    
    for (final entry in _merchantToCategory.entries) {
      if (merchantUpper.contains(entry.key.toUpperCase())) {
        return entry.value;
      }
    }
    
    if (tx.type == TransactionType.credit) return 'Income';
    
    return null; // Fallback to let the user decide
  }
}
