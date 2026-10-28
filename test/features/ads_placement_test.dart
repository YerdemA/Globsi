import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/ads/ad_service.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/core/data/preferences.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/features/flags_learn/flags_learn_screen.dart';
import 'package:globsi/features/globe/globe_providers.dart';
import 'package:globsi/features/globe/globe_screen.dart';
import 'package:globsi/features/home/home_screen.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/option_button.dart';
import 'package:globsi/features/practice/practice_screen.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bannerKey = Key('test-banner');

/// Serves a fake banner and records interstitial calls.
class _FakeAds implements AdService {
  new({this.failEverything = false});

  /// Every call throws, as a broken ad SDK might.
  final bool failEverything;
  int prepared = 0;
  int leftSummary = 0;

  @override
  final ValueListenable<bool> canRequestAds = ValueNotifier(true);

  @override
  final ValueListenable<bool> privacyOptionsRequired = ValueNotifier(false);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  Future<LoadedBanner?> loadBanner(double width) async {
    if (failEverything) throw StateError('no fill');
    return LoadedBanner(
      widget: const SizedBox(key: _bannerKey, height: 50),
      height: 50,
    );
  }

  @override
  void prepareInterstitial(int roundsCompleted) {
    prepared++;
    if (failEverything) throw StateError('load failed');
  }

  @override
  void onLeaveSummary(int roundsCompleted) {
    leftSummary++;
    if (failEverything) throw StateError('show failed');
  }
}

void main() {
  late CountryCatalog catalog;
  late GlobeGeometry geometry;

  setUpAll(() async {
    final repository = CountryRepository(rootBundle);
    catalog = await repository.loadCatalog();
    geometry = GlobeGeometry(await repository.loadGeo());
  });

  Future<void> pump(WidgetTester tester, Widget home, AdService ads) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          countryCatalogProvider.overrideWith((ref) => catalog),
          globeGeometryProvider.overrideWith((ref) => geometry),
          adServiceProvider.overrideWithValue(ads),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> playRound(WidgetTester tester) async {
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      // Rule 1: no ads while a question is on screen.
      expect(find.byKey(_bannerKey), findsNothing);
      await tester.tap(find.byType(OptionButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(i == 9 ? 'See results' : 'Continue'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('rule 2: banner on the home menu', (tester) async {
    await pump(tester, const HomeScreen(), _FakeAds());
    expect(find.byKey(_bannerKey), findsOneWidget);
  });

  testWidgets('rule 2: banner on the flag list but not the flashcards', (
    tester,
  ) async {
    await pump(tester, const FlagsLearnScreen(), _FakeAds());
    expect(find.byKey(_bannerKey), findsOneWidget);
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    expect(find.byKey(_bannerKey).hitTestable(), findsNothing);
  });

  testWidgets('rules 1–2: no banner on the globe', (tester) async {
    await pump(tester, const GlobeScreen(), _FakeAds());
    expect(find.byKey(_bannerKey), findsNothing);
  });

  testWidgets('rules 1–3: banner only on the summary; the interstitial is '
      'prepared there and offered only when leaving it', (tester) async {
    final ads = _FakeAds();
    await pump(
      tester,
      PracticeScreen(mode: PracticeMode.flag, random: Random(1)),
      ads,
    );
    expect(find.byKey(_bannerKey), findsNothing, reason: 'filter screen');
    await playRound(tester);

    expect(find.text('Play again'), findsOneWidget);
    expect(find.byKey(_bannerKey), findsOneWidget);
    expect(ads.prepared, 1);
    expect(ads.leftSummary, 0);

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();
    expect(ads.leftSummary, 1);
    expect(find.text('Question 1 of 10'), findsOneWidget);
  });

  testWidgets('rule 4: failing ads never block or break the flow', (
    tester,
  ) async {
    final ads = _FakeAds(failEverything: true);
    await pump(
      tester,
      PracticeScreen(mode: PracticeMode.flag, random: Random(2)),
      ads,
    );
    await playRound(tester);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.byKey(_bannerKey), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 10'), findsOneWidget);
    expect(ads.leftSummary, 1);
  });
}
