import 'dart:convert';
import 'package:http/http.dart' as http;

class PotentialCommander {
  final String name;
  final String url;
  final String? picture;

  PotentialCommander({
    required this.name,
    required this.url,
    required this.picture,
  });

  factory PotentialCommander.fromJson(Map<String, dynamic> json) {
    String? picture;
    if (json['image_uris'] != null) {
      picture = json['image_uris']['art_crop'];
    } else if (json['card_faces'] != null) {
      picture = json['card_faces'][0]['image_uris']['art_crop'];
    }

    return PotentialCommander(
      name: json['name'],
      url: json['related_uris']['edhrec'],
      picture: picture,
    );
  }
}

class AllCommanders {
  static const String _initialUrl =
      'https://api.scryfall.com/cards/search?q=is%3Acommander+legal%3Acommander';

  static List<PotentialCommander>? _cache;
  static Future<List<PotentialCommander>>? _inFlight;

  static Future<List<PotentialCommander>> load() {
    if (_cache != null) return Future.value(_cache);
    _inFlight ??= _fetch()
        .then((value) {
          _cache = value;
          return value;
        })
        .catchError((e) {
          _inFlight = null; // allow retry after failure
          throw e;
        });
    return _inFlight!;
  }

  static Future<List<PotentialCommander>> _fetch() async {
    final List<PotentialCommander> all = [];
    String? url = _initialUrl;
    while (url != null) {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) {
        throw Exception('Failed to load commanders (${resp.statusCode})');
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final list = (data['data'] as List<dynamic>)
          .map((e) => PotentialCommander.fromJson(e as Map<String, dynamic>))
          .toList();
      all.addAll(list);
      url = (data['has_more'] == true) ? data['next_page'] as String? : null;
      if (url != null) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    return all;
  }

  static void clearCache() {
    _cache = null;
    _inFlight = null;
  }
}
