import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/card_image.dart';

class CardDisplay extends StatefulWidget {
  final CardInfo card;
  const CardDisplay({super.key, required this.card});

  @override
  State<CardDisplay> createState() => _CardDisplayState();
}

class _CardDisplayState extends State<CardDisplay> {
  int _frontIndex = 0;

  void _cycleFront() {
    setState(() {
      _frontIndex = (_frontIndex + 1) % widget.card.imageUrls.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.card.imageUrls;

    const double offsetStep = 20.0;

    if (images.length == 1) {
      // Use LayoutBuilder so single-image cards occupy the same max horizontal
      // space the stacked variant would (avoids layout shift when counts vary).
      const int assumedBehind = 1; // reserve space as if 3 behind cards existed
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 300.0;
          final cardWidth = maxWidth.clamp(180.0, 320.0);
          final stackWidth = cardWidth + offsetStep * assumedBehind + 4;
          final stackHeight =
              (cardWidth * 1.4) + offsetStep * assumedBehind + 4;
          return SizedBox(
            width: stackWidth,
            height: stackHeight,
            child: CardImage(url: images.first),
          );
        },
      );
    }

    final behindIndices = <int>[];
    for (int i = 0; i < images.length; i++) {
      if (i == _frontIndex) continue;
      behindIndices.add(i);
      if (behindIndices.length == 3) break; // cap number of behind cards
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Derive card width from available width with a sane max.
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0; // fallback if unconstrained
        final cardWidth = maxWidth.clamp(180.0, 320.0);
        // Reserve space based on actual behind count.
        final stackWidth = cardWidth + offsetStep * behindIndices.length + 4;
        final stackHeight =
            (cardWidth * 1.4) + offsetStep * behindIndices.length + 4;
        return SizedBox(
          width: stackWidth,
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int bi = 0; bi < behindIndices.length; bi++)
                Positioned(
                  left: offsetStep * (bi + 1),
                  top: offsetStep * (bi + 1),
                  child: Opacity(
                    opacity: 0.7 - (0.15 * bi),
                    child: SizedBox(
                      width: cardWidth,
                      child: IgnorePointer(
                        child: CardImage(url: images[behindIndices[bi]]),
                      ),
                    ),
                  ),
                ),
              // Front image
              SizedBox(
                width: cardWidth,
                child: CardImage(url: images[_frontIndex]),
              ),
              // Swap button overlay (position relative to front card)
              Positioned(
                right: 4,
                top: 4,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    tooltip: 'Cycle image',
                    onPressed: _cycleFront,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// End of file
