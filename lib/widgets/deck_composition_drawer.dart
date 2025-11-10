import 'package:edhrec_commander_tinder/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

const categoryCounts = <String, int>{
  'Creature': 26,
  'Instant': 10,
  'Sorcery': 10,
  'Artifact': 8,
  'Enchantment': 6,
  'Planeswalker': 3,
  'Land': 38,
};

class DeckCompositionDrawer extends StatelessWidget {
  final DeckController deckCtrl;
  const DeckCompositionDrawer({super.key, required this.deckCtrl});

  Widget _titleRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.query_stats, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'Deck Composition',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-read in case deck updated while open.
    final controller = context.watch<DeckController>();
    final List<CardInfo> cards = [
      ...controller.deck,
      ...controller.basics,
      if (controller.commander != null) controller.commander!.cardInfo,
    ];

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleRow(context),
              const Divider(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: categoryColors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final spec = categoryColors.entries.elementAt(i);
                    final count = cards.where((c) => c.type == spec.key).length;
                    final pct = count / categoryCounts[spec.key]!;
                    return _CategoryProgress(
                      category: spec.key,
                      color: spec.value,
                      count: count,
                      percent: pct,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryProgress extends StatelessWidget {
  final String category;
  final Color color;
  final int count;
  final double percent;
  const _CategoryProgress({
    required this.category,
    required this.color,
    required this.count,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CategoryTile(
      category: category,
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
              value: percent.clamp(0, 1),
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
