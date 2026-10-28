import 'dart:math';

import 'package:globsi/core/data/country.dart';
import 'package:globsi/core/data/name_collation.dart';

/// Continent display order in the flag screens.
const List<Continent> continentOrder = [
  Continent.europe,
  Continent.asia,
  Continent.africa,
  Continent.northAmerica,
  Continent.southAmerica,
  Continent.oceania,
];

/// Countries of [continent] (all when `null`), alphabetical in
/// [languageCode].
List<Country> countriesSorted(
  Iterable<Country> countries,
  String languageCode, {
  Continent? continent,
}) =>
    [
      for (final c in countries)
        if (continent == null || c.continent == continent) c,
    ]..sort(
      (a, b) => compareNames(
        a.name.resolve(languageCode),
        b.name.resolve(languageCode),
        languageCode,
      ),
    );

/// Countries grouped by continent in [continentOrder], each group sorted.
Map<Continent, List<Country>> countriesByContinent(
  Iterable<Country> countries,
  String languageCode,
) => {
  for (final continent in continentOrder)
    continent: countriesSorted(countries, languageCode, continent: continent),
};

/// The flashcard order: alphabetical, or shuffled with [random].
List<Country> flashcardDeck(
  Iterable<Country> countries,
  String languageCode, {
  Continent? continent,
  Random? random,
}) {
  final deck = countriesSorted(countries, languageCode, continent: continent);
  if (random != null) deck.shuffle(random);
  return deck;
}
