// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

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
