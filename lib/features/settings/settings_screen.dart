import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/features/settings/locale_provider.dart';
import 'package:globsi/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const new({super.key});

  // Language names are shown in their own language, so they are not localized.
  static const _languages = {'tr': 'Türkçe', 'en': 'English'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeProvider)?.languageCode;
    final notifier = ref.read(localeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(title: Text(l10n.settingsLanguage)),
          RadioGroup<String?>(
            groupValue: current,
            onChanged: (code) =>
                notifier.setLocale(code == null ? null : Locale(code)),
            child: Column(
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(l10n.languageSystem),
                ),
                for (final MapEntry(:key, :value) in _languages.entries)
                  RadioListTile<String?>(value: key, title: Text(value)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
