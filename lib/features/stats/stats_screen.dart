import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/core/stats/practice_stats.dart';
import 'package:globsi/core/stats/stats_service.dart';
import 'package:globsi/core/ui/flag_image.dart';
import 'package:globsi/features/flags_learn/flag_detail_sheet.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/practice_labels.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Overall accuracy, most confused countries and best scores.
class StatsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(statsProvider);
    final catalog = ref.watch(countryCatalogProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: stats.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l10n.statsEmpty, textAlign: TextAlign.center),
              ),
            )
          : _StatsBody(stats: stats, catalog: catalog),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const new({required this.stats, required this.catalog});

  final PracticeStats stats;
  final CountryCatalog? catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final missed = stats.mostMissed();
    final bests = [
      for (final MapEntry(:key, :value) in stats.bestScores.entries)
        if (key.split('|') case [final mode, final filter])
          (
            mode: PracticeMode.values.where((m) => m.name == mode).firstOrNull,
            filter: PracticeFilter.fromKey(filter),
            score: value,
          ),
    ]..sort((a, b) => (a.mode?.index ?? 9).compareTo(b.mode?.index ?? 9));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.statsRounds,
                  value: '${stats.roundsCompleted}',
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: l10n.statsAccuracy,
                  value: _percent(stats.totals(), language),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (final mode in PracticeMode.values)
          if (stats.totals(mode: mode.name) case final t when t.total > 0)
            ListTile(
              leading: Icon(
                mode == PracticeMode.map ? Icons.travel_explore : Icons.flag,
              ),
              title: Text(mode.label(l10n)),
              subtitle: Text(l10n.statsAnswers(t.correct, t.total)),
              trailing: Text(
                _percent(t, language),
                style: theme.textTheme.titleMedium,
              ),
            ),
        if (missed.isNotEmpty) ...[
          _SectionTitle(l10n.statsMostMissed),
          for (final m in missed)
            if (catalog?[m.countryId] case final country?)
              ListTile(
                leading: FlagImage(country: country, width: 48, height: 36),
                title: Text(country.name.resolve(language)),
                subtitle: Text(
                  l10n.statsMissedCount(m.count.wrong, m.count.correct),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showFlagDetail(context, country),
              ),
        ],
        if (bests.isNotEmpty) ...[
          _SectionTitle(l10n.statsBestScores),
          for (final b in bests)
            ListTile(
              title: Text(b.mode?.label(l10n) ?? ''),
              subtitle: Text(describeFilter(b.filter, l10n)),
              trailing: Text(
                l10n.summaryScore(b.score.score, b.score.total),
                style: theme.textTheme.titleMedium,
              ),
            ),
        ],
      ],
    );
  }

  /// Locale-aware percentage ("%80" in Turkish, "80%" in English).
  static String _percent(AnswerCount c, String language) => c.total == 0
      ? '–'
      : NumberFormat.percentPattern(language).format(c.correct / c.total);
}

class _StatTile extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(value, style: theme.textTheme.headlineMedium),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
