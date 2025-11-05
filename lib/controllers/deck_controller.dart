import 'package:flutter/foundation.dart';
import 'package:edhrec_commander_tinder/models/commander.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

class DeckController extends ChangeNotifier {
  String? _commanderUrl;
  Commander? _commander;
  final List<CardInfo> _deck = [];
  bool _loadingCommander = false;
  Object? _loadError;

  String? get commanderUrl => _commanderUrl;
  Commander? get commander => _commander;
  List<CardInfo> get deck => List.unmodifiable(_deck);
  bool get loadingCommander => _loadingCommander;
  Object? get loadError => _loadError;

  void setCommanderUrl(String url) {
    _commanderUrl = url.trim();
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
}
