enum Continent {
  africa('africa'),
  asia('asia'),
  europe('europe'),
  northAmerica('north_america'),
  southAmerica('south_america'),
  oceania('oceania');

  new(this.json);

  final String json;

  static Continent fromJson(String value) => values.firstWhere(
    (c) => c.json == value,
    orElse: () => throw FormatException('Unknown continent "$value"'),
  );
}

enum CountryStatus {
  unMember('un_member'),
  observer('observer'),
  partiallyRecognized('partially_recognized');

  new(this.json);

  final String json;

  static CountryStatus fromJson(String value) => values.firstWhere(
    (s) => s.json == value,
    orElse: () => throw FormatException('Unknown status "$value"'),
  );
}

/// A text available in every supported app language.
class LocalizedText {
  const new({required this.tr, required this.en});

  factory fromJson(Map<String, Object?> json) =>
      LocalizedText(tr: json['tr']! as String, en: json['en']! as String);

  final String tr;
  final String en;

  /// Text for [languageCode], falling back to Turkish.
  String resolve(String languageCode) => languageCode == 'en' ? en : tr;
}

class Country {
  const new({
    required this.id,
    required this.iso3,
    required this.name,
    required this.capital,
    required this.continent,
    required this.status,
    required this.difficulty,
    required this.isTiny,
    required this.centroidLat,
    required this.centroidLon,
    required this.flag,
    required this.similarTo,
    required this.neighbors,
  });

  factory fromJson(Map<String, Object?> json) {
    final centroid = (json['centroid']! as List<Object?>).cast<num>();
    return Country(
      id: json['id']! as String,
      iso3: json['iso3']! as String,
      name: LocalizedText.fromJson(json['name']! as Map<String, Object?>),
      capital: LocalizedText.fromJson(json['capital']! as Map<String, Object?>),
      continent: Continent.fromJson(json['continent']! as String),
      status: CountryStatus.fromJson(json['status']! as String),
      difficulty: json['difficulty']! as int,
      isTiny: json['isTiny']! as bool,
      centroidLat: centroid[0].toDouble(),
      centroidLon: centroid[1].toDouble(),
      flag: json['flag']! as String,
      similarTo: (json['similarTo']! as List<Object?>).cast<String>(),
      neighbors: (json['neighbors']! as List<Object?>).cast<String>(),
    );
  }

  /// ISO 3166-1 alpha-2, or a custom code for countries without one.
  final String id;
  final String iso3;
  final LocalizedText name;
  final LocalizedText capital;
  final Continent continent;
  final CountryStatus status;

  /// 1 easy, 2 medium, 3 hard.
  final int difficulty;
  final bool isTiny;
  final double centroidLat;
  final double centroidLon;

  /// File name under `assets/flags/`.
  final String flag;

  /// Countries with confusable flags (hint for practice distractors).
  final List<String> similarTo;

  /// Countries sharing a land border (generated from the geo data).
  final List<String> neighbors;

  String get flagAsset => 'assets/flags/$flag';
}
