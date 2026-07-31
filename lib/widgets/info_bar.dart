import 'package:edhrec_commander_tinder/widgets/cost_label.dart';
import 'package:edhrec_commander_tinder/widgets/inclusion_label.dart';
import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

/// PriceBar
/// Displays the current card price and position in the draft stack.
/// Takes references to the resolved and futures lists so it can lazily
/// trigger fetching of the current card if needed.
class InfoBar extends StatelessWidget {
  final int numItems;
  final CardInfo? card;
  final int currentIndex;
  const InfoBar({
    super.key,
    required this.numItems,
    required this.card,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (currentIndex >= numItems) {
      return _wrap(
        Text(
          'Done',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      );
    }

    if (card != null) {
      return _wrap(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            CostLabel(cost: card!.price),
            Spacer(),
            InclusionLabel(stats: card!.stats!),
            Spacer(),
            Text(
              'Card ${currentIndex + 1}/$numItems',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Spacer(),
          ],
        ),
      );
    }

    return _wrap(
      SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
      ),
    );
  }

  Widget _wrap(Widget child) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cs.surfaceVariant,
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
            ),
          ),
          child: Center(child: child),
        );
      },
    );
  }
}
