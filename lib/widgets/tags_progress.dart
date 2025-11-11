import 'package:edhrec_commander_tinder/models/card_info.dart';
import 'package:edhrec_commander_tinder/models/tagger.dart';
import 'package:flutter/material.dart';

class TagAnnotation {
  final String tag;
  final int targetCount;
  final Color color;

  const TagAnnotation({
    required this.tag,
    required this.targetCount,
    required this.color,
  });

  /// Returns true if the card's tags satisfy this annotation.
  /// If the annotation `tag` ends with a hyphen (e.g. `protects-`) it matches
  /// any card tag that starts with that prefix; otherwise it requires an exact
  /// match.
  bool matches(CardInfo card) {
    if (tag.contains(' OR ')) {
      final parts = tag
          .split(' OR ')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty);
      for (final part in parts) {
        if (_singleMatches(card, part)) return true;
      }
      return false;
    }
    return _singleMatches(card, tag);
  }

  bool _singleMatches(CardInfo card, String raw) {
    if (raw.endsWith('-')) {
      final prefix = raw;
      return card.tags.any((t) => t.startsWith(prefix));
    }
    return card.tags.contains(raw);
  }

  /// Counts how many cards in the provided list satisfy this annotation.
  int countIn(Iterable<CardInfo> cards) => cards.where(matches).length;
}

const tagCounts = [
  TagAnnotation(tag: 'card-advantage', targetCount: 12, color: Colors.indigo),
  TagAnnotation(
    tag: 'removal OR counterspell',
    targetCount: 12,
    color: Colors.deepOrange,
  ),
  TagAnnotation(tag: 'ramp', targetCount: 10, color: Colors.green),
  TagAnnotation(tag: 'life-gain', targetCount: 3, color: Colors.pinkAccent),
  TagAnnotation(tag: 'protects-', targetCount: 3, color: Colors.amber),
  TagAnnotation(tag: 'recursion', targetCount: 3, color: Colors.teal),
  TagAnnotation(tag: 'sweeper', targetCount: 3, color: Colors.black87),
];

class TagsProgress extends StatelessWidget {
  final List<CardInfo> cards;
  const TagsProgress({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    // If tagger not yet loaded show a compact progress indicator.
    if (!Tagger.instance.isLoaded) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final tag in tagCounts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TagProgress(
              tag: tag.tag,
              color: tag.color,
              count: tag.countIn(cards),
              total: tag.targetCount,
            ),
          ),
      ],
    );
  }
}

class _TagProgress extends StatelessWidget {
  final String tag;
  final Color color;
  final int count;
  final int total;
  const _TagProgress({
    required this.tag,
    required this.color,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tag
                      .split(RegExp(r'[\s-]+'))
                      .map(
                        (part) => part.isEmpty
                            ? part
                            : '${part[0].toUpperCase()}${part.substring(1)}',
                      )
                      .join(' '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('$count of $total', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: (count / total).clamp(0, 1),
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
