import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/models/commander.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'finished_screen.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/commander_card.dart';
import 'package:edhrec_commander_tinder/widgets/deck_panel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edhrec_commander_tinder/widgets/SwipePanel.dart';

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
  int _mobileTab = 0; // 0 = draft, 1 = commander, 2 = deck
  int _currentIndex = 0; // tracks active swipe card index

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
              if ((deckCtrl.deck.length + deckCtrl.basics.length) == 99 &&
                  mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FinishedScreen()),
                );
              }
              if (mounted && _currentIndex == i) {
                setState(() => _currentIndex++);
              }
            });
          },
          nopeAction: () {
            // Advance index on dislike/pass
            if (mounted && _currentIndex == i) {
              setState(() => _currentIndex++);
            }
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
    final isMobile = width < 900;
    return isMobile
        ? _buildMobileLayout(deckCtrl, commander)
        : _buildDesktopLayout(deckCtrl, commander);
  }

  Widget _buildDesktopLayout(DeckController deckCtrl, Commander commander) {
    return Scaffold(
      appBar: AppBar(title: Text('Draft: ${commander.cardInfo.name}')),
      body: Row(
        children: [
          const Expanded(child: CommanderCardPanel()),
          Expanded(
            flex: 2,
            child: SwipePanel(
              showProgressBar: false,
              engine: _engine,
              items: _items,
              resolved: _resolved,
              futures: _futures,
              currentIndex: _currentIndex,
              basicsLength: deckCtrl.basics.length,
              onCardResolved: (i) {
                if (mounted) setState(() {});
              },
            ),
          ),
          const Expanded(child: DeckPanel()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(DeckController deckCtrl, Commander commander) {
    String title;
    switch (_mobileTab) {
      case 1:
        title = 'Commander';
        break;
      case 2:
        title = 'Deck (${deckCtrl.deck.length + deckCtrl.basics.length}/99)';
        break;
      default:
        title = 'Draft: ${commander.cardInfo.name}';
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _buildMobileContent(deckCtrl, commander),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _mobileTab,
        onTap: (i) => setState(() => _mobileTab = i),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/draft.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            label: 'Draft',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Commander',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'Deck',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent(DeckController deckCtrl, Commander commander) {
    switch (_mobileTab) {
      case 1:
        // Commander view
        return CommanderCardPanel();
      case 2:
        // Deck list view
        return const DeckPanel();
      default:
        // Draft swipe view
        return SwipePanel(
          engine: _engine,
          items: _items,
          resolved: _resolved,
          futures: _futures,
          currentIndex: _currentIndex,
          basicsLength: deckCtrl.basics.length,
          onCardResolved: (i) {
            if (mounted) setState(() {});
          },
        );
    }
  }
}

// CommanderCard extracted; placeholder wrapper to keep Expanded usage simple.
class CommanderCardPanel extends StatelessWidget {
  const CommanderCardPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final deckCtrl = context.watch<DeckController>();
    final commander = deckCtrl.commander;
    if (commander == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return CommanderCard(commander: commander);
  }
}

// (Price bar logic moved to widgets/price_bar.dart)
