import 'dart:convert';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:http/http.dart' as http;

class Commander {
  final CardInfo cardInfo;
  final List<String> cardJsonUrls;

  Commander({required this.cardInfo, required this.cardJsonUrls});

  factory Commander.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cardLists = json['container']['json_dict']['cardlists'];

    final List<MapEntry<String, double>> urlWithNumber = [];
    for (final Map<String, dynamic> cardList in cardLists) {
      for (final Map<String, dynamic> card in cardList['cardviews']) {
        final String url = 'https://json.edhrec.com/pages${card['url']}.json';

        final num inclusion = card['inclusion'] as num;
        final num potentialDecks = card['potential_decks'] as num;
        urlWithNumber.add(MapEntry(url, inclusion / potentialDecks));
      }
    }

    urlWithNumber.sort((a, b) => b.value.compareTo(a.value));

    final List<String> urls = urlWithNumber.map((e) => e.key).toList();

    final CardInfo cardInfo = CardInfo.fromJson(json);

    return Commander(cardInfo: cardInfo, cardJsonUrls: urls);
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
    return CardInfo.fromUrl(cardJsonUrls[index]);
  }
}
