import 'package:flutter_test/flutter_test.dart';
import 'package:roshetta_ai/core/utils/validators.dart';
import 'package:roshetta_ai/core/utils/formatters.dart';
import 'package:roshetta_ai/core/network/api_result.dart';

void main() {
  group('Validators', () {
    test('email rejects invalid addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
    });

    test('password enforces minimum length', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('longenoughpassword'), isNull);
    });

    test('confirmPassword matches original', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
      expect(Validators.confirmPassword('abc12345', 'different'), isNotNull);
    });
  });

  group('Formatters', () {
    test('confidencePercent clamps and rounds correctly', () {
      expect(Formatters.confidencePercent(0.873), 87);
      expect(Formatters.confidencePercent(1.4), 100);
      expect(Formatters.confidencePercent(-0.2), 0);
    });

    test('initials extracts first letters of up to two name parts', () {
      expect(Formatters.initials('أحمد الزبون'), 'أا');
      expect(Formatters.initials('Single'), 'S');
    });
  });

  group('ApiResult', () {
    test('Success.when calls the success branch', () {
      const result = Success<int>(42);
      final mapped = result.when(success: (data) => data * 2, failure: (_) => -1);
      expect(mapped, 84);
    });

    test('Error.when calls the failure branch', () {
      final result = Error<int>(Failure.network());
      final mapped = result.when(success: (_) => -1, failure: (f) => f.type);
      expect(mapped, FailureType.network);
    });
  });
}
