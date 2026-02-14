import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/features/auth/domain/value_objects/phone_number.dart';

void main() {
  group('PhoneNumber.normalize', () {
    test('keeps valid E.164 as is', () {
      expect(PhoneNumber.normalize('+9647000000000'), '+9647000000000');
    });

    test('normalizes Iraqi local format 07xxxxxxxxx', () {
      expect(PhoneNumber.normalize('07912345678'), '+9647912345678');
    });

    test('normalizes international prefix 00...', () {
      expect(PhoneNumber.normalize('009647000000000'), '+9647000000000');
    });

    test('normalizes number starting with country code without plus', () {
      expect(PhoneNumber.normalize('9647000000000'), '+9647000000000');
    });

    test('rejects invalid values', () {
      expect(PhoneNumber.normalize(''), isNull);
      expect(PhoneNumber.normalize('abc'), isNull);
      expect(PhoneNumber.normalize('+123'), isNull);
      expect(PhoneNumber.normalize('+15551234567'), isNull);
    });
  });
}
