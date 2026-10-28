// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Globsi';

  @override
  String get menuExplore => 'Explore';

  @override
  String get menuExploreSubtitle => 'Spin the globe, discover countries';

  @override
  String get menuFlagsLearn => 'Learn Flags';

  @override
  String get menuFlagsLearnSubtitle => 'List and flashcards';

  @override
  String get menuMapPractice => 'Map Practice';

  @override
  String get menuMapPracticeSubtitle => 'Which country is highlighted?';

  @override
  String get menuFlagPractice => 'Flag Practice';

  @override
  String get menuFlagPracticeSubtitle => 'Whose flag is this?';

  @override
  String get settings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get continentAfrica => 'Africa';

  @override
  String get continentAsia => 'Asia';

  @override
  String get continentEurope => 'Europe';

  @override
  String get continentNorthAmerica => 'North America';

  @override
  String get continentSouthAmerica => 'South America';

  @override
  String get continentOceania => 'Oceania';

  @override
  String get statusObserver => 'UN observer state';

  @override
  String get statusPartiallyRecognized => 'Partially recognized state';

  @override
  String get infoCapital => 'Capital';

  @override
  String get infoContinent => 'Continent';

  @override
  String get close => 'Close';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get loadError => 'Couldn\'t load the data.';

  @override
  String get retry => 'Retry';

  @override
  String get flagsTabList => 'List';

  @override
  String get flagsTabCards => 'Cards';

  @override
  String get filterAll => 'All';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String cardPosition(int index, int total) {
    return '$index / $total';
  }

  @override
  String get tapToReveal => 'Tap to reveal the country';

  @override
  String get showOnGlobe => 'Show on globe';

  @override
  String get practiceContinents => 'Continents';

  @override
  String get practiceDifficulty => 'Difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyMixed => 'Mixed';

  @override
  String get practiceSimilar => 'Similar choices';

  @override
  String get practiceSimilarHint =>
      'Wrong choices are similar flags, neighbours or from the same continent';

  @override
  String practicePoolCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries match these filters',
      one: '1 country matches these filters',
    );
    return '$_temp0';
  }

  @override
  String practiceShortened(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The round will have only $count questions.',
      one: 'The round will have only 1 question.',
    );
    return '$_temp0';
  }

  @override
  String practiceShortenedStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Only $count questions with these filters.',
      one: 'Only 1 question with these filters.',
    );
    return '$_temp0';
  }

  @override
  String get practiceNoCountries => 'No countries match these filters.';

  @override
  String get practiceStart => 'Start';

  @override
  String get mapQuestion => 'Which country is highlighted?';

  @override
  String get flagQuestion => 'Whose flag is this?';

  @override
  String questionProgress(int index, int total) {
    return 'Question $index of $total';
  }

  @override
  String scoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String get answerCorrect => 'Correct!';

  @override
  String answerWrong(String name) {
    return 'Wrong. The answer is $name.';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get seeResults => 'See results';

  @override
  String get summaryTitle => 'Round complete';

  @override
  String summaryScore(int score, int total) {
    return '$score / $total';
  }

  @override
  String get summaryGreat => 'Excellent!';

  @override
  String get summaryGood => 'Good job!';

  @override
  String get summaryKeepGoing => 'Keep practising!';

  @override
  String get summaryMistakes => 'Your mistakes';

  @override
  String get summaryNoMistakes => 'No mistakes!';

  @override
  String summaryYourAnswer(String name) {
    return 'Your answer: $name';
  }

  @override
  String get playAgain => 'Play again';

  @override
  String get mainMenu => 'Main menu';

  @override
  String get changeFilters => 'Change filters';

  @override
  String get quitRoundTitle => 'Leave this round?';

  @override
  String get quitRoundBody => 'Your progress in this round will be lost.';

  @override
  String get quitRoundConfirm => 'Leave';

  @override
  String get cancel => 'Cancel';

  @override
  String get summaryNewBest => 'New best score!';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsEmpty =>
      'No rounds completed yet. Finish a practice round to see your stats here.';

  @override
  String get statsRounds => 'Rounds completed';

  @override
  String get statsAccuracy => 'Accuracy';

  @override
  String statsAnswers(int correct, int total) {
    return '$correct correct of $total';
  }

  @override
  String get statsMostMissed => 'Most confused';

  @override
  String statsMissedCount(int wrong, int correct) {
    return '$wrong wrong, $correct correct';
  }

  @override
  String get statsBestScores => 'Best scores';

  @override
  String get filterSimilarShort => 'similar choices';

  @override
  String get filterRandomShort => 'random choices';

  @override
  String get settingsResetStats => 'Reset statistics';

  @override
  String get settingsResetStatsHint =>
      'Deletes all answer counts and best scores';

  @override
  String get resetStatsTitle => 'Reset statistics?';

  @override
  String get resetStatsBody =>
      'Your whole practice history will be deleted. This can\'t be undone.';

  @override
  String get resetStatsConfirm => 'Reset';

  @override
  String get statsResetDone => 'Statistics reset.';

  @override
  String get settingsPrivacy => 'Privacy options';

  @override
  String get settingsPrivacyHint => 'Change your ad and data consent choices';
}
