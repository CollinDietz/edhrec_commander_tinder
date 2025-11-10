import 'package:flutter/foundation.dart';
import 'package:edhrec_commander_tinder/models/commander.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

class DeckController extends ChangeNotifier {
  String? _commanderUrl;
  Commander? _commander;
  final List<CardInfo> _deck = [];
  final List<CardInfo> _basics = [];
  bool _loadingCommander = false;
  Object? _loadError;

  String? get commanderUrl => _commanderUrl;
  Commander? get commander => _commander;
  List<CardInfo> get deck => List.unmodifiable(_deck);
  List<CardInfo> get basics => List.unmodifiable(_basics);
  bool get loadingCommander => _loadingCommander;
  Object? get loadError => _loadError;

  void setCommanderUrl(String url) {
    final commanderId = url.trim().replaceFirst(
      RegExp(r'^https:\/\/edhrec\.com\/commanders\/'),
      '',
    );
    _commanderUrl =
        'https://json.edhrec.com/pages/commanders/$commanderId.json';
    _commander = null;
    _deck.clear();
    _loadError = null;
    notifyListeners();
  }

  Future<void> loadCommander() async {
    final url = _commanderUrl;
    if (url == null || url.isEmpty || _loadingCommander) return;
    _loadingCommander = true;
    _loadError = null;
    notifyListeners();
    try {
      _commander = await Commander.fromUrl(url);
      _basics.clear();
      final currentCommander = _commander;
      final urls = currentCommander?.basicsUrls ?? const [];
      for (final u in urls) {
        CardInfo.fromUrlAndStats(u, null)
            .then((card) {
              if (!identical(currentCommander, _commander)) return;
              _basics.add(card);
              notifyListeners();
            })
            .catchError((_) {
              // Ignore individual basic load errors.
            });
      }
    } catch (e) {
      _loadError = e;
    } finally {
      _loadingCommander = false;
      notifyListeners();
    }
  }

  void addCard(CardInfo card) {
    if (_deck.length >= 99) return;
    _deck.add(card);
    notifyListeners();
  }

  void reset() {
    _commanderUrl = null;
    _commander = null;
    _deck.clear();
    _loadError = null;
    notifyListeners();
  }

  double get price =>
      deck.fold<double>(0, (sum, card) => sum + (card.price)) +
      basics.fold<double>(0, (sum, card) => sum + (card.price)) +
      (commander != null ? commander!.cardInfo.price : 0);
}
