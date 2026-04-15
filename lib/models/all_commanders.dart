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

  static String _slugifyCommanderName(String raw) {
    // For split / dual-face names like "Gwen Stacy // Ghost Spider" only use the first part.
    if (raw.contains('//')) {
      raw = raw.split('//')[0].trim();
    }
    var s = raw.replaceAll('+', ' ');
    s = s.toLowerCase();
    // Normalize diacritics to ASCII. We remove combining marks after NFD and also
    // map certain multi-char ligatures.
    // Dart (without third-party) doesn't have direct unicode normalization, but for
    // common commander-name characters we can transliterate via map.
    const multiMap = {
      'æ': 'ae',
      'œ': 'oe',
      'ß': 'ss',
      'ø': 'o',
      'ð': 'd',
      'þ': 'th',
      'å': 'a',
    };
    const singleMap = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'å': 'a',
      'ā': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'ė': 'e',
      'ę': 'e',
      'ē': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ī': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ő': 'o',
      'ō': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ű': 'u',
      'ū': 'u',
      'ý': 'y',
      'ÿ': 'y',
      'ç': 'c',
      'ñ': 'n',
    };
    final buffer = StringBuffer();
    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      if (multiMap.containsKey(ch)) {
        buffer.write(multiMap[ch]);
      } else if (singleMap.containsKey(ch)) {
        buffer.write(singleMap[ch]);
      } else {
        buffer.write(ch);
      }
    }
    s = buffer.toString();
    // Remove standard colon and modifier letter colon (U+A789) without creating word breaks.
    s = s.replaceAll(RegExp(r'[:꞉]'), '');
    // Remove apostrophes/backticks
    s = s.replaceAll(RegExp(r"['`]"), "");
    // Replace any remaining non-alphanumeric (except space & hyphen) with space
    s = s.replaceAll(RegExp(r"[^a-z0-9\s-]"), " ");
    // Collapse whitespace
    s = s.replaceAll(RegExp(r"\s+"), " ").trim();
    s = s.replaceAll(' ', '-');
    // Collapse multiple hyphens
    s = s.replaceAll(RegExp(r"-+"), "-");
    return s;
  }

  factory PotentialCommander.fromJson(Map<String, dynamic> json) {
    String? picture;
    if (json['image_uris'] != null) {
      picture = json['image_uris']['art_crop'];
    } else if (json['card_faces'] != null) {
      picture = json['card_faces'][0]['image_uris']['art_crop'];
    }

    return PotentialCommander(
      name: json['name'],
      url:
          'https://json.edhrec.com/pages/commanders/${_slugifyCommanderName(json['name'])}.json',
      picture: picture,
    );
  }
}

class AllCommanders {
  static const String _initialUrl =
      'https://api.scryfall.com/cards/search?q=is%3Acommander+(date>now+or+legal%3Acommander)';

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
