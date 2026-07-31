import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/deck_controller.dart';
import 'screens/loading_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DeckController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commander Tinder',
      theme: AppTheme.dark, // dark mode primary theme
      darkTheme: AppTheme.dark, // identical for now; can add light later
      themeMode: ThemeMode.dark,
      home: const LoadingScreen(),
    );
  }
}
