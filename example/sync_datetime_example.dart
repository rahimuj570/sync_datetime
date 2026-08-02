import 'package:sync_datetime/sync_datetime.dart';

void main() {
  // 1. Convert local time to UTC
  final localNow = DateTime.now();
  final utcNow = SyncDateTime.toUtc(localNow);
  print('Local Time:       $localNow');
  print('UTC Time:         $utcNow');

  // 2. Convert UTC to local time
  final localBack = SyncDateTime.fromUtc(utcNow);
  print('Local Time (back): $localBack');

  // 3. Serialize local time to server ISO 8601 UTC string
  final serverString = SyncDateTime.toServer(localNow);
  print('Server Payload:   $serverString');

  // 4. Parse server ISO 8601 string back to local time
  // Note: Works correctly even if the timezone suffix (e.g. 'Z') is omitted.
  final parsedLocal = SyncDateTime.fromServer('2026-08-02T12:00:00');
  print('Parsed Local:     $parsedLocal');

  // 5. Parse separate server date and time strings
  final parsedParts = SyncDateTime.fromServerParts(
    date: '2026-08-02',
    time: '08:49:50.551Z',
  );
  print('Parsed Parts:     $parsedParts');

  // 6. Combine Date and Time components
  final dateOnly = DateTime(2026, 8, 2); // Local date
  final timeOnly = DateTime(2020, 1, 1, 14, 30, 0); // Local time
  final combined = SyncDateTime.combine(dateOnly, timeOnly);
  print('Combined Local:   $combined');

  // 7. Serialize DateTime to separate UTC date and time strings
  final parts = SyncDateTime.toServerParts(localNow);
  print('Serialized Date:  ${parts.date}');
  print('Serialized Time:  ${parts.time}');
}
