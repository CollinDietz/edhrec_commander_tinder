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
  bool flipped = false;

  void _cycleFront() {
    setState(() {
      flipped = !flipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.card.imageUrls;
    final label = resolveCardLabel(widget.card);
    final bool hasLabel = label != null;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      children: [
        CardImage(url: flipped ? images.first : images.last),
        _OutlinedCardImage(
          url: flipped ? images.last : images.first,
          outlineColor: label?.color,
          banner: hasLabel ? _CardBanner(label: label) : null,
        ),
        if (images.length > 1)
          Positioned(
            right: 4,
            top: 40,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.flip_camera_android,
                  color: Colors.white,
                ),
                tooltip: 'Flip card',
                onPressed: _cycleFront,
              ),
            ),
          ),
      ],
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
  final CardLabelDescriptor label;
  const _CardBanner({required this.label});

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
