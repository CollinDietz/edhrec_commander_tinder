import 'package:flutter/material.dart';
import 'package:edhrec_commander_tinder/models/card_info.dart';

/// Describes a label that can be applied to a card (outline + banner).
class CardLabelDescriptor {
  final String id; // stable key
  final String text; // banner text
  final String shortText; // banner text
  final Color color; // primary color (outline + banner background)
  final bool Function(CardInfo card) predicate; // applies to card?

  const CardLabelDescriptor({
    required this.id,
    required this.text,
    required this.shortText,
    required this.color,
    required this.predicate,
  });
}

/// Registry of all labels (ordered by declaration; priority decides precedence).
/// To add a new label: append a descriptor with a unique id and predicate.
final List<CardLabelDescriptor> kCardLabels = [
  CardLabelDescriptor(
    id: 'game_changer',
    text: 'GAME CHANGER',
    shortText: 'GC',
    color: Colors.redAccent,
    predicate: (c) => c.isGameChanger,
  ),
  CardLabelDescriptor(
    id: 'salty',
    text: 'SALTY',
    shortText: 'SALT',
    color: Colors.orangeAccent,
    predicate: (c) => c.isSalty,
  ),
];

/// Returns the highest-priority matching label for a card, or null.
CardLabelDescriptor? resolveCardLabel(CardInfo card) {
  for (final label in kCardLabels) {
    if (label.predicate(card)) {
      return label;
    }
  }
  return null;
}
