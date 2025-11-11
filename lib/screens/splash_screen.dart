import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'draft_screen.dart';
import '../models/all_commanders.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _error;
  final FocusNode _fieldFocus = FocusNode();
  late Future<List<PotentialCommander>> _futureCommanders;
  List<PotentialCommander> _all = [];
  PotentialCommander? _selected;

  @override
  void initState() {
    super.initState();
    _futureCommanders = AllCommanders.load();
  }

  @override
  void dispose() {
    _fieldFocus.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: FutureBuilder<List<PotentialCommander>>(
                future: _futureCommanders,
                builder: (context, snapshot) {
                  Widget child;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    child = const _LoadingSplash();
                  } else if (snapshot.hasError) {
                    child = _ErrorPanel(
                      error: 'Failed to load commanders: ${snapshot.error}',
                    );
                  } else {
                    _all = snapshot.data ?? [];
                    child = _LoadedSelectorPanel(
                      all: _all,
                      fieldFocus: _fieldFocus,
                      nameController: _nameController,
                      selected: _selected,
                      error: _error,
                      loadingDeck: deck.loadingCommander,
                      onSelected: (c) => setState(() {
                        _selected = c;
                        _nameController.text = c.name;
                        _nameController.selection = TextSelection.collapsed(
                          offset: c.name.length,
                        );
                      }),
                      onClear: () => setState(() {
                        _selected = null;
                        _nameController.clear();
                      }),
                      onStart: () async {
                        if (_selected == null) {
                          setState(() => _error = 'Please pick a commander');
                          return;
                        }
                        setState(() => _error = null);
                        final resolved = await _resolveEdhrecUrl(
                          _selected!.url,
                        );
                        deck.setCommanderUrl(resolved);
                        final navigator = Navigator.of(context);
                        await deck.loadCommander();
                        if (deck.loadError != null) {
                          if (!mounted) return;
                          setState(() => _error = 'Failed to load commander');
                          return;
                        }
                        if (!mounted) return;
                        navigator.pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const DraftScreen(),
                          ),
                        );
                      },
                    );
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: child,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated loading splash used while commander list is fetched.
class _LoadingSplash extends StatefulWidget {
  const _LoadingSplash();

  @override
  State<_LoadingSplash> createState() => _LoadingSplashState();
}

class _LoadingSplashState extends State<_LoadingSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.05,
    ).animate(CurvedAnimation(curve: Curves.easeInOut, parent: _controller));
    _rotate = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(curve: Curves.linear, parent: _controller));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotate.value * 2 * 3.1415926535,
                child: Transform.scale(scale: _pulse.value, child: child),
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F6AA3), Color(0xFF2F3E55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 54,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Loading commanders…',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 220,
            child: LinearProgressIndicator(
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: 0.6,
            child: Text(
              'Fetching full legal commander index…',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error panel used when commander list fails to load.
class _ErrorPanel extends StatelessWidget {
  final String error;
  const _ErrorPanel({required this.error});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SurfacePanel(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                SizedBox(width: 12),
                Text(
                  'Load Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => AllCommanders.clearCache(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel shown once commanders are loaded.
class _LoadedSelectorPanel extends StatelessWidget {
  final List<PotentialCommander> all;
  final FocusNode fieldFocus;
  final TextEditingController nameController;
  final PotentialCommander? selected;
  final String? error;
  final bool loadingDeck;
  final ValueChanged<PotentialCommander> onSelected;
  final VoidCallback onClear;
  final VoidCallback onStart;
  const _LoadedSelectorPanel({
    required this.all,
    required this.fieldFocus,
    required this.nameController,
    required this.selected,
    required this.error,
    required this.loadingDeck,
    required this.onSelected,
    required this.onClear,
    required this.onStart,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SurfacePanel(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Commander Tinder',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search a commander to start drafting recommendations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            RawAutocomplete<PotentialCommander>(
              focusNode: fieldFocus,
              textEditingController: nameController,
              displayStringForOption: (o) => o.name,
              optionsBuilder: (TextEditingValue value) {
                final query = value.text.trim().toLowerCase();
                if (query.isEmpty) return all.take(20);
                return all
                    .where((c) => c.name.toLowerCase().contains(query))
                    .take(25);
              },
              onSelected: onSelected,
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Commander Name (${all.length} loaded)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: selected != null
                            ? IconButton(
                                tooltip: 'Clear selection',
                                icon: const Icon(Icons.clear),
                                onPressed: onClear,
                              )
                            : null,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onFieldSubmitted(),
                    );
                  },
              optionsViewBuilder: (context, onSel, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 380,
                        minWidth: 480,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final opt = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSel(opt),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 42,
                                    height: 42,
                                    child:
                                        (opt.picture != null &&
                                            opt.picture!.isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              opt.picture!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: const Color(
                                              0xFFE1E8EF,
                                            ),
                                            child: Text(
                                              opt.name.isNotEmpty
                                                  ? opt.name[0]
                                                  : '?',
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      opt.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: loadingDeck
                  ? const Center(child: CircularProgressIndicator())
                  : FloatingActionButton(
                      onPressed: onStart,
                      child: Icon(Icons.play_arrow),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frosted/glass effect panel wrapper.
class _SurfacePanel extends StatelessWidget {
  final Widget child;
  const _SurfacePanel({required this.child});
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(28),
      color: Colors.white,
      child: child,
    );
  }
}

/// Performs a HEAD/GET request to the EDHREC route endpoint without following redirects
/// and extracts the canonical commanders/<slug> URL from the HTML body.
Future<String> _resolveEdhrecUrl(String routeUrl) async {
  final uri = Uri.parse(routeUrl);
  // If already canonical just return.
  if (uri.path.contains('/commanders/')) return routeUrl;
  try {
    final resp = await http.get(
      uri,
      headers: {'User-Agent': 'CommanderTinder/1.0 (Flutter)'},
    );
    // http automatically follows redirects; check final request URL.
    final finalUrl = resp.request?.url;
    if (finalUrl != null && finalUrl.path.contains('/commanders/')) {
      return 'https://edhrec.com${finalUrl.path}';
    }
    // If not redirected, attempt slugify from cc query param.
    final cc = uri.queryParameters['cc'];
    if (cc != null && cc.isNotEmpty) {
      final slug = _slugifyCommanderName(cc);
      return 'https://edhrec.com/commanders/$slug';
    }
    return routeUrl;
  } catch (_) {
    // Graceful fallback.
    final cc = uri.queryParameters['cc'];
    if (cc != null && cc.isNotEmpty) {
      final slug = _slugifyCommanderName(cc);
      return 'https://edhrec.com/commanders/$slug';
    }
    return routeUrl;
  }
}

String _slugifyCommanderName(String raw) {
  var s = raw.replaceAll('+', ' ');
  s = s.toLowerCase();
  // Remove apostrophes/backticks
  s = s.replaceAll(RegExp(r"['`]"), "");
  // Replace non-alphanumeric (except space & hyphen) with space
  s = s.replaceAll(RegExp(r"[^a-z0-9\s-]"), " ");
  // Collapse whitespace
  s = s.replaceAll(RegExp(r"\s+"), " ").trim();
  s = s.replaceAll(' ', '-');
  // Collapse multiple hyphens
  s = s.replaceAll(RegExp(r"-+"), "-");
  return s;
}
