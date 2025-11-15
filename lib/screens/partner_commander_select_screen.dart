import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/screens/draft_screen.dart';
import 'package:edhrec_commander_tinder/models/all_commanders.dart';

class PotentialSecondaryCommander {
  final String name;
  final String url; // full JSON URL for combined commander pair
  final num numberOfDecks; // inclusion / popularity metric
  final String? imageUrl;
  PotentialSecondaryCommander({
    required this.name,
    required this.url,
    required this.numberOfDecks,
    this.imageUrl,
  });
}

String _slugifyCommanderName(String raw) {
  if (raw.contains('//')) raw = raw.split('//')[0].trim();
  var s = raw.replaceAll('+', ' ').toLowerCase();
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
  s = s.replaceAll(RegExp(r'[:꞉]'), '');
  s = s.replaceAll(RegExp(r"['`]"), "");
  s = s.replaceAll(RegExp(r"[^a-z0-9\s-]"), " ");
  s = s.replaceAll(RegExp(r"\s+"), " ").trim();
  s = s.replaceAll(' ', '-');
  s = s.replaceAll(RegExp(r"-+"), "-");
  return s;
}

class SecondaryCommanderSelectScreen extends StatefulWidget {
  const SecondaryCommanderSelectScreen({super.key});
  @override
  State<SecondaryCommanderSelectScreen> createState() =>
      _SecondaryCommanderSelectScreenState();
}

class _SecondaryCommanderSelectScreenState
    extends State<SecondaryCommanderSelectScreen> {
  late Future<List<PotentialSecondaryCommander>> _future;
  bool _loadingPair = false;

  @override
  void initState() {
    super.initState();
    _future = _loadPartners();
  }

  Future<List<PotentialSecondaryCommander>> _loadPartners() async {
    final deck = context.read<DeckController>();
    final commander = deck.commander;
    if (commander == null) return const [];
    if (!commander.isPartner) return const [];
    final primarySlug = _slugifyCommanderName(commander.cardInfo.name);
    final url = 'https://json.edhrec.com/pages/partners/$primarySlug.json';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load partners (${resp.statusCode})');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final partnerCounts = (data['partnercounts'] as List<dynamic>?);
    if (partnerCounts == null) return const [];
    // Load all commanders for image lookup
    final allCommanders = await AllCommanders.load();
    final List<PotentialSecondaryCommander> list = [];
    for (final raw in partnerCounts) {
      final m = raw as Map<String, dynamic>;
      final name = (m['value'] ?? m['name'] ?? '') as String;
      final rel =
          (m['href'] ?? m['url'] ?? '')
              as String; // e.g. /commanders/other-primary
      if (name.isEmpty || rel.isEmpty) continue;
      final numberOfDecks = (m['inclusion'] ?? m['count'] ?? 0) as num;
      final fullUrl = 'https://json.edhrec.com/pages$rel.json';
      // Find image from allCommanders by name
      String? imageUrl;
      final matches = allCommanders.where(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
      if (matches.isNotEmpty) {
        imageUrl = matches.first.picture;
      }
      list.add(
        PotentialSecondaryCommander(
          name: name,
          url: fullUrl,
          numberOfDecks: numberOfDecks,
          imageUrl: imageUrl,
        ),
      );
    }
    return list;
  }

  Future<void> _select(PotentialSecondaryCommander p) async {
    setState(() => _loadingPair = true);
    final deck = context.read<DeckController>();
    deck.setCommanderUrl(p.url);
    await deck.loadCommander();
    if (!mounted) return;
    setState(() => _loadingPair = false);
    if (deck.loadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load combined partner data')),
      );
      return;
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const DraftScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deck = context.watch<DeckController>();
    final commander = deck.commander;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          commander == null
              ? 'Select Partner'
              : 'Partner for ${commander.cardInfo.name.split('//')[0].trim()}',
        ),
      ),
      body: _loadingPair
          ? const Center(child: CircularProgressIndicator())
          : commander == null
          ? Center(
              child: Text(
                'No primary commander loaded',
                style: theme.textTheme.bodyLarge?.copyWith(color: cs.error),
              ),
            )
          : (!commander.isPartner
                ? Center(
                    child: Text(
                      'Primary commander has no legal partners',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : FutureBuilder<List<PotentialSecondaryCommander>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load partners',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: cs.error,
                            ),
                          ),
                        );
                      }
                      final data = snap.data ?? const [];
                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            'No partners found',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          Widget leading;
                          if (i == 0) {
                            // No Partner: use loaded commander's image
                            String? imageUrl;
                            final cardInfo = commander.cardInfo;

                            imageUrl = cardInfo.smallImageUrls.first;

                            leading = ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            );
                            return Material(
                              color: cs.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const DraftScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      leading,
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'No Partner',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          final p = data[i - 1];
                          leading = p.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    p.imageUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: cs.onSurfaceVariant,
                                  ),
                                );
                          return Material(
                            color: cs.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _select(p),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    leading,
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Number Of Decks: ${p.numberOfDecks}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )),
    );
  }
}
