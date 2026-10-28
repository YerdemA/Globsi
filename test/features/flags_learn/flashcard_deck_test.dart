import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/features/flags_learn/flashcard_deck.dart';

void main() {
  final countries = [
    for (final c in (jsonDecode(
      File('assets/data/countries.json').readAsStringSync(),
    ) as List).cast<Map<String, Object?>>())
      Country.fromJson(c),
  ];

  test('groups every country under its continent in display order', () {
    final groups = countriesByContinent(countries, 'tr');
    expect(groups.keys.toList(), continentOrder);
    expect(groups.values.fold(0, (n, g) => n + g.length), countries.length);
    for (final MapEntry(:key, :value) in groups.entries) {
      expect(value.every((c) => c.continent == key), isTrue);
    }
  });

  test('groups are alphabetical in the app language', () {
    final europe = countriesByContinent(
      countries,
      'tr',
    )[Continent.europe]!.map((c) => c.name.tr).toList();
    expect(europe.first, 'Almanya');
    expect(europe.indexOf('Çekya'), greaterThan(europe.indexOf('Belçika')));
    expect(europe.indexOf('Çekya'), lessThan(europe.indexOf('Danimarka')));
    expect(europe.last, 'Yunanistan');
  });

  test('the deck filters by continent', () {
    final deck = flashcardDeck(countries, 'en', continent: Continent.oceania);
    expect(deck, hasLength(14));
    expect(deck.first.name.en, 'Australia');
  });

  test('shuffling is reproducible with a seed and keeps every card', () {
    final a = flashcardDeck(countries, 'tr', random: Random(7));
    final b = flashcardDeck(countries, 'tr', random: Random(7));
    final sorted = flashcardDeck(countries, 'tr');
    expect(a.map((c) => c.id), b.map((c) => c.id));
    expect(a.map((c) => c.id), isNot(sorted.map((c) => c.id)));
    expect(a.map((c) => c.id).toSet(), sorted.map((c) => c.id).toSet());
  });
}
