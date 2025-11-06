import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/screens/finished_screen.dart';

class FinishButton extends StatelessWidget {
  final bool enabled;
  const FinishButton({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled
          ? () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FinishedScreen()),
            )
          : null,
      child: const Text('Finish'),
    );
  }
}
