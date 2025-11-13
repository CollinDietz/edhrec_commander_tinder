import 'package:edhrec_commander_tinder/models/card_info.dart';
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
    final cs = Theme.of(context).colorScheme;
    // Build a dynamic color map aligned with current theme palette.
    final categoryColors = <String, Color>{
      'Creature': cs.secondary,
      'Instant': cs.primary,
      'Sorcery': cs.tertiary,
      'Artifact': cs.outlineVariant,
      'Enchantment': cs.primaryContainer,
      'Planeswalker': cs.secondaryContainer,
      'Land': cs.surfaceTint, // subtle accent
    };

    return Column(
      children: [
        for (final entry in categoryCounts.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _CategoryProgress(
              category: entry.key,
              color: categoryColors[entry.key] ?? cs.onSurfaceVariant,
              count: cards.where((c) => c.type == entry.key).length,
              total: entry.value,
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
                  style:
                      theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ) ??
                      const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$count of ${categoryCounts[category]!}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
