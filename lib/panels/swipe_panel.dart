import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import '../widgets/swipe_area.dart';
import '../widgets/info_bar.dart';

class SwipePanel extends StatelessWidget {
  final MatchEngine? engine;
  final List<SwipeItem> items;
  final List<CardInfo?> resolved;
  final List<Future<CardInfo>?> futures;
  final int basicsLength;
  final ValueChanged<int> onCardResolved;
  final ValueChanged<int> onItemChanged;
  final int currentIndex;

  const SwipePanel({
    super.key,
    required this.engine,
    required this.items,
    required this.resolved,
    required this.futures,
    required this.basicsLength,
    required this.onCardResolved,
    required this.onItemChanged,
    required this.currentIndex,
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
              // If resolved item is current engine item, notify parent post-frame.
              if (engine?.currentItem == items[i]) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => onCardResolved(i),
                );
              }
            },
            onItemChanged: onItemChanged,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {
                    engine!.currentItem?.nope();
                  },
                  child: const Icon(Icons.close_rounded),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {
                    engine!.currentItem?.like();
                  },
                  child: const Icon(Icons.favorite),
                ),
              ],
            ),
          ),
        ),
        InfoBar(
          numItems: items.length,
          card: resolved[currentIndex],
          currentIndex: currentIndex,
        ),
      ],
    );
  }
}
