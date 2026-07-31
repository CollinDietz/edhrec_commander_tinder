import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CostLabel extends StatelessWidget {
  final num cost;
  final TextStyle textStyle;

  const CostLabel({
    super.key,
    required this.cost,
    this.textStyle = const TextStyle(fontWeight: FontWeight.w600),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final style = textStyle == const TextStyle(fontWeight: FontWeight.w600)
        ? theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ) ??
              const TextStyle(fontWeight: FontWeight.w600)
        : textStyle;
    return Tooltip(
      message: 'Estimated deck price',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(cs),
          const SizedBox(width: 8),
          Text('\$${cost.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }

  Widget _buildIcon(ColorScheme cs) {
    return SvgPicture.asset(
      'assets/icons/draft.svg',
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(cs.secondary, BlendMode.srcIn),
    );
  }
}
