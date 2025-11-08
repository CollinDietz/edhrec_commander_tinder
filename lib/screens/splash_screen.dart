import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import 'draft_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _textController = TextEditingController(
    text: "https://edhrec.com/commanders/",
  );
  String? _error;

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Commander Tinder')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Commander JSON URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              deck.loadingCommander
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final url = _textController.text.trim();
                        if (url.isEmpty) {
                          setState(() => _error = 'Please enter a URL');
                          return;
                        }

                        if (!url.startsWith('https://edhrec.com/commanders/')) {
                          setState(
                            () => _error =
                                'URL must start with https://edhrec.com/commanders/',
                          );
                          return;
                        }
                        setState(() => _error = null);
                        deck.setCommanderUrl(url);
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
                      child: const Text('Start Draft'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
