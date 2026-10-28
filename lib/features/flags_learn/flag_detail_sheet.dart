import 'dart:async';

import 'package:flutter/material.dart';
import 'package:globsi/app/localized_names.dart';
import 'package:globsi/app/router.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/core/ui/flag_image.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

Future<void> showFlagDetail(BuildContext context, Country country) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => FlagDetailSheet(country: country),
    );

/// Large flag with the country's facts and a link to the globe.
class FlagDetailSheet extends StatelessWidget {
  const new({required this.country, super.key});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final status = country.status.label(l10n);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Center(child: FlagImage(country: country, width: 240, height: 180)),
            const SizedBox(height: 8),
            Text(
              country.name.resolve(language),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (status != null)
              Text(
                status,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ListTile(
              leading: const Icon(Icons.location_city_outlined),
              title: Text(country.capital.resolve(language)),
              subtitle: Text(l10n.infoCapital),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(country.continent.label(l10n)),
              subtitle: Text(l10n.infoContinent),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.travel_explore),
              label: Text(l10n.showOnGlobe),
              onPressed: () {
                Navigator.of(context).pop();
                unawaited(context.push(Routes.exploreCountry(country.id)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
