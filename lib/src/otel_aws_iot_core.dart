// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_iot_core_suppression.dart';

class AwsIoTCoreResult {
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

class AwsIoTCoreCallResult<T> {
  const AwsIoTCoreCallResult({required this.value, this.result});
  final T value;
  final AwsIoTCoreResult? result;
}

Future<T> tracedAwsIoTCore<T>({
  required String operation,
  required Future<AwsIoTCoreCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsIoTCoreInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_iot_core');
  final span = t.startSpan('iot $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'aws-api');
    span.setStringAttribute('rpc.service', 'IoT');
    span.setStringAttribute('messaging.system', 'aws_iot');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.thingName != null) {
        span.setStringAttribute('iot.thing.name', res.thingName!);
      }
      if (res.thingArn != null) {
        span.setStringAttribute('iot.thing.arn', res.thingArn!);
      }
      if (res.thingType != null) {
        span.setStringAttribute('iot.thing.type', res.thingType!);
      }
      if (res.clientId != null) {
        span.setStringAttribute('messaging.client_id', res.clientId!);
      }
      if (res.topic != null) {
        span.setStringAttribute('messaging.destination.name', res.topic!);
      }
      if (res.ruleName != null) {
        span.setStringAttribute('aws.iot.rule.name', res.ruleName!);
      }
      if (res.jobId != null) {
        span.setStringAttribute('aws.iot.job.id', res.jobId!);
      }
      if (res.shadowName != null) {
        span.setStringAttribute('aws.iot.shadow.name', res.shadowName!);
      }
      if (res.qos != null) {
        span.setIntAttribute('messaging.kafka.message.priority', res.qos!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('iot.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'iot.error',
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
