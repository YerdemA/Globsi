import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/features/flags_learn/flags_learn_screen.dart';
import 'package:globsi/l10n/app_localizations.dart';

void main() {
  late CountryCatalog catalog;

  setUpAll(() async {
    catalog = await CountryRepository(rootBundle).loadCatalog();
  });

  Future<void> pumpScreen(WidgetTester tester, {String locale = 'tr'}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [countryCatalogProvider.overrideWith((ref) => catalog)],
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FlagsLearnScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the grid starts with Europe and opens a detail sheet', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('Avrupa (48)'), findsOneWidget);
    expect(find.text('Almanya'), findsOneWidget);

    await tester.tap(find.text('Almanya'));
    await tester.pumpAndSettle();
    expect(find.text('Berlin'), findsOneWidget);
    expect(find.text('Kürede göster'), findsOneWidget);
  });

  testWidgets('a flashcard flips to reveal the country', (tester) async {
    await pumpScreen(tester, locale: 'en');
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();

    // First card alphabetically: Abkhazia.
    expect(find.text('1 / 202'), findsOneWidget);
    expect(find.text('Abkhazia'), findsNothing);
    await tester.tap(find.text('Tap to reveal the country'));
    await tester.pumpAndSettle();
    expect(find.text('Abkhazia'), findsOneWidget);
    expect(find.text('Capital: Sukhumi'), findsOneWidget);

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 202'), findsOneWidget);
  });

  testWidgets('choosing a continent narrows the deck', (tester) async {
    await pumpScreen(tester, locale: 'en');
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();

    final oceania = find.widgetWithText(ChoiceChip, 'Oceania');
    await tester.ensureVisible(oceania);
    await tester.pumpAndSettle();
    await tester.tap(oceania);
    await tester.pumpAndSettle();
    expect(find.text('1 / 14'), findsOneWidget);

    await tester.tap(find.byTooltip('Shuffle'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 14'), findsOneWidget);
  });
}
