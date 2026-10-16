import 'package:flutter_test/flutter_test.dart';
import 'package:beecount/utils/kelly_calculator.dart';

void main() {
  test('computes Kelly stake with unit payout odds', () {
    expect(
      kellyFraction(winProbability: 0.6, netWinPerLoss: 1),
      closeTo(0.2, 1e-10),
    );
  });

  test('returns zero when there is no positive edge', () {
    expect(kellyFraction(winProbability: 0.5, netWinPerLoss: 1), 0);
    expect(kellyFraction(winProbability: 0.4, netWinPerLoss: 1), 0);
  });

  test('uses net win to loss ratio', () {
    expect(
      kellyFraction(winProbability: 0.4, netWinPerLoss: 2),
      closeTo(0.1, 1e-10),
    );
  });
}
