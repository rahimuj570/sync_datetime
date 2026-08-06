part of '../sync_datetime.dart';

abstract final class _ArithmeticHelper {
  static DateTime addDays(DateTime dateTime, int days) {
    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day + days,
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
      millisecond: dateTime.millisecond,
      microsecond: dateTime.microsecond,
    );
  }

  static DateTime previousDay(DateTime dateTime) {
    return addDays(dateTime, -1);
  }

  static DateTime nextDay(DateTime dateTime) {
    return addDays(dateTime, 1);
  }

  static DateTime addMonths(DateTime dateTime, int months) {
    final totalMonths = (dateTime.month - 1) + months;
    int targetYear = dateTime.year + (totalMonths ~/ 12);
    final targetMonthIndex = totalMonths % 12;
    if (totalMonths < 0 && targetMonthIndex != 0) {
      targetYear -= 1;
    }
    final targetMonth = targetMonthIndex + 1;

    final temp = _createDateTime(
      isUtc: dateTime.isUtc,
      year: targetYear,
      month: targetMonth,
      day: 1,
    );
    final maxDays = _CalendarHelper.daysInMonth(temp);
    final targetDay = dateTime.day > maxDays ? maxDays : dateTime.day;

    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: targetYear,
      month: targetMonth,
      day: targetDay,
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
      millisecond: dateTime.millisecond,
      microsecond: dateTime.microsecond,
    );
  }

  static DateTime previousMonth(DateTime dateTime) {
    return addMonths(dateTime, -1);
  }

  static DateTime nextMonth(DateTime dateTime) {
    return addMonths(dateTime, 1);
  }

  static DateTime addYears(DateTime dateTime, int years) {
    return addMonths(dateTime, years * 12);
  }

  static DateTime previousYear(DateTime dateTime) {
    return addYears(dateTime, -1);
  }

  static DateTime nextYear(DateTime dateTime) {
    return addYears(dateTime, 1);
  }

  static DateTime addHours(DateTime dateTime, int hours) {
    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour + hours,
      minute: dateTime.minute,
      second: dateTime.second,
      millisecond: dateTime.millisecond,
      microsecond: dateTime.microsecond,
    );
  }

  static DateTime addMinutes(DateTime dateTime, int minutes) {
    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour,
      minute: dateTime.minute + minutes,
      second: dateTime.second,
      millisecond: dateTime.millisecond,
      microsecond: dateTime.microsecond,
    );
  }

  static DateTime min(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return a.isBefore(b) ? a : b;
  }

  static DateTime max(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return a.isAfter(b) ? a : b;
  }

  static DateTime clamp(DateTime value, DateTime min, DateTime max) {
    _validateTimezone(value, min);
    _validateTimezone(value, max);

    if (min.isAfter(max)) {
      throw ArgumentError('min must not be greater than max.');
    }

    if (value.isBefore(min)) {
      return min;
    }
    if (value.isAfter(max)) {
      return max;
    }
    return value;
  }
}
