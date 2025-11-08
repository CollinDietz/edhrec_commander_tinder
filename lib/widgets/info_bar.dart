import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'package:edhrec_commander_tinder/widgets/inclusion_label.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

/// PriceBar
/// Displays the current card price and position in the draft stack.
/// Takes references to the resolved and futures lists so it can lazily
/// trigger fetching of the current card if needed.
class InfoBar extends StatelessWidget {
  final List<SwipeItem> items;
  final List<CardInfo?> resolved;
  final List<Future<CardInfo>?> futures;
  final int currentIndex;
  const InfoBar({
    super.key,
    required this.items,
    required this.resolved,
    required this.futures,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final int total = items.length;

    if (currentIndex >= total) {
      return _wrap(
        const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      );
    }

    final CardInfo? info = resolved[currentIndex];
    if (info != null) {
      return _wrap(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CostLabel(cost: info.price),
            const SizedBox(width: 24),
            InclusionLabel(stats: info.stats!),
            const SizedBox(width: 24),
            Text(
              'Card ${currentIndex + 1}/$total',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
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
