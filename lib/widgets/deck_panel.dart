import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'card_popup.dart';

class DeckPanel extends StatelessWidget {
  const DeckPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final deckCtrl = context.watch<DeckController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: deckCtrl.basics.length + deckCtrl.deck.length,
            itemBuilder: (_, i) {
              final isBasic = i < deckCtrl.basics.length;
              final card = isBasic
                  ? deckCtrl.basics[i]
                  : deckCtrl.deck[i - deckCtrl.basics.length];
              final cardColor = isBasic ? Colors.green[50] : null;
              final titleStyle = isBasic
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null;
              final trailing = isBasic
                  ? const Icon(Icons.grass, color: Colors.green)
                  : null;

              return Card(
                color: cardColor,
                child: ListTile(
                  leading: Image.network(
                    card.smallImageUrls.first,
                    fit: BoxFit.cover,
                  ),
                  title: Text(card.name, style: titleStyle),
                  trailing: trailing,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => CardPopup(card: card),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
