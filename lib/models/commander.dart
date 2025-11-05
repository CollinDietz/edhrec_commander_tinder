import 'dart:convert';
import 'package:commander_tinder/models/card_info.dart';
import 'package:http/http.dart' as http;

class Commander {
  final String name;
  final String image_url;
  final List<String> cardJsonUrls;

  Commander({
    required this.name,
    required this.image_url,
    required this.cardJsonUrls,
  });

  factory Commander.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cardLists = json['container']['json_dict']['cardlists'];

    List<String> urls = [];
    for (Map<String, dynamic> cardList in cardLists) {
      for (Map<String, dynamic> card in cardList['cardviews']) {
        urls.add('https://json.edhrec.com/pages${card['url']}.json');
      }
    }

    return Commander(
      name: json['container']['json_dict']['card']['name'] ?? '',
      image_url:
          json['container']['json_dict']['card']['image_uris'][0]['normal'],
      cardJsonUrls: urls,
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
    return CardInfo.fromUrl(cardJsonUrls[index]);
  }
}
