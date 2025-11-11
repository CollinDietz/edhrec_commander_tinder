import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/card_image.dart';
import 'package:edhrec_commander_tinder/widgets/card_labels.dart';

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
    final label = resolveCardLabel(widget.card);
    final bool hasLabel = label != null;
    const double offsetStep = 20.0;

    // Single-face card
    if (images.length == 1) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 300.0;
          final cardWidth = maxWidth.clamp(180.0, 320.0);
          final cardHeight =
              (cardWidth * 1.4) + 4; // maintain same ratio used previously
          // No extra width: keep image box tight so parent centers naturally.
          return SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _OutlinedCardImage(
                  url: images.first,
                  outlineColor: label?.color,
                  banner: hasLabel
                      ? _CardBanner(width: cardWidth, label: label)
                      : null,
                ),
              ],
            ),
          );
        },
      );
    }

    // Multi-face card (double-faced / flip / meld etc.)
    final behindIndices = <int>[];
    for (int i = 0; i < images.length; i++) {
      if (i == _frontIndex) continue;
      behindIndices.add(i);
      if (behindIndices.length == 3)
        break; // cap number behind for visual clarity
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0;
        final cardWidth = maxWidth.clamp(180.0, 320.0);
        final stackWidth = cardWidth + offsetStep * behindIndices.length + 4;
        final stackHeight =
            (cardWidth * 1.4) + offsetStep * behindIndices.length + 4;
        return SizedBox(
          width: stackWidth,
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              for (int bi = 0; bi < behindIndices.length; bi++)
                Positioned(
                  left: offsetStep * (bi + 1),
                  top: offsetStep * (bi + 1),
                  child: Opacity(
                    opacity: 0.7 - (0.15 * bi),
                    child: SizedBox(
                      width: cardWidth,
                      child: CardImage(url: images[behindIndices[bi]]),
                    ),
                  ),
                ),
              _OutlinedCardImage(
                url: images[_frontIndex],
                outlineColor: label?.color,
                banner: hasLabel
                    ? _CardBanner(width: cardWidth, label: label)
                    : null,
              ),
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

/// Card image with optional colored outline based on label.
class _OutlinedCardImage extends StatelessWidget {
  final String url;
  final Color? outlineColor;
  final _CardBanner? banner;
  const _OutlinedCardImage({
    required this.url,
    required this.outlineColor,
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          foregroundDecoration: outlineColor != null
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outlineColor!, width: 4),
                )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CardImage(url: url),
          ),
        ),
        if (banner != null) banner!,
      ],
    );
  }
}

class _CardBanner extends StatelessWidget {
  final double width;
  final CardLabelDescriptor label;
  const _CardBanner({required this.width, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: label.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          // topRight: Radius.circular(8),
          // bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        label.text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
