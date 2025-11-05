import 'package:commander_tinder/models/card_info.dart';
import 'package:commander_tinder/models/commander.dart';
import 'package:commander_tinder/widgets/card_image.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commander Tinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Commander> _commanderFuture;
  MatchEngine? _matchEngine;
  final List<SwipeItem> swipeItems = [];

  List<Future<CardInfo>?> _cardFutures = [];
  List<CardInfo?> _resolvedCards = [];

  List<CardInfo> deck = [];

  @override
  void initState() {
    super.initState();

    _commanderFuture = Commander.fromUrl(
      'https://json.edhrec.com/pages/commanders/gwen-stacy.json',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Commander>(
      future: _commanderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error:d${snapshot.error}')),
          );
        } else {
          final commander = snapshot.data!;

          if (_matchEngine == null) {
            _cardFutures = List<Future<CardInfo>?>.filled(
              commander.cardJsonUrls.length,
              null,
            );
            _resolvedCards = List<CardInfo?>.filled(
              commander.cardJsonUrls.length,
              null,
            );

            for (int i = 0; i < commander.cardJsonUrls.length; i++) {
              swipeItems.add(
                SwipeItem(
                  content: () {
                    _cardFutures[i] ??= commander.getCard(i);
                    return _cardFutures[i]!;
                  },
                  likeAction: () {
                    _cardFutures[i]?.then((cardInfo) {
                      setState(() {
                        deck.add(cardInfo);
                      });
                    });
                  },
                ),
              );
            }
            _matchEngine = MatchEngine(swipeItems: swipeItems);
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Commander Tinder')),
            body: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        Text("Commander"),
                        Text(commander.name),
                        CardImage(url: commander.image_url),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 1000),
                    child: SwipeCards(
                      matchEngine: _matchEngine!,
                      itemBuilder: (BuildContext context, int index) {
                        // If already resolved, bypass FutureBuilder entirely.
                        final cached = _resolvedCards[index];
                        if (cached != null) {
                          return Container(
                            alignment: Alignment.center,
                            child: CardImage(url: cached.url),
                          );
                        }
                        final future = swipeItems[index].content();
                        return FutureBuilder<CardInfo>(
                          future: future,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData) {
                              return const Text('No data');
                            }
                            final data = snapshot.data!;
                            // Cache result without triggering another rebuild.
                            _resolvedCards[index] = data;
                            return Container(
                              alignment: Alignment.center,
                              child: CardImage(url: data.url),
                            );
                          },
                        );
                      },
                      onStackFinished: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Stack Finished"),
                            duration: Duration(milliseconds: 500),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        Text("Deck"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: deck.length / 99,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.pink,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('${deck.length} / 99'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: deck.length,
                            itemBuilder: (context, index) {
                              final card = deck[index];
                              return ListTile(
                                leading: Image.network(
                                  card.url,
                                  width: 40,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(card.name),
                              );
                            },
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
      },
    );
  }
}
