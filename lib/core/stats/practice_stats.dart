/// Answer counts for one country in one mode.
class AnswerCount {
  const new({this.correct = 0, this.wrong = 0});

  factory fromJson(Object? json) {
    final list = (json! as List<Object?>).cast<int>();
    return AnswerCount(correct: list[0], wrong: list[1]);
  }

  final int correct;
  final int wrong;

  int get total => correct + wrong;

  AnswerCount operator +(AnswerCount other) =>
      AnswerCount(correct: correct + other.correct, wrong: wrong + other.wrong);

  List<int> toJson() => [correct, wrong];
}

/// A round score; compared by ratio, then by round length.
class BestScore {
  const new(this.score, this.total);

  factory fromJson(Object? json) {
    final list = (json! as List<Object?>).cast<int>();
    return BestScore(list[0], list[1]);
  }

  final int score;
  final int total;

  bool isBetterThan(BestScore? other) {
    if (other == null) return true;
    final a = score * other.total;
    final b = other.score * total;
    return a != b ? a > b : total > other.total;
  }

  List<int> toJson() => [score, total];
}

/// One answered question of a finished round.
typedef AnswerResult = ({String countryId, bool correct});

/// Everything recorded on the device about practice (CLAUDE.md §7).
/// Immutable; [recordRound] returns an updated copy.
///
/// Modes and filters are plain strings (`PracticeMode.name`,
/// `PracticeFilter.key`) so this stays independent of the practice feature.
class PracticeStats {
  const new({
    this.answers = const {},
    this.bestScores = const {},
    this.roundsCompleted = 0,
  });

  /// Reads [toJson] output. Unknown or broken data yields empty stats
  /// rather than an error, so a bad value never blocks the app.
  factory fromJson(Object? json) {
    try {
      final map = json! as Map<String, Object?>;
      if (map['version'] != version) return const PracticeStats();
      return PracticeStats(
        answers: {
          for (final MapEntry(key: mode, value: perCountry)
              in (map['answers']! as Map<String, Object?>).entries)
            mode: {
              for (final MapEntry(:key, :value)
                  in (perCountry! as Map<String, Object?>).entries)
                key: AnswerCount.fromJson(value),
            },
        },
        bestScores: {
          for (final MapEntry(:key, :value)
              in (map['best']! as Map<String, Object?>).entries)
            key: BestScore.fromJson(value),
        },
        roundsCompleted: map['rounds']! as int,
      );
    } on Object {
      return const PracticeStats();
    }
  }

  static const int version = 1;

  /// `answers[mode][countryId]`.
  final Map<String, Map<String, AnswerCount>> answers;

  /// Best score per `"mode|filterKey"`.
  final Map<String, BestScore> bestScores;
  final int roundsCompleted;

  bool get isEmpty => roundsCompleted == 0;

  static String bestKey(String mode, String filterKey) => '$mode|$filterKey';

  BestScore? bestScore(String mode, String filterKey) =>
      bestScores[bestKey(mode, filterKey)];

  /// Totals over all countries, for one [mode] or all modes.
  AnswerCount totals({String? mode}) {
    var sum = const AnswerCount();
    for (final MapEntry(key: m, value: perCountry) in answers.entries) {
      if (mode != null && m != mode) continue;
      for (final count in perCountry.values) {
        sum += count;
      }
    }
    return sum;
  }

  /// Countries answered wrongly most often (all modes), most first; ties
  /// broken by the lower success rate.
  List<({String countryId, AnswerCount count})> mostMissed({int limit = 10}) {
    final merged = <String, AnswerCount>{};
    for (final perCountry in answers.values) {
      for (final MapEntry(:key, :value) in perCountry.entries) {
        merged[key] = (merged[key] ?? const AnswerCount()) + value;
      }
    }
    final missed =
        [
          for (final MapEntry(:key, :value) in merged.entries)
            if (value.wrong > 0) (countryId: key, count: value),
        ]..sort((a, b) {
          final byWrong = b.count.wrong.compareTo(a.count.wrong);
          if (byWrong != 0) return byWrong;
          return (a.count.correct / a.count.total).compareTo(
            b.count.correct / b.count.total,
          );
        });
    return missed.take(limit).toList();
  }

  PracticeStats recordRound({
    required String mode,
    required String filterKey,
    required List<AnswerResult> results,
  }) {
    final perCountry = {...?answers[mode]};
    for (final r in results) {
      final add = r.correct
          ? const AnswerCount(correct: 1)
          : const AnswerCount(wrong: 1);
      perCountry[r.countryId] =
          (perCountry[r.countryId] ?? const AnswerCount()) + add;
    }
    final score = BestScore(
      results.where((r) => r.correct).length,
      results.length,
    );
    final key = bestKey(mode, filterKey);
    return PracticeStats(
      answers: {...answers, mode: perCountry},
      bestScores: score.isBetterThan(bestScores[key])
          ? {...bestScores, key: score}
          : bestScores,
      roundsCompleted: roundsCompleted + 1,
    );
  }

  Map<String, Object?> toJson() => {
    'version': version,
    'answers': {
      for (final MapEntry(key: mode, value: perCountry) in answers.entries)
        mode: {
          for (final MapEntry(:key, :value) in perCountry.entries)
            key: value.toJson(),
        },
    },
    'best': {
      for (final MapEntry(:key, :value) in bestScores.entries)
        key: value.toJson(),
    },
    'rounds': roundsCompleted,
  };
}
