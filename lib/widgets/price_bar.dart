import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

/// PriceBar
/// Displays the current card price and position in the draft stack.
/// Takes references to the resolved and futures lists so it can lazily
/// trigger fetching of the current card if needed.
class PriceBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final List<CardInfo?> resolved;
  final List<Future<CardInfo>?> futures;
  const PriceBar({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.resolved,
    required this.futures,
  });

  @override
  Widget build(BuildContext context) {
    // Watch deck controller so bar rebuilds when deck changes (e.g., index advances).
    context.watch<DeckController>();

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
            const Icon(Icons.attach_money, color: Colors.green),
            Text(
              info.price.toStringAsFixed(2),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 24),
            Text(
              'Card ${currentIndex + 1}/$total',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    // Trigger fetch if not already started.
    final deckCtrl = context.read<DeckController>();
    if (futures[currentIndex] == null) {
      futures[currentIndex] = deckCtrl.commander!.getCard(currentIndex);
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
