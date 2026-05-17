// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_increase_suppression.dart';

class IncreaseResult {
  const IncreaseResult({
    this.groupId,
    this.entityId,
    this.accountId,
    this.accountNumberId,
    this.transferId,
    this.transferType,
    this.amount,
    this.currency,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? groupId;
  final String? entityId;
  final String? accountId;
  final String? accountNumberId;
  final String? transferId;
  final String? transferType;
  final double? amount;
  final String? currency;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class IncreaseCallResult<T> {
  const IncreaseCallResult({required this.value, this.result});
  final T value;
  final IncreaseResult? result;
}

Future<T> tracedIncrease<T>({
  required String operation,
  required Future<IncreaseCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (increaseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_increase');
  final span = t.startSpan('increase $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'increase');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.groupId != null) {
        span.setStringAttribute('increase.group.id', res.groupId!);
      }
      if (res.entityId != null) {
        span.setStringAttribute('increase.entity.id', res.entityId!);
      }
      if (res.accountId != null) {
        span.setStringAttribute('increase.account.id', res.accountId!);
      }
      if (res.accountNumberId != null) {
        span.setStringAttribute(
          'increase.account_number.id',
          res.accountNumberId!,
        );
      }
      if (res.transferId != null) {
        span.setStringAttribute('increase.transfer.id', res.transferId!);
      }
      if (res.transferType != null) {
        span.setStringAttribute('increase.transfer.type', res.transferType!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('increase.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('increase.currency', res.currency!);
      }
      if (res.status != null) {
        span.setStringAttribute('increase.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('increase.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'increase.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
