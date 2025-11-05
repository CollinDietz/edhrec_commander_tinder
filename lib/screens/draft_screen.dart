import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/widgets/card_image.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'finished_screen.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

class DraftScreen extends StatefulWidget {
  const DraftScreen({super.key});

  @override
  State<DraftScreen> createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  MatchEngine? _engine;
  List<SwipeItem> _items = [];
  List<Future<CardInfo>?> _futures = [];
  List<CardInfo?> _resolved = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deckCtrl = context.watch<DeckController>();
    final commander = deckCtrl.commander;
    if (commander != null && _engine == null) {
      _futures = List.filled(commander.cardJsonUrls.length, null);
      _resolved = List.filled(commander.cardJsonUrls.length, null);
      _items = List.generate(commander.cardJsonUrls.length, (i) {
        return SwipeItem(
          content: () {
            _futures[i] ??= commander.getCard(i);
            return _futures[i]!;
          },
          likeAction: () {
            _futures[i]?.then((c) {
              deckCtrl.addCard(c);
              if (deckCtrl.deck.length == 99 && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FinishedScreen()),
                );
              }
            });
          },
        );
      });
      _engine = MatchEngine(swipeItems: _items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckCtrl = context.watch<DeckController>();
    final commander = deckCtrl.commander;
    if (commander == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Draft: ${commander.name}')),
      body: Row(
        children: [
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    commander.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CardImage(url: commander.image_url),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: _engine == null
                  ? const Center(child: CircularProgressIndicator())
                  : SwipeCards(
                      matchEngine: _engine!,
                      itemBuilder: (context, index) {
                        final cached = _resolved[index];
                        if (cached != null) {
                          return CardImage(url: cached.url);
                        }
                        final future = _items[index].content();
                        return FutureBuilder<CardInfo>(
                          future: future,
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snap.hasError) {
                              return Text('Error');
                            }
                            if (!snap.hasData) {
                              return const Text('No data');
                            }
                            _resolved[index] = snap.data;
                            return CardImage(url: snap.data!.url);
                          },
                        );
                      },
                      onStackFinished: () {
                        if (deckCtrl.deck.length < 99) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No more cards')),
                          );
                        }
                      },
                    ),
            ),
          ),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '${deckCtrl.deck.length} / 99',
                    style: const TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FinishedScreen(),
                        ),
                      );
                    },
                    child: const Text('Finish Early'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: deckCtrl.deck.length,
                      itemBuilder: (_, i) => ListTile(
                        dense: true,
                        title: Text(deckCtrl.deck[i].name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
