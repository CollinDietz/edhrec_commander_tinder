import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'swipe_area.dart';
import 'draft_progress_bar.dart';
import 'price_bar.dart';

class SwipePanel extends StatelessWidget {
  final MatchEngine? engine;
  final List<SwipeItem> items;
  final List<CardInfo?> resolved;
  final List<Future<CardInfo>?> futures;
  final int currentIndex;
  final int basicsLength;
  final ValueChanged<int> onCardResolved;

  const SwipePanel({
    super.key,
    required this.engine,
    required this.items,
    required this.resolved,
    required this.futures,
    required this.currentIndex,
    required this.basicsLength,
    required this.onCardResolved,
  });

  @override
  Widget build(BuildContext context) {
    final deckCtrl = context.watch<DeckController>();
    return Column(
      children: [
        Expanded(
          child: SwipeArea(
            engine: engine,
            items: items,
            resolved: resolved,
            deckCtrl: deckCtrl,
            basicsLength: basicsLength,
            onResolved: (i) {
              if (i == currentIndex) {
                // Defer to next frame to avoid setState in build higher up.
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => onCardResolved(i),
                );
              }
            },
          ),
        ),
        // Text(engine.currentItem.content)
        PriceBar(
          currentIndex: currentIndex,
          total: items.length,
          resolved: resolved,
          futures: futures,
        ),
      ],
    );
  }
}
