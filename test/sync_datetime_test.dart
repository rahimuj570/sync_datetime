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

    group('toServerParts', () {
      test(
        'converts local DateTime to UTC and splits into date and time parts',
        () {
          final local = DateTime(2026, 8, 2, 12, 0, 0);
          final result = SyncDateTime.toServerParts(local);

          final expectedUtc = local.toUtc();
          final expectedIso = expectedUtc.toIso8601String();
          final split = expectedIso.split('T');

          expect(result.date, split.first);
          expect(result.time, split.last);
          expect(result.time.endsWith('Z'), isTrue);
        },
      );

      test(
        'converts UTC DateTime directly into correct date and time parts',
        () {
          final utc = DateTime.utc(2026, 8, 2, 14, 30, 15, 123);
          final result = SyncDateTime.toServerParts(utc);

          expect(result.date, '2026-08-02');
          expect(result.time, '14:30:15.123Z');
        },
      );
    });

    group('today, todayUtc, and nowUtc', () {
      test('today returns local start of day', () {
        final result = SyncDateTime.today();
        final now = DateTime.now();
        expect(result.isUtc, isFalse);
        expect(result.year, now.year);
        expect(result.month, now.month);
        expect(result.day, now.day);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0);
        expect(result.microsecond, 0);
      });

      test('todayUtc returns UTC start of day', () {
        final result = SyncDateTime.todayUtc();
        final nowUtc = DateTime.now().toUtc();
        expect(result.isUtc, isTrue);
        expect(result.year, nowUtc.year);
        expect(result.month, nowUtc.month);
        expect(result.day, nowUtc.day);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0);
        expect(result.microsecond, 0);
      });

      test('nowUtc returns the current UTC date and time', () {
        final result = SyncDateTime.nowUtc();
        final nowUtc = DateTime.now().toUtc();
        expect(result.isUtc, isTrue);
        expect(result.difference(nowUtc).inSeconds.abs(), lessThanOrEqualTo(1));
      });
    });

    group('startOfDay and endOfDay', () {
      test('startOfDay preserves local and sets time to zero', () {
        final local = DateTime(2026, 8, 3, 15, 30, 20, 100, 200);
        final result = SyncDateTime.startOfDay(local);
        expect(result.isUtc, isFalse);
        expect(result, DateTime(2026, 8, 3));
      });

      test('startOfDay preserves UTC and sets time to zero', () {
        final utc = DateTime.utc(2026, 8, 3, 15, 30, 20, 100, 200);
        final result = SyncDateTime.startOfDay(utc);
        expect(result.isUtc, isTrue);
        expect(result, DateTime.utc(2026, 8, 3));
      });

      test('endOfDay preserves local and sets time to end of day', () {
        final local = DateTime(2026, 8, 3, 15, 30, 20, 100, 200);
        final result = SyncDateTime.endOfDay(local);
        expect(result.isUtc, isFalse);
        expect(result, DateTime(2026, 8, 3, 23, 59, 59, 999, 999));
      });

      test('endOfDay preserves UTC and sets time to end of day', () {
        final utc = DateTime.utc(2026, 8, 3, 15, 30, 20, 100, 200);
        final result = SyncDateTime.endOfDay(utc);
        expect(result.isUtc, isTrue);
        expect(result, DateTime.utc(2026, 8, 3, 23, 59, 59, 999, 999));
      });
    });

    group('stripDate and stripTime', () {
      test('stripDate extracts date string correctly', () {
        final local = DateTime(2002, 2, 6, 17, 15, 30);
        expect(SyncDateTime.stripDate(local), '2002-02-06');

        final utc = DateTime.utc(2002, 2, 6, 17, 15, 30);
        expect(SyncDateTime.stripDate(utc), '2002-02-06');
      });

      test(
        'stripTime extracts time string correctly preserving timezone compatibility',
        () {
          final local = DateTime(2002, 2, 6, 17, 15, 30);
          expect(SyncDateTime.stripTime(local), startsWith('17:15:30'));

          final utc = DateTime.utc(2002, 2, 6, 17, 15, 30);
          expect(SyncDateTime.stripTime(utc), startsWith('17:15:30'));
          expect(SyncDateTime.stripTime(utc).endsWith('Z'), isTrue);
        },
      );
    });

    group('copyWith', () {
      test('copyWith preserves local and updates specified fields', () {
        final local = DateTime(2026, 8, 3, 12, 0, 0);
        final result = SyncDateTime.copyWith(local, year: 2027, hour: 15);
        expect(result.isUtc, isFalse);
        expect(result, DateTime(2027, 8, 3, 15, 0, 0));
      });

      test('copyWith preserves UTC and updates specified fields', () {
        final utc = DateTime.utc(2026, 8, 3, 12, 0, 0);
        final result = SyncDateTime.copyWith(utc, month: 9, minute: 30);
        expect(result.isUtc, isTrue);
        expect(result, DateTime.utc(2026, 9, 3, 12, 30, 0));
      });
    });

    group('isSameDay, isSameMonth, and isSameYear', () {
      test('isSameDay detects matching days', () {
        final a = DateTime(2026, 8, 3, 10, 0);
        final b = DateTime(2026, 8, 3, 22, 0);
        expect(SyncDateTime.isSameDay(a, b), isTrue);

        final c = DateTime(2026, 8, 4, 10, 0);
        expect(SyncDateTime.isSameDay(a, c), isFalse);
      });

      test('isSameDay throws on mismatched timezones', () {
        expect(
          () => SyncDateTime.isSameDay(
            DateTime(2026, 8, 3),
            DateTime.utc(2026, 8, 3),
          ),
          throwsArgumentError,
        );
      });

      test('isSameMonth detects matching months', () {
        final a = DateTime(2026, 8, 3);
        final b = DateTime(2026, 8, 25);
        expect(SyncDateTime.isSameMonth(a, b), isTrue);

        final c = DateTime(2026, 9, 3);
        expect(SyncDateTime.isSameMonth(a, c), isFalse);
      });

      test('isSameMonth throws on mismatched timezones', () {
        expect(
          () => SyncDateTime.isSameMonth(
            DateTime(2026, 8, 3),
            DateTime.utc(2026, 8, 3),
          ),
          throwsArgumentError,
        );
      });

      test('isSameYear detects matching years', () {
        final a = DateTime(2026, 8, 3);
        final b = DateTime(2026, 12, 31);
        expect(SyncDateTime.isSameYear(a, b), isTrue);

        final c = DateTime(2027, 8, 3);
        expect(SyncDateTime.isSameYear(a, c), isFalse);
      });

      test('isSameYear throws on mismatched timezones', () {
        expect(
          () => SyncDateTime.isSameYear(
            DateTime(2026, 8, 3),
            DateTime.utc(2026, 8, 3),
          ),
          throwsArgumentError,
        );
      });
    });

    group('daysBetween and differenceInDays', () {
      test(
        'daysBetween calculates positive, negative and zero differences',
        () {
          final a = DateTime(2026, 8, 3, 23, 59);
          final b = DateTime(2026, 8, 4, 0, 1);
          expect(SyncDateTime.daysBetween(a, b), 1);
          expect(SyncDateTime.daysBetween(b, a), -1);
          expect(SyncDateTime.daysBetween(a, a), 0);
        },
      );

      test('daysBetween handles DST changes gracefully via UTC conversion', () {
        final a = DateTime.utc(2026, 3, 29, 1, 0);
        final b = DateTime.utc(2026, 3, 30, 0, 0);
        expect(SyncDateTime.daysBetween(a, b), 1);
      });

      test('daysBetween throws on mismatched timezones', () {
        expect(
          () => SyncDateTime.daysBetween(
            DateTime(2026, 8, 3),
            DateTime.utc(2026, 8, 4),
          ),
          throwsArgumentError,
        );
      });

      test('differenceInDays behaves identically to daysBetween', () {
        final a = DateTime(2026, 8, 3, 23, 59);
        final b = DateTime(2026, 8, 4, 0, 1);
        expect(SyncDateTime.differenceInDays(a, b), 1);
      });
    });

    group('isWeekend, isWeekday, daysInMonth, isLeapYear', () {
      test(
        'daysInMonth returns correct days count including leap year February',
        () {
          expect(SyncDateTime.daysInMonth(DateTime(2026, 1)), 31);
          expect(SyncDateTime.daysInMonth(DateTime(2026, 2)), 28);
          expect(SyncDateTime.daysInMonth(DateTime(2024, 2)), 29);
          expect(SyncDateTime.daysInMonth(DateTime(2026, 4)), 30);
        },
      );

      test('isLeapYear checks leap years correctly', () {
        expect(SyncDateTime.isLeapYear(2024), isTrue);
        expect(SyncDateTime.isLeapYear(2000), isTrue);
        expect(SyncDateTime.isLeapYear(1900), isFalse);
        expect(SyncDateTime.isLeapYear(2026), isFalse);
      });
    });

    group(
      'differenceInYears, differenceInHours, differenceInMinutes, differenceInSeconds, differenceInMilliseconds',
      () {
        test('differenceInYears calculates full years elapsed', () {
          final a = DateTime(2024, 8, 3);
          final b = DateTime(2026, 8, 2);
          final c = DateTime(2026, 8, 3);
          final d = DateTime(2026, 8, 4);

          expect(SyncDateTime.differenceInYears(a, b), 1);
          expect(SyncDateTime.differenceInYears(a, c), 2);
          expect(SyncDateTime.differenceInYears(a, d), 2);

          expect(SyncDateTime.differenceInYears(b, a), -1);
          expect(SyncDateTime.differenceInYears(c, a), -2);
          expect(SyncDateTime.differenceInYears(d, a), -2);
        });

        test('difference helpers throw on mismatched timezones', () {
          final a = DateTime(2026, 8, 3, 10);
          final b = DateTime.utc(2026, 8, 3, 10);
          expect(
            () => SyncDateTime.differenceInHours(a, b),
            throwsArgumentError,
          );
          expect(
            () => SyncDateTime.differenceInMinutes(a, b),
            throwsArgumentError,
          );
          expect(
            () => SyncDateTime.differenceInSeconds(a, b),
            throwsArgumentError,
          );
          expect(
            () => SyncDateTime.differenceInMilliseconds(a, b),
            throwsArgumentError,
          );
          expect(
            () => SyncDateTime.differenceInYears(a, b),
            throwsArgumentError,
          );
        });
      },
    );

    group('normalizeServerTimestamp', () {
      test('normalizes timestamp without timezone suffix (assumed UTC)', () {
        final result = SyncDateTime.normalizeServerTimestamp(
          '2026-08-02T12:00:00.000',
        );
        expect(result, '2026-08-02T12:00:00.000Z');
      });

      test('normalizes timestamp with Z suffix directly', () {
        final result = SyncDateTime.normalizeServerTimestamp(
          '2026-08-02T12:00:00.000Z',
        );
        expect(result, '2026-08-02T12:00:00.000Z');
      });

      test(
        'normalizes timestamp with timezone offset to UTC representation',
        () {
          final result = SyncDateTime.normalizeServerTimestamp(
            '2026-08-02T12:00:00.000+02:00',
          );
          expect(result, '2026-08-02T10:00:00.000Z');
        },
      );

      test('throws FormatException for invalid timestamps', () {
        expect(
          () => SyncDateTime.normalizeServerTimestamp('invalid'),
          throwsFormatException,
        );
      });
    });
  });
}
