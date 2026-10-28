/// Alphabetical ordering of country names per app language.
///
/// Dart has no locale-aware collation, so names are mapped to sort keys:
/// Turkish orders Ç, Ğ, I/İ, Ö, Ş, Ü as their own letters (c < ç < d,
/// ı < i), English folds them onto the base letter. Accents that are not
/// letters of the language (é, ô, ã, ñ, …) fold onto the base letter.
/// Spaces, hyphens and apostrophes sort before letters.
int compareNames(String a, String b, String languageCode) {
  final ka = _sortKey(a, languageCode);
  final kb = _sortKey(b, languageCode);
  final n = ka.length < kb.length ? ka.length : kb.length;
  for (var i = 0; i < n; i++) {
    if (ka[i] != kb[i]) return ka[i] - kb[i];
  }
  if (ka.length != kb.length) return ka.length - kb.length;
  return a.compareTo(b);
}

const _turkishAlphabet = 'abcçdefgğhıijklmnoöpqrsştuüvwxyz';
const _englishAlphabet = 'abcdefghijklmnopqrstuvwxyz';

/// Letters folded onto a base letter before ranking.
const _fold = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ø': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', //
  'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
};

/// Turkish letters folded for English ordering.
const _turkishToLatin = {
  'ç': 'c',
  'ğ': 'g',
  'ı': 'i',
  'ö': 'o',
  'ş': 's',
  'ü': 'u',
};

List<int> _sortKey(String name, String languageCode) {
  final turkish = languageCode == 'tr';
  final alphabet = turkish ? _turkishAlphabet : _englishAlphabet;
  final key = <int>[];
  for (final rune in name.runes) {
    var c = String.fromCharCode(rune);
    c = switch (c) {
      'I' when turkish => 'ı',
      'İ' => 'i',
      _ => c.toLowerCase(),
    };
    c = _fold[c] ?? c;
    if (!turkish) c = _turkishToLatin[c] ?? c;
    final rank = alphabet.indexOf(c);
    if (rank >= 0) {
      key.add(100 + rank);
    } else if (c == ' ' || c == '-') {
      key.add(1);
    } else if (c == "'" || c == 'ʻ' || c == '’' || c == '.' || c == ',') {
      continue;
    } else {
      // Digits and anything else: after spaces, before letters.
      key.add(10 + (rune % 80));
    }
  }
  return key;
}
