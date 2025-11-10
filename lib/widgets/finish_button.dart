import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/screens/finished_screen.dart';

class FinishButton extends StatelessWidget {
  const FinishButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(64, 32),
        textStyle: const TextStyle(fontSize: 12),
      ),
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FinishedScreen()),
      ),
      child: const Text('Finish'),
    );
  }
}
