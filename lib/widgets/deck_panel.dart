import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'package:edhrec_commander_tinder/widgets/count_label.dart';
import 'package:edhrec_commander_tinder/widgets/deck_progress_indicator.dart';
import 'package:edhrec_commander_tinder/widgets/draft_progress_bar.dart';
import 'package:edhrec_commander_tinder/widgets/finish_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/screens/finished_screen.dart';

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
              if (isBasic) {
                return Card(
                  color: Colors.green[50],
                  child: ListTile(
                    leading: Image.network(
                      card.small_image_url,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      card.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.grass, color: Colors.green),
                  ),
                );
              }
              return Card(
                child: ListTile(
                  leading: Image.network(
                    card.small_image_url,
                    fit: BoxFit.cover,
                  ),
                  title: Text(card.name),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
