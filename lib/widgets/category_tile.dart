import 'package:flutter/material.dart';

const categoryColors = <String, Color>{
  'Creature': Colors.green,
  'Instant': Colors.blue,
  'Sorcery': Colors.deepPurple,
  'Artifact': Colors.grey,
  'Enchantment': Colors.pink,
  'Planeswalker': Colors.orange,
  'Land': Colors.brown,
};

class CategoryTile extends StatelessWidget {
  final String category;
  final Widget child;
  const CategoryTile({required this.child, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: child,
      tileColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: categoryColors[category]!.withOpacity(1),
          width: 1, // thicker border
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      // dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
