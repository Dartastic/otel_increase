// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_increase_suppression.dart';

class IncreaseResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class IncreaseCallResult<T> {
  /// Creates a call result.
  const IncreaseCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final IncreaseResult? result;
}

Future<T> tracedIncrease<T>({
  required String operation,
  required Future<IncreaseCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (increaseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_increase');
  final span = t.startSpan('increase $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'increase')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.groupId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('increase.group.id', res.groupId!)]));
      }
      if (res.entityId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('increase.entity.id', res.entityId!)]));
      }
      if (res.accountId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('increase.account.id', res.accountId!)]));
      }
      if (res.accountNumberId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'increase.account_number.id',
            res.accountNumberId!,
          )
        ]));
      }
      if (res.transferId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('increase.transfer.id', res.transferId!)
        ]));
      }
      if (res.transferType != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('increase.transfer.type', res.transferType!)
        ]));
      }
      if (res.amount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('increase.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('increase.currency', res.currency!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('increase.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('increase.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'increase.error',
          )
        ]));
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
