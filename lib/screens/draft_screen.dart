import 'package:edhrec_commander_tinder/widgets/draft_progress_bar.dart';
import 'package:edhrec_commander_tinder/widgets/deck_composition_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'package:edhrec_commander_tinder/models/commander.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'finished_screen.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/widgets/card_with_info.dart';
import 'package:edhrec_commander_tinder/widgets/deck_panel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edhrec_commander_tinder/widgets/swipe_panel.dart';

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
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deckCtrl = context.watch<DeckController>();
    final commander = deckCtrl.commander;
    if (commander != null && _engine == null) {
      _futures = List.filled(commander.cardStats.length, null);
      _resolved = List.filled(commander.cardStats.length, null);
      _items = List.generate(commander.cardStats.length, (i) {
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
            });
          },
        );
      });
      _engine = MatchEngine(swipeItems: _items);
      _currentIndex = 0;
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
      endDrawer: DeckCompositionDrawer(deckCtrl: deckCtrl),
      body: Row(
        children: [
          const Expanded(child: CommanderCardPanel()),
          Expanded(
            flex: 2,
            child: SwipePanel(
              engine: _engine,
              items: _items,
              resolved: _resolved,
              futures: _futures,
              basicsLength: deckCtrl.basics.length,
              onCardResolved: (i) {
                if (mounted) setState(() {});
              },
              onItemChanged: (i) {
                if (mounted) setState(() => _currentIndex = i);
              },
              currentIndex: _currentIndex,
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                DraftProgressBar(),
                Expanded(child: DeckPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(DeckController deckCtrl, Commander commander) {
    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: DraftProgressBar(),
        ),
      ),
      drawer: DeckCompositionDrawer(deckCtrl: deckCtrl),
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
          basicsLength: deckCtrl.basics.length,
          onCardResolved: (i) {
            if (mounted) setState(() {});
          },
          onItemChanged: (i) {
            if (mounted) setState(() => _currentIndex = i);
          },
          currentIndex: _currentIndex,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Target ideal width/height based on typical card aspect ratio.
        const double idealWidth = 320;
        const double aspect = 88 / 63; // card height/width approx
        final double idealHeight =
            idealWidth * aspect + 140; // image + info area

        // Compute scale so content fits within available constraints.
        final scaleW = constraints.maxWidth / idealWidth;
        final scaleH = constraints.maxHeight / idealHeight;
        final scale = scaleW < scaleH ? scaleW : scaleH;

        // Clamp scale to not blow up excessively.
        final appliedScale = scale.clamp(0.2, 1.0);

        return Center(
          child: Transform.scale(
            scale: appliedScale.toDouble(),
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: idealWidth),
              child: CardWithInfo(card: commander.cardInfo),
            ),
          ),
        );
      },
    );
  }
}
