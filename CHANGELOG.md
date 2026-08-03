## 0.1.5

- Add Core Utilities: `today()`, `todayUtc()`, `nowUtc()`, `startOfDay()`, `endOfDay()`, `stripDate()`, `stripTime()`, and `copyWith()`.
- Add Comparison Utilities: `isSameDay()`, `isSameMonth()`, `isSameYear()`, `daysBetween()`, and `daysInMonth()`, `isLeapYear()`.
- Add Difference Helpers: `differenceInYears()`, `differenceInDays()`, `differenceInHours()`, `differenceInMinutes()`, `differenceInSeconds()`, and `differenceInMilliseconds()`.
- Add Server Synchronization Helper: `normalizeServerTimestamp()`.
- Enforce strict timezone matching across all comparison and difference APIs, throwing `ArgumentError` on mismatches.
- Expand test coverage and update package examples.

## 0.1.4

- Add `toServerParts` static helper method to serialize a `DateTime` into a `ServerDateTimeParts` object (containing separate UTC date and time strings).
- Export `ServerDateTimeParts` from the main library entry point.
- Update documentation and example script to showcase `toServerParts`.

## 0.1.3

- Add `fromServerParts` static helper method to parse separate date and time strings.
- Update documentation and example script to showcase `fromServerParts`.

## 0.1.2

- Update README version references and documentation.

## 0.1.1

- Add repository metadata to `pubspec.yaml`.
- Fix potential 1-hour parsing offset bug under Daylight Saving Time (DST) transitions in `fromServer`.
- Improve parameter naming on `toUtc` and `toServer` for clarity.
- Implement detailed `ArgumentError.value` debugging information.
- Add additional test coverage for negative timezone offset parsing.

## 0.1.0

- Initial version.
- Implement reliable, predictable DateTime synchronization methods: `toUtc`, `fromUtc`, `toServer`, `fromServer`, and `combine`.
- Enforce strict parameter validation and robust parsing of ISO 8601 strings (handling both explicit and implicit UTC formats).
