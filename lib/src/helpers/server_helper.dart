part of '../sync_datetime.dart';

abstract final class _ServerHelper {
  static final RegExp _timezoneRegex = RegExp(
    r'([zZ]|[+-]\d{2}(?::?\d{2}(?::?\d{2})?)?)$',
  );

  static String toServer(DateTime dateTime) {
    return _ConversionHelper.toUtc(dateTime).toIso8601String();
  }

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

  static ServerDateTimeParts toServerParts(DateTime dateTime) {
    final utc = _ConversionHelper.toUtc(dateTime);

    final iso = utc.toIso8601String();

    final split = iso.split('T');

    return ServerDateTimeParts(date: split.first, time: split.last);
  }

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
