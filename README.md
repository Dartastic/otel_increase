# otel_increase

Dartastic OpenTelemetry bridge for Increase (banking-as-a-service).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_increase/otel_increase.dart';

await tracedIncrease<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return IncreaseCallResult(value: r, result: IncreaseResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutIncreaseInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
