import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/app/router.dart';
import 'package:globsi/app/theme.dart';
import 'package:globsi/features/intro/intro_overlay.dart';
import 'package:globsi/features/settings/locale_provider.dart';
import 'package:globsi/features/settings/theme_mode_provider.dart';
import 'package:globsi/l10n/app_localizations.dart';

class GlobsiApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Turkish is listed first: the fallback for unsupported system locales.
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => IntroOverlay(child: child!),
    );
  }
}
