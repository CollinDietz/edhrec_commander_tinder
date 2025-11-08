import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/recommendation_stats.dart';

/// InclusionLabel
/// Displays inclusion rate as a percentage plus a fraction-style
/// inclusion / potentialDecks with a horizontal bar.
class InclusionLabel extends StatelessWidget {
  final RecommendationStats stats;
  final int precision;
  final TextStyle textStyle;
  final Color? barColor;
  final double fractionWidth;

  const InclusionLabel({
    super.key,
    required this.stats,
    this.precision = 1,
    this.textStyle = const TextStyle(fontWeight: FontWeight.w600),
    this.barColor,
    this.fractionWidth = 54,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle;
    final percentStr = '${stats.ratioPercent.toStringAsFixed(precision)}%';
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(percentStr, style: style.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        _Fraction(
          numerator: stats.inclusion.toString(),
          denominator: stats.potentialDecks.toString(),
          width: fractionWidth,
          color: barColor ?? (style.color ?? Colors.black54),
          textStyle: style,
        ),
      ],
    );
  }
}

class _Fraction extends StatelessWidget {
  final String numerator;
  final String denominator;
  final double width;
  final Color color;
  final TextStyle? textStyle;
  const _Fraction({
    required this.numerator,
    required this.denominator,
    required this.width,
    required this.color,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(numerator, style: textStyle, textAlign: TextAlign.center),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 1.5,
            color: color,
          ),
          Text(denominator, style: textStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
