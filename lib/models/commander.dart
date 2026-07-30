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
  final bool isPartner;
  final bool isCompanion;

  static const List<String> basics = [
    "mountain",
    "plains",
    "island",
    "swamp",
    "forest",
  ];

  Commander({
    required this.cardInfo,
    required this.basicsUrls,
    required this.cardStats,
    required this.isPartner,
    required this.isCompanion,
  });

  factory Commander.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cardLists = json['container']['json_dict']['cardlists'];

    final Set<CardStat> uniqueCards = {};
    final List<String> basicsUrl = [];
    for (final Map<String, dynamic> cardList in cardLists) {
      for (final Map<String, dynamic> card in cardList['cardviews']) {
        final String url = 'https://json.edhrec.com/pages${card['url']}.json';
        final String sanitized = card['sanitized'];

        final num inclusion = card['num_decks'] as num;
        final num potentialDecks = card['potential_decks'] as num;

        if (basics.contains(sanitized)) {
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

    return Commander(
      cardInfo: cardInfo,
      basicsUrls: basicsUrl,
      cardStats: allCards,
      isCompanion:
          (json['container']['json_dict']['card']['legal_companion']
              as bool?) ??
          false,
      isPartner:
          (json['container']['json_dict']['card']['legal_partner'] as bool?) ??
          false,
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
