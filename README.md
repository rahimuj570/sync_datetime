# sync_datetime

[![pub package](https://img.shields.io/pub/v/sync_datetime.svg)](https://pub.dev/packages/sync_datetime)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Language: Dart](https://img.shields.io/badge/language-Dart-blue)](https://dart.dev/)

A lightweight, dependency-free Dart package for reliable, predictable, and minimal-boilerplate DateTime synchronization between client applications (local time) and backend servers (UTC).

---

## ✨ Why sync_datetime?

Handling `DateTime` correctly across mobile apps and backend APIs is harder than it looks.

Common problems include:

- Sending local time to a server that expects UTC.
- Parsing UTC timestamps without timezone indicators.
- Accidentally mixing UTC and local `DateTime` objects.
- Writing the same timezone conversion boilerplate throughout your application.

`sync_datetime` provides a small, focused API that makes these operations predictable, safe, and easy to read.

---

## 🚀 Quick Example

```dart
import 'package:sync_datetime/sync_datetime.dart';

// Local meeting time
final meeting = DateTime.now();

// Send to server (UTC ISO8601)
final payload = SyncDateTime.toServer(meeting);

// Receive from server
final localMeeting = SyncDateTime.fromServer(payload);

// Combine date & time
final appointment = SyncDateTime.combine(
  DateTime.now(),
  DateTime.now(),
);
```

No timezone boilerplate.
No hidden conversions.
Just predictable behavior.

---

## 🎯 Philosophy

> **Simple APIs. Predictable behavior. Zero surprises.**

`sync_datetime` intentionally prefers explicit behavior over silent conversions.

When an operation is ambiguous—for example, combining a UTC `DateTime` with a local `DateTime`—the package throws an error instead of guessing.

This approach helps prevent subtle timezone-related bugs that can be difficult to detect in production.

---

## ✨ Features

- ✅ Idempotent UTC normalization
- ✅ Safe UTC ⇄ Local conversion
- ✅ Reliable server serialization/deserialization
- ✅ Handles ISO 8601 strings with or without timezone indicators
- ✅ Safe Date & Time combination
- ✅ Defensive API design with clear exceptions
- ✅ Zero external dependencies
- ✅ Built entirely on top of the Dart SDK

---

## 📦 Installation

Add the package to your project:

```yaml
dependencies:
  sync_datetime: ^0.1.3
```

or run:

```bash
dart pub add sync_datetime
```

---

## 📚 API Overview

| Method | Description |
|---------|-------------|
| `toUtc()` | Converts a local `DateTime` to UTC. |
| `fromUtc()` | Converts a UTC `DateTime` to local time. |
| `toServer()` | Converts a `DateTime` to a UTC ISO 8601 string for APIs. |
| `fromServer()` | Safely parses UTC server timestamps into local time. |
| `fromServerParts()` | Parses separate date and time strings from the server. |
| `combine()` | Combines the date from one `DateTime` with the time from another. |

---

# Usage

## 1. Convert Local Time to UTC

Safely converts local `DateTime` values to UTC.

```dart
import 'package:sync_datetime/sync_datetime.dart';

final local = DateTime.now();

final utc = SyncDateTime.toUtc(local);

print(utc);
```

If the input is already UTC, it is returned unchanged.

---

## 2. Convert UTC to Local

Converts UTC back to the device's local timezone.

```dart
final utc = DateTime.utc(2026, 8, 2, 5, 50);

final local = SyncDateTime.fromUtc(utc);

print(local);
```

Passing a non-UTC `DateTime` throws an `ArgumentError` to prevent accidental misuse.

---

## 3. Serialize Before Sending to Server

Convert any `DateTime` into a UTC ISO 8601 string.

```dart
final appointment = DateTime.now();

final payload = SyncDateTime.toServer(appointment);

print(payload);

// 2026-08-02T05:50:00.000Z
```

Perfect for REST APIs, GraphQL, Firebase, Supabase, and similar backends.

---

## 4. Parse Server Timestamps

Most servers return UTC timestamps.

```dart
final meeting = SyncDateTime.fromServer(
  '2026-08-02T05:50:00.000Z',
);
```

The package also supports timestamps **without** timezone indicators.

```dart
final meeting = SyncDateTime.fromServer(
  '2026-08-02T05:50:00.000',
);
```

Unlike Dart's default `DateTime.parse()`, timestamps without a timezone suffix are assumed to represent **UTC**, making them safe for common backend API responses.

---

## 5. Parse Separate Server Date & Time Parts

Many APIs separate date and time values. `fromServerParts()` combines them dynamically and normalizes to local time:

```dart
final meeting = SyncDateTime.fromServerParts(
  date: '2026-08-02',
  time: '08:49:50.551Z', // Supports explicit & implicit UTC
);
```

---

## 6. Combine Date & Time

Create a single `DateTime` from separate date and time values.

```dart
final date = DateTime(2026, 8, 2);

final time = DateTime(
  2020,
  1,
  1,
  14,
  30,
);

final appointment = SyncDateTime.combine(
  date,
  time,
);

print(appointment);

// 2026-08-02 14:30:00.000
```

Both arguments must use the same timezone type (both local or both UTC).

---

# 💼 Real World Example

Scheduling an appointment.

```dart
final appointment = SyncDateTime.combine(
  selectedDate,
  selectedTime,
);

// Send to backend
await api.createAppointment(
  scheduledAt: SyncDateTime.toServer(appointment),
);

// Receive later
final meeting = SyncDateTime.fromServer(
  response.scheduledAt,
);

print(meeting);
```

---

## 🛣️ Roadmap

The API is intentionally kept small and focused.

Future releases may include:

- Safe parsing helpers (`tryParse`)
- UTC & local convenience methods
- Semantic date comparisons
- Additional formatting helpers
- Carefully selected timezone utilities

New functionality will only be added if it aligns with the package philosophy of **predictable DateTime synchronization**.

---

## 🤝 Contributing

Contributions, bug reports, feature suggestions, and documentation improvements are always welcome.

If you find an issue or have an idea for improvement, please open an issue or submit a pull request.

---

## 📄 License

This project is licensed under the **MIT License**.

See the [LICENSE](LICENSE) file for details.