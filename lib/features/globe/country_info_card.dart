import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:globsi/app/localized_names.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// Bottom card with a country's flag, name, capital and continent.
class CountryInfoCard extends StatelessWidget {
  const new({required this.country, required this.onClose, super.key});

  final Country country;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final status = country.status.label(l10n);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: SvgPicture.asset(
                  country.flagAsset,
                  width: 72,
                  height: 54,
                  semanticsLabel: country.name.resolve(language),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    country.name.resolve(language),
                    style: theme.textTheme.titleLarge,
                  ),
                  if (status != null)
                    Text(
                      status,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  _InfoRow(
                    label: l10n.infoCapital,
                    value: country.capital.resolve(language),
                  ),
                  _InfoRow(
                    label: l10n.infoContinent,
                    value: country.continent.label(l10n),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.close,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          TextSpan(text: value),
        ],
      ),
      style: theme.textTheme.bodyLarge,
    );
  }
}
