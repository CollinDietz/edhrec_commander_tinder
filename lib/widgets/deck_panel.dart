import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/card_labels.dart';
import 'package:edhrec_commander_tinder/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'card_popup.dart';

class DeckPanel extends StatelessWidget {
  const DeckPanel({super.key});

  Widget _labelBadge(CardLabelDescriptor label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: label!.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label!.shortText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

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

              CardLabelDescriptor? label = resolveCardLabel(card);
              bool labeled = label != null;

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
                      if (labeled) _labelBadge(label),
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
