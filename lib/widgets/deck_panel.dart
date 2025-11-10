import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'card_popup.dart';

class DeckPanel extends StatelessWidget {
  const DeckPanel({super.key});

  // Widget _basicCountBadge(List<CardInfo> basics, CardInfo card) {
  //   final count = ;
  //   return Text(
  //     'x $count',
  //     style: const TextStyle(fontWeight: FontWeight.w600),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final deckCtrl = context.watch<DeckController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: deckCtrl.basicsWithCounts.length + deckCtrl.deck.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (_, i) {
              final isBasic = i < deckCtrl.basicsWithCounts.length;
              CardInfo card;
              int count = 0;

              if (isBasic) {
                final cardWithCount = deckCtrl.basicsWithCounts.elementAt(i);
                card = cardWithCount.key;
                count = cardWithCount.value;
              } else {
                card = deckCtrl.deck[i - deckCtrl.basicsWithCounts.length];
              }

              String text = card.name;
              if (isBasic) {
                text = "$text x$count";
              }

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => CardPopup(
                      card: card,
                      onRemove: !isBasic
                          ? (() => deckCtrl.removeCard(card))
                          : null,
                    ),
                  );
                },
                child: CategoryTile(
                  category: card.type,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          card.smallImageUrls.first,
                          width: 60,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CostLabel(cost: card.price),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
