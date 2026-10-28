import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Globsi'**
  String get appTitle;

  /// No description provided for @menuExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get menuExplore;

  /// No description provided for @menuExploreSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Küreyi döndür, ülkeleri tanı'**
  String get menuExploreSubtitle;

  /// No description provided for @menuFlagsLearn.
  ///
  /// In tr, this message translates to:
  /// **'Bayrakları Öğren'**
  String get menuFlagsLearn;

  /// No description provided for @menuFlagsLearnSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Liste ve kart çevirme'**
  String get menuFlagsLearnSubtitle;

  /// No description provided for @menuMapPractice.
  ///
  /// In tr, this message translates to:
  /// **'Harita Pratiği'**
  String get menuMapPractice;

  /// No description provided for @menuMapPracticeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Vurgulanan ülke hangisi?'**
  String get menuMapPracticeSubtitle;

  /// No description provided for @menuFlagPractice.
  ///
  /// In tr, this message translates to:
  /// **'Bayrak Pratiği'**
  String get menuFlagPractice;

  /// No description provided for @menuFlagPracticeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu bayrak hangi ülkenin?'**
  String get menuFlagPracticeSubtitle;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem dili'**
  String get languageSystem;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Yakında'**
  String get comingSoon;

  /// No description provided for @continentAfrica.
  ///
  /// In tr, this message translates to:
  /// **'Afrika'**
  String get continentAfrica;

  /// No description provided for @continentAsia.
  ///
  /// In tr, this message translates to:
  /// **'Asya'**
  String get continentAsia;

  /// No description provided for @continentEurope.
  ///
  /// In tr, this message translates to:
  /// **'Avrupa'**
  String get continentEurope;

  /// No description provided for @continentNorthAmerica.
  ///
  /// In tr, this message translates to:
  /// **'Kuzey Amerika'**
  String get continentNorthAmerica;

  /// No description provided for @continentSouthAmerica.
  ///
  /// In tr, this message translates to:
  /// **'Güney Amerika'**
  String get continentSouthAmerica;

  /// No description provided for @continentOceania.
  ///
  /// In tr, this message translates to:
  /// **'Okyanusya'**
  String get continentOceania;

  /// No description provided for @statusObserver.
  ///
  /// In tr, this message translates to:
  /// **'BM gözlemci devlet'**
  String get statusObserver;

  /// No description provided for @statusPartiallyRecognized.
  ///
  /// In tr, this message translates to:
  /// **'Kısmen tanınan devlet'**
  String get statusPartiallyRecognized;

  /// No description provided for @infoCapital.
  ///
  /// In tr, this message translates to:
  /// **'Başkent'**
  String get infoCapital;

  /// No description provided for @infoContinent.
  ///
  /// In tr, this message translates to:
  /// **'Kıta'**
  String get infoContinent;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @zoomIn.
  ///
  /// In tr, this message translates to:
  /// **'Yakınlaştır'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In tr, this message translates to:
  /// **'Uzaklaştır'**
  String get zoomOut;

  /// No description provided for @loadError.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @flagsTabList.
  ///
  /// In tr, this message translates to:
  /// **'Liste'**
  String get flagsTabList;

  /// No description provided for @flagsTabCards.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar'**
  String get flagsTabCards;

  /// No description provided for @filterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get filterAll;

  /// No description provided for @shuffle.
  ///
  /// In tr, this message translates to:
  /// **'Karıştır'**
  String get shuffle;

  /// No description provided for @previous.
  ///
  /// In tr, this message translates to:
  /// **'Önceki'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki'**
  String get next;

  /// No description provided for @cardPosition.
  ///
  /// In tr, this message translates to:
  /// **'{index} / {total}'**
  String cardPosition(int index, int total);

  /// No description provided for @tapToReveal.
  ///
  /// In tr, this message translates to:
  /// **'Ülkeyi görmek için dokun'**
  String get tapToReveal;

  /// No description provided for @showOnGlobe.
  ///
  /// In tr, this message translates to:
  /// **'Kürede göster'**
  String get showOnGlobe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
