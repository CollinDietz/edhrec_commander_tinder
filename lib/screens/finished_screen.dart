import 'dart:convert';
import 'package:edhrec_commander_tinder/screens/commander_select_screen.dart';
import 'package:edhrec_commander_tinder/models/all_commanders.dart';
import 'package:edhrec_commander_tinder/widgets/deck_panel.dart';
import 'package:edhrec_commander_tinder/widgets/stats_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class FinishedScreen extends StatelessWidget {
  const FinishedScreen({super.key});

  String _buildArchidektSandboxUrl(DeckController deckCtrl) {
    if (deckCtrl.deck.isEmpty) return 'https://archidekt.com/sandbox';

    // Aggregate quantities by UUID
    final Map<String, Map<String, dynamic>> byUuid = {};
    byUuid[deckCtrl.commander!.cardInfo.uuid] = {
      'c': 'c', // 'c' for commander, 'm' for main deck
      'f': 0, // format (0 = default sandbox)
      'q': 1, // quantity starts at 1
      'u': deckCtrl.commander!.cardInfo.uuid, // Archidekt card UUID
    };

    for (int i = 0; i < deckCtrl.deck.length; i++) {
      final card = deckCtrl.deck[i];
      final uuid = card.uuid; // CardInfo.uuid assumed non-null & non-empty
      if (byUuid.containsKey(uuid)) {
        byUuid[uuid]!['q'] = (byUuid[uuid]!['q'] as int) + 1;
      } else {
        byUuid[uuid] = {
          'c': 'm', // 'c' for commander, 'm' for main deck
          'f': 0, // format (0 = default sandbox)
          'q': 1, // quantity starts at 1
          'u': uuid, // Archidekt card UUID
        };
      }
    }

    for (int i = 0; i < deckCtrl.basics.length; i++) {
      final card = deckCtrl.basics[i];
      final uuid = card.uuid; // CardInfo.uuid assumed non-null & non-empty
      if (byUuid.containsKey(uuid)) {
        byUuid[uuid]!['q'] = (byUuid[uuid]!['q'] as int) + 1;
      } else {
        byUuid[uuid] = {
          'c': 'm', // 'c' for commander, 'm' for main deck
          'f': 0, // format (0 = default sandbox)
          'q': 1, // quantity starts at 1
          'u': uuid, // Archidekt card UUID
        };
      }
    }

    final cards = byUuid.values.toList();
    final json = jsonEncode(cards); // Proper JSON with quoted keys/values
    final encoded = Uri.encodeComponent(json);
    return 'https://archidekt.com/sandbox?deck=$encoded';
  }

  /// Builds a simple clipboard-friendly list of card counts and names.
  /// Format:
  /// 1 Commander Name
  /// N Card Name
  /// Includes basics.
  String _buildDeckListText(DeckController deckCtrl) {
    final Map<String, int> counts = {};
    final Map<String, String> nameByUuid = {};
    final commander = deckCtrl.commander?.cardInfo;
    if (commander != null) {
      counts[commander.uuid] = (counts[commander.uuid] ?? 0) + 1;
      nameByUuid[commander.uuid] = "${commander.name} [Commander]";
    }
    for (final card in deckCtrl.deck) {
      counts[card.uuid] = (counts[card.uuid] ?? 0) + 1;
      nameByUuid[card.uuid] = card.name;
    }
    for (final card in deckCtrl.basics) {
      counts[card.uuid] = (counts[card.uuid] ?? 0) + 1;
      nameByUuid[card.uuid] = card.name;
    }
    // Sort by name for stable ordering.
    final entries = counts.entries.toList()
      ..sort(
        (a, b) => nameByUuid[a.key]!.toLowerCase().compareTo(
          nameByUuid[b.key]!.toLowerCase(),
        ),
      );
    final buffer = StringBuffer();
    for (final e in entries) {
      buffer.writeln('${e.value} ${nameByUuid[e.key]}');
    }
    return buffer.toString().trim();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckCtrl = context.watch<DeckController>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Deck Complete'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Summary', icon: Icon(Icons.info_outline)),
              Tab(text: 'Deck List', icon: Icon(Icons.list)),
              Tab(text: 'Stats', icon: Icon(Icons.query_stats)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SummaryPane(
              deckCtrl: deckCtrl,
              isMobile: isMobile,
              onLaunch: (mobile) {
                if (mobile) {
                  final listText = _buildDeckListText(deckCtrl);
                  Clipboard.setData(ClipboardData(text: listText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deck list copied to clipboard.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  _launchUrl('https://archidekt.com/sandbox');
                } else {
                  final exportUrl = _buildArchidektSandboxUrl(deckCtrl);
                  _launchUrl(exportUrl);
                }
              },
              onCopy: () {
                final listText = _buildDeckListText(deckCtrl);
                Clipboard.setData(ClipboardData(text: listText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deck list copied to clipboard.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              onReset: () {
                deckCtrl.reset();
                deckCtrl.ensureTaggerLoading();
                // Load cached (or fetch) commander list then navigate.
                AllCommanders.load().then((all) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommanderSelectScreen(commanders: all),
                    ),
                    (route) => false,
                  );
                });
              },
            ),
            const Padding(padding: EdgeInsets.all(8.0), child: DeckPanel()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StatsPanel(deckCtrl: deckCtrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPane extends StatelessWidget {
  final DeckController deckCtrl;
  final bool isMobile;
  final ValueChanged<bool> onLaunch; // param: isMobile
  final VoidCallback onCopy;
  final VoidCallback onReset;
  const _SummaryPane({
    required this.deckCtrl,
    required this.isMobile,
    required this.onLaunch,
    required this.onCopy,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            deckCtrl.commander?.cardInfo.name ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Icon(Icons.layers, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            '${(deckCtrl.deck.length + deckCtrl.basics.length)} / 99 cards',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SvgPicture.asset(
            'assets/icons/draft.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(Colors.green[700]!, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${deckCtrl.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => onLaunch(isMobile),
                child: isMobile
                    ? const Text('Copy + Open Archidekt')
                    : const Text('Open in Archidekt'),
              ),
              ElevatedButton(
                onPressed: onCopy,
                child: const Text('Copy Deck List'),
              ),
              ElevatedButton(
                onPressed: onReset,
                child: const Text('Start Over'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
