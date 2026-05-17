# otel_aws_iot_core

Dartastic OpenTelemetry bridge for AWS IoT Core (device connectivity + rules + jobs).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_iot_core/otel_aws_iot_core.dart';

await tracedAwsIoTCore<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsIoTCoreCallResult(value: r, result: AwsIoTCoreResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsIoTCoreInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
