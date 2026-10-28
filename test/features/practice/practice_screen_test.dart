import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/core/data/preferences.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/core/stats/stats_service.dart';
import 'package:globsi/features/globe/globe_providers.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/option_button.dart';
import 'package:globsi/features/practice/practice_screen.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CountryCatalog catalog;
  late GlobeGeometry geometry;
  late ProviderContainer container;

  setUpAll(() async {
    final repository = CountryRepository(rootBundle);
    catalog = await repository.loadCatalog();
    geometry = GlobeGeometry(await repository.loadGeo());
  });

  Future<void> pumpPractice(WidgetTester tester, PracticeMode mode) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        countryCatalogProvider.overrideWith((ref) => catalog),
        globeGeometryProvider.overrideWith((ref) => geometry),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PracticeScreen(mode: mode, random: Random(3)),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// Answers the current question with the first option.
  Future<void> answerFirst(WidgetTester tester) async {
    await tester.tap(find.byType(OptionButton).first);
    await tester.pumpAndSettle();
  }

  testWidgets('a flag round goes from filters through 10 questions to the '
      'summary', (tester) async {
    await pumpPractice(tester, PracticeMode.flag);
    expect(find.text('202 countries match these filters'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 10'), findsOneWidget);
    expect(find.text('Whose flag is this?'), findsOneWidget);
    expect(find.byType(OptionButton), findsNWidgets(4));
    expect(find.text('Continue'), findsNothing);

    for (var i = 0; i < 10; i++) {
      await answerFirst(tester);
      // Feedback uses an icon, not just color.
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(
        find.textContaining(RegExp(r'^(Correct!|Wrong\.)')),
        findsOneWidget,
      );
      await tester.tap(find.text(i == 9 ? 'See results' : 'Continue'));
      await tester.pumpAndSettle();
    }

    expect(find.textContaining(' / 10'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    final stats = container.read(statsProvider);
    expect(stats.roundsCompleted, 1);
    expect(stats.totals(mode: 'flag').total, 10);
    // The first round on a filter sets, but does not beat, a best score.
    expect(find.text('New best score!'), findsNothing);
    expect(find.text('Main menu'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 10'), findsOneWidget);
  });

  testWidgets('a small pool shortens the round and says so', (tester) async {
    await pumpPractice(tester, PracticeMode.flag);
    await tester.tap(find.widgetWithText(FilterChip, 'South America'));
    await tester.pump();
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('The round will have only'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.textContaining('questions with these filters'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'Question 1 of [1-9]$')),
      findsOneWidget,
    );
  });

  testWidgets('map practice shows the globe and four names', (tester) async {
    await pumpPractice(tester, PracticeMode.map);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Which country is highlighted?'), findsOneWidget);
    expect(find.byType(OptionButton), findsNWidgets(4));

    await answerFirst(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Question 2 of 10'), findsOneWidget);
  });

  testWidgets('leaving a round asks for confirmation', (tester) async {
    await pumpPractice(tester, PracticeMode.flag);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Leave this round?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 10'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
  });
}
