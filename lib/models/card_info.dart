import 'dart:convert';

import 'package:edhrec_commander_tinder/models/recommendation_stats.dart';
import 'package:edhrec_commander_tinder/models/tagger.dart';
import 'package:http/http.dart' as http;

class CardInfo {
  final String name;
  final String type;
  final List<String> imageUrls;
  final List<String> smallImageUrls;
  final String uuid;
  final String oracleId;
  final double price;
  final double manaCost;
  final bool isSalty;
  final bool isGameChanger;
  final RecommendationStats? stats;
  final List<String> tags;

  CardInfo({
    required this.name,
    required this.type,
    required this.uuid,
    required this.oracleId,
    required this.imageUrls,
    required this.smallImageUrls,
    required this.price,
    required this.manaCost,
    required this.isSalty,
    required this.stats,
    required this.isGameChanger,
    required this.tags,
  });

  CardInfo copyWith({List<String>? tags}) => CardInfo(
    name: name,
    type: type,
    uuid: uuid,
    oracleId: oracleId,
    imageUrls: imageUrls,
    smallImageUrls: smallImageUrls,
    price: price,
    manaCost: manaCost,
    isSalty: isSalty,
    stats: stats,
    isGameChanger: isGameChanger,
    tags: tags ?? this.tags,
  );

  factory CardInfo.fromJsonAndStats(
    Map<String, dynamic> edhrecJson,
    Map<String, dynamic>? scryfallJson,
    RecommendationStats? stats, {
    Tagger? tagger,
  }) {
    final cardJson = edhrecJson['container']['json_dict']['card'];
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

    final bool isGameChange = scryfallJson != null
        ? (scryfallJson['game_changer'] == true)
        : false;

    final String oracleId =
        scryfallJson != null && scryfallJson['oracle_id'] is String
        ? scryfallJson['oracle_id'] as String
        : '';

    final cardName = cardJson['name'] as String;
    final List<String> tags = (tagger?.isLoaded ?? false)
        ? List<String>.unmodifiable(tagger!.getTags(oracleId))
        : const [];

    final num salt = cardJson['salt'];

    return CardInfo(
      name: cardName,
      type: cardJson['primary_type'] as String,
      uuid: cardJson['id'] as String,
      oracleId: oracleId,
      manaCost: cardJson['cmc'] as double,
      isSalty: salt.toDouble() > 1.0,
      price: cardJson['prices']['tcgplayer']['price'] as double,
      imageUrls: normalImages,
      smallImageUrls: artCropImages,
      stats: stats,
      isGameChanger: isGameChange,
      tags: tags,
    );
  }

  static Future<CardInfo> fromUrlAndStats(
    String url,
    RecommendationStats? stats, {
    Tagger? tagger,
  }) async {
    final uri = Uri.parse(url);
    final edhrecResponse = await http.get(uri);
    if (edhrecResponse.statusCode != 200) {
      throw Exception('Failed to load commander data');
    }
    final edhrecJsonData = json.decode(edhrecResponse.body);

    final id = edhrecJsonData['container']['json_dict']['card']['id'];

    final scryfallResponse = await http.get(
      Uri.parse('https://api.scryfall.com/cards/$id'),
    );

    if (scryfallResponse.statusCode != 200) {
      throw Exception('Failed to load commander data');
    }

    final scryfallJsonData = json.decode(scryfallResponse.body);

    return CardInfo.fromJsonAndStats(
      edhrecJsonData,
      scryfallJsonData,
      stats,
      tagger: tagger,
    );
  }
}
