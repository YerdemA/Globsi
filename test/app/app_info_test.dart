import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/app/app_info.dart';
import 'package:globsi/core/data/preferences.dart';
import 'package:globsi/features/settings/privacy_policy_screen.dart';
import 'package:globsi/features/settings/settings_screen.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('appVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([\d.]+)',
      multiLine: true,
    ).firstMatch(pubspec)![1];
    expect(appVersion, version);
  });

  test('the privacy policy exists in both languages and is complete', () {
    for (final lang in ['tr', 'en']) {
      final text = File(PrivacyPolicyScreen.assetFor(lang)).readAsStringSync();
      expect(text, contains('AdMob'));
      expect(text, contains('https://policies.google.com/'));
      expect(text.split('\n').where((l) => l.startsWith('## ')).length, 5);
    }
  });

  test('the public policy page is generated from the in-app texts', () {
    final page = File('docs/privacy-policy/index.html').readAsStringSync();
    for (final lang in ['tr', 'en']) {
      final first = File(PrivacyPolicyScreen.assetFor(lang))
          .readAsLinesSync()
          .firstWhere((l) => l.startsWith('# '));
      expect(page, contains(first.substring(2)), reason: lang);
    }
  });

  test('data licenses cover maps and flags', () async {
    final names = await dataLicenses()
        .expand((entry) => entry.packages)
        .toList();
    expect(
      names,
      containsAll(['Natural Earth', 'flag-icons', 'Wikimedia Commons flags']),
    );
  });

  testWidgets('settings show About with version and the privacy policy', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.scrollUntilVisible(find.text('About Globsi'), 200);
    expect(find.text('Privacy policy'), findsOneWidget);

    await tester.tap(find.text('About Globsi'));
    await tester.pumpAndSettle();
    expect(find.text(appVersion), findsOneWidget);
    expect(find.textContaining('Natural Earth'), findsOneWidget);
  });

  testWidgets('markdown blocks render headings, bullets and paragraphs', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ListView(
            children: markdownBlocks(
              context,
              '# Title\n\n## Part\n- item\nText',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Part'), findsOneWidget);
    expect(find.text('item'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
  });

  test('LicenseRegistry accepts the data licenses', () async {
    LicenseRegistry.addLicense(dataLicenses);
    final all = await LicenseRegistry.licenses.toList();
    expect(all.any((l) => l.packages.contains('Natural Earth')), isTrue);
  });
}
