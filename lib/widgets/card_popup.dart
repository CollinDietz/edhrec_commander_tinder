import 'package:edhrec_commander_tinder/widgets/card_with_info.dart';
import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

/// Dialog showing a larger view of a card.
class CardPopup extends StatelessWidget {
  final CardInfo card;
  const CardPopup({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardWithInfo(card: card),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
