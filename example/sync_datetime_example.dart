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

  final parts = SyncDateTime.toServerParts(localNow);
  print('Server Parts - Date:        ${parts.date}, Time: ${parts.time}');

  final parsedParts = SyncDateTime.fromServerParts(
    date: parts.date,
    time: parts.time,
  );
  print('Parsed Server Parts back:   $parsedParts');

  final dateOnly = DateTime(2026, 8, 3);
  final timeOnly = DateTime(2020, 1, 1, 14, 30, 0);
  final combined = SyncDateTime.combine(dateOnly, timeOnly);
  print('Combined Local:             $combined');

  print('\n=== 2. Core Utilities ===');
  final today = SyncDateTime.today();
  final todayUtc = SyncDateTime.todayUtc();
  print('Today Local:                $today');
  print('Today UTC:                  $todayUtc');
  print('Now UTC:                    ${SyncDateTime.nowUtc()}');

  final start = SyncDateTime.startOfDay(localNow);
  final end = SyncDateTime.endOfDay(localNow);
  print('Start of Day:               $start');
  print('End of Day:                 $end');

  final dateStr = SyncDateTime.stripDate(localNow);
  final timeStr = SyncDateTime.stripTime(localNow);
  print('Date component string:      $dateStr');
  print('Time component string:      $timeStr');

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
  print(
    'Is Same Year tomorrow?      ${SyncDateTime.isSameYear(localNow, tomorrow)}',
  );
  print('Days in Month:              ${SyncDateTime.daysInMonth(localNow)}');
  print('Is Leap Year (2024)?        ${SyncDateTime.isLeapYear(2024)}');

  print('\n=== 4. Difference Helpers ===');
  final pastDate = DateTime(2024, 8, 3);
  print(
    'Years between $pastDate and today: ${SyncDateTime.differenceInYears(pastDate, today)}',
  );
  print(
    'Days between $pastDate and today:  ${SyncDateTime.differenceInDays(pastDate, today)}',
  );
  print(
    'Hours between $pastDate and today: ${SyncDateTime.differenceInHours(pastDate, today)}',
  );
  print(
    'Minutes between $pastDate and today: ${SyncDateTime.differenceInMinutes(pastDate, today)}',
  );
  print(
    'Seconds between $pastDate and today: ${SyncDateTime.differenceInSeconds(pastDate, today)}',
  );
  print(
    'Milliseconds between $pastDate and today: ${SyncDateTime.differenceInMilliseconds(pastDate, today)}',
  );

  print('\n=== 5. Server Normalization ===');
  final rawTimestamp = '2026-08-02T12:00:00.000+02:00';
  final normalized = SyncDateTime.normalizeServerTimestamp(rawTimestamp);
  print('Normalized $rawTimestamp -> $normalized');

  print('\n=== 6. Calendar Arithmetic ===');
  final sampleDate = DateTime(2026, 8, 3, 10, 30);
  print('Original Date:              $sampleDate');
  print('Add 5 days:                 ${SyncDateTime.addDays(sampleDate, 5)}');
  print('Previous Day:               ${SyncDateTime.previousDay(sampleDate)}');
  print('Next Day:                   ${SyncDateTime.nextDay(sampleDate)}');
  print('Add 1 Month:                ${SyncDateTime.addMonths(sampleDate, 1)}');
  print(
    'Previous Month:             ${SyncDateTime.previousMonth(sampleDate)}',
  );
  print('Next Month:                 ${SyncDateTime.nextMonth(sampleDate)}');
  print('Add 2 Years:                ${SyncDateTime.addYears(sampleDate, 2)}');
  print('Previous Year:              ${SyncDateTime.previousYear(sampleDate)}');
  print('Next Year:                  ${SyncDateTime.nextYear(sampleDate)}');
  print('Add 3 Hours:                ${SyncDateTime.addHours(sampleDate, 3)}');
  print(
    'Add 45 Minutes:             ${SyncDateTime.addMinutes(sampleDate, 45)}',
  );

  final earlier = DateTime(2026, 8, 1);
  final later = DateTime(2026, 8, 10);
  print('Min between earlier/later:  ${SyncDateTime.min(earlier, later)}');
  print('Max between earlier/later:  ${SyncDateTime.max(earlier, later)}');
  print(
    'Clamp middle to bounds:     ${SyncDateTime.clamp(sampleDate, earlier, later)}',
  );

  print('\n=== 7. Validation Helpers ===');
  print('Is Today?                   ${SyncDateTime.isToday(localNow)}');
  print('Is Tomorrow?                 ${SyncDateTime.isTomorrow(tomorrow)}');
  print(
    'Is Yesterday?                ${SyncDateTime.isYesterday(localNow.subtract(const Duration(days: 1)))}',
  );
  print(
    'Is Past?                     ${SyncDateTime.isPast(localNow.subtract(const Duration(seconds: 1)))}',
  );
  print('Is Future?                   ${SyncDateTime.isFuture(tomorrow)}');
  print(
    'Is Between?                  ${SyncDateTime.isBetween(sampleDate, earlier, later)}',
  );
  print(
    'Is Same Hour?                ${SyncDateTime.isSameHour(sampleDate, sampleDate.add(const Duration(minutes: 5)))}',
  );
  print(
    'Is Same Minute?              ${SyncDateTime.isSameMinute(sampleDate, sampleDate.add(const Duration(seconds: 5)))}',
  );
  print(
    'Is Same Second?              ${SyncDateTime.isSameSecond(sampleDate, sampleDate.add(const Duration(milliseconds: 5)))}',
  );
  print('Is Start of Day (midnight)?  ${SyncDateTime.isStartOfDay(start)}');
  print('Is End of Day (23:59:59)?    ${SyncDateTime.isEndOfDay(end)}');

  print('\n=== 8. Rounding APIs ===');
  final testTime = DateTime(2026, 8, 3, 14, 52, 41, 987);
  print('Test Time:                  $testTime');
  print('Floor to Minute:            ${SyncDateTime.floorToMinute(testTime)}');
  print('Ceil to Minute:             ${SyncDateTime.ceilToMinute(testTime)}');
  print('Round to Minute:            ${SyncDateTime.roundToMinute(testTime)}');
  print('Floor to Hour:              ${SyncDateTime.floorToHour(testTime)}');
  print('Ceil to Hour:               ${SyncDateTime.ceilToHour(testTime)}');
  print('Round to Hour:              ${SyncDateTime.roundToHour(testTime)}');
  print('Floor to Day:               ${SyncDateTime.floorToDay(testTime)}');
  print('Ceil to Day:                ${SyncDateTime.ceilToDay(testTime)}');
  print('Round to Day:               ${SyncDateTime.roundToDay(testTime)}');
}
