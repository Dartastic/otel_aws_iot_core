// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_aws_iot_core/otel_aws_iot_core.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_iot_core', () {
    test('suppression toggles in zone', () async {
      expect(awsIoTCoreInstrumentationSuppressed(), isFalse);
      await runWithoutAwsIoTCoreInstrumentationAsync(() async {
        expect(awsIoTCoreInstrumentationSuppressed(), isTrue);
      });
      expect(awsIoTCoreInstrumentationSuppressed(), isFalse);
    });

    test('AwsIoTCoreResult fields default null', () {
      const r = AwsIoTCoreResult();
      expect(r.statusCode, isNull);
    });
  });
}
