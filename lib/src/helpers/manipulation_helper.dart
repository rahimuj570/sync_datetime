part of '../sync_datetime.dart';

abstract final class _ManipulationHelper {
  static DateTime combine(DateTime date, DateTime time) {
    if (date.isUtc != time.isUtc) {
      throw ArgumentError.value(
        time,
        'time',
        'Both date and time must have the same timezone type (both UTC or both local). '
            'date.isUtc is ${date.isUtc}, but time.isUtc is ${time.isUtc}.',
      );
    }

    return _createDateTime(
      isUtc: date.isUtc,
      year: date.year,
      month: date.month,
      day: date.day,
      hour: time.hour,
      minute: time.minute,
      second: time.second,
      millisecond: time.millisecond,
      microsecond: time.microsecond,
    );
  }

  static DateTime startOfDay(DateTime dateTime) {
    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
    );
  }

  static DateTime endOfDay(DateTime dateTime) {
    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: 23,
      minute: 59,
      second: 59,
      millisecond: 999,
      microsecond: 999,
    );
  }

  static String stripDate(DateTime dateTime) {
    final iso = dateTime.toIso8601String();
    return iso.split('T').first;
  }

  static String stripTime(DateTime dateTime) {
    final iso = dateTime.toIso8601String();
    return iso.split('T').last;
  }

  static DateTime copyWith(
    DateTime dateTime, {
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return _createDateTime(
      isUtc: dateTime.isUtc,
      year: year ?? dateTime.year,
      month: month ?? dateTime.month,
      day: day ?? dateTime.day,
      hour: hour ?? dateTime.hour,
      minute: minute ?? dateTime.minute,
      second: second ?? dateTime.second,
      millisecond: millisecond ?? dateTime.millisecond,
      microsecond: microsecond ?? dateTime.microsecond,
    );
  }
}
