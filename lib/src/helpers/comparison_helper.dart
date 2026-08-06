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

  static bool isToday(DateTime dateTime) {
    final today = dateTime.isUtc ? _CalendarHelper.todayUtc() : _CalendarHelper.today();
    return isSameDay(dateTime, today);
  }

  static bool isTomorrow(DateTime dateTime) {
    final today = dateTime.isUtc ? _CalendarHelper.todayUtc() : _CalendarHelper.today();
    final tomorrow = _ArithmeticHelper.addDays(today, 1);
    return isSameDay(dateTime, tomorrow);
  }

  static bool isYesterday(DateTime dateTime) {
    final today = dateTime.isUtc ? _CalendarHelper.todayUtc() : _CalendarHelper.today();
    final yesterday = _ArithmeticHelper.addDays(today, -1);
    return isSameDay(dateTime, yesterday);
  }

  static bool isPast(DateTime dateTime) {
    final now = dateTime.isUtc ? _CalendarHelper.nowUtc() : DateTime.now();
    return dateTime.isBefore(now);
  }

  static bool isFuture(DateTime dateTime) {
    final now = dateTime.isUtc ? _CalendarHelper.nowUtc() : DateTime.now();
    return dateTime.isAfter(now);
  }

  static bool isBetween(
    DateTime value,
    DateTime start,
    DateTime end, {
    bool inclusive = true,
  }) {
    _validateTimezone(value, start);
    _validateTimezone(value, end);

    if (start.isAfter(end)) {
      throw ArgumentError('start must not be after end.');
    }

    if (inclusive) {
      return (value.isAfter(start) || value.isAtSameMomentAs(start)) &&
          (value.isBefore(end) || value.isAtSameMomentAs(end));
    } else {
      return value.isAfter(start) && value.isBefore(end);
    }
  }

  static bool isSameHour(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour;
  }

  static bool isSameMinute(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  static bool isSameSecond(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute &&
        a.second == b.second;
  }

  static bool isStartOfDay(DateTime dateTime) {
    return dateTime.hour == 0 &&
        dateTime.minute == 0 &&
        dateTime.second == 0 &&
        dateTime.millisecond == 0 &&
        dateTime.microsecond == 0;
  }

  static bool isEndOfDay(DateTime dateTime) {
    return dateTime.hour == 23 &&
        dateTime.minute == 59 &&
        dateTime.second == 59 &&
        dateTime.millisecond == 999 &&
        dateTime.microsecond == 999;
  }
}
