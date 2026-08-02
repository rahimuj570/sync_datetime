import 'package:sync_datetime/sync_datetime.dart';
import 'package:test/test.dart';

void main() {
  group('SyncDateTime', () {
    group('toUtc', () {
      test(
        'returns the same UTC DateTime if the input is already UTC (idempotent)',
        () {
          final utc = DateTime.utc(2026, 8, 2, 12, 0, 0);
          final result = SyncDateTime.toUtc(utc);
          expect(result.isUtc, isTrue);
          expect(result, same(utc));
        },
      );

      test('converts local DateTime to UTC correctly', () {
        final local = DateTime(2026, 8, 2, 12, 0, 0);
        final result = SyncDateTime.toUtc(local);
        expect(result.isUtc, isTrue);
        expect(result, local.toUtc());

        // Check offset consistency
        final offset = local.timeZoneOffset;
        expect(result.add(offset).year, local.year);
        expect(result.add(offset).hour, local.hour);
      });
    });

    group('fromUtc', () {
      test('converts UTC DateTime to local representation', () {
        final utc = DateTime.utc(2026, 8, 2, 12, 0, 0);
        final result = SyncDateTime.fromUtc(utc);
        expect(result.isUtc, isFalse);
        expect(result, utc.toLocal());
      });

      test('throws ArgumentError when input is not in UTC timezone', () {
        final local = DateTime(2026, 8, 2, 12, 0, 0);
        expect(
          () => SyncDateTime.fromUtc(local),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('The input DateTime must be in UTC timezone'),
            ),
          ),
        );
      });
    });

    group('toServer', () {
      test('converts local DateTime to UTC ISO 8601 string representation', () {
        final local = DateTime(2026, 8, 2, 12, 0, 0);
        final result = SyncDateTime.toServer(local);

        expect(result.endsWith('Z'), isTrue);
        final parsed = DateTime.parse(result);
        expect(parsed.isUtc, isTrue);
        expect(parsed, local.toUtc());
      });

      test('correctly serializes UTC DateTime directly', () {
        final utc = DateTime.utc(2026, 8, 2, 12, 0, 0);
        final result = SyncDateTime.toServer(utc);

        expect(result, '2026-08-02T12:00:00.000Z');
      });
    });

    group('fromServer', () {
      test(
        'parses standard ISO 8601 UTC string ending in Z and returns local time',
        () {
          final serverUtc = '2026-08-02T12:00:00.000Z';
          final result = SyncDateTime.fromServer(serverUtc);

          expect(result.isUtc, isFalse);
          expect(result, DateTime.utc(2026, 8, 2, 12, 0, 0).toLocal());
        },
      );

      test(
        'parses ISO 8601 string without Z, assumes UTC, and shifts to local',
        () {
          final serverUtc = '2026-08-02T12:00:00.000';
          final result = SyncDateTime.fromServer(serverUtc);

          expect(result.isUtc, isFalse);
          expect(result, DateTime.utc(2026, 8, 2, 12, 0, 0).toLocal());
        },
      );

      test(
        'parses ISO 8601 string with specific offset, assumes UTC, and shifts to local',
        () {
          final serverUtc = '2026-08-02T12:00:00.000+02:00';
          final result = SyncDateTime.fromServer(serverUtc);

          expect(result.isUtc, isFalse);
          // +02:00 represents a timezone 2 hours ahead of UTC, so the UTC time is 10:00:00
          expect(result, DateTime.utc(2026, 8, 2, 10, 0, 0).toLocal());
        },
      );

      test('throws FormatException for invalid date-time strings', () {
        expect(
          () => SyncDateTime.fromServer('invalid-timestamp'),
          throwsFormatException,
        );
        expect(
          () => SyncDateTime.fromServer('2026-08-02T'),
          throwsFormatException,
        );
      });

      test('parses ISO 8601 string with negative offset', () {
        final serverUtc = '2026-08-02T12:00:00.000-05:00';

        final result = SyncDateTime.fromServer(serverUtc);

        expect(result, DateTime.utc(2026, 8, 2, 17, 0, 0).toLocal());
      });
    });

    group('fromServerParts', () {
      test(
        'combines and parses date and time strings correctly with Z suffix',
        () {
          final result = SyncDateTime.fromServerParts(
            date: '2026-08-02',
            time: '08:49:50.551Z',
          );
          expect(result.isUtc, isFalse);
          expect(result, DateTime.utc(2026, 8, 2, 8, 49, 50, 551).toLocal());
        },
      );

      test(
        'combines and parses date and time strings correctly with implicit UTC (no suffix)',
        () {
          final result = SyncDateTime.fromServerParts(
            date: '2026-08-02',
            time: '08:49:50.551',
          );
          expect(result.isUtc, isFalse);
          expect(result, DateTime.utc(2026, 8, 2, 8, 49, 50, 551).toLocal());
        },
      );

      test('handles leading T or space in time string gracefully', () {
        final resultWithT = SyncDateTime.fromServerParts(
          date: '2026-08-02',
          time: 'T08:49:50.551Z',
        );
        final resultWithSpace = SyncDateTime.fromServerParts(
          date: '2026-08-02',
          time: ' 08:49:50.551Z',
        );
        expect(resultWithT, DateTime.utc(2026, 8, 2, 8, 49, 50, 551).toLocal());
        expect(
          resultWithSpace,
          DateTime.utc(2026, 8, 2, 8, 49, 50, 551).toLocal(),
        );
      });

      test('throws FormatException for invalid component values', () {
        expect(
          () => SyncDateTime.fromServerParts(
            date: 'invalid-date',
            time: '12:00:00',
          ),
          throwsFormatException,
        );
      });
    });

    group('combine', () {
      test('combines date and time when both are local', () {
        final date = DateTime(2026, 8, 2, 0, 0, 0);
        final time = DateTime(2020, 1, 1, 14, 30, 15, 123, 456);
        final result = SyncDateTime.combine(date, time);

        expect(result.isUtc, isFalse);
        expect(result.year, 2026);
        expect(result.month, 8);
        expect(result.day, 2);
        expect(result.hour, 14);
        expect(result.minute, 30);
        expect(result.second, 15);
        expect(result.millisecond, 123);
        expect(result.microsecond, 456);
      });

      test('combines date and time when both are UTC', () {
        final date = DateTime.utc(2026, 8, 2, 0, 0, 0);
        final time = DateTime.utc(2020, 1, 1, 14, 30, 15, 123, 456);
        final result = SyncDateTime.combine(date, time);

        expect(result.isUtc, isTrue);
        expect(result.year, 2026);
        expect(result.month, 8);
        expect(result.day, 2);
        expect(result.hour, 14);
        expect(result.minute, 30);
        expect(result.second, 15);
        expect(result.millisecond, 123);
        expect(result.microsecond, 456);
      });

      test('throws ArgumentError if timezones are mismatched', () {
        final localDate = DateTime(2026, 8, 2);
        final utcTime = DateTime.utc(2020, 1, 1, 14, 30);

        expect(
          () => SyncDateTime.combine(localDate, utcTime),
          throwsArgumentError,
        );

        final utcDate = DateTime.utc(2026, 8, 2);
        final localTime = DateTime(2020, 1, 1, 14, 30);

        expect(
          () => SyncDateTime.combine(utcDate, localTime),
          throwsArgumentError,
        );
      });
    });
  });
}
