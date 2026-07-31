import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String category;
  final Widget child;
  const CategoryTile({super.key, required this.child, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Derive category colors from current theme; keeps palette cohesive and supports dark/light.
    final categoryColors = <String, Color>{
      'Creature': cs.secondary,
      'Instant': cs.primary,
      'Sorcery': cs.tertiary,
      'Artifact': cs.outlineVariant,
      'Enchantment': cs.primaryContainer,
      'Planeswalker': cs.secondaryContainer,
      'Land': cs.surfaceTint, // subtle accent
    };
    final borderColor = categoryColors[category] ?? cs.onSurfaceVariant;

    return ListTile(
      title: child,
      tileColor: cs.surfaceVariant.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: borderColor,
          width: 1, // thicker border
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      // dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
