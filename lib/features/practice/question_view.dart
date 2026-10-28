import 'package:flutter/material.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/core/ui/flag_image.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/engine/round_state.dart';
import 'package:globsi/features/practice/map_prompt.dart';
import 'package:globsi/features/practice/option_button.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// One question: the prompt (highlighted country or flag), four options,
/// feedback after answering and a Continue button. No ads here (§8).
class QuestionView extends StatelessWidget {
  const new({
    required this.mode,
    required this.state,
    required this.onAnswer,
    required this.onContinue,
    this.geometry,
    super.key,
  });

  final PracticeMode mode;
  final RoundState state;

  /// Needed for [PracticeMode.map].
  final GlobeGeometry? geometry;
  final ValueChanged<String> onAnswer;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final question = state.current;
    final answer = question.answer;
    final choice = state.currentChoice;

    OptionFeedback feedbackFor(String id) {
      if (choice == null) return OptionFeedback.none;
      if (id == answer.id) return OptionFeedback.correct;
      if (id == choice.id) return OptionFeedback.wrong;
      return OptionFeedback.dimmed;
    }

    final prompt = switch (mode) {
      PracticeMode.map => MapPrompt(geometry: geometry!, country: answer),
      PracticeMode.flag => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FlagImage(
            country: answer,
            width: 320,
            height: 240,
            semanticsLabel: l10n.flagQuestion,
          ),
        ),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.questionProgress(state.index + 1, state.length),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                l10n.scoreLabel(state.score),
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: LinearProgressIndicator(
            value: (state.index + (state.isAnswered ? 1 : 0)) / state.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            mode == PracticeMode.map ? l10n.mapQuestion : l10n.flagQuestion,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(child: ClipRect(child: prompt)),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                for (final option in question.options)
                  OptionButton(
                    key: ValueKey(option.id),
                    label: option.name.resolve(language),
                    feedback: feedbackFor(option.id),
                    onPressed: choice == null
                        ? () => onAnswer(option.id)
                        : null,
                  ),
                const SizedBox(height: 4),
                if (choice != null) ...[
                  Text(
                    state.isCurrentCorrect
                        ? l10n.answerCorrect
                        : l10n.answerWrong(answer.name.resolve(language)),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: state.isCurrentCorrect
                          ? AnswerColors.correct(theme.brightness)
                          : AnswerColors.wrong(theme.colorScheme),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: onContinue,
                    child: Text(
                      state.index == state.length - 1
                          ? l10n.seeResults
                          : l10n.continueButton,
                    ),
                  ),
                ] else
                  // Keeps the layout from jumping when feedback appears.
                  const SizedBox(height: 56 + 8 + 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
