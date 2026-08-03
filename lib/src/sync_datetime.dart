import 'package:sync_datetime/src/models/server_datetime_parts_model.dart';

/// A utility class providing predictable and zero-boilerplate DateTime
/// synchronization methods.
///
/// This class acts as a single namespace for DateTime operations, focusing
/// on correct timezone conversion, robust parsing of server timestamps, and
/// combination of date and time components.
abstract final class SyncDateTime {
  static final RegExp _timezoneRegex = RegExp(
    r'([zZ]|[+-]\d{2}(?::?\d{2}(?::?\d{2})?)?)$',
  );

  /// Converts any [DateTime] to a UTC [DateTime].
  ///
  /// If the input [dateTime] is already in UTC, it is returned as-is (making the
  /// operation idempotent). Otherwise, it converts [dateTime] to UTC using
  /// [DateTime.toUtc].
  ///
  /// Example:
  /// ```dart
  /// final local = DateTime.now(); // e.g., 2026-08-02 11:50:00 (local)
  /// final utc = SyncDateTime.toUtc(local); // 2026-08-02 05:50:00.000Z
  /// ```
  ///
  /// Returns a new [DateTime] object with [DateTime.isUtc] set to true.
  static DateTime toUtc(DateTime dateTime) {
    return dateTime.isUtc ? dateTime : dateTime.toUtc();
  }

  /// Converts a UTC [DateTime] to a local [DateTime].
  ///
  /// Throws an [ArgumentError] if the input [utc] is not in UTC (i.e.
  /// `!utc.isUtc`). This strictly enforces correctness, preventing developers
  /// from passing local timezones by mistake.
  ///
  /// Example:
  /// ```dart
  /// final utc = DateTime.utc(2026, 8, 2, 5, 50, 0);
  /// final local = SyncDateTime.fromUtc(utc); // Local timezone representation
  /// ```
  ///
  /// Returns a new [DateTime] object with [DateTime.isUtc] set to false.
  ///
  /// Throws [ArgumentError] if the input [utc] does not represent a UTC time.
  static DateTime fromUtc(DateTime utc) {
    if (!utc.isUtc) {
      throw ArgumentError.value(
        utc,
        'utc',
        'The input DateTime must be in UTC timezone (isUtc must be true).',
      );
    }
    return utc.toLocal();
  }

  /// Converts a [DateTime] to a UTC ISO 8601 string representation.
  ///
  /// The input is automatically converted to UTC before formatting. This is
  /// useful for serializing timestamps to match API payloads.
  ///
  /// Example:
  /// ```dart
  /// final local = DateTime(2026, 8, 2, 11, 50, 0);
  /// final serverStr = SyncDateTime.toServer(local); // '2026-08-02T05:50:00.000Z'
  /// ```
  ///
  /// Returns a string formatted like `2026-08-02T12:00:00.000Z` or
  /// `2026-08-02T12:00:00.000000Z`.
  static String toServer(DateTime dateTime) {
    return toUtc(dateTime).toIso8601String();
  }

  /// Parses a UTC ISO 8601 string [serverUtc] from the server and converts it
  /// to local time.
  ///
  /// If the input string lacks a timezone designator (like 'Z' or '+00:00'), it
  /// is assumed to represent UTC. To avoid local Daylight Saving Time (DST)
  /// transition issues during parsing, the string is normalized to UTC before
  /// parsing, then offset to local time.
  ///
  /// Example:
  /// ```dart
  /// // With timezone designator:
  /// final local1 = SyncDateTime.fromServer('2026-08-02T05:50:00Z');
  ///
  /// // Without timezone designator (assumed UTC):
  /// final local2 = SyncDateTime.fromServer('2026-08-02T05:50:00');
  /// ```
  ///
  /// Returns a new [DateTime] in the local timezone.
  ///
  /// Throws [FormatException] if the input [serverUtc] is not a valid ISO 8601
  /// date-time.
  static DateTime fromServer(String serverUtc) {
    final trimmed = serverUtc.trim();
    final isPureDate =
        !trimmed.contains(':') &&
        !trimmed.contains('T') &&
        !trimmed.contains(' ');
    final hasTimezone = !isPureDate && _timezoneRegex.hasMatch(trimmed);

    String normalized;
    if (hasTimezone) {
      normalized = trimmed;
    } else {
      normalized = isPureDate ? '${trimmed}T00:00:00Z' : '${trimmed}Z';
    }
    return DateTime.parse(normalized).toLocal();
  }

