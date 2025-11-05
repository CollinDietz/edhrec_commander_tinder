import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:commander_tinder/controllers/deck_controller.dart';
import 'splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FinishedScreen extends StatelessWidget {
  const FinishedScreen({super.key});

  String _buildArchidektSandboxUrl(DeckController deckCtrl) {
    if (deckCtrl.deck.isEmpty) return 'https://archidekt.com/sandbox';

    // Aggregate quantities by UUID
    final Map<String, Map<String, dynamic>> byUuid = {};
    byUuid[deckCtrl.commander!.uuid] = {
      'c': 'c', // 'c' for commander, 'm' for main deck
      'f': 0, // format (0 = default sandbox)
      'q': 1, // quantity starts at 1
      'u': deckCtrl.commander!.uuid, // Archidekt card UUID
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

    final cards = byUuid.values.toList();
    final json = jsonEncode(cards); // Proper JSON with quoted keys/values
    final encoded = Uri.encodeComponent(json);
    return 'https://archidekt.com/sandbox?deck=$encoded';
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
    final exportUrl = _buildArchidektSandboxUrl(deckCtrl);

    return Scaffold(
      appBar: AppBar(title: const Text('Deck Complete')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commander: ${deckCtrl.commander?.name ?? ''}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Total cards selected: ${deckCtrl.deck.length}'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: deckCtrl.deck.isEmpty
                      ? null
                      : () => _launchUrl(exportUrl),
                  child: const Text('Open in Archidekt Sandbox'),
                ),
                ElevatedButton(
                  onPressed: () {
                    deckCtrl.reset();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Start Over'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              exportUrl,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: deckCtrl.deck.length,
                itemBuilder: (_, i) =>
                    ListTile(dense: true, title: Text(deckCtrl.deck[i].name)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
