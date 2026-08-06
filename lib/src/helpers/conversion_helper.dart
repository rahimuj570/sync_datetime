part of '../sync_datetime.dart';

abstract final class _ConversionHelper {
  static DateTime toUtc(DateTime dateTime) {
    return dateTime.isUtc ? dateTime : dateTime.toUtc();
  }

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
}
