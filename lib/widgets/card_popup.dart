import 'package:edhrec_commander_tinder/widgets/card_with_info.dart';
import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

/// Dialog showing a larger view of a card.
class CardPopup extends StatelessWidget {
  final CardInfo card;
  final VoidCallback? onRemove;
  const CardPopup({super.key, required this.card, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: cs.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardWithInfo(card: card),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onRemove != null)
                  TextButton.icon(
                    onPressed: () {
                      onRemove!.call();
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: cs.onErrorContainer,
                    ),
                    label: Text(
                      'Remove Card',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: cs.errorContainer,
                      foregroundColor: cs.onErrorContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
