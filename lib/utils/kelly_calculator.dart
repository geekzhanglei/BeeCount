/// Returns the Kelly fraction of bankroll for a binary outcome.
/// [netWinPerLoss] is the net profit for each unit of loss risked.
double kellyFraction({
  required double winProbability,
  required double netWinPerLoss,
}) {
  if (winProbability < 0 || winProbability > 1 || netWinPerLoss <= 0) {
    return 0;
  }
  final lossProbability = 1 - winProbability;
  return ((netWinPerLoss * winProbability - lossProbability) / netWinPerLoss)
      .clamp(0.0, 1.0);
}
