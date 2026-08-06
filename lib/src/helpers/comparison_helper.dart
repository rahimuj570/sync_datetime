part of '../sync_datetime.dart';

abstract final class _ComparisonHelper {
  static bool isSameDay(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return a.year == b.year && a.month == b.month;
  }

  static bool isSameYear(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return a.year == b.year;
  }
}
