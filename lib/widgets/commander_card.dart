import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/commander.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/card_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommanderCard extends StatelessWidget {
  final Commander commander;
  const CommanderCard({super.key, required this.commander});

  @override
  Widget build(BuildContext context) {
    final CardInfo card = commander.cardInfo;
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              card.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            CardImage(url: card.image_url),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  '\$${card.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
