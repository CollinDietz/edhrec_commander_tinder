import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/card_display.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';

class SwipeArea extends StatelessWidget {
  final MatchEngine? engine;
  final List<SwipeItem> items;
  final List<CardInfo?> resolved;
  final DeckController deckCtrl;
  final int basicsLength;
  final ValueChanged<int>? onResolved;
  final ValueChanged<int>? onItemChanged;
  const SwipeArea({
    super.key,
    required this.engine,
    required this.items,
    required this.resolved,
    required this.deckCtrl,
    required this.basicsLength,
    this.onResolved,
    this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (engine == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SwipeCards(
      matchEngine: engine!,
      itemBuilder: (context, index) {
        final cached = resolved[index];
        if (cached != null) {
          return _displayCard(cached);
        }
        final future = items[index].content();
        return FutureBuilder<CardInfo>(
          future: future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text('Error'));
            }
            if (!snap.hasData) {
              return const Center(child: Text('No data'));
            }
            if (resolved[index] == null) {
              resolved[index] = snap.data;
              onResolved?.call(index); // notify parent to allow UI refresh
            }
            return _displayCard(resolved[index]!);
          },
        );
      },
      onStackFinished: () {
        if ((deckCtrl.deck.length + basicsLength) < 99) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No more cards')));
        }
      },
      itemChanged: (item, index) {
        onItemChanged?.call(index);
      },
    );
  }

  Widget _displayCard(CardInfo cached) =>
      Center(child: CardDisplay(card: cached));
}
