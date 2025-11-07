import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/screens/finished_screen.dart';

class FinishButton extends StatelessWidget {
  const FinishButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FinishedScreen()),
      ),
      child: const Text('Finish'),
    );
  }
}
