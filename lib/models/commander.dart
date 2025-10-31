import 'dart:convert';
import 'package:http/http.dart' as http;

class Commander {
  final String name;
  final String image_url;

  Commander({required this.name, required this.image_url});

  factory Commander.fromJson(Map<String, dynamic> json) {
    return Commander(
      name: json['container']['json_dict']['card']['name'] ?? '',
      image_url:
          json['container']['json_dict']['card']['image_uris'][0]['normal'],
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
}
