// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Globsi';

  @override
  String get menuExplore => 'Keşfet';

  @override
  String get menuExploreSubtitle => 'Küreyi döndür, ülkeleri tanı';

  @override
  String get menuFlagsLearn => 'Bayrakları Öğren';

  @override
  String get menuFlagsLearnSubtitle => 'Liste ve kart çevirme';

  @override
  String get menuMapPractice => 'Harita Pratiği';

  @override
  String get menuMapPracticeSubtitle => 'Vurgulanan ülke hangisi?';

  @override
  String get menuFlagPractice => 'Bayrak Pratiği';

  @override
  String get menuFlagPracticeSubtitle => 'Bu bayrak hangi ülkenin?';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get languageSystem => 'Sistem dili';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get continentAfrica => 'Afrika';

  @override
  String get continentAsia => 'Asya';

  @override
  String get continentEurope => 'Avrupa';

  @override
  String get continentNorthAmerica => 'Kuzey Amerika';

  @override
  String get continentSouthAmerica => 'Güney Amerika';

  @override
  String get continentOceania => 'Okyanusya';

  @override
  String get statusObserver => 'BM gözlemci devlet';

  @override
  String get statusPartiallyRecognized => 'Kısmen tanınan devlet';

  @override
  String get infoCapital => 'Başkent';

  @override
  String get infoContinent => 'Kıta';

  @override
  String get close => 'Kapat';

  @override
  String get zoomIn => 'Yakınlaştır';

  @override
  String get zoomOut => 'Uzaklaştır';

  @override
  String get loadError => 'Veriler yüklenemedi.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get flagsTabList => 'Liste';

  @override
  String get flagsTabCards => 'Kartlar';

  @override
  String get filterAll => 'Tümü';

  @override
  String get shuffle => 'Karıştır';

  @override
  String get previous => 'Önceki';

  @override
  String get next => 'Sonraki';

  @override
  String cardPosition(int index, int total) {
    return '$index / $total';
  }

  @override
  String get tapToReveal => 'Ülkeyi görmek için dokun';

  @override
  String get showOnGlobe => 'Kürede göster';

  @override
  String get practiceContinents => 'Kıtalar';

  @override
  String get practiceDifficulty => 'Zorluk';

  @override
  String get difficultyEasy => 'Kolay';

  @override
  String get difficultyMedium => 'Orta';

  @override
  String get difficultyHard => 'Zor';

  @override
  String get difficultyMixed => 'Karışık';

  @override
  String get practiceSimilar => 'Benzer şıklar';

  @override
  String get practiceSimilarHint =>
      'Yanlış şıklar benzer bayraklardan, komşulardan veya aynı kıtadan seçilir';

  @override
  String practicePoolCount(int count) {
    return '$count ülke bu filtrelere uyuyor';
  }

  @override
  String practiceShortened(int count) {
    return 'Tur $count soruya kısaltılacak.';
  }

  @override
  String practiceShortenedStarted(int count) {
    return 'Bu filtrelerle yalnızca $count soru var.';
  }

  @override
  String get practiceNoCountries => 'Bu filtrelere uyan ülke yok.';

  @override
  String get practiceStart => 'Başla';

  @override
  String get mapQuestion => 'Vurgulanan ülke hangisi?';

  @override
  String get flagQuestion => 'Bu bayrak hangi ülkenin?';

  @override
  String questionProgress(int index, int total) {
    return 'Soru $index / $total';
  }

  @override
  String scoreLabel(int score) {
    return 'Puan: $score';
  }

  @override
  String get answerCorrect => 'Doğru!';

  @override
  String answerWrong(String name) {
    return 'Yanlış. Doğru cevap: $name';
  }

  @override
  String get continueButton => 'Devam';

  @override
  String get seeResults => 'Sonuçları gör';

  @override
  String get summaryTitle => 'Tur bitti';

  @override
  String summaryScore(int score, int total) {
    return '$score / $total';
  }

  @override
  String get summaryGreat => 'Harika!';

  @override
  String get summaryGood => 'İyi iş!';

  @override
  String get summaryKeepGoing => 'Pratik yapmaya devam!';

  @override
  String get summaryMistakes => 'Yanlışların';

  @override
  String get summaryNoMistakes => 'Hiç yanlış yok!';

  @override
  String summaryYourAnswer(String name) {
    return 'Senin cevabın: $name';
  }

  @override
  String get playAgain => 'Tekrar oyna';

  @override
  String get mainMenu => 'Ana menü';

  @override
  String get changeFilters => 'Filtreleri değiştir';

  @override
  String get quitRoundTitle => 'Turdan çıkılsın mı?';

  @override
  String get quitRoundBody => 'Bu turdaki ilerlemen kaybolacak.';

  @override
  String get quitRoundConfirm => 'Çık';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get summaryNewBest => 'Yeni en iyi skor!';

  @override
  String get statsTitle => 'İstatistikler';

  @override
  String get statsEmpty =>
      'Henüz tamamlanmış tur yok. Bir pratik turunu bitirdiğinde istatistiklerin burada görünür.';

  @override
  String get statsRounds => 'Tamamlanan tur';

  @override
  String get statsAccuracy => 'Doğruluk';

  @override
  String statsAnswers(int correct, int total) {
    return '$total sorudan $correct doğru';
  }

  @override
  String get statsMostMissed => 'En çok karıştırılanlar';

  @override
  String statsMissedCount(int wrong, int correct) {
    return '$wrong yanlış, $correct doğru';
  }

  @override
  String get statsBestScores => 'En iyi skorlar';

  @override
  String get filterSimilarShort => 'benzer şıklar';

  @override
  String get filterRandomShort => 'rastgele şıklar';

  @override
  String get settingsResetStats => 'İstatistikleri sıfırla';

  @override
  String get settingsResetStatsHint =>
      'Tüm doğru/yanlış sayıları ve en iyi skorlar silinir';

  @override
  String get resetStatsTitle => 'İstatistikler sıfırlansın mı?';

  @override
  String get resetStatsBody =>
      'Tüm pratik geçmişin silinecek. Bu işlem geri alınamaz.';

  @override
  String get resetStatsConfirm => 'Sıfırla';

  @override
  String get statsResetDone => 'İstatistikler sıfırlandı.';

  @override
  String get settingsPrivacy => 'Gizlilik seçenekleri';

  @override
  String get settingsPrivacyHint =>
      'Reklam ve veri onayı tercihlerini değiştir';
}
