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
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 8),
        Text('\$${cost.toStringAsFixed(2)}', style: textStyle),
      ],
    );
  }

  Widget _buildIcon() {
    return SvgPicture.asset(
      'assets/icons/draft.svg',
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(Colors.green[700]!, BlendMode.srcIn),
    );
  }
}
