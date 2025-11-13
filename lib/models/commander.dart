import 'dart:convert';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/models/recommendation_stats.dart';
import 'package:edhrec_commander_tinder/models/tagger.dart';
import 'package:http/http.dart' as http;

class CardStat {
  final String url;
  final RecommendationStats stats;
  const CardStat({required this.url, required this.stats});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CardStat && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

class Commander {
  final CardInfo cardInfo;
  final List<String> basicsUrls;
  final List<CardStat> cardStats;

  static const List<String> basics = [
    "c44f81ca-f72f-445c-8901-3a894a2a47f9", // Mountain
    "4069fb4a-8ee1-41ef-ab93-39a8cc58e0e5", // Plains
    "a2e22347-f0cb-4cfd-88a3-4f46a16e4946", // Island
    "f0b234d8-d6bb-48ec-8a4d-d8a570a69c62", // Swamp
    "a305e44f-4253-4754-b83f-1e34103d77b0", // Forest
  ];

  Commander({
    required this.cardInfo,
    required this.basicsUrls,
    required this.cardStats,
  });

  factory Commander.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cardLists = json['container']['json_dict']['cardlists'];

    final Set<CardStat> uniqueCards = {};
    final List<String> basicsUrl = [];
    for (final Map<String, dynamic> cardList in cardLists) {
      for (final Map<String, dynamic> card in cardList['cardviews']) {
        final String url = 'https://json.edhrec.com/pages${card['url']}.json';
        final String id = card['id'];

        final num inclusion = card['inclusion'] as num;
        final num potentialDecks = card['potential_decks'] as num;

        if (basics.contains(id)) {
          basicsUrl.add(url);
        } else {
          uniqueCards.add(
            CardStat(
              url: url,
              stats: RecommendationStats(
                inclusion: inclusion,
                potentialDecks: potentialDecks,
              ),
            ),
          );
        }
      }
    }

    final List<CardStat> allCards = uniqueCards.toList();

    allCards.sort((a, b) => b.stats.ratio.compareTo(a.stats.ratio));

    final CardInfo cardInfo = CardInfo.fromJsonAndStats(json, null, null);

    print('legal_commander');
    print(json['container']['json_dict']['card']['legal_commander']);
    print('legal_partner');
    print(json['container']['json_dict']['card']['legal_partner']);
    print('legal_companion');
    print(json['container']['json_dict']['card']['legal_companion']);

    return Commander(
      cardInfo: cardInfo,
      basicsUrls: basicsUrl,
      cardStats: allCards,
    );
  }

  static Future<Commander> fromUrl(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load commander data');
    }
    final jsonData = json.decode(response.body);
    return Commander.fromJson(jsonData);
  }

  Future<CardInfo> getCard(int index) {
    return CardInfo.fromUrlAndStats(
      cardStats[index].url,
      cardStats[index].stats,
      tagger: Tagger.instance,
    );
  }
}
