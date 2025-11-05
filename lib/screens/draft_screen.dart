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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          commander.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(child: CardImage(url: commander.image_url)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Card(
              child: _engine == null
                  ? const Center(child: CircularProgressIndicator())
                  : SwipeCards(
                      matchEngine: _engine!,
                      itemBuilder: (context, index) {
                        final cached = _resolved[index];
                        if (cached != null) {
                          return Center(
                            child: CardImage(url: cached.image_url),
                          );
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
                            return Center(
                              child: CardImage(url: snap.data!.image_url),
                            );
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.layers, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          '${deckCtrl.deck.length} / 99 cards',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(
                      value: deckCtrl.deck.length / 99,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: deckCtrl.deck.length,
                      itemBuilder: (_, i) => Card(
                        child: ListTile(
                          leading: Image.network(
                            deckCtrl.deck[i].small_image_url,
                            fit: BoxFit.cover,
                          ),
                          title: Text(deckCtrl.deck[i].name),
                        ),
                      ),
                    ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
