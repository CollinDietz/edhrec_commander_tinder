import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/models/commander.dart';
import 'package:edhrec_commander_tinder/widgets/card_image.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'finished_screen.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900; // breakpoint
    return isMobile
        ? _buildMobileLayout(deckCtrl, commander)
        : _buildDesktopLayout(deckCtrl, commander);
  }

  Widget _buildDesktopLayout(DeckController deckCtrl, Commander commander) {
    return Scaffold(
      appBar: AppBar(title: Text('Draft: ${commander.cardInfo.name}')),
      body: Row(
        children: [
          Expanded(child: _buildCommanderCard(commander)),
          Expanded(flex: 2, child: _buildSwipeArea(deckCtrl)),
          Expanded(child: _buildDeckPanel(deckCtrl)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(DeckController deckCtrl, Commander commander) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            // Replace the icon below with any Material icon you prefer
            // or swap with a CircleAvatar to show the commander art.
            icon: const Icon(Icons.shield),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Show Commander',
          ),
        ),
        title: Text('Draft: ${commander.cardInfo.name}'),
      ),
      drawer: _buildCommanderCard(commander),
      endDrawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: _buildDeckPanel(deckCtrl),
      ),
      body: Column(
        children: [
          _buildDeckSummaryBar(deckCtrl),
          Expanded(child: _buildSwipeArea(deckCtrl)),
        ],
      ),
    );
  }

  Widget _buildCommanderCard(Commander commander) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              commander.cardInfo.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            _buildCard(commander.cardInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(CardInfo card) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CardImage(url: card.image_url),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/draft.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  Colors.green[700]!,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${card.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeArea(DeckController deckCtrl) {
    if (_engine == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SwipeCards(
      matchEngine: _engine!,
      itemBuilder: (context, index) {
        final cached = _resolved[index];
        if (cached != null) {
          return Card(child: _buildCard(cached));
        }
        final future = _items[index].content();
        return FutureBuilder<CardInfo>(
          future: future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text('Error'));
            }
            if (!snap.hasData) {
              return const Center(child: Text('No data'));
            }
            _resolved[index] = snap.data;
            return Card(child: _buildCard(snap.data!));
          },
        );
      },
      onStackFinished: () {
        if (deckCtrl.deck.length < 99) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No more cards')));
        }
      },
    );
  }

  Widget _buildDeckPanel(DeckController deckCtrl) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Spacer(),
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
                      Spacer(),
                      SvgPicture.asset(
                        'assets/icons/draft.svg',
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          Colors.green[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${(deckCtrl.deck.fold<double>(0, (sum, card) => sum + (card.price)) + deckCtrl.commander!.cardInfo.price).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              value: deckCtrl.deck.length / 99,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FinishedScreen()),
                );
              },
              child: const Text('Finish Early'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckSummaryBar(DeckController deckCtrl) {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.layers, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text('${deckCtrl.deck.length} / 99'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: LinearProgressIndicator(
                  value: deckCtrl.deck.length / 99,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FinishedScreen()),
                );
              },
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
