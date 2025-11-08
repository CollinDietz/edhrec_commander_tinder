import 'dart:convert';

import 'package:http/http.dart' as http;

class CardInfo {
  final String name;
  final List<String> imageUrls;
  final List<String> smallImageUrls;
  final String uuid;
  final double price;

  CardInfo({
    required this.name,
    required this.uuid,
    required this.imageUrls,
    required this.smallImageUrls,
    required this.price,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    final cardJson = json['container']['json_dict']['card'];
    final List<dynamic> imageUris = cardJson['image_uris'] as List<dynamic>;
    final normalImages = <String>[];
    final artCropImages = <String>[];
    for (final uriEntry in imageUris) {
      if (uriEntry is Map<String, dynamic>) {
        final normal = uriEntry['normal'];
        final art = uriEntry['art_crop'];
        if (normal is String) normalImages.add(normal);
        if (art is String) artCropImages.add(art);
      }
    }
    return CardInfo(
      name: cardJson['name'] as String,
      uuid: cardJson['id'] as String,
      price: cardJson['prices']['tcgplayer']['price'] as double,
      imageUrls: normalImages,
      smallImageUrls: artCropImages,
    );
  }

  static Future<CardInfo> fromUrl(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load commander data');
    }
    final jsonData = json.decode(response.body);
    return CardInfo.fromJson(jsonData);
  }
}
