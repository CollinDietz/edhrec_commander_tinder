import 'package:flutter/material.dart';

class DeckProgressIndicator extends StatelessWidget {
  final double progress;
  const DeckProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double clamped = progress.clamp(0, 1).toDouble();
    final barColor = clamped >= 0.9 ? cs.secondaryContainer : cs.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: clamped,
        backgroundColor: cs.surfaceVariant.withOpacity(0.5),
        valueColor: AlwaysStoppedAnimation<Color>(barColor),
        semanticsLabel: 'Deck completion progress',
      ),
    );
  }
}
