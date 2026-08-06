part of '../sync_datetime.dart';

abstract final class _CalendarHelper {
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime todayUtc() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  static DateTime nowUtc() {
    return DateTime.now().toUtc();
  }

  static int daysInMonth(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month;
    if (month == 2) {
      return isLeapYear(year) ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  static bool isLeapYear(int year) {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }
}
