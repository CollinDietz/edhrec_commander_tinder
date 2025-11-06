import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'count_label.dart';
import 'deck_progress_indicator.dart';
import 'finish_button.dart';

/// DraftProgressBar
/// A compact status bar showing:
///  * Current total card count (including basics) out of the 99 target.
///  * Linear progress indicator.
///  * A Finish button to end the draft early.
///
/// Keeps all layout concerns local and minimizes inline arithmetic noise
/// by extracting derived values.
class DraftProgressBar extends StatelessWidget {
  const DraftProgressBar({super.key});

  static const int targetDeckSize = 99;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeckController>();
    final int basicsCount = controller.basics.length;
    final int deckCount = controller.deck.length;
    final int totalCount = basicsCount + deckCount;
    final double progress = totalCount / targetDeckSize;
    final num cost =
        controller.deck.fold<double>(0, (sum, card) => sum + (card.price)) +
        controller.basics.fold<double>(0, (sum, card) => sum + (card.price)) +
        controller.commander!.cardInfo.price;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          CountLabel(totalCount: totalCount),
          const SizedBox(width: 16),
          DeckProgressIndicator(progress: progress),
          const SizedBox(width: 16),
          CostLabel(cost: cost),
          const SizedBox(width: 16),
          FinishButton(enabled: totalCount > 0),
        ],
      ),
    );
  }
}
