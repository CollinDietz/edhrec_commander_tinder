import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/screens/finished_screen.dart';

class FinishButton extends StatelessWidget {
  final bool compact;
  const FinishButton({super.key, this.compact = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Finish drafting and view deck summary',
      child: ElevatedButton.icon(
        icon: Icon(Icons.flag, size: compact ? 16 : 18, color: cs.onPrimary),
        label: Text(
          'Finish',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: cs.onPrimary,
            fontSize: compact ? 12 : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 16,
            vertical: compact ? 6 : 10,
          ),
          minimumSize: compact ? const Size(72, 34) : const Size(96, 40),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.surfaceVariant,
          disabledForegroundColor: cs.onSurfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FinishedScreen()),
        ),
      ),
    );
  }
}
