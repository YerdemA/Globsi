import 'package:flutter/foundation.dart';

/// Shown in Settings > About. Must match `version:` in pubspec.yaml (a test
/// checks this), so no plugin is needed to read it at runtime.
const String appVersion = '1.0.0';

const String appLegalese = '© 2026 Yusuf Erdem Aykaç';

/// Public copy of the privacy policy (GitHub Pages from `docs/`).
const String privacyPolicyUrl =
    'https://yerdema.github.io/Globsi/privacy-policy/';

/// Licenses of the bundled map and flag data, added to the licenses page
/// next to the package licenses Flutter collects automatically.
Stream<LicenseEntry> dataLicenses() async* {
  yield const LicenseEntryWithLineBreaks(
    ['Natural Earth'],
    '''
Made with Natural Earth. Free vector and raster map data @ naturalearthdata.com.

Natural Earth 1:50m Cultural Vectors are in the public domain.
Boundaries were simplified; Crimea is shown as part of Ukraine, the Golan
Heights as part of Syria, and Abkhazia and South Ossetia separately.''',
  );
  yield const LicenseEntryWithLineBreaks(
    ['flag-icons'],
    '''
The MIT License (MIT)

Copyright (c) 2013 Panayiotis Lipiridis

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.''',
  );
  yield const LicenseEntryWithLineBreaks(
    ['Wikimedia Commons flags'],
    '''
Flags of Northern Cyprus, Somaliland, Abkhazia and South Ossetia are from
Wikimedia Commons and are in the public domain.''',
  );
}
