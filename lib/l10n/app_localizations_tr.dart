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
}
