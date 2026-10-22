// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_iot_core/otel_aws_iot_core.dart';

/// Traces Aws Iot Core calls with OpenTelemetry.
///
/// `otel_aws_iot_core` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Iot Core call in
/// [tracedAwsIoTCore]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-iot-core-example');

  // Traces a Aws Iot Core call.
  final awsIoTCoreId = await tracedAwsIoTCore<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Iot Core call here, then report what it returned.
      const id = 'aws_iot_core_8f3a2c';
      return const AwsIoTCoreCallResult(
          value: id,
          result: AwsIoTCoreResult(
              thingName: 'example',
              thingArn: 'example',
              thingType: 'standard',
              clientId: 'client_8f3a2c',
              topic: 'orders',
              ruleName: 'example',
              jobId: 'job_8f3a2c',
              shadowName: 'example',
              qos: 1,
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsIoTCore create returned $awsIoTCoreId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsIoTCoreInstrumentationAsync.
  await runWithoutAwsIoTCoreInstrumentationAsync(
    () => tracedAwsIoTCore<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_iot_core_8f3a2c';
        return const AwsIoTCoreCallResult(
            value: id,
            result: AwsIoTCoreResult(
                thingName: 'example',
                thingArn: 'example',
                thingType: 'standard',
                clientId: 'client_8f3a2c',
                topic: 'orders',
                ruleName: 'example',
                jobId: 'job_8f3a2c',
                shadowName: 'example',
                qos: 1,
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
