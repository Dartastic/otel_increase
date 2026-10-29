// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'dart:async';

const _key = #dartastic_otel_libs_increase_suppress;

/// Whether instrumentation is suppressed in the current zone.
bool increaseInstrumentationSuppressed() => Zone.current[_key] == true;

/// Runs [body] without creating spans for calls made inside it.
T runWithoutIncreaseInstrumentation<T>(T Function() body) =>
    runZoned(body, zoneValues: {_key: true});

/// Runs [body] without creating spans for calls made inside it.
Future<T> runWithoutIncreaseInstrumentationAsync<T>(
  Future<T> Function() body,
) =>
    runZoned(body, zoneValues: {_key: true});
