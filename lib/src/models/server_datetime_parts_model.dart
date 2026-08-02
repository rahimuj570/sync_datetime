/// Represents separate UTC date and time values suitable for backend APIs.
///
/// Many backend frameworks expose date and time as individual fields instead
/// of a single ISO 8601 timestamp.
///
/// Example:
/// ```json
/// {
///   "scheduled_date": "2026-08-02",
///   "scheduled_time": "08:49:50.551Z"
/// }
/// ```
final class ServerDateTimeParts {
  /// UTC date formatted as `yyyy-MM-dd`.
  final String date;

  /// UTC time formatted as `HH:mm:ss.SSSZ`.
  final String time;

  /// Creates a [ServerDateTimeParts] instance with the specified [date] and [time].
  const ServerDateTimeParts({required this.date, required this.time});

  @override
  String toString() => 'ServerDateTimeParts(date: $date, time: $time)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerDateTimeParts && other.date == date && other.time == time;

  @override
  int get hashCode => Object.hash(date, time);
}
