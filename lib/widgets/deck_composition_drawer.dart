import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

class DeckCompositionDrawer extends StatelessWidget {
  final DeckController deckCtrl;
  const DeckCompositionDrawer({super.key, required this.deckCtrl});

  static final _categories = <_CatSpec>[
    _CatSpec('Creature', Colors.green, (t) => t.contains('Creature')),
    _CatSpec('Instant', Colors.blue, (t) => t.contains('Instant')),
    _CatSpec('Sorcery', Colors.deepPurple, (t) => t.contains('Sorcery')),
    _CatSpec('Artifact', Colors.grey, (t) => t.contains('Artifact')),
    _CatSpec('Enchantment', Colors.pink, (t) => t.contains('Enchantment')),
    _CatSpec('Planeswalker', Colors.orange, (t) => t.contains('Planeswalker')),
    _CatSpec('Land', Colors.brown, (t) => t.contains('Land')),
  ];

  @override
  Widget build(BuildContext context) {
    // Re-read in case deck updated while open.
    final controller = context.watch<DeckController>();
    final List<CardInfo> cards = [
      ...controller.deck,
      ...controller.basics,
      if (controller.commander != null) controller.commander!.cardInfo,
    ];
    final totalTarget = 99.0;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_graph,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Deck Composition',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final spec = _categories[i];
                    final count = cards
                        .where((c) => spec.predicate(c.type))
                        .length;
                    final pct = count / totalTarget;
                    return _CategoryTile(
                      spec: spec,
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

class _CatSpec {
  final String label;
  final Color color;
  final bool Function(String) predicate;
  const _CatSpec(this.label, this.color, this.predicate);
}

class _CategoryTile extends StatelessWidget {
  final _CatSpec spec;
  final int count;
  final double percent;
  const _CategoryTile({
    required this.spec,
    required this.count,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: spec.color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: spec.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  spec.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('$count', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: percent.clamp(0, 1),
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation(spec.color),
            ),
          ),
        ],
      ),
    );
  }
}
