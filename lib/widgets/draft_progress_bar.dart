import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'cost_label.dart';
import 'count_label.dart';
import 'deck_progress_indicator.dart';
import 'finish_button.dart';

/// Category specification for modular progress rendering.
class CardCategorySpec {
  final String label;
  final Color color;
  final bool Function(String typeLine) predicate;
  CardCategorySpec({
    required this.label,
    required this.color,
    required this.predicate,
  });
}

/// DraftProgressBar
/// A compact status bar showing:
///  * Current total card count (including basics) out of the 99 target.
///  * Linear progress indicator.
///  * A Finish button to end the draft early.
///
/// Keeps all layout concerns local and minimizes inline arithmetic noise
/// by extracting derived values.
class DraftProgressBar extends StatefulWidget {
  final ValueChanged<bool>? onExpandedChanged;
  const DraftProgressBar({super.key, this.onExpandedChanged});

  static const int targetDeckSize = 99;

  static final List<CardCategorySpec> categories = [
    CardCategorySpec(
      label: 'Creature',
      color: Colors.green,
      predicate: (t) => t.contains('Creature'),
    ),
    CardCategorySpec(
      label: 'Instant',
      color: Colors.blue,
      predicate: (t) => t.contains('Instant'),
    ),
    CardCategorySpec(
      label: 'Sorcery',
      color: Colors.deepPurple,
      predicate: (t) => t.contains('Sorcery'),
    ),
    CardCategorySpec(
      label: 'Artifact',
      color: Colors.grey,
      predicate: (t) => t.contains('Artifact'),
    ),
    CardCategorySpec(
      label: 'Enchantment',
      color: Colors.pink,
      predicate: (t) => t.contains('Enchantment'),
    ),
    CardCategorySpec(
      label: 'Planeswalker',
      color: Colors.orange,
      predicate: (t) => t.contains('Planeswalker'),
    ),
    CardCategorySpec(
      label: 'Land',
      color: Colors.brown,
      predicate: (t) => t.contains('Land'),
    ),
  ];

  @override
  State<DraftProgressBar> createState() => _DraftProgressBarState();
}

class _DraftProgressBarState extends State<DraftProgressBar>
    with TickerProviderStateMixin {
  bool _expanded = false;
  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    widget.onExpandedChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeckController>();
    final basicsCount = controller.basics.length;
    final deckCount = controller.deck.length;
    final totalCount = basicsCount + deckCount;
    final progress = totalCount / DraftProgressBar.targetDeckSize;
    final cost =
        controller.deck.fold<num>(0, (sum, card) => sum + card.price) +
        controller.basics.fold<num>(0, (sum, card) => sum + card.price) +
        (controller.commander?.cardInfo.price ?? 0);

    final allCards = [
      ...controller.deck,
      ...controller.basics,
      if (controller.commander != null) controller.commander!.cardInfo,
    ];
    final categoriesPanel = !_expanded
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: _CategoriesWrap(allCards: allCards),
          );

    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: _expanded ? 4 : 0,
              ),
              // Keep a minimal tap target height while avoiding extra empty space above.
              constraints: const BoxConstraints(minHeight: 56),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    visualDensity: const VisualDensity(
                      horizontal: -3,
                      vertical: -3,
                    ),
                    icon: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    tooltip: _expanded ? 'Collapse' : 'Expand deck composition',
                    onPressed: _toggleExpanded,
                  ),
                  const SizedBox(width: 6),
                  CountLabel(totalCount: totalCount),
                  const SizedBox(width: 8),
                  Expanded(child: DeckProgressIndicator(progress: progress)),
                  const SizedBox(width: 8),
                  CostLabel(cost: cost),
                  const SizedBox(width: 8),
                  const FinishButton(),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: categoriesPanel,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesWrap extends StatelessWidget {
  final List<CardInfo> allCards; // card objects with .type
  const _CategoriesWrap({required this.allCards});

  @override
  Widget build(BuildContext context) {
    final total = DraftProgressBar.targetDeckSize.toDouble();
    final listChildren = <Widget>[];
    for (final c in DraftProgressBar.categories) {
      final count = allCards.where((card) => c.predicate(card.type)).length;
      final double pct = total == 0 ? 0 : count / total;
      listChildren.add(
        _CategoryBar(
          label: c.label,
          count: count,
          percent: pct,
          color: c.color,
        ),
      );
      listChildren.add(const SizedBox(height: 12));
    }
    if (listChildren.isNotEmpty) {
      listChildren.removeLast(); // remove trailing spacer
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_graph,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Deck Composition',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
          ],
        ),
        const Divider(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: listChildren,
        ),
      ],
    );
  }
}

/// Single category progress bar with label, count, and linear indicator.
class _CategoryBar extends StatelessWidget {
  final String label;
  final int count;
  final double percent; // 0..1
  final Color color;
  const _CategoryBar({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.surfaceVariant.withOpacity(0.6);
    final barColor = color; // could lighten/darken if needed
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: barColor.withOpacity(0.4), width: 1),
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
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$count',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
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
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
