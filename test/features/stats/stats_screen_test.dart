import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/core/data/preferences.dart';
import 'package:globsi/core/stats/stats_service.dart';
import 'package:globsi/features/settings/settings_screen.dart';
import 'package:globsi/features/stats/stats_screen.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CountryCatalog catalog;

  setUpAll(() async {
    catalog = await CountryRepository(rootBundle).loadCatalog();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget home, {
    String locale = 'tr',
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        countryCatalogProvider.overrideWith((ref) => catalog),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(statsProvider.notifier)
        .recordRound(
          mode: 'flag',
          filterKey: 'c=europe;d=easy;s=1',
          results: [
            (countryId: 'TD', correct: false),
            (countryId: 'TR', correct: true),
          ],
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: Locale(locale),
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
    return container;
  }

  testWidgets('shows rounds, accuracy, most missed and best scores', (
    tester,
  ) async {
    await pump(tester, const StatsScreen());
    expect(find.text('1'), findsOneWidget);
    expect(find.text('%50'), findsNWidgets(2)); // overall and flag mode
    expect(find.text('Çad'), findsOneWidget);
    expect(find.text('1 yanlış, 0 doğru'), findsOneWidget);
    expect(find.text('Avrupa · Kolay · benzer şıklar'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('formats percentages for English', (tester) async {
    await pump(tester, const StatsScreen(), locale: 'en');
    expect(find.text('50%'), findsNWidgets(2));
  });

  testWidgets('settings reset asks first, then clears the stats', (
    tester,
  ) async {
    final container = await pump(tester, const SettingsScreen());
    await tester.tap(find.text('İstatistikleri sıfırla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(container.read(statsProvider).isEmpty, isFalse);

    await tester.tap(find.text('İstatistikleri sıfırla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sıfırla'));
    await tester.pumpAndSettle();
    expect(container.read(statsProvider).isEmpty, isTrue);
    expect(find.text('İstatistikler sıfırlandı.'), findsOneWidget);
  });
}
