// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'increase')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.groupId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('increase.group.id', res.groupId!)]));
      }
      if (res.entityId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('increase.entity.id', res.entityId!)]));
      }
      if (res.accountId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('increase.account.id', res.accountId!)]));
      }
      if (res.accountNumberId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            'increase.account_number.id',
            res.accountNumberId!,
          )
        ]));
      }
      if (res.transferId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('increase.transfer.id', res.transferId!)]));
      }
      if (res.transferType != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('increase.transfer.type', res.transferType!)
        ]));
      }
      if (res.amount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('increase.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('increase.currency', res.currency!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('increase.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('increase.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
