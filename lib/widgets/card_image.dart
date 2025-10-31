import 'package:flutter/material.dart';

class CardImage extends StatelessWidget {
  final String url;

  const CardImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Center(child: Icon(Icons.broken_image)),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
