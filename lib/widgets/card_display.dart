import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/card_image.dart';

class CardDisplay extends StatelessWidget {
  final CardInfo card;
  const CardDisplay({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return CardImage(url: card.imageUrl);
  }
}