  /// Assumes [date] and [time] originate from the same server payload and
  /// represent a single UTC timestamp.
  ///
  /// This method does not validate timezone consistency because the inputs
  /// are plain strings and do not carry timezone metadata. It simply
  /// reconstructs a valid ISO 8601 timestamp and delegates parsing to
  /// [fromServer()].
  ///
  /// This method is a helper for APIs that return date and time as separate
  /// payload fields, preventing the need to manually format string concatenations.
  ///
  /// Example:
  /// ```dart
  /// final local = SyncDateTime.fromServerParts(
  ///   date: '2026-08-02',
  ///   time: '08:49:50.551Z',
  /// );
  /// ```
  ///
  /// Returns a new [DateTime] in the local timezone.
  ///
  /// Throws [FormatException] if the concatenated result is not a valid ISO 8601 representation.
  static DateTime fromServerParts({
    required String date,
    required String time,
  }) {
    final trimmedDate = date.trim();
    final trimmedTime = time.trim();
    final separator = trimmedTime.startsWith('T') || trimmedTime.startsWith(' ')
        ? ''
        : 'T';
    return fromServer('$trimmedDate$separator$trimmedTime');
  }

  /// Combines the date components of [date] with the time components of [time].
  ///
  /// Both [date] and [time] must have matching timezone types (both local or
  /// both UTC) to avoid ambiguity. If their timezone types differ, an
  /// [ArgumentError] is thrown.
  ///
  /// The returned [DateTime] will have the same timezone type as the inputs.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 8, 2);
  /// final time = DateTime(2020, 1, 1, 14, 30, 0);
  /// final combined = SyncDateTime.combine(date, time); // 2026-08-02 14:30:00.000
  /// ```
  ///
  /// Returns a new [DateTime] with the calendar date from [date] and clock time
  /// from [time].
  ///
  /// Throws [ArgumentError] if the timezone types (UTC vs local) of the inputs
  /// mismatch.
  static DateTime combine(DateTime date, DateTime time) {
    if (date.isUtc != time.isUtc) {
      throw ArgumentError.value(
        time,
        'time',
        'Both date and time must have the same timezone type (both UTC or both local). '
            'date.isUtc is ${date.isUtc}, but time.isUtc is ${time.isUtc}.',
      );
    }

    if (date.isUtc) {
      return DateTime.utc(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        time.second,
        time.millisecond,
        time.microsecond,
      );
    } else {
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        time.second,
        time.millisecond,
        time.microsecond,
      );
    }
  }

  /// Converts a [DateTime] into separate UTC date and time strings suitable
  /// for backend APIs that expect individual fields.
  ///
  /// The input is first normalized to UTC before extracting the components.
  ///
  /// Example:
  /// ```dart
  /// final parts = SyncDateTime.toServerParts(DateTime.now());
  ///
  /// api.send(
  ///   scheduled_date: parts.date,
  ///   scheduled_time: parts.time,
  /// );
  /// ```
  ///
  /// Returns a [ServerDateTimeParts].
  static ServerDateTimeParts toServerParts(DateTime dateTime) {
    final utc = toUtc(dateTime);

    final iso = utc.toIso8601String();

    final split = iso.split('T');

    return ServerDateTimeParts(date: split.first, time: split.last);
  }

  /// Returns the start of the current local calendar day.
  ///
  /// The returned [DateTime] has its time components set to
  /// `00:00:00.000`, making it useful for date comparisons,
  /// filtering, and database queries.
  ///
  /// Example:
  /// ```dart
  /// final today = SyncDateTime.today();
  /// ```
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns the start of the current UTC calendar day.
  ///
  /// The returned [DateTime] is in UTC (`isUtc == true`) with
  /// its time components set to `00:00:00.000Z`.
  ///
  /// Example:
  /// ```dart
  /// final todayUtc = SyncDateTime.todayUtc();
  /// ```
  static DateTime todayUtc() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  /// Returns the current UTC date and time.
  ///
  /// This is a convenience wrapper around `DateTime.now().toUtc()`,
  /// making UTC timestamps easier to obtain when communicating with
  /// backend services.
  ///
  /// Example:
  /// ```dart
  /// final now = SyncDateTime.nowUtc();
  /// print(now.isUtc); // true
  /// ```
  static DateTime nowUtc() {
    return DateTime.now().toUtc();
  }

  /// Returns a new [DateTime] set to the start of the day (00:00:00.000000)
  /// for the given [dateTime], preserving its timezone type (UTC or Local).
  ///
  /// Example:
  /// ```dart
  /// final local = DateTime(2026, 8, 2, 11, 50, 0);
  /// final start = SyncDateTime.startOfDay(local); // 2026-08-02 00:00:00.000
  ///
  /// final utc = DateTime.utc(2026, 8, 2, 11, 50, 0);
  /// final startUtc = SyncDateTime.startOfDay(utc); // 2026-08-02 00:00:00.000Z
  /// ```
  static DateTime startOfDay(DateTime dateTime) {
    if (dateTime.isUtc) {
      return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
    } else {
      return DateTime(dateTime.year, dateTime.month, dateTime.day);
    }
  }

  /// Returns a new [DateTime] set to the end of the day (23:59:59.999999)
  /// for the given [dateTime], preserving its timezone type (UTC or Local).
  ///
  /// Example:
  /// ```dart
  /// final local = DateTime(2026, 8, 2, 11, 50, 0);
  /// final end = SyncDateTime.endOfDay(local); // 2026-08-02 23:59:59.999999
  ///
  /// final utc = DateTime.utc(2026, 8, 2, 11, 50, 0);
  /// final endUtc = SyncDateTime.endOfDay(utc); // 2026-08-02 23:59:59.999999Z
  /// ```
  static DateTime endOfDay(DateTime dateTime) {
    if (dateTime.isUtc) {
      return DateTime.utc(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        23,
        59,
        59,
        999,
        999,
      );
    } else {
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        23,
        59,
        59,
        999,
        999,
      );
    }
  }

  /// Extracts the date component from [dateTime] and returns it as a string
  /// formatted as `yyyy-MM-dd` (e.g. '2002-02-06').
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 8, 3, 11, 50, 0);
  /// final dateStr = SyncDateTime.stripDate(date); // '2026-08-03'
  /// ```
  static String stripDate(DateTime dateTime) {
    final iso = dateTime.toIso8601String();
    return iso.split('T').first;
  }

  /// Extracts the time component from [dateTime] and returns it as a string
  /// (e.g. '17:15:30.000' or '17:15:30.000Z' if UTC), preserving timezone compatibility.
  ///
  /// Example:
  /// ```dart
  /// final local = DateTime(2026, 8, 3, 17, 15, 30);
  /// final timeStr = SyncDateTime.stripTime(local); // '17:15:30.000'
  ///
  /// final utc = DateTime.utc(2026, 8, 3, 17, 15, 30);
  /// final timeUtcStr = SyncDateTime.stripTime(utc); // '17:15:30.000Z'
  /// ```
  static String stripTime(DateTime dateTime) {
    final iso = dateTime.toIso8601String();
    return iso.split('T').last;
  }

  /// Returns a copy of [dateTime] with the specified fields replaced with new values,
  /// preserving the timezone type (UTC or Local) of the input.
  ///
  /// Example:
  /// ```dart
  /// final base = DateTime.utc(2026, 8, 3, 12, 0);
  /// final updated = SyncDateTime.copyWith(base, year: 2027, hour: 15);
  /// // 2027-08-03 15:00:00.000Z
  /// ```
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
    if (dateTime.isUtc) {
      return DateTime.utc(
        year ?? dateTime.year,
        month ?? dateTime.month,
        day ?? dateTime.day,
        hour ?? dateTime.hour,
        minute ?? dateTime.minute,
        second ?? dateTime.second,
        millisecond ?? dateTime.millisecond,
        microsecond ?? dateTime.microsecond,
      );
    } else {
      return DateTime(
        year ?? dateTime.year,
        month ?? dateTime.month,
        day ?? dateTime.day,
        hour ?? dateTime.hour,
        minute ?? dateTime.minute,
        second ?? dateTime.second,
        millisecond ?? dateTime.millisecond,
        microsecond ?? dateTime.microsecond,
      );
    }
  }

  /// Checks if [a] and [b] represent the same calendar day.
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3, 10, 0);
  /// final second = DateTime(2026, 8, 3, 23, 59);
  /// final result = SyncDateTime.isSameDay(first, second); // true
  /// ```
  static bool isSameDay(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if [a] and [b] represent the same month and year.
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3);
  /// final second = DateTime(2026, 8, 20);
  /// final result = SyncDateTime.isSameMonth(first, second); // true
  /// ```
  static bool isSameMonth(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
    return a.year == b.year && a.month == b.month;
  }

  /// Checks if [a] and [b] represent the same year.
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3);
  /// final second = DateTime(2026, 12, 31);
  /// final result = SyncDateTime.isSameYear(first, second); // true
  /// ```
  static bool isSameYear(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
    return a.year == b.year;
  }

  /// Computes the difference in calendar days between [a] and [b].
  ///
  /// Returns a positive integer if [b] is after [a], a negative integer if [b]
  /// is before [a], and zero if they represent the same day.
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3, 23, 59);
  /// final second = DateTime(2026, 8, 4, 0, 1);
  /// final diff = SyncDateTime.daysBetween(first, second); // 1
  /// ```
  static int daysBetween(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
    final aUtc = DateTime.utc(a.year, a.month, a.day);
    final bUtc = DateTime.utc(b.year, b.month, b.day);
    return bUtc.difference(aUtc).inDays;
  }

  /// Returns the number of days in the month of the given [dateTime].
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 2, 1);
  /// final days = SyncDateTime.daysInMonth(date); // 28
  /// ```
  static int daysInMonth(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month;
    if (month == 2) {
      return isLeapYear(year) ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  /// Checks if the given [year] is a leap year.
  ///
  /// Example:
  /// ```dart
  /// final leap = SyncDateTime.isLeapYear(2024); // true
  /// final common = SyncDateTime.isLeapYear(2026); // false
  /// ```
  static bool isLeapYear(int year) {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }

  /// Computes the number of full years between [a] and [b].
  ///
  /// Returns a positive integer if [b] is after [a], a negative integer if [b]
  /// is before [a], and zero if less than a full year separates them.
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2024, 8, 3);
  /// final second = DateTime(2026, 8, 2);
  /// final diff = SyncDateTime.differenceInYears(first, second); // 1 (not yet 2 full years)
  /// ```
  static int differenceInYears(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
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

  /// Computes the difference in calendar days between [a] and [b].
  ///
  /// This is a convenience alias for [daysBetween].
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3, 23, 59);
  /// final second = DateTime(2026, 8, 4, 0, 1);
  /// final diff = SyncDateTime.differenceInDays(first, second); // 1
  /// ```
  static int differenceInDays(DateTime a, DateTime b) {
    return daysBetween(a, b);
  }

  /// Computes the difference in whole hours between [a] and [b].
  ///
  /// Returns a positive integer if [b] is after [a], a negative integer if [b]
  /// is before [a], and zero if less than a full hour separates them.
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3, 10, 0);
  /// final second = DateTime(2026, 8, 3, 12, 30);
  /// final diff = SyncDateTime.differenceInHours(first, second); // 2
  /// ```
  static int differenceInHours(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
    return b.difference(a).inHours;
  }

  /// Computes the difference in whole minutes between [a] and [b].
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3, 10, 0);
  /// final second = DateTime(2026, 8, 3, 10, 45);
  /// final diff = SyncDateTime.differenceInMinutes(first, second); // 45
  /// ```
  static int differenceInMinutes(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
    return b.difference(a).inMinutes;
  }

  /// Computes the difference in whole seconds between [a] and [b].
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3, 10, 0, 0);
  /// final second = DateTime(2026, 8, 3, 10, 0, 30);
  /// final diff = SyncDateTime.differenceInSeconds(first, second); // 30
  /// ```
  static int differenceInSeconds(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
    return b.difference(a).inSeconds;
  }

  /// Computes the difference in whole milliseconds between [a] and [b].
  ///
  /// Throws an [ArgumentError] if the input [DateTime] instances have mismatching
  /// timezone types (one UTC, one local).
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3, 10, 0, 0, 0);
  /// final second = DateTime(2026, 8, 3, 10, 0, 0, 500);
  /// final diff = SyncDateTime.differenceInMilliseconds(first, second); // 500
  /// ```
  static int differenceInMilliseconds(DateTime a, DateTime b) {
    if (a.isUtc != b.isUtc) {
      throw ArgumentError(
        'Both DateTime instances must have the same timezone type. '
        'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
      );
    }
    return b.difference(a).inMilliseconds;
  }

  /// Standardizes a raw server timestamp string into a normalized UTC ISO 8601 string.
  ///
  /// If the input string lacks a timezone designator, it is assumed to represent UTC.
  /// All timezone offsets (e.g. +02:00 or -05:00) are resolved to UTC, and the
  /// resulting string is formatted in the standard UTC format ending with 'Z'.
  ///
  /// This is useful for storing uniform, lexicographically sortable UTC timestamps
  /// in local databases or offline caches.
  ///
  /// Example:
  /// ```dart
  /// // With timezone designator:
  /// final ts1 = SyncDateTime.normalizeServerTimestamp('2026-08-02T12:00:00+02:00');
  /// // '2026-08-02T10:00:00.000Z'
  ///
  /// // Without timezone designator (assumed UTC):
  /// final ts2 = SyncDateTime.normalizeServerTimestamp('2026-08-02T12:00:00');
  /// // '2026-08-02T12:00:00.000Z'
  /// ```
  ///
  /// Throws [FormatException] if the input [timestamp] is not a valid ISO 8601 date-time.
  static String normalizeServerTimestamp(String timestamp) {
    final trimmed = timestamp.trim();
    final isPureDate =
        !trimmed.contains(':') &&
        !trimmed.contains('T') &&
        !trimmed.contains(' ');
    final hasTimezone = !isPureDate && _timezoneRegex.hasMatch(trimmed);

    String normalized;
    if (hasTimezone) {
      normalized = trimmed;
    } else {
      normalized = isPureDate ? '${trimmed}T00:00:00Z' : '${trimmed}Z';
    }
    final parsed = DateTime.parse(normalized);
    return parsed.toUtc().toIso8601String();
  }
}
