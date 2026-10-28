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

  /// No description provided for @practiceContinents.
  ///
  /// In tr, this message translates to:
  /// **'Kıtalar'**
  String get practiceContinents;

  /// No description provided for @practiceDifficulty.
  ///
  /// In tr, this message translates to:
  /// **'Zorluk'**
  String get practiceDifficulty;

  /// No description provided for @difficultyEasy.
  ///
  /// In tr, this message translates to:
  /// **'Kolay'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In tr, this message translates to:
  /// **'Zor'**
  String get difficultyHard;

  /// No description provided for @difficultyMixed.
  ///
  /// In tr, this message translates to:
  /// **'Karışık'**
  String get difficultyMixed;

  /// No description provided for @practiceSimilar.
  ///
  /// In tr, this message translates to:
  /// **'Benzer şıklar'**
  String get practiceSimilar;

  /// No description provided for @practiceSimilarHint.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış şıklar benzer bayraklardan, komşulardan veya aynı kıtadan seçilir'**
  String get practiceSimilarHint;

  /// No description provided for @practicePoolCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} ülke bu filtrelere uyuyor'**
  String practicePoolCount(int count);

  /// No description provided for @practiceShortened.
  ///
  /// In tr, this message translates to:
  /// **'Tur {count} soruya kısaltılacak.'**
  String practiceShortened(int count);

  /// No description provided for @practiceShortenedStarted.
  ///
  /// In tr, this message translates to:
  /// **'Bu filtrelerle yalnızca {count} soru var.'**
  String practiceShortenedStarted(int count);

  /// No description provided for @practiceNoCountries.
  ///
  /// In tr, this message translates to:
  /// **'Bu filtrelere uyan ülke yok.'**
  String get practiceNoCountries;

  /// No description provided for @practiceStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get practiceStart;

  /// No description provided for @mapQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Vurgulanan ülke hangisi?'**
  String get mapQuestion;

  /// No description provided for @flagQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Bu bayrak hangi ülkenin?'**
  String get flagQuestion;

  /// No description provided for @questionProgress.
  ///
  /// In tr, this message translates to:
  /// **'Soru {index} / {total}'**
  String questionProgress(int index, int total);

  /// No description provided for @scoreLabel.
  ///
  /// In tr, this message translates to:
  /// **'Puan: {score}'**
  String scoreLabel(int score);

  /// No description provided for @answerCorrect.
  ///
  /// In tr, this message translates to:
  /// **'Doğru!'**
  String get answerCorrect;

  /// No description provided for @answerWrong.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış. Doğru cevap: {name}'**
  String answerWrong(String name);

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueButton;

  /// No description provided for @seeResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuçları gör'**
  String get seeResults;

  /// No description provided for @summaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tur bitti'**
  String get summaryTitle;

  /// No description provided for @summaryScore.
  ///
  /// In tr, this message translates to:
  /// **'{score} / {total}'**
  String summaryScore(int score, int total);

  /// No description provided for @summaryGreat.
  ///
  /// In tr, this message translates to:
  /// **'Harika!'**
  String get summaryGreat;

  /// No description provided for @summaryGood.
  ///
  /// In tr, this message translates to:
  /// **'İyi iş!'**
  String get summaryGood;

  /// No description provided for @summaryKeepGoing.
  ///
  /// In tr, this message translates to:
  /// **'Pratik yapmaya devam!'**
  String get summaryKeepGoing;

  /// No description provided for @summaryMistakes.
  ///
  /// In tr, this message translates to:
  /// **'Yanlışların'**
  String get summaryMistakes;

  /// No description provided for @summaryNoMistakes.
  ///
  /// In tr, this message translates to:
  /// **'Hiç yanlış yok!'**
  String get summaryNoMistakes;

  /// No description provided for @summaryYourAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Senin cevabın: {name}'**
  String summaryYourAnswer(String name);

  /// No description provided for @playAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar oyna'**
  String get playAgain;

  /// No description provided for @mainMenu.
  ///
  /// In tr, this message translates to:
  /// **'Ana menü'**
  String get mainMenu;

  /// No description provided for @changeFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri değiştir'**
  String get changeFilters;

  /// No description provided for @quitRoundTitle.
  ///
  /// In tr, this message translates to:
  /// **'Turdan çıkılsın mı?'**
  String get quitRoundTitle;

  /// No description provided for @quitRoundBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu turdaki ilerlemen kaybolacak.'**
  String get quitRoundBody;

  /// No description provided for @quitRoundConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çık'**
  String get quitRoundConfirm;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @summaryNewBest.
  ///
  /// In tr, this message translates to:
  /// **'Yeni en iyi skor!'**
  String get summaryNewBest;

  /// No description provided for @statsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statsTitle;

  /// No description provided for @statsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tamamlanmış tur yok. Bir pratik turunu bitirdiğinde istatistiklerin burada görünür.'**
  String get statsEmpty;

  /// No description provided for @statsRounds.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan tur'**
  String get statsRounds;

  /// No description provided for @statsAccuracy.
  ///
  /// In tr, this message translates to:
  /// **'Doğruluk'**
  String get statsAccuracy;

  /// No description provided for @statsAnswers.
  ///
  /// In tr, this message translates to:
  /// **'{total} sorudan {correct} doğru'**
  String statsAnswers(int correct, int total);

  /// No description provided for @statsMostMissed.
  ///
  /// In tr, this message translates to:
  /// **'En çok karıştırılanlar'**
  String get statsMostMissed;

  /// No description provided for @statsMissedCount.
  ///
  /// In tr, this message translates to:
  /// **'{wrong} yanlış, {correct} doğru'**
  String statsMissedCount(int wrong, int correct);

  /// No description provided for @statsBestScores.
  ///
  /// In tr, this message translates to:
  /// **'En iyi skorlar'**
  String get statsBestScores;

  /// No description provided for @filterSimilarShort.
  ///
  /// In tr, this message translates to:
  /// **'benzer şıklar'**
  String get filterSimilarShort;

  /// No description provided for @filterRandomShort.
  ///
  /// In tr, this message translates to:
  /// **'rastgele şıklar'**
  String get filterRandomShort;

  /// No description provided for @settingsResetStats.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikleri sıfırla'**
  String get settingsResetStats;

  /// No description provided for @settingsResetStatsHint.
  ///
  /// In tr, this message translates to:
  /// **'Tüm doğru/yanlış sayıları ve en iyi skorlar silinir'**
  String get settingsResetStatsHint;

  /// No description provided for @resetStatsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler sıfırlansın mı?'**
  String get resetStatsTitle;

  /// No description provided for @resetStatsBody.
  ///
  /// In tr, this message translates to:
  /// **'Tüm pratik geçmişin silinecek. Bu işlem geri alınamaz.'**
  String get resetStatsBody;

  /// No description provided for @resetStatsConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get resetStatsConfirm;

  /// No description provided for @statsResetDone.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler sıfırlandı.'**
  String get statsResetDone;

  /// No description provided for @settingsPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik seçenekleri'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyHint.
  ///
  /// In tr, this message translates to:
  /// **'Reklam ve veri onayı tercihlerini değiştir'**
  String get settingsPrivacyHint;

  /// No description provided for @settingsAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsAbout;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik politikası'**
  String get privacyPolicy;

  /// No description provided for @aboutDescription.
  ///
  /// In tr, this message translates to:
  /// **'Küreyi keşfet, bayrakları öğren ve kendini harita ve bayrak pratiğiyle sına. Globsi internet olmadan çalışır; reklamlar için bağlantı kullanılır.'**
  String get aboutDescription;

  /// No description provided for @aboutDataSources.
  ///
  /// In tr, this message translates to:
  /// **'Harita verisi: Natural Earth (kamu malı). Bayraklar: flag-icons (MIT) ve Wikimedia Commons (kamu malı). Ayrıntılar lisanslar sayfasında.'**
  String get aboutDataSources;
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
