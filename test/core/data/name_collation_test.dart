import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/name_collation.dart';

List<String> sorted(List<String> names, String language) =>
    [...names]..sort((a, b) => compareNames(a, b, language));

void main() {
  test('Turkish puts Ç, Ğ, I/İ, Ö, Ş, Ü in their own places', () {
    const expected = [
      'Cezayir',
      'Çad',
      'Çekya',
      'Çin',
      'Danimarka',
      'Irak',
      'İran',
      'İrlanda',
      'İsveç',
      'Oman',
      'Özbekistan',
      'Suriye',
      'Şili',
      'Uganda',
      'Umman',
      'Ürdün',
    ];
    expect(sorted(expected.reversed.toList(), 'tr'), expected);
  });

  test('Turkish dotless I sorts before dotted İ', () {
    expect(sorted(['İzlanda', 'Irak', 'Israil'], 'tr'), [
      'Irak',
      'Israil',
      'İzlanda',
    ]);
  });

  test('foreign accents fold onto the base letter', () {
    expect(sorted(['São Tomé ve Príncipe', 'Samoa', 'Suudi Arabistan'], 'tr'), [
      'Samoa',
      'São Tomé ve Príncipe',
      'Suudi Arabistan',
    ]);
  });

  test('English ignores accents and Turkish letters', () {
    expect(
      sorted([
        "Côte d'Ivoire",
        'Costa Rica',
        'Turkmenistan',
        'Türkiye',
        'San Marino',
        'São Tomé and Príncipe',
        'Saudi Arabia',
      ], 'en'),
      [
        'Costa Rica',
        "Côte d'Ivoire",
        'San Marino',
        'São Tomé and Príncipe',
        'Saudi Arabia',
        'Türkiye',
        'Turkmenistan',
      ],
    );
  });

  test('spaces and hyphens sort alike, before letters', () {
    expect(sorted(['Gine Ekvator', 'Gine', 'Gine-Bissau', 'Gineli'], 'tr'), [
      'Gine',
      'Gine-Bissau',
      'Gine Ekvator',
      'Gineli',
    ]);
  });
}
