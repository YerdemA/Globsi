import 'package:globsi/app/localized_names.dart';
import 'package:globsi/features/flags_learn/flashcard_deck.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/l10n/app_localizations.dart';

extension DifficultyFilterName on DifficultyFilter {
  String label(AppLocalizations l10n) => switch (this) {
    DifficultyFilter.easy => l10n.difficultyEasy,
    DifficultyFilter.medium => l10n.difficultyMedium,
    DifficultyFilter.hard => l10n.difficultyHard,
    DifficultyFilter.mixed => l10n.difficultyMixed,
  };
}

extension PracticeModeName on PracticeMode {
  String label(AppLocalizations l10n) => switch (this) {
    PracticeMode.map => l10n.menuMapPractice,
    PracticeMode.flag => l10n.menuFlagPractice,
  };
}

/// One-line description, e.g. "Avrupa, Asya · Kolay · benzer şıklar".
String describeFilter(PracticeFilter filter, AppLocalizations l10n) {
  final continents = filter.continents.isEmpty
      ? l10n.filterAll
      : [
          for (final c in continentOrder)
            if (filter.continents.contains(c)) c.label(l10n),
        ].join(', ');
  return [
    continents,
    filter.difficulty.label(l10n),
    if (filter.similarChoices)
      l10n.filterSimilarShort
    else
      l10n.filterRandomShort,
  ].join(' · ');
}
