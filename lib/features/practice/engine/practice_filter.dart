import 'package:globsi/core/data/country.dart';

enum PracticeMode { map, flag }

enum DifficultyFilter {
  easy(1),
  medium(2),
  hard(3),
  mixed(null);

  new(this.level);

  /// Matching `difficulty` value, or `null` for any.
  final int? level;
}

/// Round settings chosen before a round starts.
class PracticeFilter {
  const new({
    this.continents = const {},
    this.difficulty = DifficultyFilter.mixed,
    this.similarChoices = true,
  });

  /// Selected continents; empty means all.
  final Set<Continent> continents;
  final DifficultyFilter difficulty;

  /// Wrong options resemble the answer (similar flags, neighbours, same
  /// continent) instead of being random.
  final bool similarChoices;

  bool matches(Country c) =>
      (continents.isEmpty || continents.contains(c.continent)) &&
      (difficulty.level == null || c.difficulty == difficulty.level);

  PracticeFilter copyWith({
    Set<Continent>? continents,
    DifficultyFilter? difficulty,
    bool? similarChoices,
  }) => PracticeFilter(
    continents: continents ?? this.continents,
    difficulty: difficulty ?? this.difficulty,
    similarChoices: similarChoices ?? this.similarChoices,
  );

  /// Stable identifier of this combination (e.g. for best scores).
  String get key {
    final c = continents.isEmpty
        ? 'all'
        : (continents.map((c) => c.json).toList()..sort()).join('+');
    return 'c=$c;d=${difficulty.name};s=${similarChoices ? 1 : 0}';
  }
}
