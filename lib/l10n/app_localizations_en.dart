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
}
