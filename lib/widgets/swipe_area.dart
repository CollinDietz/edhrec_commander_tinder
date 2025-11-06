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
  const SwipeArea({
    super.key,
    required this.engine,
    required this.items,
    required this.resolved,
    required this.deckCtrl,
    required this.basicsLength,
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
          return Card(
            child: Center(child: CardDisplay(card: cached)),
          );
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
            resolved[index] = snap.data;
            return Card(
              child: Center(child: CardDisplay(card: snap.data!)),
            );
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
    );
  }
}
