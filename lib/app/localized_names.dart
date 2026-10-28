import 'package:globsi/core/data/country.dart';
import 'package:globsi/l10n/app_localizations.dart';

extension ContinentName on Continent {
  String label(AppLocalizations l10n) => switch (this) {
    Continent.africa => l10n.continentAfrica,
    Continent.asia => l10n.continentAsia,
    Continent.europe => l10n.continentEurope,
    Continent.northAmerica => l10n.continentNorthAmerica,
    Continent.southAmerica => l10n.continentSouthAmerica,
    Continent.oceania => l10n.continentOceania,
  };
}

extension CountryStatusName on CountryStatus {
  /// Short note for non-UN-member countries, `null` for UN members.
  String? label(AppLocalizations l10n) => switch (this) {
    CountryStatus.unMember => null,
    CountryStatus.observer => l10n.statusObserver,
    CountryStatus.partiallyRecognized => l10n.statusPartiallyRecognized,
  };
}
