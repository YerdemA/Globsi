import 'package:flutter/material.dart';
import 'package:globsi/app/localized_names.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/core/ui/flag_image.dart';
import 'package:globsi/features/flags_learn/flag_detail_sheet.dart';
import 'package:globsi/features/flags_learn/flashcard_deck.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// All flags, grouped by continent and sorted by name.
class FlagGridView extends StatelessWidget {
  const new({required this.countries, super.key});

  final List<Country> countries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final groups = countriesByContinent(countries, language);

    return CustomScrollView(
      slivers: [
        for (final MapEntry(key: continent, value: members) in groups.entries)
          if (members.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  '${continent.label(l10n)} (${members.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.9,
                ),
                itemCount: members.length,
                itemBuilder: (context, i) => _FlagTile(country: members[i]),
              ),
            ),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _FlagTile extends StatelessWidget {
  const new({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showFlagDetail(context, country),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          spacing: 6,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: FlagImage(country: country),
            ),
            Expanded(
              child: Text(
                country.name.resolve(language),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
