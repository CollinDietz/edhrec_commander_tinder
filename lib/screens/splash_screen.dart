import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'draft_screen.dart';

// A more polished splash/onboarding screen allowing the user to paste a commander URL
// with improved styling & validation feedback.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController(
    text: 'https://edhrec.com/commanders/',
  );
  String? _loadError;
  bool _submitted = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter a commander URL';
    if (!v.startsWith('https://edhrec.com/commanders/')) {
      return 'Must start with https://edhrec.com/commanders/';
    }
    return null;
  }

  Future<void> _startDraft(DeckController deck) async {
    setState(() {
      _submitted = true;
      _loadError = null;
    });
    final navigator = Navigator.of(context);
    deck.setCommanderUrl(_urlController.text.trim());
    await deck.loadCommander();
    if (!mounted) return;
    if (deck.loadError != null) {
      setState(() => _loadError = 'Failed to load commander');
      return;
    }
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const DraftScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckController>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Commander Tinder')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LogoHeader(light: true),
                const SizedBox(height: 24),
                _LightPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Enter Commander URL',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _urlController,
                          autofocus: true,
                          autovalidateMode: _submitted
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          validator: _validateUrl,
                          decoration: InputDecoration(
                            labelText: 'https://edhrec.com/commanders/...',
                            prefixIcon: const Icon(Icons.link),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textInputAction: TextInputAction.go,
                          onFieldSubmitted: (_) {
                            if (_formKey.currentState?.validate() ?? false) {
                              _startDraft(deck);
                            } else {
                              setState(() => _submitted = true);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _urlController.text =
                                    'https://edhrec.com/commanders/';
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Find a Commander URL'),
                                    content: const Text(
                                      'Navigate to a commander on EDHREC and copy its page URL.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.help_outline),
                              label: const Text('Help'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: deck.loadingCommander
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  key: const ValueKey('startBtn'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() => _submitted = true);
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _startDraft(deck);
                                    }
                                  },
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text(
                                    'Start Draft',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        if (_loadError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              _loadError!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    'v1.0 • Powered by EDHREC & Scryfall',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Logo header adapted for light theme.
class _LogoHeader extends StatelessWidget {
  final bool light;
  const _LogoHeader({this.light = false});

  @override
  Widget build(BuildContext context) {
    final isLight = light;
    final bgGradient = isLight
        ? const LinearGradient(colors: [Color(0xFFE3E7F0), Color(0xFFCBD3E4)])
        : const LinearGradient(colors: [Color(0xFF3F4C77), Color(0xFF1F2335)]);
    final iconColor = isLight ? const Color(0xFF374151) : Colors.white;
    final titleColor = isLight ? const Color(0xFF1F2937) : Colors.white;
    final subtitleColor = isLight ? const Color(0xFF4B5563) : Colors.white70;
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12, width: 2),
            gradient: bgGradient,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Icon(Icons.auto_awesome, size: 42, color: iconColor),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Commander Tinder',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Draft smarter. Brew faster.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
        ),
      ],
    );
  }
}

// Light panel wrapper with subtle elevation.
class _LightPanel extends StatelessWidget {
  final Widget child;
  const _LightPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black12),
        ),
        child: child,
      ),
    );
  }
}
