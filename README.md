# sync_datetime

[![pub package](https://img.shields.io/pub/v/sync_datetime.svg)](https://pub.dev/packages/sync_datetime)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Language: Dart](https://img.shields.io/badge/language-Dart-blue)](https://dart.dev/)
[![Platform Support](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue)](https://pub.dev/packages/sync_datetime)

A lightweight, dependency-free **Flutter DateTime** and **Dart DateTime** synchronization library. Safely manage **UTC conversion**, **timezone handling**, **ISO 8601 parsing**, and **client-server synchronization** without timezone offset bugs.

---

## 📚 Table of Contents

* [🚀 Quick Start](#quick-start)
* [🎯 Why sync_datetime?](#why-sync_datetime)
* [💻 Ecosystem & Platform Support](#ecosystem--platform-support)
* [✨ Features](#features)
* [📚 API Reference & Utility List](#api-reference--utility-list)
* [🛠️ Detailed API Usage Examples](#detailed-api-usage-examples)
* [🔍 Search Intent Coverage: How-To Guides](#search-intent-coverage-how-to-guides)
* [⚖️ Comparison: sync_datetime vs. Native Dart DateTime](#comparison-sync_datetime-vs-native-dart-datetime)
* [🛡️ Best Practices & Performance Notes](#best-practices--performance-notes)
* [⚠️ Common Mistakes & Troubleshooting](#common-mistakes--troubleshooting)
* [🚧 Version Compatibility](#version-compatibility)
* [🤝 Contributing & License](#contributing--license)

---

## Quick Start

### Installation

Add `sync_datetime` to your `pubspec.yaml` file:

```yaml
dependencies:
  sync_datetime: ^0.2.1
```

Or run the pub command:

```bash
dart pub add sync_datetime
```

### Import

Import the package in your **Flutter** or **Dart** files:

```dart
import 'package:sync_datetime/sync_datetime.dart';
```

### Quick Example

```dart
import 'package:sync_datetime/sync_datetime.dart';

// 1. Capture local timezone DateTime
final DateTime localMeeting = DateTime.now();

// 2. Format local time to UTC ISO 8601 string for REST API serialization
final String payload = SyncDateTime.toServer(localMeeting); 

// 3. Parse UTC server timestamp back to local device timezone
final DateTime localBack = SyncDateTime.fromServer(payload);

// 4. Combine date & time components timezone-safely
final DateTime appointment = SyncDateTime.combine(
  DateTime.now(),
  DateTime.now(),
);

// 5. Shift calendar events safely (Calendar Arithmetic)
final DateTime nextMonth = SyncDateTime.nextMonth(appointment);
final DateTime nextDay = SyncDateTime.nextDay(nextMonth);

// 6. Validate dates easily
final bool isTomorrow = SyncDateTime.isTomorrow(nextDay);
```

---

## Why sync_datetime?

Handling **DateTime** values correctly across a **Flutter** client application, **Dart** server backend, and remote database is a frequent source of bugs. Developers often run into timezone mismatches when serializing data to a **REST API**, parsing a UTC **timestamp** that lacks a timezone designator, or performing calendar calculations under Daylight Saving Time (DST) transitions.

`sync_datetime` provides a robust, zero-dependency set of **Flutter DateTime utilities** and **Dart DateTime utilities**. It automates **UTC timezone conversion**, resolves missing timezone suffixes, and helps format consistent payloads for **backend services** like **Firebase**, **Supabase**, and SQL databases. 

Whether you are building an **offline-first** local database or managing calendar events, this package protects you against silent clock skew and timezone conversion errors. It is designed to fit naturally into real-world Flutter applications such as:

* **Booking Apps:** Prevent date shift errors when customers book flights or hotel rooms across timezones.
* **Scheduling Apps:** Keep reminders, calendar events, and recurring meetings synchronized with the server clock.
* **Attendance Systems:** Log precise work shifts without local device clock manipulation interfering with server validation.
* **POS & E-commerce Systems:** Standardize order timestamps, discount expiration times, and receipt dates.
* **Chat Applications:** Sort message histories chronologically using unified UTC sorting.
* **Healthcare Apps:** Track medication times, doctor appointments, and patient logs timezone-safely.

At its core, `sync_datetime` focuses entirely on correctness, timezone safety, predictable calendar arithmetic, and client-server synchronization rather than formatting or localization. This targeted scope ensures the library remains lightweight and robust, avoiding the bloat and complexity of heavy internationalization frameworks while solving the most critical date and time issues developers face.

---

## Ecosystem & Platform Support

### Supported Platforms
As a pure **Dart** package with **zero dependencies**, `sync_datetime` runs on all platforms supported by Dart and **Flutter**:
* **Web** (Chrome, Safari, Edge, Firefox)
* **Mobile** (iOS, Android)
* **Desktop** (macOS, Windows, Linux)
* **Server-side** (Dart VM, Docker containers)

### Architecture Compatibility
`sync_datetime` integrates seamlessly into modern Dart and Flutter architectures:

* **State Management:** Fully compatible with state managers like **Riverpod**, **Bloc**, **Cubit**, **Provider**, and **GetX** because of its immutable API design.
* **Clean Architecture & MVVM:** Ideal for usage inside the **Repository Pattern** and data sources to normalize API models before they reach the domain layer.
* **Network Clients:** Works out of the box with serialization tools like **Dio**, **Retrofit**, and `http` requests.
* **Cloud Backends:** Complements **Appwrite**, **PocketBase**, and custom REST/GraphQL services.

---

## Features

* **Client ↔ Server Synchronization:** Serialize, parse, normalize, and safely exchange UTC timestamps with backend services.
* **Strict Timezone Safety:** Prevent accidental comparisons between UTC and local `DateTime` instances.
* **Calendar Arithmetic:** Add or subtract days, months, years, hours, and minutes while correctly handling leap years and month boundaries.
* **Validation Helpers:** Easily determine whether a date is today, tomorrow, yesterday, in the past, or in the future.
* **Comparison Utilities:** Compare dates by day, month, year, hour, minute, or second.
* **Boundary Utilities:** Get the start/end of a day, clamp dates, find minimum/maximum values, and normalize timestamps.
* **ISO 8601 Utilities:** Parse, normalize, split, combine, and serialize timestamps without timezone surprises.
* **DST-Safe Difference Calculations:** Calendar-aware difference helpers that avoid daylight saving edge cases.
* **Zero Dependencies:** Built entirely on top of the Dart SDK.

---

## API Reference & Utility List

### 1. Client-Server DateTime Synchronization
| Method | Returns | Description |
|---------|---------|-------------|
| `toServer(DateTime)` | `String` | Serializes a **DateTime** to a standard UTC **ISO 8601** string. |
| `toServerParts(DateTime)` | `ServerDateTimeParts` | Splits a **DateTime** into separate UTC date and time payload strings. |
| `fromServer(String)` | `DateTime` | Parses an **ISO 8601** UTC **server timestamp** into local time. |
| `fromServerParts(date, time)` | `DateTime` | Parses separate date and time strings, returning a local **DateTime**. |
| `normalizeServerTimestamp(String)` | `String` | Standardizes any API timestamp string to a clean UTC **ISO 8601** format. |

### 2. Flutter Timezone Utilities & UTC Helpers
| Method | Returns | Description |
|---------|---------|-------------|
| `toUtc(DateTime)` | `DateTime` | Safely converts a local **DateTime** to UTC (idempotent helper). |
| `fromUtc(DateTime)` | `DateTime` | Converts a UTC **DateTime** to local representation (strict validation). |
| `nowUtc()` | `DateTime` | Obtains the current clock timestamp in UTC. |

### 3. Core Date Extraction & Cloner Utilities
| Method | Returns | Description |
|---------|---------|-------------|
| `today()` | `DateTime` | Returns the start of the current local day (`00:00:00.000`). |
| `todayUtc()` | `DateTime` | Returns the start of the current UTC day (`00:00:00.000Z`). |
| `startOfDay(DateTime)` | `DateTime` | Sets time component to the start of the day (`00:00:00.000`). |
| `endOfDay(DateTime)` | `DateTime` | Sets time component to the end of the day (`23:59:59.999`). |
| `stripDate(DateTime)` | `String` | Extracts only the date string formatted as `yyyy-MM-dd`. |
| `stripTime(DateTime)` | `String` | Extracts only the time components as an ISO 8601 time string. |
| `copyWith(DateTime, ...)` | `DateTime` | Creates a copy of a **DateTime** with modified fields, preserving its timezone. |
| `combine(DateTime, DateTime)` | `DateTime` | Merges the date of one and time of another timezone-safely. |

### 4. Calendar Comparison Helpers
| Method | Returns | Description |
|---------|---------|-------------|
| `isSameDay(DateTime, DateTime)` | `bool` | Checks if two dates represent the same calendar day. |
| `isSameMonth(DateTime, DateTime)` | `bool` | Checks if two dates represent the same month and year. |
| `isSameYear(DateTime, DateTime)` | `bool` | Checks if two dates represent the same calendar year. |
| `daysInMonth(DateTime)` | `int` | Returns total days in a month (handling leap years). |
| `isLeapYear(int)` | `bool` | Checks if a given year is a leap year. |

### 5. DST-Safe Difference Calculators
| Method | Returns | Description |
|---------|---------|-------------|
| `daysBetween(DateTime, DateTime)` | `int` | Difference in calendar days between two dates. |
| `differenceInYears(DateTime, DateTime)` | `int` | Computes full elapsed calendar years between two dates. |
| `differenceInDays(DateTime, DateTime)` | `int` | Alias for `daysBetween()`. |
| `differenceInHours(DateTime, DateTime)` | `int` | Computes whole hours between two dates. |
| `differenceInMinutes(DateTime, DateTime)` | `int` | Computes whole minutes between two dates. |
| `differenceInSeconds(DateTime, DateTime)` | `int` | Computes whole seconds between two dates. |
| `differenceInMilliseconds(DateTime, DateTime)` | `int` | Computes whole milliseconds between two dates. |

### 6. Calendar Arithmetic & Bound Calculators
| Method | Returns | Description |
|---------|---------|-------------|
| `addDays(DateTime, int)` | `DateTime` | Adds/subtracts calendar days timezone-safely. |
| `previousDay(DateTime)` | `DateTime` | Shorthand to move 1 day backward. |
| `nextDay(DateTime)` | `DateTime` | Shorthand to move 1 day forward. |
| `addMonths(DateTime, int)` | `DateTime` | Adds/subtracts calendar months with valid day clamping (leap year safe). |
| `previousMonth(DateTime)` | `DateTime` | Shorthand to move 1 month backward. |
| `nextMonth(DateTime)` | `DateTime` | Shorthand to move 1 month forward. |
| `addYears(DateTime, int)` | `DateTime` | Adds/subtracts calendar years (handles February 29th rollover). |
| `previousYear(DateTime)` | `DateTime` | Shorthand to move 1 year backward. |
| `nextYear(DateTime)` | `DateTime` | Shorthand to move 1 year forward. |
| `addHours(DateTime, int)` | `DateTime` | Adds/subtracts hours. |
| `addMinutes(DateTime, int)` | `DateTime` | Adds/subtracts minutes. |
| `min(DateTime, DateTime)` | `DateTime` | Returns the earlier DateTime (throws on timezone mismatch). |
| `max(DateTime, DateTime)` | `DateTime` | Returns the later DateTime (throws on timezone mismatch). |
| `clamp(DateTime, DateTime, DateTime)` | `DateTime` | Clamps a DateTime between a min and max limit (throws on mismatch). |

### 7. Validation Helpers
| Method | Returns | Description |
|---------|---------|-------------|
| `isToday(DateTime)` | `bool` | Checks if a date falls on the current calendar day (same timezone). |
| `isTomorrow(DateTime)` | `bool` | Checks if a date falls on tomorrow's calendar day (same timezone). |
| `isYesterday(DateTime)` | `bool` | Checks if a date falls on yesterday's calendar day (same timezone). |
| `isPast(DateTime)` | `bool` | Checks if a date is in the past compared to now (same timezone). |
| `isFuture(DateTime)` | `bool` | Checks if a date is in the future compared to now (same timezone). |
| `isBetween(DateTime, DateTime, DateTime, {bool inclusive})` | `bool` | Checks if a value falls between start and end (throws on mismatch). |
| `isSameHour(DateTime, DateTime)` | `bool` | Checks if two dates fall on the same calendar hour (same timezone). |
| `isSameMinute(DateTime, DateTime)` | `bool` | Checks if two dates fall on the same calendar minute (same timezone). |
| `isSameSecond(DateTime, DateTime)` | `bool` | Checks if two dates fall on the same calendar second (same timezone). |
| `isStartOfDay(DateTime)` | `bool` | Checks if a date falls exactly at midnight (`00:00:00.000000`). |
| `isEndOfDay(DateTime)` | `bool` | Checks if a date falls exactly at the end of day (`23:59:59.999999`). |

### 8. Rounding APIs
| Method | Returns | Description |
|---------|---------|-------------|
| `floorToMinute(DateTime)` | `DateTime` | Rounds a DateTime down to the nearest minute, preserving timezone. |
| `ceilToMinute(DateTime)` | `DateTime` | Rounds a DateTime up to the nearest minute, preserving timezone. |
| `roundToMinute(DateTime)` | `DateTime` | Rounds a DateTime to the nearest minute mathematically. |
| `floorToHour(DateTime)` | `DateTime` | Rounds a DateTime down to the nearest hour, preserving timezone. |
| `ceilToHour(DateTime)` | `DateTime` | Rounds a DateTime up to the nearest hour, preserving timezone. |
| `roundToHour(DateTime)` | `DateTime` | Rounds a DateTime to the nearest hour mathematically. |
| `floorToDay(DateTime)` | `DateTime` | Rounds a DateTime down to start of day, preserving timezone. |
| `ceilToDay(DateTime)` | `DateTime` | Rounds a DateTime up to the next day's start, preserving timezone. |
| `roundToDay(DateTime)` | `DateTime` | Rounds a DateTime to the nearest day mathematically. |

---

## Detailed API Usage Examples

### 1. UTC Timezone Conversion & Normalization
```dart
import 'package:sync_datetime/sync_datetime.dart';

final DateTime local = DateTime.now();
final DateTime utc = SyncDateTime.toUtc(local);
print(utc); // 2026-08-03 05:46:31.000Z
```

### 2. Converting UTC Server Timestamps to Local Time
```dart
final DateTime utc = DateTime.utc(2026, 8, 2, 5, 50);
final DateTime local = SyncDateTime.fromUtc(utc);
print(local); 
```

### 3. Formatting Datetime Payloads for REST APIs & Databases
```dart
final DateTime appointment = DateTime.now();
final String payload = SyncDateTime.toServer(appointment);
print(payload); // '2026-08-03T05:46:31.000Z'
```

### 4. Day Normalization & DateTime Component Extraction
```dart
final DateTime today = SyncDateTime.today(); // 2026-08-03 00:00:00.000 (local)
final DateTime todayUtc = SyncDateTime.todayUtc(); // 2026-08-03 00:00:00.000Z

final DateTime start = SyncDateTime.startOfDay(DateTime.now()); // 00:00:00.000
final DateTime end = SyncDateTime.endOfDay(DateTime.now()); // 23:59:59.999999

// Extract string components cleanly
final String dateStr = SyncDateTime.stripDate(DateTime.now()); // "2026-08-03"
final String timeStr = SyncDateTime.stripTime(DateTime.now()); // "10:20:24.380"
```

---

## Search Intent Coverage: How-To Guides

### How do I convert local DateTime to UTC in Flutter?
To convert local time to UTC safely without redundant transformations, use the `toUtc()` method. If the input is already in UTC, it returns unchanged.
```dart
final DateTime local = DateTime.now();
final DateTime utc = SyncDateTime.toUtc(local);
```

### How do I convert UTC to local time?
To convert UTC back to the device's local timezone, use `fromUtc()`. The package strictly enforces timezone safety and throws an `ArgumentError` if the input is not in UTC.
```dart
final DateTime utc = DateTime.utc(2026, 8, 3, 10, 0);
final DateTime local = SyncDateTime.fromUtc(utc);
```

### How do I parse ISO 8601 timestamps?
To parse an **ISO 8601** string from a server payload, use `fromServer()`. If the backend timestamp misses timezone indicators (like 'Z' or offset), it is parsed as UTC to avoid local timezone offset shifts.
```dart
final DateTime local = SyncDateTime.fromServer('2026-08-02T12:00:00');
```

### How do I normalize timestamps?
To standardize varying server timestamp shapes to UTC format, use `normalizeServerTimestamp()`.
```dart
final String standardized = SyncDateTime.normalizeServerTimestamp('2026-08-02T14:00:00+02:00');
// '2026-08-02T10:00:00.000Z'
```

### How do I split DateTime into date and time?
For database designs that store dates and times as individual columns, use `toServerParts()`. It converts the input to UTC and outputs date and time strings.
```dart
final parts = SyncDateTime.toServerParts(DateTime.now());
print(parts.date); // '2026-08-03'
print(parts.time); // '05:46:31.000Z'
```

### How do I combine date and time?
Use `combine()` to construct a new **DateTime** using the date components of one instance and time components of another. It throws an `ArgumentError` if the timezones do not match.
```dart
final DateTime dateOnly = DateTime(2026, 8, 3);
final DateTime timeOnly = DateTime(2020, 1, 1, 14, 30);
final DateTime combined = SyncDateTime.combine(dateOnly, timeOnly);
```

### How do I compare dates without time?
Use `isSameDay()` to compare the calendar year, month, and day components of two dates while ignoring time components.
```dart
final bool sameDay = SyncDateTime.isSameDay(dateA, dateB);
```

### How do I compare DateTime safely?
To check if two **DateTime** values fall on the same day, month, or year, use `isSameDay()`, `isSameMonth()`, and `isSameYear()`. These methods protect your app by throwing an error if one argument is local and the other is UTC.
```dart
final bool same = SyncDateTime.isSameDay(localDate, localDate2);
```

### How do I compare months?
To compare whether two instances share the exact same month and year:
```dart
final bool sameMonth = SyncDateTime.isSameMonth(dateA, dateB);
```

### How do I compare years?
To compare whether two instances share the exact same year:
```dart
final bool sameYear = SyncDateTime.isSameYear(dateA, dateB);
```

### How do I strip time?
To get only the date portion as a string in `yyyy-MM-dd` format:
```dart
final String dateStr = SyncDateTime.stripDate(DateTime.now());
```

### How do I strip date?
To get only the time portion as an ISO 8601 compatible string:
```dart
final String timeStr = SyncDateTime.stripTime(DateTime.now());
```

### How do I calculate calendar days?
Calculating day differences using `duration.inDays` is error-prone because daylight saving transitions change day lengths (e.g. 23 or 25 hours), yielding incorrect calculations. `daysBetween()` strips time components and normalizes coordinates to UTC beforehand, ensuring a stable calendar calculation.
```dart
final int days = SyncDateTime.daysBetween(firstDate, secondDate);
```

### How do I calculate years between dates?
To calculate the total number of full elapsed calendar years between two dates:
```dart
final int years = SyncDateTime.differenceInYears(startDate, endDate);
```

### How do I calculate age?
Pass the birth date and today's date to `differenceInYears` to obtain the user's correct age, safe from timezone shifts.
```dart
final int age = SyncDateTime.differenceInYears(birthDate, SyncDateTime.today());
```

### How do I get start of day?
Get a new `DateTime` instance aligned to `00:00:00.000` while preserving local or UTC timezone details:
```dart
final DateTime start = SyncDateTime.startOfDay(DateTime.now());
```

### How do I get end of day?
Get a new `DateTime` instance aligned to `23:59:59.999999` while preserving local or UTC timezone details:
```dart
final DateTime end = SyncDateTime.endOfDay(DateTime.now());
```

### How do I store UTC timestamps?
Use `SyncDateTime.toServer(dateTime)` to convert local times to standard UTC ISO 8601 strings before saving them to remote databases.

### How do I avoid timezone bugs?
Avoid raw `DateTime` comparison operations. Enforce strict timezone matching by comparing dates only when both are UTC or both are local, which `sync_datetime` does by throwing on mismatch.

### How do I avoid DST issues?
Never perform date calculations by dividing milliseconds or durations directly. Project dates to UTC without time details, then perform calendar calculations using the helper methods.

### How do I serialize DateTime?
Serialize date objects to JSON strings using `toServer` or split them into date and time parts using `toServerParts`.

### How do I send UTC to REST API?
Convert any local time instance to UTC ISO 8601 format using `toServer` when preparing your HTTP body.

### How do I synchronize client and server time?
Standardize client-to-server operations: use `toServer` to send local inputs to the backend in UTC, and `fromServer` to convert UTC backend times to local representation on the device.

### How do I store timestamps in SQLite?
Convert inputs to UTC string format before database insertion using `normalizeServerTimestamp` or `toServer` to ensure clean, lexicographically sortable strings.

### How do I add days?
Add or subtract calendar days timezone-safely without mutating the original object:
```dart
final fiveDaysLater = SyncDateTime.addDays(DateTime.now(), 5);
```

### How do I add months safely?
Add months with automatic date clamping for months with fewer days:
```dart
final nextMonth = SyncDateTime.addMonths(DateTime(2026, 1, 31), 1); // 2026-02-28
```

### How do I add years safely?
Add years while correctly handling leap year boundaries:
```dart
final leapDayPlusYear = SyncDateTime.addYears(DateTime(2024, 2, 29), 1); // 2025-02-28
```

### How do I move to next month?
Get the exact time in the next month, clamping the day if necessary:
```dart
final nextMonth = SyncDateTime.nextMonth(DateTime.now());
```

### How do I move to previous month?
Get the exact time in the previous month, clamping the day if necessary:
```dart
final lastMonth = SyncDateTime.previousMonth(DateTime.now());
```

### How do I move to next year?
Get the exact time in the next year, handling leap year rollovers:
```dart
final nextYear = SyncDateTime.nextYear(DateTime.now());
```

### How do I clamp a DateTime?
Clamp a DateTime to fall within the specified min and max bounds:
```dart
final clamped = SyncDateTime.clamp(currentDate, minDate, maxDate);
```

### How do I get min/max DateTime?
Get the earlier or later of two timezone-compatible dates:
```dart
final earliest = SyncDateTime.min(dateA, dateB);
final latest = SyncDateTime.max(dateA, dateB);
```

### How do I check if a date is today?
Validate if a DateTime falls on the current calendar day:
```dart
final isToday = SyncDateTime.isToday(DateTime.now());
```

### How do I check if a date is tomorrow?
Validate if a DateTime falls on tomorrow:
```dart
final isTomorrow = SyncDateTime.isTomorrow(tomorrowDate);
```

### How do I check if a date is yesterday?
Validate if a DateTime falls on yesterday:
```dart
final isYesterday = SyncDateTime.isYesterday(yesterdayDate);
```

### How do I check if a date is in the past?
Check if a local or UTC DateTime is in the past relative to now:
```dart
final wasPast = SyncDateTime.isPast(pastDate);
```

### How do I check if a date is in the future?
Check if a local or UTC DateTime is in the future relative to now:
```dart
final isFuture = SyncDateTime.isFuture(futureDate);
```

### How do I check whether a date is between two dates?
Verify if a value lies within a start and end range (supports inclusive/exclusive bounds):
```dart
final between = SyncDateTime.isBetween(middleDate, startDate, endDate, inclusive: true);
```

### How do I compare hours?
Check if two timezone-compatible dates represent the same calendar hour:
```dart
final sameHour = SyncDateTime.isSameHour(dateA, dateB);
```

### How do I compare minutes?
Check if two timezone-compatible dates represent the same calendar minute:
```dart
final sameMinute = SyncDateTime.isSameMinute(dateA, dateB);
```

### How do I compare seconds?
Check if two timezone-compatible dates represent the same calendar second:
```dart
final sameSecond = SyncDateTime.isSameSecond(dateA, dateB);
```

### How do I detect start of day?
Check if a DateTime's time components are exactly at midnight (`00:00:00.000000`):
```dart
final isMidnight = SyncDateTime.isStartOfDay(dateTime);
```

### How do I detect end of day?
Check if a DateTime's time components are exactly at the end of the day (`23:59:59.999999`):
```dart
final isEndOfDay = SyncDateTime.isEndOfDay(dateTime);
```

---

## Why not just use Dart's DateTime?

Dart's built-in `DateTime` is an excellent low-level API, but it intentionally leaves many application-level concerns to developers.

`sync_datetime` adds higher-level utilities commonly required in production Flutter applications:

- predictable UTC serialization
- strict timezone validation
- client-server synchronization helpers
- ISO 8601 normalization
- DST-safe calendar calculations
- reusable DateTime utilities

It complements `DateTime`; it does not replace it.

---

## Comparison: sync_datetime vs. Native Dart DateTime

| Feature / Scenario | Native Dart `DateTime` | `SyncDateTime` Utility |
|---|---|---|
| **Ambiguous Timezones** | Silently performs implicit conversions, causing hard-to-detect bugs. | Throws strict `ArgumentError` when comparing mismatched timezones. |
| **Calendar Arithmetic** | Native `add()` with `Duration` is unsafe for months/years due to varying length (leap years, 28/30/31 days). | Type-safe `addDays()`, `addMonths()`, `addYears()` handle calendar math correctly. |
| **Validation Helpers** | Requires manual writing of multi-line component checks. | Native-like `isToday()`, `isTomorrow()`, `isYesterday()`, `isPast()`, and `isFuture()`. |
| **Boundary Helpers** | Manual instantiation of matching timezone components. | Built-in `startOfDay()`, `endOfDay()`, `clamp()`, `min()`, and `max()`. |
| **Missing Timezone Suffix** | `DateTime.parse()` assumes local timezone, distorting UTC times. | `fromServer()` assumes UTC, resolving standard REST API shapes correctly. |
| **DST Transitions** | Math based on `Duration.inDays` returns off-by-one errors on 23/25 hour days. | `daysBetween()` normalizes dates to UTC internally, guaranteeing correct calendar offsets. |
| **Component Cloning** | Custom builders are verbose and require manually checking timezone flags. | `copyWith()` updates fields while automatically preserving UTC/local status. |
| **Immutability** | Native `DateTime` is immutable but lacks clean copying methods. | Provides clean `copyWith` and helper operations without modification. |
| **Validation Strictness** | Soft verification: permits incorrect configurations, causing bugs later. | Defensive design: immediately throws `ArgumentError` or `FormatException`. |
| **Zero Dependencies** | Built-in. | Built-in and relies entirely on core library features. |

---

## Best Practices & Performance Notes

### Immutability & Memory Footprint
Every API within `sync_datetime` is stateless and side-effect free. It never mutates input `DateTime` objects. This allows safe reuse of constants and variables across asynchronous operations without worrying about state drifts.

### Thread Safety in Flutter UI
Since `copyWith` and conversion utilities are atomic, they can be safely called within Flutter widget trees, `ListBuilder` items, or background isolates without thread synchronization issues.

---

## Common Mistakes & Troubleshooting

### Common Mistake: Comparing UTC and Local DateTime Directly
Dart allows comparing UTC and local times using native operators (e.g. `utcTime.isBefore(localTime)`), which implicitly shifts timezones and easily hides bugs. 
* **Fix:** Use comparison utilities like `isSameDay` which will explicitly fail fast with an `ArgumentError` if timezones are mismatched.

### Troubleshooting: Missing `Z` suffix on server dates
When a server payload omits the UTC indicator (e.g. `2026-08-02T12:00:00`), Dart's default parser treats it as local time.
* **Fix:** Always use `SyncDateTime.fromServer()` to parse server response strings. It automatically normalizes dates to UTC timezone representation before rendering them locally.

---

## Version Compatibility

### SDK Compatibility
* **Dart SDK:** `^3.9.0`
* **Flutter SDK:** `^3.0.0` or higher

### Versioning Policy
`sync_datetime` strictly follows semantic versioning (SemVer).
* **Patch releases (0.x.Y):** Bug fixes and performance improvements.
* **Minor releases (0.Y.0):** Non-breaking API additions.
* **Major releases (X.0.0):** Breaking changes.



For detailed changes, view the [CHANGELOG.md](CHANGELOG.md).

---

## Contributing & License

Contributions, bug reports, feature suggestions, and documentation improvements are always welcome.

If you find an issue or have an idea for improvement, please open an issue or submit a pull request on the [GitHub repository](https://github.com/rahimuj570/sync_datetime).

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.