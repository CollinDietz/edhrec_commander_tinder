import 'package:edhrec_commander_tinder/widgets/categories_progress.dart';
import 'package:edhrec_commander_tinder/widgets/mana_curve.dart';
import 'package:edhrec_commander_tinder/widgets/tags_progress.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

class StatsPanel extends StatelessWidget {
  final DeckController deckCtrl;
  const StatsPanel({super.key, required this.deckCtrl});

  @override
  Widget build(BuildContext context) {
    // Re-read in case deck updated while open.
    final controller = context.watch<DeckController>();
    final List<CardInfo> cards = [
      ...controller.deck,
      ...controller.basics,
      if (controller.commander != null) controller.commander!.cardInfo,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _Section(
                title: "Tags",
                subtitle: "Counts of cards in important tags",
                child: TagsProgress(cards: cards),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Type',
                subtitle: 'Counts of cards in each primary type',
                child: CategoriesProgress(cards: cards),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Mana Curve',
                subtitle: 'Distribution by mana value',
                child: ManaCurve(cards: cards),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
