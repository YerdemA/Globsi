import 'package:flutter/material.dart';
import 'package:globsi/core/ui/flag_image.dart';
import 'package:globsi/features/flags_learn/flag_detail_sheet.dart';
import 'package:globsi/features/practice/engine/round_state.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// Score and mistakes after a round. Tapping a mistake opens its info card.
class RoundSummaryView extends StatelessWidget {
  const new({
    required this.state,
    required this.onPlayAgain,
    required this.onChangeFilters,
    required this.onMainMenu,
    this.isNewBest = false,
    super.key,
  });

  final RoundState state;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeFilters;
  final VoidCallback onMainMenu;

  /// Beat the previous best score for this mode and filter.
  final bool isNewBest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final ratio = state.score / state.length;
    final mistakes = state.mistakes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              Text(
                l10n.summaryScore(state.score, state.length),
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                ratio >= 0.8
                    ? l10n.summaryGreat
                    : ratio >= 0.5
                    ? l10n.summaryGood
                    : l10n.summaryKeepGoing,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (isNewBest)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: theme.colorScheme.tertiary,
                      ),
                      Text(
                        l10n.summaryNewBest,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  mistakes.isEmpty
                      ? l10n.summaryNoMistakes
                      : l10n.summaryMistakes,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              for (final m in mistakes)
                ListTile(
                  leading: FlagImage(country: m.answer, width: 48, height: 36),
                  title: Text(m.answer.name.resolve(language)),
                  subtitle: Text(
                    l10n.summaryYourAnswer(m.chosen.name.resolve(language)),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showFlagDetail(context, m.answer),
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
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.replay),
                  label: Text(l10n.playAgain),
                  onPressed: onPlayAgain,
                ),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: onChangeFilters,
                        child: Text(l10n.changeFilters),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: onMainMenu,
                        child: Text(l10n.mainMenu),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
