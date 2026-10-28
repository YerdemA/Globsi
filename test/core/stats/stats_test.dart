import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/preferences.dart';
import 'package:globsi/core/stats/practice_stats.dart';
import 'package:globsi/core/stats/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<AnswerResult> results(Map<String, bool> answers) => [
  for (final MapEntry(:key, :value) in answers.entries)
    (countryId: key, correct: value),
];

void main() {
  group('PracticeStats', () {
    test('counts answers per mode and country, and completed rounds', () {
      final stats = const PracticeStats()
          .recordRound(
            mode: 'flag',
            filterKey: 'k',
            results: results({'TR': true, 'FR': false}),
          )
          .recordRound(
            mode: 'map',
            filterKey: 'k',
            results: results({'TR': false}),
          );
      expect(stats.roundsCompleted, 2);
      expect(stats.answers['flag']!['TR']!.correct, 1);
      expect(stats.answers['flag']!['FR']!.wrong, 1);
      expect(stats.answers['map']!['TR']!.wrong, 1);
      expect(stats.totals().total, 3);
      expect(stats.totals().correct, 1);
      expect(stats.totals(mode: 'flag').total, 2);
    });

    test('keeps the best score per mode and filter', () {
      var stats = const PracticeStats();
      List<AnswerResult> score(int right, int total) => [
        for (var i = 0; i < total; i++) (countryId: 'C$i', correct: i < right),
      ];
      stats = stats.recordRound(
        mode: 'flag',
        filterKey: 'a',
        results: score(6, 10),
      );
      stats = stats.recordRound(
        mode: 'flag',
        filterKey: 'a',
        results: score(4, 10),
      );
      stats = stats.recordRound(
        mode: 'flag',
        filterKey: 'b',
        results: score(9, 10),
      );
      stats = stats.recordRound(
        mode: 'map',
        filterKey: 'a',
        results: score(2, 10),
      );
      expect(stats.bestScore('flag', 'a')!.score, 6);
      expect(stats.bestScore('flag', 'b')!.score, 9);
      expect(stats.bestScore('map', 'a')!.score, 2);
      expect(stats.bestScore('map', 'b'), isNull);
    });

    test('best scores compare by ratio, then by round length', () {
      expect(
        const BestScore(5, 6).isBetterThan(const BestScore(8, 10)),
        isTrue,
      );
      expect(
        const BestScore(10, 10).isBetterThan(const BestScore(6, 6)),
        isTrue,
      );
      expect(
        const BestScore(6, 6).isBetterThan(const BestScore(10, 10)),
        isFalse,
      );
      expect(const BestScore(0, 10).isBetterThan(null), isTrue);
    });

    test('most missed sorts by wrong answers, then by success rate', () {
      var stats = const PracticeStats();
      stats = stats.recordRound(
        mode: 'flag',
        filterKey: 'k',
        results: results({'TD': false, 'RO': false, 'MC': true}),
      );
      stats = stats.recordRound(
        mode: 'map',
        filterKey: 'k',
        results: results({'TD': false, 'RO': true, 'MC': false, 'TR': true}),
      );
      // MC: 1 wrong of 3, RO: 1 wrong of 2 → RO is the worse of the two.
      stats = stats.recordRound(
        mode: 'flag',
        filterKey: 'k',
        results: results({'MC': true}),
      );
      final missed = stats.mostMissed();
      expect(missed.map((m) => m.countryId), ['TD', 'RO', 'MC']);
      expect(missed.first.count.wrong, 2);
    });

    test('round-trips through JSON', () {
      final stats = const PracticeStats().recordRound(
        mode: 'map',
        filterKey: 'c=all;d=mixed;s=1',
        results: results({'TR': true, 'VA': false}),
      );
      final restored = PracticeStats.fromJson(
        jsonDecode(jsonEncode(stats.toJson())),
      );
      expect(restored.roundsCompleted, 1);
      expect(restored.answers['map']!['VA']!.wrong, 1);
      expect(restored.bestScore('map', 'c=all;d=mixed;s=1')!.score, 1);
    });

    test('broken or unknown data gives empty stats instead of an error', () {
      expect(PracticeStats.fromJson(null).isEmpty, isTrue);
      expect(PracticeStats.fromJson({'version': 99}).isEmpty, isTrue);
      expect(
        PracticeStats.fromJson({'version': 1, 'rounds': 'x'}).isEmpty,
        isTrue,
      );
    });
  });

  group('StatsService', () {
    Future<ProviderContainer> containerWith(Map<String, Object> values) async {
      SharedPreferences.setMockInitialValues(values);
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('data survives an app restart', () async {
      final first = await containerWith({});
      final previous = await first
          .read(statsProvider.notifier)
          .recordRound(
            mode: 'flag',
            filterKey: 'k',
            results: results({'TR': true, 'FR': false}),
          );
      expect(previous, isNull);
      final saved = (await SharedPreferences.getInstance()).getString(
        StatsService.storageKey,
      )!;

      // A new process starts with only what was written to storage.
      final second = await containerWith({StatsService.storageKey: saved});
      final stats = second.read(statsProvider);
      expect(stats.roundsCompleted, 1);
      expect(stats.answers['flag']!['FR']!.wrong, 1);

      final best = await second
          .read(statsProvider.notifier)
          .recordRound(
            mode: 'flag',
            filterKey: 'k',
            results: results({'TR': true}),
          );
      expect(best!.score, 1);
      expect(best.total, 2);
    });

    test('reset clears memory and storage', () async {
      final container = await containerWith({});
      await container
          .read(statsProvider.notifier)
          .recordRound(
            mode: 'map',
            filterKey: 'k',
            results: results({'TR': true}),
          );
      await container.read(statsProvider.notifier).reset();
      expect(container.read(statsProvider).isEmpty, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StatsService.storageKey), isNull);
    });

    test('a corrupted stored value starts empty', () async {
      final container = await containerWith({
        StatsService.storageKey: '{not json',
      });
      expect(container.read(statsProvider).isEmpty, isTrue);
    });
  });
}
