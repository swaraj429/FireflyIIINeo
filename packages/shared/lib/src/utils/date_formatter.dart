import 'package:intl/intl.dart';

/// Date formatting utilities for FireflyIII Neo
abstract class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _monthFormat = DateFormat('MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');
  static final DateFormat _apiDateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
  static final DateFormat _apiDateFormatLocal = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Formats a date as 'DD MMM YYYY', e.g. '26 May 2025'
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Formats a date as 'DD MMM YYYY, HH:MM', e.g. '26 May 2025, 14:30'
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Formats a date relative to now: 'Today', 'Yesterday', '2 days ago', etc.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 14) return 'Last week';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    if (diff < 60) return 'Last month';
    if (diff < 365) return '${(diff / 30).floor()} months ago';
    return '${(diff / 365).floor()} year${(diff / 365).floor() > 1 ? 's' : ''} ago';
  }

  /// Formats future dates relative to now: 'Today', 'Tomorrow', 'In 2 days', etc.
  static String formatRelativeFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 7) return 'In $diff days';
    if (diff < 14) return 'Next week';
    if (diff < 30) return 'In ${(diff / 7).floor()} weeks';
    if (diff < 60) return 'Next month';
    if (diff < 365) return 'In ${(diff / 30).floor()} months';
    return 'In ${(diff / 365).floor()} years';
  }

  /// Formats a date as 'MMM YYYY', e.g. 'May 2025'
  static String formatMonth(DateTime date) => _monthFormat.format(date);

  /// Formats time only as 'HH:MM', e.g. '14:30'
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Formats date as 'DD MMM', e.g. '26 May'
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  /// Parses an ISO 8601 date string from the API
  static DateTime parseApiDate(String date) {
    try {
      return DateTime.parse(date).toLocal();
    } catch (_) {
      try {
        return _apiDateFormat.parseUtc(date).toLocal();
      } catch (_) {
        return _apiDateFormatLocal.parse(date);
      }
    }
  }

  /// Returns the start of a given day
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Returns the end of a given day
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  /// Returns the first day of the current month
  static DateTime startOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  /// Returns the last day of the current month
  static DateTime endOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 0, 23, 59, 59, 999);
  }

  /// Returns the first day of the current year
  static DateTime startOfYear([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, 1, 1);
  }

  /// Returns true if two dates are on the same day
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns true if [date] is today
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Returns true if [date] was yesterday
  static bool isYesterday(DateTime date) => isSameDay(
        date,
        DateTime.now().subtract(const Duration(days: 1)),
      );

  /// Generates a list of months between [start] and [end]
  static List<DateTime> monthsBetween(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = DateTime(start.year, start.month);
    final endMonth = DateTime(end.year, end.month);
    while (!current.isAfter(endMonth)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    return months;
  }

  /// Formats duration in human-readable form
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays}d';
    if (duration.inHours > 0) return '${duration.inHours}h';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m';
    return '${duration.inSeconds}s';
  }
}
