import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/commander.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/card_image.dart';

class CommanderCard extends StatelessWidget {
  final Commander commander;
  const CommanderCard({super.key, required this.commander});

  @override
  Widget build(BuildContext context) {
    final CardInfo card = commander.cardInfo;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CardImage(url: card.image_url),
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
