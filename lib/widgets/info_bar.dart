import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'package:edhrec_commander_tinder/widgets/inclusion_label.dart';
import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

/// PriceBar
/// Displays the current card price and position in the draft stack.
/// Takes references to the resolved and futures lists so it can lazily
/// trigger fetching of the current card if needed.
class InfoBar extends StatelessWidget {
  final int numItems;
  final CardInfo? card;
  final int currentIndex;
  const InfoBar({
    super.key,
    required this.numItems,
    required this.card,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= numItems) {
      return _wrap(
        const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      );
    }

    if (card != null) {
      return _wrap(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CostLabel(cost: card!.price),
            const SizedBox(width: 8),
            InclusionLabel(stats: card!.stats!),
            const SizedBox(width: 8),
            Text(
              'Card ${currentIndex + 1}/$numItems',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(card!.type),
          ],
        ),
      );
    }

    return _wrap(
      const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _wrap(Widget child) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(child: child),
    );
  }
}
