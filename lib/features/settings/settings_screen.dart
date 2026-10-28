import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/ads/ad_service.dart';
import 'package:globsi/core/stats/stats_service.dart';
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
          const Divider(),
          ValueListenableBuilder(
            valueListenable: ref
                .watch(adServiceProvider)
                .privacyOptionsRequired,
            builder: (context, required, _) => required
                ? ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(l10n.settingsPrivacy),
                    subtitle: Text(l10n.settingsPrivacyHint),
                    onTap: () =>
                        ref.read(adServiceProvider).showPrivacyOptions(),
                  )
                : const SizedBox.shrink(),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.settingsResetStats),
            subtitle: Text(l10n.settingsResetStatsHint),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetStatsTitle),
        content: Text(l10n.resetStatsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.resetStatsConfirm),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    await ref.read(statsProvider.notifier).reset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.statsResetDone)));
  }
}
