// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_iot_core_suppression.dart';

class AwsIoTCoreResult {
  /// Creates a result.
  const AwsIoTCoreResult({
    this.thingName,
    this.thingArn,
    this.thingType,
    this.clientId,
    this.topic,
    this.ruleName,
    this.jobId,
    this.shadowName,
    this.qos,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? thingName;
  final String? thingArn;
  final String? thingType;
  final String? clientId;
  final String? topic;
  final String? ruleName;
  final String? jobId;
  final String? shadowName;
  final int? qos;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AwsIoTCoreCallResult<T> {
  /// Creates a call result.
  const AwsIoTCoreCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AwsIoTCoreResult? result;
}

Future<T> tracedAwsIoTCore<T>({
  required String operation,
  required Future<AwsIoTCoreCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (awsIoTCoreInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_aws_iot_core');
  final span = t.startSpan('iot $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'aws-api')]));
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.service', 'IoT')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('messaging.system', 'aws_iot')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.thingName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('iot.thing.name', res.thingName!)]));
      }
      if (res.thingArn != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('iot.thing.arn', res.thingArn!)]));
      }
      if (res.thingType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('iot.thing.type', res.thingType!)]));
      }
      if (res.clientId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('messaging.client_id', res.clientId!)]));
      }
      if (res.topic != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('messaging.destination.name', res.topic!)
        ]));
      }
      if (res.ruleName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.iot.rule.name', res.ruleName!)]));
      }
      if (res.jobId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.iot.job.id', res.jobId!)]));
      }
      if (res.shadowName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.iot.shadow.name', res.shadowName!)]));
      }
      if (res.qos != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('messaging.kafka.message.priority', res.qos!)
        ]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('iot.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'iot.error',
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
