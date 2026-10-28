import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/app/app.dart';
import 'package:globsi/app/app_info.dart';
import 'package:globsi/core/ads/ad_config.dart';
import 'package:globsi/core/ads/ad_history.dart';
import 'package:globsi/core/ads/ad_service.dart';
import 'package:globsi/core/data/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(dataLicenses);
  final prefs = await SharedPreferences.getInstance();
  final adHistory = AdHistory(prefs);
  await adHistory.startSession();
  final ads = GoogleAdService(adHistory, policy: AdConfig.interstitialPolicy);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        adServiceProvider.overrideWithValue(ads),
      ],
      child: const GlobsiApp(),
    ),
  );
  // Consent and the ads SDK start in the background; nothing waits on them.
  unawaited(ads.initialize());
}
