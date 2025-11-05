import 'dart:convert';

import 'package:http/http.dart' as http;

class CardInfo {
  final String name;
  final String url;

  CardInfo({required this.name, required this.url});

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      name: json['container']['json_dict']['card']['name'] as String,
      url:
          json['container']['json_dict']['card']['image_uris'][0]['normal']
              as String,
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
