import 'package:flutter/material.dart';

class CardImage extends StatelessWidget {
  final String url;

  const CardImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(12),
        bottom: Radius.circular(12),
      ),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Icon(Icons.broken_image, color: cs.error)),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: cs.primary,
                strokeWidth: 3,
              ),
            ),
          );
        },
      ),
    );
  }
}
