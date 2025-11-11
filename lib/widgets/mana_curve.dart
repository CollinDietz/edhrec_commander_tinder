import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

/// Displays a mana value distribution for a list of cards.
/// Buckets:
///  0-1, >1-2, >2-3, >3-4, >4-5, >5-6, >6-7, >7-8, >8
class ManaCurve extends StatelessWidget {
  final List<CardInfo> cards;
  final double barHeight;
  final EdgeInsets padding;
  const ManaCurve({
    super.key,
    required this.cards,
    this.barHeight = 18,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final buckets = _buildBuckets(cards);
    final total = buckets.fold<int>(0, (p, e) => p + e.count);
    final nonZero = cards.where((c) => c.mana_cost > 0).toList();
    final double average = nonZero.isEmpty
        ? 0
        : nonZero.map((c) => c.mana_cost).fold<double>(0, (p, v) => p + v) /
              nonZero.length;
    final maxCount = buckets
        .map((b) => b.count)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(total: total, average: average),
          const SizedBox(height: 8),
          for (final b in buckets)
            _BucketRow(bucket: b, maxCount: maxCount, barHeight: barHeight),
        ],
      ),
    );
  }

  List<_Bucket> _buildBuckets(List<CardInfo> cards) {
    int c(double minIncl, double maxIncl) => cards
        .where((c) => c.mana_cost > minIncl && c.mana_cost <= maxIncl)
        .length;
    int o(double minExcl, double maxIncl) => cards
        .where((c) => c.mana_cost > minExcl && c.mana_cost <= maxIncl)
        .length;
    int g(double minExcl) => cards.where((c) => c.mana_cost > minExcl).length;

    return [
      _Bucket(label: '1', count: c(0, 1)),
      _Bucket(label: '2', count: o(1, 2)),
      _Bucket(label: '3', count: o(2, 3)),
      _Bucket(label: '4', count: o(3, 4)),
      _Bucket(label: '5', count: o(4, 5)),
      _Bucket(label: '6', count: o(5, 6)),
      _Bucket(label: '7', count: o(6, 7)),
      _Bucket(label: '8+', count: g(7)),
    ];
  }
}

class _Bucket {
  final String label;
  final int count;
  const _Bucket({required this.label, required this.count});
}

class _Header extends StatelessWidget {
  final int total;
  final double average;
  const _Header({required this.total, required this.average});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Avg: ${average.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _BucketRow extends StatelessWidget {
  final _Bucket bucket;
  final int maxCount;
  final double barHeight;
  const _BucketRow({
    required this.bucket,
    required this.maxCount,
    required this.barHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double fraction = maxCount == 0 ? 0 : bucket.count / maxCount;
    final color = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              bucket.label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    minHeight: barHeight,
                    value: fraction,
                    backgroundColor: theme.colorScheme.surfaceVariant
                        .withOpacity(0.4),
                    valueColor: AlwaysStoppedAnimation(
                      // Preserve slight gradient feel by tweaking opacity if desired.
                      color,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        bucket.count.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: fraction > 0.18
                              ? Colors.white
                              : theme.colorScheme.onSurface.withOpacity(0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
