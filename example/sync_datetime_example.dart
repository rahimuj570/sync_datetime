import 'package:sync_datetime/sync_datetime.dart';

void main() {
  print('=== 1. Core Synchronization APIs ===');
  final localNow = DateTime.now();
  final utcNow = SyncDateTime.toUtc(localNow);
  print('Local Time:                 $localNow');
  print('UTC Time:                   $utcNow');

  final localBack = SyncDateTime.fromUtc(utcNow);
  print('Local Time (converted):     $localBack');

  final serverString = SyncDateTime.toServer(localNow);
  print('Server Payload string:      $serverString');

  final parsedLocal = SyncDateTime.fromServer('2026-08-02T12:00:00');
  print('Parsed Local (assumed UTC): $parsedLocal');

  final dateOnly = DateTime(2026, 8, 3);
  final timeOnly = DateTime(2020, 1, 1, 14, 30, 0);
  final combined = SyncDateTime.combine(dateOnly, timeOnly);
  print('Combined Local:             $combined');

  print('\n=== 2. New Core Utilities ===');
  final today = SyncDateTime.today();
  final todayUtc = SyncDateTime.todayUtc();
  print('Today Local:                $today');
  print('Today UTC:                  $todayUtc');

  final start = SyncDateTime.startOfDay(localNow);
  final end = SyncDateTime.endOfDay(localNow);
  print('Start of Day:               $start');
  print('End of Day:                 $end');

  final dateStr = SyncDateTime.stripDate(localNow);
  final timeStr = SyncDateTime.stripTime(localNow);
  print('Date components string:     $dateStr');
  print('Time components string:     $timeStr');

  final updated = SyncDateTime.copyWith(localNow, year: 2030, month: 12);
  print('CopyWith 2030-12:           $updated');

  print('\n=== 3. Comparison Utilities ===');
  final tomorrow = localNow.add(const Duration(days: 1));
  print(
    'Is Same Day tomorrow?       ${SyncDateTime.isSameDay(localNow, tomorrow)}',
  );
  print(
    'Is Same Month tomorrow?     ${SyncDateTime.isSameMonth(localNow, tomorrow)}',
  );
  print('Days in Month:              ${SyncDateTime.daysInMonth(localNow)}');
  print('Is Leap Year (2024)?        ${SyncDateTime.isLeapYear(2024)}');

  print('\n=== 4. Difference Helpers ===');
  final pastDate = DateTime(2024, 8, 3);
  final diffYears = SyncDateTime.differenceInYears(pastDate, today);
  final diffDays = SyncDateTime.differenceInDays(pastDate, today);
  print('Years between $pastDate and today: $diffYears');
  print('Days between $pastDate and today:  $diffDays');

  print('\n=== 5. Server Sync Helpers ===');
  final rawTimestamp = '2026-08-02T12:00:00.000+02:00';
  final normalized = SyncDateTime.normalizeServerTimestamp(rawTimestamp);
  print('Normalized $rawTimestamp -> $normalized');
}
