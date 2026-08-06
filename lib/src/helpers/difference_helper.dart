part of '../sync_datetime.dart';

abstract final class _DifferenceHelper {
  static int daysBetween(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    final aUtc = DateTime.utc(a.year, a.month, a.day);
    final bUtc = DateTime.utc(b.year, b.month, b.day);
    return bUtc.difference(aUtc).inDays;
  }

  static int differenceInYears(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    int years = b.year - a.year;
    if (years > 0) {
      if (b.month < a.month || (b.month == a.month && b.day < a.day)) {
        years--;
      }
    } else if (years < 0) {
      if (b.month > a.month || (b.month == a.month && b.day > a.day)) {
        years++;
      }
    }
    return years;
  }

  static int differenceInDays(DateTime a, DateTime b) {
    return daysBetween(a, b);
  }

  static int differenceInHours(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return b.difference(a).inHours;
  }

  static int differenceInMinutes(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return b.difference(a).inMinutes;
  }

  static int differenceInSeconds(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return b.difference(a).inSeconds;
  }

  static int differenceInMilliseconds(DateTime a, DateTime b) {
    _validateTimezone(a, b);
    return b.difference(a).inMilliseconds;
  }
}
