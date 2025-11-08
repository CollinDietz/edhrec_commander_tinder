import 'package:edhrec_commander_tinder/widgets/card_display.dart';
import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

class CardWithPrice extends StatelessWidget {
  final CardInfo card;
  const CardWithPrice({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CardDisplay(card: card),
          const SizedBox(height: 8),
          CostLabel(
            cost: card.price,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
