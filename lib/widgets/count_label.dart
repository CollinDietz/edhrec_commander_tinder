import 'package:flutter/material.dart';
import 'draft_progress_bar.dart';

class CountLabel extends StatelessWidget {
  final int totalCount;
  final TextStyle? textStyle;

  const CountLabel({super.key, required this.totalCount, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        _buildIcon(cs),
        const SizedBox(width: 8),
        Text(
          '$totalCount/${DraftProgressBar.targetDeckSize}',
          style:
              textStyle ??
              theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ) ??
              const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildIcon(ColorScheme cs) {
    return Icon(
      Icons.layers,
      color: cs.secondary,
      size: 20,
      semanticLabel: 'Deck progress',
    );
  }
}
