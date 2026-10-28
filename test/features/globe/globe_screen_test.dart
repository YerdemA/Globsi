import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/features/globe/globe_providers.dart';
import 'package:globsi/features/globe/globe_screen.dart';
import 'package:globsi/l10n/app_localizations.dart';

void main() {
  late CountryCatalog catalog;
  late GlobeGeometry geometry;

  setUpAll(() async {
    final repository = CountryRepository(rootBundle);
    catalog = await repository.loadCatalog();
    geometry = GlobeGeometry(await repository.loadGeo());
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          countryCatalogProvider.overrideWith((ref) => catalog),
          globeGeometryProvider.overrideWith((ref) => geometry),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: GlobeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the country in the center opens its info card', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.byType(CustomPaint), findsWidgets);

    // The initial camera looks at Türkiye.
    final globe = tester.getRect(find.byType(GlobeScreen));
    await tester.tapAt(globe.center + const Offset(0, 28));
    await tester.pumpAndSettle();

    expect(find.text('Türkiye'), findsOneWidget);
    expect(find.textContaining('Ankara', findRichText: true), findsOneWidget);
    expect(find.textContaining('Avrupa', findRichText: true), findsOneWidget);

    await tester.tap(find.byTooltip('Kapat'));
    await tester.pumpAndSettle();
    expect(find.text('Türkiye'), findsNothing);
  });

  testWidgets('dragging rotates the globe away from the start', (tester) async {
    await pumpScreen(tester);
    final center = tester.getCenter(find.byType(GlobeScreen));
    await tester.dragFrom(center, const Offset(-200, 0));
    await tester.pumpAndSettle();

    await tester.tapAt(center + const Offset(0, 28));
    await tester.pumpAndSettle();
    expect(find.text('Türkiye'), findsNothing);
  });
}
