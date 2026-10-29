// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_increase/otel_increase.dart';

/// Traces Increase calls with OpenTelemetry.
///
/// `otel_increase` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Increase call in
/// [tracedIncrease]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'increase-example');

  // Traces a Increase call.
  final increaseId = await tracedIncrease<String>(
    operation: 'create',
    invoke: () async {
      // Make the Increase call here, then report what it returned.
      const id = 'increase_8f3a2c';
      return const IncreaseCallResult(
          value: id,
          result: IncreaseResult(
              groupId: 'group_8f3a2c',
              entityId: 'entity_8f3a2c',
              accountId: 'account_8f3a2c',
              accountNumberId: 'accountnumber_8f3a2c',
              transferId: 'transfer_8f3a2c',
              transferType: 'standard',
              amount: 0.5,
              currency: 'usd',
              status: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedIncrease create returned $increaseId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutIncreaseInstrumentationAsync.
  await runWithoutIncreaseInstrumentationAsync(
    () => tracedIncrease<String>(
      operation: 'create',
      invoke: () async {
        const id = 'increase_8f3a2c';
        return const IncreaseCallResult(
            value: id,
            result: IncreaseResult(
                groupId: 'group_8f3a2c',
                entityId: 'entity_8f3a2c',
                accountId: 'account_8f3a2c',
                accountNumberId: 'accountnumber_8f3a2c',
                transferId: 'transfer_8f3a2c',
                transferType: 'standard',
                amount: 0.5,
                currency: 'usd',
                status: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
