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

  // Returns list of each unique basic card with its count.
  List<MapEntry<CardInfo, int>> get basicsWithCounts {
    final map = <CardInfo, int>{};
    for (final card in _basics) {
      map[card] = (map[card] ?? 0) + 1;
    }
    return map.entries.toList(growable: false);
  }

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

      final futures = urls.map((u) async {
        try {
          return await CardInfo.fromUrlAndStats(u, null);
        } catch (_) {
          return null;
        }
      }).toList();

      final loaded = await Future.wait(futures);

      if (!identical(currentCommander, _commander)) return;

      final basicsList = loaded.whereType<CardInfo>().toList();
      _basics.addAll(basicsList);
      while (_basics.length < 38 && basicsList.isNotEmpty) {
        _basics.add(basicsList[_basics.length % basicsList.length]);
      }
      notifyListeners();
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

  bool removeCard(CardInfo card) {
    // Attempt removal from deck first; basics are generally auto-generated.
    final index = _deck.indexWhere(
      (c) => identical(c, card) || c.uuid == card.uuid,
    );
    if (index != -1) {
      _deck.removeAt(index);
      notifyListeners();
      return true;
    }
    // Allow removal of a single instance of a basic if explicitly requested.
    final basicIndex = _basics.indexWhere(
      (c) => identical(c, card) || c.uuid == card.uuid,
    );
    if (basicIndex != -1) {
      _basics.removeAt(basicIndex);
      notifyListeners();
      return true;
    }
    return false;
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
