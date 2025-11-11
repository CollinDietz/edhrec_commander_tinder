import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/category_tile.dart';
import 'package:flutter/material.dart';

const categoryCounts = <String, int>{
  'Creature': 26,
  'Instant': 10,
  'Sorcery': 10,
  'Artifact': 8,
  'Enchantment': 6,
  'Planeswalker': 3,
  'Land': 38,
};

class CategoriesProgress extends StatelessWidget {
  final List<CardInfo> cards;
  const CategoriesProgress({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final spec in categoryColors.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _CategoryProgress(
              category: spec.key,
              color: spec.value,
              count: cards.where((c) => c.type == spec.key).length,
              total: categoryCounts[spec.key]!,
            ),
          ),
      ],
    );
  }
}

class _CategoryProgress extends StatelessWidget {
  final String category;
  final Color color;
  final int count;
  final int total;
  const _CategoryProgress({
    required this.category,
    required this.color,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$count of ${categoryCounts[category]!}',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: (count / total).clamp(0, 1),
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                0.4,
              ),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
