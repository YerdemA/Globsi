import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/app/app.dart';
import 'package:globsi/core/data/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester, {String? locale}) async {
  SharedPreferences.setMockInitialValues({'locale': ?locale});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const GlobsiApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home menu shows four entries in Turkish', (tester) async {
    await pumpApp(tester, locale: 'tr');
    for (final label in [
      'Keşfet',
      'Bayrakları Öğren',
      'Harita Pratiği',
      'Bayrak Pratiği',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('each menu card opens its screen', (tester) async {
    await pumpApp(tester, locale: 'en');
    for (final label in [
      'Explore',
      'Learn Flags',
      'Map Practice',
      'Flag Practice',
    ]) {
      await tester.tap(find.text(label));
      // The globe screen keeps a progress indicator spinning while its data
      // loads, so pump the route transition instead of settling.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(label)),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('changing language updates menu texts', (tester) async {
    await pumpApp(tester, locale: 'tr');
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Keşfet'), findsNothing);
  });
}
