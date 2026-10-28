import 'package:flutter/material.dart';
import 'package:globsi/app/localized_names.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/features/flags_learn/flashcard_deck.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/engine/question_generator.dart';
import 'package:globsi/features/practice/practice_labels.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// Filter choices shown before a round.
class PracticeSetupView extends StatelessWidget {
  const new({
    required this.filter,
    required this.poolSize,
    required this.onChanged,
    required this.onStart,
    super.key,
  });

  final PracticeFilter filter;

  /// Countries matching [filter].
  final int poolSize;
  final ValueChanged<PracticeFilter> onChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final continents = filter.continents;

    void toggle(Continent c) {
      final next = {...continents};
      if (!next.remove(c)) next.add(c);
      // Selecting every continent is the same as "all".
      onChanged(
        filter.copyWith(
          continents: next.length == Continent.values.length ? {} : next,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.practiceContinents, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(l10n.filterAll),
                    selected: continents.isEmpty,
                    onSelected: (_) =>
                        onChanged(filter.copyWith(continents: {})),
                  ),
                  for (final c in continentOrder)
                    FilterChip(
                      label: Text(c.label(l10n)),
                      selected: continents.contains(c),
                      onSelected: (_) => toggle(c),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.practiceDifficulty, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<DifficultyFilter>(
                showSelectedIcon: false,
                segments: [
                  for (final d in DifficultyFilter.values)
                    ButtonSegment(value: d, label: Text(d.label(l10n))),
                ],
                selected: {filter.difficulty},
                onSelectionChanged: (s) =>
                    onChanged(filter.copyWith(difficulty: s.single)),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.practiceSimilar),
                subtitle: Text(l10n.practiceSimilarHint),
                value: filter.similarChoices,
                onChanged: (v) => onChanged(filter.copyWith(similarChoices: v)),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text(
                  poolSize == 0
                      ? l10n.practiceNoCountries
                      : poolSize < QuestionGenerator.roundLength
                      ? '${l10n.practicePoolCount(poolSize)} '
                            '${l10n.practiceShortened(poolSize)}'
                      : l10n.practicePoolCount(poolSize),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: poolSize < QuestionGenerator.roundLength
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: poolSize == 0 ? null : onStart,
                  child: Text(l10n.practiceStart),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
