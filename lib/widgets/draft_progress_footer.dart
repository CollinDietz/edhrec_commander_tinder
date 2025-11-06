import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/screens/finished_screen.dart';

class DraftProgressFooter extends StatelessWidget {
  const DraftProgressFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final deckCtrl = context.watch<DeckController>();
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.layers, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Text('${deckCtrl.deck.length + deckCtrl.basics.length}/99'),
          const SizedBox(width: 16),
          Expanded(
            child: LinearProgressIndicator(
              value: (deckCtrl.deck.length + deckCtrl.basics.length) / 99,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FinishedScreen()),
              );
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
