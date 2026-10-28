import 'dart:math';

import 'package:globsi/core/data/country.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';

/// One question: identify [answer] among [options] (shuffled, includes
/// [answer], no duplicates).
class Question {
  const new({required this.answer, required this.options});

  final Country answer;
  final List<Country> options;
}

/// Builds practice rounds from the country list.
class QuestionGenerator {
  new({
    required List<Country> countries,
    required this.filter,
    required this.mode,
    Random? random,
  }) : _all = countries,
       _byId = {for (final c in countries) c.id: c},
       _random = random ?? Random(),
       pool = [
         for (final c in countries)
           if (filter.matches(c)) c,
       ];

  static const int roundLength = 10;
  static const int optionCount = 4;

  final List<Country> _all;
  final Map<String, Country> _byId;
  final Random _random;
  final PracticeFilter filter;
  final PracticeMode mode;

  /// Countries the filter allows as answers.
  final List<Country> pool;

  /// Questions for one round: up to [roundLength] different countries from
  /// [pool]. Shorter when the pool is smaller.
  List<Question> generateRound() {
    final answers = [...pool]..shuffle(_random);
    return [
      for (final answer in answers.take(roundLength))
        Question(answer: answer, options: _optionsFor(answer)),
    ];
  }

  List<Country> _optionsFor(Country answer) {
    final chosen = <Country>[answer];
    final seen = {answer.id};

    void takeFrom(Iterable<Country> candidates) {
      final list = candidates.where((c) => !seen.contains(c.id)).toList()
        ..shuffle(_random);
      for (final c in list) {
        if (chosen.length >= optionCount) return;
        if (seen.add(c.id)) chosen.add(c);
      }
    }

    if (filter.similarChoices) {
      Iterable<Country> ids(List<String> list) => [
        for (final id in list) ?_byId[id],
      ];
      final similarFlags = ids(answer.similarTo);
      final neighbours = ids(answer.neighbors);
      // Flags are confused by look, places by location: look-alike flags
      // only help in flag questions.
      [
        if (mode == PracticeMode.flag) similarFlags,
        neighbours,
        pool.where((c) => c.continent == answer.continent),
        _all.where((c) => c.continent == answer.continent),
      ].forEach(takeFrom);
    } else {
      takeFrom(pool);
    }
    // Small pools: fill up from all countries.
    takeFrom(_all);
    return chosen..shuffle(_random);
  }
}
