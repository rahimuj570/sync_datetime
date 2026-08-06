part of '../sync_datetime.dart';

abstract final class _RoundingHelper {
  static DateTime floorToMinute(DateTime dateTime) {
    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }

  static DateTime ceilToMinute(DateTime dateTime) {
    if (dateTime.second == 0 &&
        dateTime.millisecond == 0 &&
        dateTime.microsecond == 0) {
      return dateTime;
    }
    final floored = floorToMinute(dateTime);
    return _ArithmeticHelper.addMinutes(floored, 1);
  }

  static DateTime roundToMinute(DateTime dateTime) {
    if (dateTime.second >= 30) {
      return ceilToMinute(dateTime);
    } else {
      return floorToMinute(dateTime);
    }
  }

  static DateTime floorToHour(DateTime dateTime) {
    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }

  static DateTime ceilToHour(DateTime dateTime) {
    if (dateTime.minute == 0 &&
        dateTime.second == 0 &&
        dateTime.millisecond == 0 &&
        dateTime.microsecond == 0) {
      return dateTime;
    }
    final floored = floorToHour(dateTime);
    return _ArithmeticHelper.addHours(floored, 1);
  }

  static DateTime roundToHour(DateTime dateTime) {
    if (dateTime.minute >= 30) {
      return ceilToHour(dateTime);
    } else {
      return floorToHour(dateTime);
    }
  }

  static DateTime floorToDay(DateTime dateTime) {
    return _ManipulationHelper.startOfDay(dateTime);
  }

  static DateTime ceilToDay(DateTime dateTime) {
    if (_ComparisonHelper.isStartOfDay(dateTime)) {
      return dateTime;
    }
    final floored = floorToDay(dateTime);
    return _ArithmeticHelper.addDays(floored, 1);
  }

  static DateTime roundToDay(DateTime dateTime) {
    if (dateTime.hour >= 12) {
      return ceilToDay(dateTime);
    } else {
      return floorToDay(dateTime);
    }
  }
}
