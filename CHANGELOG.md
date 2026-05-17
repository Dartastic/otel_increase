# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedIncrease<T>(...)` — wraps a otel_increase call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutIncreaseInstrumentation()` / `Async()`.
