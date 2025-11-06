import 'package:flutter/material.dart';
import 'draft_progress_bar.dart';

class CountLabel extends StatelessWidget {
  final int totalCount;
  final TextStyle? textStyle;

  const CountLabel({super.key, required this.totalCount, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 8),
        Text(
          '$totalCount/${DraftProgressBar.targetDeckSize}',
          style: textStyle ?? const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.layers,
      color: Colors.green[700],
      size: 20,
      semanticLabel: 'Deck progress',
    );
  }
}
