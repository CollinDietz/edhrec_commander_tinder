import 'package:flutter/material.dart';

class DeckProgressIndicator extends StatelessWidget {
  final double progress;
  const DeckProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: progress.clamp(0, 1),
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        semanticsLabel: 'Deck completion progress',
      ),
    );
  }
}
