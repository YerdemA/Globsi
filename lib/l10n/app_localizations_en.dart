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
}
