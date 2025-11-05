import 'dart:convert';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:http/http.dart' as http;

class Commander {
  final CardInfo cardInfo;
  final List<String> cardJsonUrls;
  final List<String> basicsUrls;

  static const List<String> basics = [
    "c44f81ca-f72f-445c-8901-3a894a2a47f9", // Mountain
    "4069fb4a-8ee1-41ef-ab93-39a8cc58e0e5", // Plains
    "a2e22347-f0cb-4cfd-88a3-4f46a16e4946", // Island
    "f0b234d8-d6bb-48ec-8a4d-d8a570a69c62", // Swamp
    "a305e44f-4253-4754-b83f-1e34103d77b0", // Forest
  ];

  Commander({
    required this.cardInfo,
    required this.cardJsonUrls,
    required this.basicsUrls,
  });

  factory Commander.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cardLists = json['container']['json_dict']['cardlists'];

    final List<MapEntry<String, double>> urlWithNumber = [];
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
          urlWithNumber.add(MapEntry(url, inclusion / potentialDecks));
        }
      }
    }

    urlWithNumber.sort((a, b) => b.value.compareTo(a.value));

    final List<String> urls = urlWithNumber.map((e) => e.key).toList();

    final CardInfo cardInfo = CardInfo.fromJson(json);

    return Commander(
      cardInfo: cardInfo,
      cardJsonUrls: urls,
      basicsUrls: basicsUrl,
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

  List<Future<CardInfo>> getBasics() {
    return basicsUrls.map((url) => CardInfo.fromUrl(url)).toList();
  }

  Future<CardInfo> getCard(int index) {
    return CardInfo.fromUrl(cardJsonUrls[index]);
  }
}
