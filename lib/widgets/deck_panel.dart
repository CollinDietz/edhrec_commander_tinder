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
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Spacer(),
                      Icon(Icons.layers, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        '${(deckCtrl.deck.length + deckCtrl.basics.length)} / 99 cards',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        'assets/icons/draft.svg',
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          Colors.green[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${(deckCtrl.deck.fold<double>(0, (sum, card) => sum + (card.price)) + deckCtrl.commander!.cardInfo.price).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              value: (deckCtrl.deck.length + deckCtrl.basics.length) / 99,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FinishedScreen()),
                );
              },
              child: const Text('Finish Early'),
            ),
          ),
        ],
      ),
    );
  }
}
