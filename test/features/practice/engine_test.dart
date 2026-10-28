import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/engine/question_generator.dart';
import 'package:globsi/features/practice/engine/round_state.dart';

void main() {
  final countries = [
    for (final c in (jsonDecode(
      File('assets/data/countries.json').readAsStringSync(),
    ) as List).cast<Map<String, Object?>>())
      Country.fromJson(c),
  ];
  final byId = {for (final c in countries) c.id: c};

  QuestionGenerator generator(
    PracticeFilter filter, {
    PracticeMode mode = PracticeMode.flag,
    int seed = 1,
  }) => QuestionGenerator(
    countries: countries,
    filter: filter,
    mode: mode,
    random: Random(seed),
  );

  /// Checks the invariants every round must satisfy.
  void expectValidRound(List<Question> round, QuestionGenerator g) {
    final expectedLength = min(QuestionGenerator.roundLength, g.pool.length);
    expect(round, hasLength(expectedLength));
    expect(
      round.map((q) => q.answer.id).toSet(),
      hasLength(round.length),
      reason: 'a country is asked twice',
    );
    for (final q in round) {
      expect(g.filter.matches(q.answer), isTrue, reason: q.answer.id);
      expect(q.options, hasLength(QuestionGenerator.optionCount));
      expect(q.options.map((o) => o.id).toSet(), hasLength(4));
      expect(q.options.map((o) => o.id), contains(q.answer.id));
    }
  }

  group('QuestionGenerator', () {
    test('a full round has 10 different countries with 4 options each', () {
      final g = generator(const PracticeFilter());
      expectValidRound(g.generateRound(), g);
    });

    test('answers respect continent and difficulty filters', () {
      final g = generator(
        const PracticeFilter(
          continents: {Continent.europe, Continent.africa},
          difficulty: DifficultyFilter.easy,
        ),
      );
      final round = g.generateRound();
      expectValidRound(round, g);
      for (final q in round) {
        expect([
          Continent.europe,
          Continent.africa,
        ], contains(q.answer.continent));
        expect(q.answer.difficulty, 1);
      }
    });

    test('a small pool shortens the round but still offers 4 options', () {
      final g = generator(
        const PracticeFilter(
          continents: {Continent.southAmerica},
          difficulty: DifficultyFilter.easy,
        ),
      );
      expect(g.pool.length, lessThan(10));
      final round = g.generateRound();
      expectValidRound(round, g);
      expect(RoundState.start(round).isShortened, isTrue);
    });

    test('similar options come from similar flags, neighbours or the '
        'same continent', () {
      for (final mode in PracticeMode.values) {
        final g = generator(const PracticeFilter(), mode: mode);
        for (var i = 0; i < 20; i++) {
          for (final q in g.generateRound()) {
            final a = q.answer;
            for (final o in q.options.where((o) => o.id != a.id)) {
              expect(
                a.similarTo.contains(o.id) ||
                    a.neighbors.contains(o.id) ||
                    o.continent == a.continent,
                isTrue,
                reason: '${a.id} → ${o.id}',
              );
            }
          }
        }
      }
    });

    test('map mode never offers look-alike flags that are not nearby', () {
      final g = generator(const PracticeFilter(), mode: PracticeMode.map);
      for (var i = 0; i < 20; i++) {
        for (final q in g.generateRound()) {
          final a = q.answer;
          for (final o in q.options.where((o) => o.id != a.id)) {
            expect(
              a.neighbors.contains(o.id) || o.continent == a.continent,
              isTrue,
              reason: '${a.id} → ${o.id}',
            );
          }
        }
      }
    });

    test('map mode prefers neighbours, flag mode similar flags', () {
      final turkey = PracticeFilter(
        continents: {byId['TR']!.continent},
        difficulty: DifficultyFilter.easy,
      );
      Question questionFor(PracticeMode mode, String id) {
        for (var seed = 0; seed < 200; seed++) {
          final round = generator(
            turkey,
            mode: mode,
            seed: seed,
          ).generateRound();
          for (final q in round) {
            if (q.answer.id == id) return q;
          }
        }
        throw StateError('$id never asked');
      }

      final map = questionFor(PracticeMode.map, 'TR');
      // Türkiye has 8 neighbours, so all three come from them.
      expect(
        map.options
            .where((o) => o.id != 'TR')
            .every((o) => byId['TR']!.neighbors.contains(o.id)),
        isTrue,
      );
      final flag = questionFor(PracticeMode.flag, 'TR');
      expect(flag.options.map((o) => o.id), containsAll(['TN', 'NCY']));
    });

    test('random options stay within the pool when it is big enough', () {
      const filter = PracticeFilter(
        continents: {Continent.oceania},
        similarChoices: false,
      );
      final g = generator(filter);
      for (final q in g.generateRound()) {
        for (final o in q.options) {
          expect(o.continent, Continent.oceania);
        }
      }
    });

    test('the same seed gives the same round', () {
      List<String> ids(int seed) => [
        for (final q in generator(
          const PracticeFilter(),
          seed: seed,
        ).generateRound())
          '${q.answer.id}:${q.options.map((o) => o.id).join(',')}',
      ];
      expect(ids(42), ids(42));
      expect(ids(42), isNot(ids(43)));
    });

    test('every filter combination completes a valid round', () {
      final subsets = [
        for (var mask = 0; mask < 1 << Continent.values.length; mask++)
          {
            for (final (i, c) in Continent.values.indexed)
              if (mask & (1 << i) != 0) c,
          },
      ];
      var rounds = 0;
      for (final continents in subsets) {
        for (final difficulty in DifficultyFilter.values) {
          for (final similar in [true, false]) {
            for (final mode in PracticeMode.values) {
              final g = generator(
                PracticeFilter(
                  continents: continents,
                  difficulty: difficulty,
                  similarChoices: similar,
                ),
                mode: mode,
                seed: rounds,
              );
              expect(g.pool, isNotEmpty);
              final round = g.generateRound();
              expectValidRound(round, g);

              // Play it through, alternating right and wrong answers.
              var state = RoundState.start(round);
              while (!state.isFinished) {
                final q = state.current;
                final pick = state.index.isEven
                    ? q.answer
                    : q.options.firstWhere((o) => o.id != q.answer.id);
                state = state.answer(pick).next();
              }
              expect(state.score, (round.length + 1) ~/ 2);
              expect(state.mistakes, hasLength(round.length ~/ 2));
              rounds++;
            }
          }
        }
      }
      expect(rounds, 64 * 4 * 2 * 2);
    });
  });

  group('RoundState', () {
    final round = generator(const PracticeFilter()).generateRound();

    test('tracks answers, score and mistakes', () {
      var state = RoundState.start(round);
      expect(state.isAnswered, isFalse);

      state = state.answer(state.current.answer);
      expect(state.isAnswered, isTrue);
      expect(state.isCurrentCorrect, isTrue);
      expect(state.score, 1);

      state = state.next();
      final wrong = state.current.options.firstWhere(
        (o) => o.id != state.current.answer.id,
      );
      final asked = state.current.answer;
      state = state.answer(wrong);
      expect(state.isCurrentCorrect, isFalse);
      expect(state.mistakes.single.answer.id, asked.id);
      expect(state.mistakes.single.chosen.id, wrong.id);
    });

    test('cannot answer twice or skip a question', () {
      final state = RoundState.start(round);
      expect(state.next, throwsStateError);
      final answered = state.answer(state.current.answer);
      expect(() => answered.answer(state.current.answer), throwsStateError);
    });

    test('rejects an answer that is not an option', () {
      final state = RoundState.start(round);
      final outsider = countries.firstWhere(
        (c) => !state.current.options.any((o) => o.id == c.id),
      );
      expect(() => state.answer(outsider), throwsArgumentError);
    });

    test('finishes after the last question', () {
      var state = RoundState.start(round);
      for (var i = 0; i < round.length; i++) {
        state = state.answer(state.current.answer).next();
      }
      expect(state.isFinished, isTrue);
      expect(state.score, round.length);
      expect(state.mistakes, isEmpty);
    });

    test('an empty round is rejected', () {
      expect(() => RoundState.start([]), throwsArgumentError);
    });
  });

  test('every filter survives a key round trip', () {
    for (var mask = 0; mask < 1 << Continent.values.length; mask++) {
      for (final d in DifficultyFilter.values) {
        for (final s in [true, false]) {
          final filter = PracticeFilter(
            continents: {
              for (final (i, c) in Continent.values.indexed)
                if (mask & (1 << i) != 0) c,
            },
            difficulty: d,
            similarChoices: s,
          );
          expect(PracticeFilter.fromKey(filter.key).key, filter.key);
        }
      }
    }
  });

  test('filter keys are stable regardless of continent order', () {
    const a = PracticeFilter(continents: {Continent.asia, Continent.europe});
    const b = PracticeFilter(continents: {Continent.europe, Continent.asia});
    expect(a.key, b.key);
    expect(a.key, 'c=asia+europe;d=mixed;s=1');
  });
}
