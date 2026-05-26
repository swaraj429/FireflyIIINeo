import 'package:intl/intl.dart';

/// Currency formatting utilities for FireflyIII Neo
abstract class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, _CurrencyInfo> _currencies = {
    'INR': _CurrencyInfo(symbol: '₹', name: 'Indian Rupee', decimalDigits: 2),
    'USD': _CurrencyInfo(symbol: '\$', name: 'US Dollar', decimalDigits: 2),
    'EUR': _CurrencyInfo(symbol: '€', name: 'Euro', decimalDigits: 2),
    'GBP': _CurrencyInfo(symbol: '£', name: 'British Pound', decimalDigits: 2),
    'JPY': _CurrencyInfo(symbol: '¥', name: 'Japanese Yen', decimalDigits: 0),
    'CAD': _CurrencyInfo(symbol: 'CA\$', name: 'Canadian Dollar', decimalDigits: 2),
    'AUD': _CurrencyInfo(symbol: 'A\$', name: 'Australian Dollar', decimalDigits: 2),
    'CHF': _CurrencyInfo(symbol: 'CHF', name: 'Swiss Franc', decimalDigits: 2),
    'CNY': _CurrencyInfo(symbol: '¥', name: 'Chinese Yuan', decimalDigits: 2),
    'SGD': _CurrencyInfo(symbol: 'S\$', name: 'Singapore Dollar', decimalDigits: 2),
    'HKD': _CurrencyInfo(symbol: 'HK\$', name: 'Hong Kong Dollar', decimalDigits: 2),
    'NZD': _CurrencyInfo(symbol: 'NZ\$', name: 'New Zealand Dollar', decimalDigits: 2),
    'MXN': _CurrencyInfo(symbol: 'MX\$', name: 'Mexican Peso', decimalDigits: 2),
    'BRL': _CurrencyInfo(symbol: 'R\$', name: 'Brazilian Real', decimalDigits: 2),
    'ZAR': _CurrencyInfo(symbol: 'R', name: 'South African Rand', decimalDigits: 2),
    'AED': _CurrencyInfo(symbol: 'د.إ', name: 'UAE Dirham', decimalDigits: 2),
    'SAR': _CurrencyInfo(symbol: '﷼', name: 'Saudi Riyal', decimalDigits: 2),
    'THB': _CurrencyInfo(symbol: '฿', name: 'Thai Baht', decimalDigits: 2),
    'IDR': _CurrencyInfo(symbol: 'Rp', name: 'Indonesian Rupiah', decimalDigits: 0),
    'MYR': _CurrencyInfo(symbol: 'RM', name: 'Malaysian Ringgit', decimalDigits: 2),
  };

  /// Returns the currency symbol for [currencyCode], defaults to the code itself.
  static String symbol(String currencyCode) {
    return _currencies[currencyCode.toUpperCase()]?.symbol ?? currencyCode;
  }

  /// Formats [amount] as a currency string.
  /// e.g. formatAmount(1234.56, 'INR') => '₹1,234.56'
  static String formatAmount(double amount, String currencyCode) {
    final info = _currencies[currencyCode.toUpperCase()];
    final decimals = info?.decimalDigits ?? 2;
    final sym = info?.symbol ?? currencyCode;

    final formatter = NumberFormat.currency(
      symbol: sym,
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }

  /// Formats [amount] as a signed string (+ for positive, - for negative).
  static String formatSigned(double amount, String currencyCode) {
    final formatted = formatAmount(amount.abs(), currencyCode);
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Formats [amount] in compact form.
  /// e.g. formatCompact(1234567, 'INR') => '₹12.3L' or '₹1.2M'
  static String formatCompact(double amount, String currencyCode) {
    final sym = _currencies[currencyCode.toUpperCase()]?.symbol ?? currencyCode;
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';

    String formatted;
    if (currencyCode.toUpperCase() == 'INR') {
      // Indian numbering system
      if (abs >= 10000000) {
        formatted = '${(abs / 10000000).toStringAsFixed(2)}Cr';
      } else if (abs >= 100000) {
        formatted = '${(abs / 100000).toStringAsFixed(2)}L';
      } else if (abs >= 1000) {
        formatted = '${(abs / 1000).toStringAsFixed(1)}K';
      } else {
        formatted = abs.toStringAsFixed(0);
      }
    } else {
      if (abs >= 1000000000) {
        formatted = '${(abs / 1000000000).toStringAsFixed(2)}B';
      } else if (abs >= 1000000) {
        formatted = '${(abs / 1000000).toStringAsFixed(2)}M';
      } else if (abs >= 1000) {
        formatted = '${(abs / 1000).toStringAsFixed(1)}K';
      } else {
        formatted = abs.toStringAsFixed(0);
      }
    }
    return '$sign$sym$formatted';
  }

  /// Parses a currency string into a double. Returns null if parsing fails.
  static double? parseAmount(String text) {
    // Remove all non-numeric characters except decimal point and minus
    final cleaned = text.replaceAll(RegExp(r'[^\d.\-]'), '');
    return double.tryParse(cleaned);
  }

  /// Returns true if the currency code is supported
  static bool isSupported(String currencyCode) {
    return _currencies.containsKey(currencyCode.toUpperCase());
  }

  /// Returns all supported currency codes
  static List<String> get supportedCurrencies => _currencies.keys.toList();

  /// Returns the full name of a currency
  static String currencyName(String currencyCode) {
    return _currencies[currencyCode.toUpperCase()]?.name ?? currencyCode;
  }
}

class _CurrencyInfo {
  final String symbol;
  final String name;
  final int decimalDigits;

  const _CurrencyInfo({
    required this.symbol,
    required this.name,
    required this.decimalDigits,
  });
}
