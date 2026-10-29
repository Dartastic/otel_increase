// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_increase/otel_increase.dart';
import 'package:test/test.dart';

void main() {
  group('otel_increase', () {
    test('suppression toggles in zone', () async {
      expect(increaseInstrumentationSuppressed(), isFalse);
      await runWithoutIncreaseInstrumentationAsync(() async {
        expect(increaseInstrumentationSuppressed(), isTrue);
      });
      expect(increaseInstrumentationSuppressed(), isFalse);
    });

    test('IncreaseResult fields default null', () {
      const r = IncreaseResult();
      expect(r.statusCode, isNull);
    });
  });
}
