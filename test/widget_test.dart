// This is a basic Flutter test file.
// A simple unit test that doesn't require complex app initialization.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic unit tests', () {
    test('String manipulation test', () {
      const input = 'mobile-dev';
      final flavor = input.split('-').last;
      expect(flavor, equals('dev'));
    });

    test('List operations test', () {
      final numbers = [1, 2, 3, 4, 5];
      final evenNumbers = numbers.where((n) => n % 2 == 0).toList();
      expect(evenNumbers, equals([2, 4]));
    });

    test('Math operations test', () {
      expect(2 + 2, equals(4));
      expect(10 / 2, equals(5.0));
    });
  });
}
