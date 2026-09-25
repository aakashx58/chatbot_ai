import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai/features/chat/data/engine/expression_evaluator.dart';

void main() {
  const evaluator = ExpressionEvaluator();

  group('ExpressionEvaluator', () {
    final cases = <String, double>{
      '2+2': 4,
      '2 + 3 * 4': 14,
      '(2 + 3) * 4': 20,
      '10 / 4': 2.5,
      '2 ^ 3 ^ 2': 512, // right-associative
      '-3 + 5': 2,
      '-(2 + 3)': -5,
      '10 % 3': 1,
      '1.5 * 2': 3,
    };

    for (final MapEntry(key: expression, value: expected) in cases.entries) {
      test('evaluates "$expression" to $expected', () {
        expect(evaluator.tryEvaluate(expression), expected);
      });
    }

    for (final invalid in ['', '2 +', '(1 + 2', '1 / 0', 'abc', '1 2']) {
      test('returns null for invalid "$invalid"', () {
        expect(evaluator.tryEvaluate(invalid), isNull);
      });
    }
  });
}
