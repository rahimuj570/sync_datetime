import 'package:sync_datetime/src/models/server_datetime_parts_model.dart';

part 'helpers/conversion_helper.dart';
part 'helpers/server_helper.dart';
part 'helpers/calendar_helper.dart';
part 'helpers/comparison_helper.dart';
part 'helpers/difference_helper.dart';
part 'helpers/manipulation_helper.dart';
part 'helpers/arithmetic_helper.dart';
part 'helpers/rounding_helper.dart';

/// A utility class providing predictable and zero-boilerplate DateTime
/// synchronization methods.
///
/// This class acts as a single namespace for DateTime operations, focusing
/// on correct timezone conversion, robust parsing of server timestamps, and
/// combination of date and time components.
abstract final class SyncDateTime {
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
  static DateTime toUtc(DateTime dateTime) => _ConversionHelper.toUtc(dateTime);

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
  static DateTime fromUtc(DateTime utc) => _ConversionHelper.fromUtc(utc);

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
  static String toServer(DateTime dateTime) => _ServerHelper.toServer(dateTime);

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
  static DateTime fromServer(String serverUtc) =>
      _ServerHelper.fromServer(serverUtc);

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
  }) => _ServerHelper.fromServerParts(date: date, time: time);

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
  static DateTime combine(DateTime date, DateTime time) =>
      _ManipulationHelper.combine(date, time);

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
  static ServerDateTimeParts toServerParts(DateTime dateTime) =>
      _ServerHelper.toServerParts(dateTime);

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
  static DateTime today() => _CalendarHelper.today();

  /// Returns the start of the current UTC calendar day.
  ///
  /// The returned [DateTime] is in UTC (`isUtc == true`) with
  /// its time components set to `00:00:00.000Z`.
  ///
  /// Example:
  /// ```dart
  /// final todayUtc = SyncDateTime.todayUtc();
  /// ```
  static DateTime todayUtc() => _CalendarHelper.todayUtc();

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
  static DateTime nowUtc() => _CalendarHelper.nowUtc();

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
  static DateTime startOfDay(DateTime dateTime) =>
      _ManipulationHelper.startOfDay(dateTime);

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
  static DateTime endOfDay(DateTime dateTime) =>
      _ManipulationHelper.endOfDay(dateTime);

  /// Extracts the date component from [dateTime] and returns it as a string
  /// formatted as `yyyy-MM-dd` (e.g. '2002-02-06').
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 8, 3, 11, 50, 0);
  /// final dateStr = SyncDateTime.stripDate(date); // '2026-08-03'
  /// ```
  static String stripDate(DateTime dateTime) =>
      _ManipulationHelper.stripDate(dateTime);

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
  static String stripTime(DateTime dateTime) =>
      _ManipulationHelper.stripTime(dateTime);

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
  }) => _ManipulationHelper.copyWith(
    dateTime,
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    second: second,
    millisecond: millisecond,
    microsecond: microsecond,
  );

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
  static bool isSameDay(DateTime a, DateTime b) =>
      _ComparisonHelper.isSameDay(a, b);

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
  static bool isSameMonth(DateTime a, DateTime b) =>
      _ComparisonHelper.isSameMonth(a, b);

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
  static bool isSameYear(DateTime a, DateTime b) =>
      _ComparisonHelper.isSameYear(a, b);

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
  static int daysBetween(DateTime a, DateTime b) =>
      _DifferenceHelper.daysBetween(a, b);

  /// Returns the number of days in the month of the given [dateTime].
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 2, 1);
  /// final days = SyncDateTime.daysInMonth(date); // 28
  /// ```
  static int daysInMonth(DateTime dateTime) =>
      _CalendarHelper.daysInMonth(dateTime);

  /// Checks if the given [year] is a leap year.
  ///
  /// Example:
  /// ```dart
  /// final leap = SyncDateTime.isLeapYear(2024); // true
  /// final common = SyncDateTime.isLeapYear(2026); // false
  /// ```
  static bool isLeapYear(int year) => _CalendarHelper.isLeapYear(year);

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
  static int differenceInYears(DateTime a, DateTime b) =>
      _DifferenceHelper.differenceInYears(a, b);

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
  static int differenceInDays(DateTime a, DateTime b) =>
      _DifferenceHelper.differenceInDays(a, b);

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
  static int differenceInHours(DateTime a, DateTime b) =>
      _DifferenceHelper.differenceInHours(a, b);

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
  static int differenceInMinutes(DateTime a, DateTime b) =>
      _DifferenceHelper.differenceInMinutes(a, b);

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
  static int differenceInSeconds(DateTime a, DateTime b) =>
      _DifferenceHelper.differenceInSeconds(a, b);

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
  static int differenceInMilliseconds(DateTime a, DateTime b) =>
      _DifferenceHelper.differenceInMilliseconds(a, b);

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
  static String normalizeServerTimestamp(String timestamp) =>
      _ServerHelper.normalizeServerTimestamp(timestamp);

  /// Returns a new [DateTime] with the specified number of [days] added.
  ///
  /// The operation is timezone-safe and preserves whether the input [dateTime]
  /// is UTC or local. Positive values add days, while negative values subtract.
  ///
  /// Example:
  /// ```dart
  /// final today = DateTime.now();
  /// final fiveDaysLater = SyncDateTime.addDays(today, 5);
  /// final threeDaysAgo = SyncDateTime.addDays(today, -3);
  /// ```
  static DateTime addDays(DateTime dateTime, int days) =>
      _ArithmeticHelper.addDays(dateTime, days);

  /// Returns a new [DateTime] set to the previous day (24 hours earlier calendar-wise).
  ///
  /// The operation preserves whether the input [dateTime] is UTC or local.
  ///
  /// Example:
  /// ```dart
  /// final yesterday = SyncDateTime.previousDay(DateTime.now());
  /// ```
  static DateTime previousDay(DateTime dateTime) =>
      _ArithmeticHelper.previousDay(dateTime);

  /// Returns a new [DateTime] set to the next day (24 hours later calendar-wise).
  ///
  /// The operation preserves whether the input [dateTime] is UTC or local.
  ///
  /// Example:
  /// ```dart
  /// final tomorrow = SyncDateTime.nextDay(DateTime.now());
  /// ```
  static DateTime nextDay(DateTime dateTime) =>
      _ArithmeticHelper.nextDay(dateTime);

  /// Returns a new [DateTime] with the specified number of [months] added.
  ///
  /// Time components (hour, minute, second, millisecond, microsecond) and timezone
  /// (UTC/local) are preserved.
  ///
  /// If the target month has fewer days than the input day (e.g. adding 1 month
  /// to January 31st in a non-leap year target), the day is clamped to the last
  /// day of that month (February 28th).
  ///
  /// Example:
  /// ```dart
  /// final jan31 = DateTime(2026, 1, 31);
  /// final feb28 = SyncDateTime.addMonths(jan31, 1); // 2026-02-28
  ///
  /// final leapJan31 = DateTime(2024, 1, 31);
  /// final feb29 = SyncDateTime.addMonths(leapJan31, 1); // 2024-02-29
  /// ```
  static DateTime addMonths(DateTime dateTime, int months) =>
      _ArithmeticHelper.addMonths(dateTime, months);

  /// Returns a new [DateTime] set to the previous month, clamping day if needed.
  ///
  /// The operation preserves time components and whether the input [dateTime] is UTC or local.
  ///
  /// Example:
  /// ```dart
  /// final lastMonth = SyncDateTime.previousMonth(DateTime.now());
  /// ```
  static DateTime previousMonth(DateTime dateTime) =>
      _ArithmeticHelper.previousMonth(dateTime);

  /// Returns a new [DateTime] set to the next month, clamping day if needed.
  ///
  /// The operation preserves time components and whether the input [dateTime] is UTC or local.
  ///
  /// Example:
  /// ```dart
  /// final nextMonth = SyncDateTime.nextMonth(DateTime.now());
  /// ```
  static DateTime nextMonth(DateTime dateTime) =>
      _ArithmeticHelper.nextMonth(dateTime);

  /// Returns a new [DateTime] with the specified number of [years] added.
  ///
  /// Correctly handles leap years. For example, adding 1 year to February 29th, 2024
  /// yields February 28th, 2025.
  ///
  /// Time components and timezone (UTC/local) are preserved.
  ///
  /// Example:
  /// ```dart
  /// final leapDay = DateTime(2024, 2, 29);
  /// final nonLeapDay = SyncDateTime.addYears(leapDay, 1); // 2025-02-28
  /// ```
  static DateTime addYears(DateTime dateTime, int years) =>
      _ArithmeticHelper.addYears(dateTime, years);

  /// Returns a new [DateTime] set to the previous year.
  ///
  /// The operation preserves time components and whether the input [dateTime] is UTC or local.
  ///
  /// Example:
  /// ```dart
  /// final lastYear = SyncDateTime.previousYear(DateTime.now());
  /// ```
  static DateTime previousYear(DateTime dateTime) =>
      _ArithmeticHelper.previousYear(dateTime);

  /// Returns a new [DateTime] set to the next year.
  ///
  /// The operation preserves time components and whether the input [dateTime] is UTC or local.
  ///
  /// Example:
  /// ```dart
  /// final nextYear = SyncDateTime.nextYear(DateTime.now());
  /// ```
  static DateTime nextYear(DateTime dateTime) =>
      _ArithmeticHelper.nextYear(dateTime);

  /// Returns a new [DateTime] with the specified number of [hours] added.
  ///
  /// The operation is timezone-safe and preserves whether the input [dateTime]
  /// is UTC or local. Positive values add hours, while negative values subtract.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime.now();
  /// final threeHoursLater = SyncDateTime.addHours(now, 3);
  /// ```
  static DateTime addHours(DateTime dateTime, int hours) =>
      _ArithmeticHelper.addHours(dateTime, hours);

  /// Returns a new [DateTime] with the specified number of [minutes] added.
  ///
  /// The operation is timezone-safe and preserves whether the input [dateTime]
  /// is UTC or local. Positive values add minutes, while negative values subtract.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime.now();
  /// final thirtyMinutesLater = SyncDateTime.addMinutes(now, 30);
  /// ```
  static DateTime addMinutes(DateTime dateTime, int minutes) =>
      _ArithmeticHelper.addMinutes(dateTime, minutes);

  /// Returns the earlier of the two [DateTime] instances [a] and [b].
  ///
  /// Throws an [ArgumentError] if the timezone types (UTC vs local) mismatch.
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3);
  /// final second = DateTime(2026, 8, 4);
  /// final earlier = SyncDateTime.min(first, second); // first
  /// ```
  static DateTime min(DateTime a, DateTime b) => _ArithmeticHelper.min(a, b);

  /// Returns the later of the two [DateTime] instances [a] and [b].
  ///
  /// Throws an [ArgumentError] if the timezone types (UTC vs local) mismatch.
  ///
  /// Example:
  /// ```dart
  /// final first = DateTime(2026, 8, 3);
  /// final second = DateTime(2026, 8, 4);
  /// final later = SyncDateTime.max(first, second); // second
  /// ```
  static DateTime max(DateTime a, DateTime b) => _ArithmeticHelper.max(a, b);

  /// Clamps the [value] to be within the range [min] to [max] inclusive.
  ///
  /// Throws an [ArgumentError] if the timezone types of [value], [min], or [max] mismatch.
  /// Throws an [ArgumentError] if [min] is greater than [max].
  ///
  /// Example:
  /// ```dart
  /// final min = DateTime(2026, 8, 1);
  /// final max = DateTime(2026, 8, 10);
  /// final result = SyncDateTime.clamp(DateTime(2026, 8, 5), min, max); // 2026-08-05
  /// final clampedMin = SyncDateTime.clamp(DateTime(2026, 7, 30), min, max); // min
  /// ```
  static DateTime clamp(DateTime value, DateTime min, DateTime max) =>
      _ArithmeticHelper.clamp(value, min, max);

  /// Checks if [dateTime] is today in the same timezone (UTC or Local).
  ///
  /// Example:
  /// ```dart
  /// final result = SyncDateTime.isToday(DateTime.now()); // true
  /// ```
  static bool isToday(DateTime dateTime) =>
      _ComparisonHelper.isToday(dateTime);

  /// Checks if [dateTime] is tomorrow in the same timezone (UTC or Local).
  ///
  /// Example:
  /// ```dart
  /// final tomorrow = DateTime.now().add(Duration(days: 1));
  /// final result = SyncDateTime.isTomorrow(tomorrow); // true
  /// ```
  static bool isTomorrow(DateTime dateTime) =>
      _ComparisonHelper.isTomorrow(dateTime);

  /// Checks if [dateTime] is yesterday in the same timezone (UTC or Local).
  ///
  /// Example:
  /// ```dart
  /// final yesterday = DateTime.now().subtract(Duration(days: 1));
  /// final result = SyncDateTime.isYesterday(yesterday); // true
  /// ```
  static bool isYesterday(DateTime dateTime) =>
      _ComparisonHelper.isYesterday(dateTime);

  /// Checks if [dateTime] is in the past compared to the current time.
  ///
  /// Compares local [dateTime] against local current time, and UTC [dateTime]
  /// against UTC current time.
  ///
  /// Example:
  /// ```dart
  /// final past = DateTime.now().subtract(Duration(seconds: 1));
  /// final result = SyncDateTime.isPast(past); // true
  /// ```
  static bool isPast(DateTime dateTime) =>
      _ComparisonHelper.isPast(dateTime);

  /// Checks if [dateTime] is in the future compared to the current time.
  ///
  /// Compares local [dateTime] against local current time, and UTC [dateTime]
  /// against UTC current time.
  ///
  /// Example:
  /// ```dart
  /// final future = DateTime.now().add(Duration(seconds: 1));
  /// final result = SyncDateTime.isFuture(future); // true
  /// ```
  static bool isFuture(DateTime dateTime) =>
      _ComparisonHelper.isFuture(dateTime);

  /// Checks if [value] is between [start] and [end].
  ///
  /// Throws an [ArgumentError] if the timezone types of [value], [start], or [end] mismatch.
  /// Throws an [ArgumentError] if [start] is after [end].
  ///
  /// By default, [inclusive] is set to true.
  ///
  /// Example:
  /// ```dart
  /// final start = DateTime(2026, 8, 1);
  /// final end = DateTime(2026, 8, 10);
  /// final middle = DateTime(2026, 8, 5);
  ///
  /// final result1 = SyncDateTime.isBetween(middle, start, end); // true
  /// final result2 = SyncDateTime.isBetween(end, start, end, inclusive: false); // false
  /// ```
  static bool isBetween(
    DateTime value,
    DateTime start,
    DateTime end, {
    bool inclusive = true,
  }) =>
      _ComparisonHelper.isBetween(value, start, end, inclusive: inclusive);

  /// Checks if [a] and [b] represent the same hour, day, month, and year.
  ///
  /// Throws an [ArgumentError] if the timezone types mismatch.
  ///
  /// Example:
  /// ```dart
  /// final a = DateTime(2026, 8, 3, 14, 25);
  /// final b = DateTime(2026, 8, 3, 14, 55);
  /// final result = SyncDateTime.isSameHour(a, b); // true
  /// ```
  static bool isSameHour(DateTime a, DateTime b) =>
      _ComparisonHelper.isSameHour(a, b);

  /// Checks if [a] and [b] represent the same minute, hour, day, month, and year.
  ///
  /// Throws an [ArgumentError] if the timezone types mismatch.
  ///
  /// Example:
  /// ```dart
  /// final a = DateTime(2026, 8, 3, 14, 25, 10);
  /// final b = DateTime(2026, 8, 3, 14, 25, 50);
  /// final result = SyncDateTime.isSameMinute(a, b); // true
  /// ```
  static bool isSameMinute(DateTime a, DateTime b) =>
      _ComparisonHelper.isSameMinute(a, b);

  /// Checks if [a] and [b] represent the same second, minute, hour, day, month, and year.
  ///
  /// Throws an [ArgumentError] if the timezone types mismatch.
  ///
  /// Example:
  /// ```dart
  /// final a = DateTime(2026, 8, 3, 14, 25, 10, 100);
  /// final b = DateTime(2026, 8, 3, 14, 25, 10, 900);
  /// final result = SyncDateTime.isSameSecond(a, b); // true
  /// ```
  static bool isSameSecond(DateTime a, DateTime b) =>
      _ComparisonHelper.isSameSecond(a, b);

  /// Returns true only if the time components of [dateTime] are exactly at the start of the day.
  ///
  /// i.e., `00:00:00.000000`.
  ///
  /// Example:
  /// ```dart
  /// final midnight = DateTime(2026, 8, 3, 0, 0);
  /// final result = SyncDateTime.isStartOfDay(midnight); // true
  /// ```
  static bool isStartOfDay(DateTime dateTime) =>
      _ComparisonHelper.isStartOfDay(dateTime);

  /// Returns true only if the time components of [dateTime] are exactly at the end of the day.
  ///
  /// i.e., `23:59:59.999999`.
  ///
  /// Example:
  /// ```dart
  /// final end = DateTime(2026, 8, 3, 23, 59, 59, 999, 999);
  /// final result = SyncDateTime.isEndOfDay(end); // true
  /// ```
  static bool isEndOfDay(DateTime dateTime) =>
      _ComparisonHelper.isEndOfDay(dateTime);

  /// Rounds [dateTime] down to the nearest minute.
  ///
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt = DateTime(2026, 8, 3, 14, 52, 41, 987);
  /// final result = SyncDateTime.floorToMinute(dt); // 14:52:00.000
  /// ```
  static DateTime floorToMinute(DateTime dateTime) =>
      _RoundingHelper.floorToMinute(dateTime);

  /// Rounds [dateTime] up to the nearest minute.
  ///
  /// If already exactly on a minute boundary, returns the original value.
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt = DateTime(2026, 8, 3, 14, 52, 41);
  /// final result = SyncDateTime.ceilToMinute(dt); // 14:53:00.000
  /// ```
  static DateTime ceilToMinute(DateTime dateTime) =>
      _RoundingHelper.ceilToMinute(dateTime);

  /// Rounds [dateTime] to the nearest minute mathematically (>= 30 seconds rounds up).
  ///
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt1 = DateTime(2026, 8, 3, 14, 52, 35);
  /// final result1 = SyncDateTime.roundToMinute(dt1); // 14:53:00
  ///
  /// final dt2 = DateTime(2026, 8, 3, 14, 52, 25);
  /// final result2 = SyncDateTime.roundToMinute(dt2); // 14:52:00
  /// ```
  static DateTime roundToMinute(DateTime dateTime) =>
      _RoundingHelper.roundToMinute(dateTime);

  /// Rounds [dateTime] down to the nearest hour.
  ///
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt = DateTime(2026, 8, 3, 14, 52);
  /// final result = SyncDateTime.floorToHour(dt); // 14:00
  /// ```
  static DateTime floorToHour(DateTime dateTime) =>
      _RoundingHelper.floorToHour(dateTime);

  /// Rounds [dateTime] up to the nearest hour.
  ///
  /// If already exactly on an hour boundary, returns the original value.
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt = DateTime(2026, 8, 3, 14, 52);
  /// final result = SyncDateTime.ceilToHour(dt); // 15:00
  /// ```
  static DateTime ceilToHour(DateTime dateTime) =>
      _RoundingHelper.ceilToHour(dateTime);

  /// Rounds [dateTime] to the nearest hour mathematically (>= 30 minutes rounds up).
  ///
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt1 = DateTime(2026, 8, 3, 14, 35);
  /// final result1 = SyncDateTime.roundToHour(dt1); // 15:00
  ///
  /// final dt2 = DateTime(2026, 8, 3, 14, 25);
  /// final result2 = SyncDateTime.roundToHour(dt2); // 14:00
  /// ```
  static DateTime roundToHour(DateTime dateTime) =>
      _RoundingHelper.roundToHour(dateTime);

  /// Rounds [dateTime] down to the nearest day (equivalent to start of day).
  ///
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt = DateTime(2026, 8, 3, 14, 52);
  /// final result = SyncDateTime.floorToDay(dt); // 2026-08-03 00:00:00.000
  /// ```
  static DateTime floorToDay(DateTime dateTime) =>
      _RoundingHelper.floorToDay(dateTime);

  /// Rounds [dateTime] up to the nearest day.
  ///
  /// If already exactly at the start of the day, returns the original value.
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt = DateTime(2026, 8, 3, 13, 25);
  /// final result = SyncDateTime.ceilToDay(dt); // 2026-08-04 00:00:00.000
  /// ```
  static DateTime ceilToDay(DateTime dateTime) =>
      _RoundingHelper.ceilToDay(dateTime);

  /// Rounds [dateTime] to the nearest day mathematically (>= 12:00 rounds up).
  ///
  /// Preserves timezone and does not mutate the original object.
  ///
  /// Example:
  /// ```dart
  /// final dt1 = DateTime(2026, 8, 3, 11, 59);
  /// final result1 = SyncDateTime.roundToDay(dt1); // 2026-08-03 00:00:00.000
  ///
  /// final dt2 = DateTime(2026, 8, 3, 12, 00);
  /// final result2 = SyncDateTime.roundToDay(dt2); // 2026-08-04 00:00:00.000
  /// ```
  static DateTime roundToDay(DateTime dateTime) =>
      _RoundingHelper.roundToDay(dateTime);
}

/// Shared library-private helper method to validate timezone type matching.
void _validateTimezone(DateTime a, DateTime b) {
  if (a.isUtc != b.isUtc) {
    throw ArgumentError(
      'Both DateTime instances must have the same timezone type. '
      'a.isUtc is ${a.isUtc}, but b.isUtc is ${b.isUtc}.',
    );
  }
}

/// Shared library-private helper to create a timezone-aware DateTime instance.
DateTime _createDateTime({
  required bool isUtc,
  required int year,
  required int month,
  required int day,
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
  int microsecond = 0,
}) {
  return isUtc
      ? DateTime.utc(
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        )
      : DateTime(
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        );
}
