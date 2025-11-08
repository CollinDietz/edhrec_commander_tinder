import 'dart:convert';

import 'package:edhrec_commander_tinder/models/recommendation_stats.dart';
import 'package:http/http.dart' as http;

class CardInfo {
  final String name;
  final List<String> imageUrls;
  final List<String> smallImageUrls;
  final String uuid;
  final double price;
  final RecommendationStats? stats;

  CardInfo({
    required this.name,
    required this.uuid,
    required this.imageUrls,
    required this.smallImageUrls,
    required this.price,
    required this.stats,
  });

  factory CardInfo.fromJsonAndStats(
    Map<String, dynamic> json,
    RecommendationStats? stats,
  ) {
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
      stats: stats,
    );
  }

  static Future<CardInfo> fromUrlAndStats(
    String url,
    RecommendationStats? stats,
  ) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load commander data');
    }
    final jsonData = json.decode(response.body);
    return CardInfo.fromJsonAndStats(jsonData, stats);
  }
}
