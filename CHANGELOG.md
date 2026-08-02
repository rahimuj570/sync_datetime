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
