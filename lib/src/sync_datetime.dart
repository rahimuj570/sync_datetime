/// A utility class providing predictable and zero-boilerplate DateTime
/// synchronization methods.
///
/// This class acts as a single namespace for DateTime operations, focusing
/// on correct timezone conversion, robust parsing of server timestamps, and
/// combination of date and time components.
abstract final class SyncDateTime {
  static final RegExp _timezoneRegex = RegExp(
    r'(?:[zZ]|[+-]\d{2}(?::?\d{2})?)$',
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
    final hasTimezone = _timezoneRegex.hasMatch(serverUtc);
    final normalized = hasTimezone ? serverUtc.trim() : '${serverUtc.trim()}Z';
    return DateTime.parse(normalized).toLocal();
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
}
