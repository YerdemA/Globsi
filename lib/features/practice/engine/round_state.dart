import 'package:globsi/core/data/country.dart';
import 'package:globsi/features/practice/engine/question_generator.dart';

/// A wrongly answered question.
typedef Mistake = ({Country answer, Country chosen});

/// Progress through one round. Immutable: [answer] and [next] return new
/// states.
class RoundState {
  const new _({
    required this.questions,
    required this.index,
    required this.choices,
  });

  /// A round of [questions]; must not be empty.
  factory start(List<Question> questions) {
    if (questions.isEmpty) {
      throw ArgumentError.value(questions, 'questions', 'must not be empty');
    }
    return RoundState._(
      questions: List.unmodifiable(questions),
      index: 0,
      choices: const [],
    );
  }

  final List<Question> questions;

  /// Current question index; equals [length] once finished.
  final int index;

  /// The option picked for each answered question, in order.
  final List<Country> choices;

  int get length => questions.length;

  /// Whether the round is shorter than a full round (small pool).
  bool get isShortened => length < QuestionGenerator.roundLength;

  bool get isFinished => index >= length;

  Question get current => questions[index];

  /// Whether the current question has been answered (feedback is shown).
  bool get isAnswered => choices.length > index;

  /// The option chosen for the current question, if answered.
  Country? get currentChoice => isAnswered ? choices[index] : null;

  bool get isCurrentCorrect => currentChoice?.id == current.answer.id;

  int get score => [
    for (var i = 0; i < choices.length; i++)
      if (choices[i].id == questions[i].answer.id) i,
  ].length;

  List<Mistake> get mistakes => [
    for (var i = 0; i < choices.length; i++)
      if (choices[i].id != questions[i].answer.id)
        (answer: questions[i].answer, chosen: choices[i]),
  ];

  /// Records [option] for the current question. Answering twice is an error.
  RoundState answer(Country option) {
    if (isFinished || isAnswered) {
      throw StateError('Question already answered');
    }
    if (!current.options.any((o) => o.id == option.id)) {
      throw ArgumentError.value(option.id, 'option', 'not one of the options');
    }
    return RoundState._(
      questions: questions,
      index: index,
      choices: List.unmodifiable([...choices, option]),
    );
  }

  /// Moves on after the current question was answered.
  RoundState next() {
    if (!isAnswered) throw StateError('Answer the question first');
    return RoundState._(
      questions: questions,
      index: index + 1,
      choices: choices,
    );
  }
}
