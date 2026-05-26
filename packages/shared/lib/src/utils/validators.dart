/// Input validators for FireflyIII Neo forms
abstract class Validators {
  Validators._();

  // ─── Email ────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9]'
      r'(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ─── Password ─────────────────────────────────────────────────────────────

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    final passwordError = password(value);
    if (passwordError != null) return passwordError;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  // ─── PIN ──────────────────────────────────────────────────────────────────

  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (value.length != 4 && value.length != 6) {
      return 'PIN must be 4 or 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    return null;
  }

  // ─── Required / Non-empty ────────────────────────────────────────────────

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name must be less than 100 characters';
    }
    return null;
  }

  // ─── Amount ───────────────────────────────────────────────────────────────

  static String? amount(String? value, {bool allowZero = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    final parsed = double.tryParse(cleaned);
    if (parsed == null) {
      return 'Enter a valid amount';
    }
    if (!allowZero && parsed <= 0) {
      return 'Amount must be greater than 0';
    }
    if (parsed > 999999999) {
      return 'Amount is too large';
    }
    return null;
  }

  static String? minAmount(String? value, double minimum) {
    final error = amount(value);
    if (error != null) return error;
    final parsed = double.tryParse(value!.replaceAll(RegExp(r'[^\d.]'), ''))!;
    if (parsed < minimum) {
      return 'Amount must be at least $minimum';
    }
    return null;
  }

  // ─── URL ──────────────────────────────────────────────────────────────────

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^https?://'
      r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'
      r'localhost|'
      r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'
      r'(?::\d+)?'
      r'(?:/?|[/?]\S+)$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL (e.g. http://localhost:9090)';
    }
    return null;
  }

  static String? serverUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Server URL is required';
    }
    final trimmed = value.trim();
    // Allow both http:// and https://
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    return url(trimmed);
  }

  // ─── IBAN ─────────────────────────────────────────────────────────────────

  static String? iban(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final cleaned = value.replaceAll(' ', '').toUpperCase();
    if (cleaned.length < 15 || cleaned.length > 34) {
      return 'Enter a valid IBAN';
    }
    if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$').hasMatch(cleaned)) {
      return 'Enter a valid IBAN';
    }
    return null;
  }

  // ─── Notes / Description ─────────────────────────────────────────────────

  static String? description(String? value, {int maxLength = 255}) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.length > maxLength) {
      return 'Description must be less than $maxLength characters';
    }
    return null;
  }

  static String? notes(String? value, {int maxLength = 1000}) {
    if (value == null) return null;
    if (value.length > maxLength) {
      return 'Notes must be less than $maxLength characters';
    }
    return null;
  }

  // ─── Phone ────────────────────────────────────────────────────────────────

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (!RegExp(r'^\d{7,15}$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ─── Compose multiple validators ─────────────────────────────────────────

  /// Runs multiple validators and returns the first error, or null if all pass.
  static String? compose(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
