import 'package:flutter/material.dart';

///
/// Represents a color scheme for a card UI element.
///
class CardColorScheme {
  ///
  /// The main background color of the card.
  ///
  final Color bg;

  ///
  /// A color used for elements directly on the background,
  /// slightly darker than [bg].
  ///
  final Color onBg;

  ///
  /// The color used for the card's border or accent elements.
  ///
  final Color border;

  const CardColorScheme(this.bg, this.onBg, this.border);
}

///
/// A list of pre-defined [CardColorScheme] objects.
///
///
CardColorScheme geLobbyColors(String categoryId) => switch (categoryId) {
      //Sports
      '65c284e138cad50fa012f27f' => const CardColorScheme(
          Color(0xFFFFF0DA),
          Color(0xFFF7D7A9),
          Color(0xFFD5A867),
        ),
//Creative Arts
      '65c285ff4a090a5d03dff77b' => const CardColorScheme(
          Color(0xFFDADCFF),
          Color(0xFFA5A9F7),
          Color(0xFF5C60A8),
        ),
//Adventure Activities
      '65c286374a090a5d03dff77c' => const CardColorScheme(
          Color(0xFFF3E9FF),
          Color(0xFFBEA4DD),
          Color(0xFF72529A),
        ),
//Social & Networking Events
      '65c349962534f676d45c2470' => const CardColorScheme(
          Color(0xFFFFE2E2),
          Color(0xFFF1B7B7),
          Color(0xFFCA5757),
        ),
//Ride & Commute
      '65c34d543fc6eb511299e8b2' => const CardColorScheme(
          Color(0xFFDEF6FF),
          Color(0xFFA3DEF3),
          Color(0xFF50A0BD),
        ),
//Flat & Flatmates
      '65c367c43fc6eb511299e8b6' => const CardColorScheme(
          Color(0xFFE8FFD6),
          Color(0xFFBFE4A3),
          Color(0xFF609535),
        ),
//Music
      '66d17b1b4a496d3b37c8040c' => const CardColorScheme(
          Color(0xFFE2FFF6),
          Color(0xFFA3EFD7),
          Color(0xFF51B092),
        ),
//College
      '66d17d574a496d3b37c8040d' => const CardColorScheme(
          Color(0xFFFFF2B3),
          Color(0xFFF5D744),
          Color(0xFFD7BB2D),
        ),
      _ => defaultColorScheme,
    };

const CardColorScheme defaultColorScheme = CardColorScheme(
  Color(0xFFE2FFF6),
  Color(0xFFA3EFD7),
  Color(0xFF51B092),
);
const List<CardColorScheme> kCardColorSchemes = [
  CardColorScheme(
    Color(0xFFE6F3FF),
    Color(0xFFB8D8F2),
    Color(0xFF4A90E2),
  ),
  CardColorScheme(
    Color(0xFFFFF0E6),
    Color(0xFFFFD6B8),
    Color(0xFFE29A4A),
  ),
  CardColorScheme(
    Color(0xFFE8FFE6),
    Color(0xFFC1F2B8),
    Color(0xFF4AE24A),
  ),
  CardColorScheme(
    Color(0xFFF3E6FF),
    Color(0xFFD8B8F2),
    Color(0xFF904AE2),
  ),
  CardColorScheme(
    Color(0xFFFFE6F3),
    Color(0xFFF2B8D8),
    Color(0xFFE24A90),
  ),
  CardColorScheme(
    Color(0xFFE6FFF9),
    Color(0xFFB8F2E6),
    Color(0xFF4AE2C8),
  ),
  CardColorScheme(
    Color(0xFFE6ECFF),
    Color(0xFFB8CCF2),
    Color(0xFF4A6AE2),
  ),
  CardColorScheme(
    Color(0xFFFFE6E6),
    Color(0xFFF2B8B8),
    Color(0xFFE24A4A),
  ),
];

///
/// The number of pre-defined color schemes available.
///
final int kCardColorSchemeLength = kCardColorSchemes.length;
