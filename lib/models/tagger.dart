import 'dart:convert';
import 'package:http/http.dart' as http;

class TagRecord {
  final String label;
  final List<String> oracleIds;

  TagRecord({required this.label, required this.oracleIds});

  factory TagRecord.fromJson(Map<String, dynamic> json) {
    final oracleIdsRaw = json['oracle_ids'];
    final ids = oracleIdsRaw is List
        ? oracleIdsRaw.whereType<String>().toList()
        : <String>[];
    return TagRecord(label: json['label']?.toString() ?? '', oracleIds: ids);
  }
}

class Tagger {
  static final Tagger instance = Tagger._();
  Tagger._();

  static const _url = 'https://api.scryfall.com/private/tags/oracle';

  List<TagRecord> _records = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    print("loading");
    final resp = await http.get(Uri.parse(_url));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load tags: ${resp.statusCode}');
    }
    final decoded = jsonDecode(resp.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    if (data is List) {
      _records = data
          .whereType<Map<String, dynamic>>()
          .map(TagRecord.fromJson)
          .where((r) => r.label.isNotEmpty && r.oracleIds.isNotEmpty)
          .toList();
    }
    _loaded = true;
    print("loaded");
  }

  /// Returns list of tag labels for the given card. Call load() first.
  List<String> getTags(String id) {
    if (!_loaded) return const [];
    if (id.isEmpty) return const [];
    final result = <String>[];
    for (final record in _records) {
      if (record.oracleIds.contains(id)) {
        result.add(record.label);
      }
    }
    return result;
  }
}
