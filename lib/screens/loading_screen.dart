import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import '../models/all_commanders.dart';
import 'commander_select_screen.dart';

/// Initial loading screen: fetches full commander list and starts Tagger loading.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Future<List<PotentialCommander>> _futureCommanders;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _futureCommanders = AllCommanders.load();
    // Start Tagger loading immediately.
    Provider.of<DeckController>(context, listen: false).ensureTaggerLoading();
  }

  void _goToSelect(List<PotentialCommander> list) {
    if (_navigated) return; // prevent duplicate navigation on rebuilds
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CommanderSelectScreen(commanders: list),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: FutureBuilder<List<PotentialCommander>>(
            future: _futureCommanders,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingSplash();
              }
              if (snapshot.hasError) {
                return _ErrorPanel(
                  error: 'Failed to load commanders: ${snapshot.error}',
                  onRetry: () {
                    AllCommanders.clearCache();
                    setState(() {
                      _futureCommanders = AllCommanders.load();
                    });
                  },
                );
              }
              final list = snapshot.data ?? [];
              _goToSelect(list);
              // Show loader briefly until navigation happens.
              return const _LoadingSplash();
            },
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

class _ErrorPanel extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(28),
      color: Colors.white,
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
            Text(error, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
