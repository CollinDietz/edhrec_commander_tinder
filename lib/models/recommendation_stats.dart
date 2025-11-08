class RecommendationStats {
  final num inclusion;
  final num potentialDecks;

  const RecommendationStats({
    required this.inclusion,
    required this.potentialDecks,
  });

  double get ratio => potentialDecks == 0 ? 0 : inclusion / potentialDecks;
  double get ratioPercent => ratio * 100;
}
