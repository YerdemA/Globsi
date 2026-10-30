import 'package:flutter/material.dart';
import 'package:globsi/app/router.dart';
import 'package:globsi/core/ads/ad_banner.dart';
import 'package:globsi/core/ui/globsi_wordmark.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(
        title: const GlobsiWordmark(fontSize: 30),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: l10n.statsTitle,
            onPressed: () => context.push(Routes.stats),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              _MenuSection(
                label: l10n.menuSectionLearn,
                color: colors.primary,
                cards: [
                  _MenuCard(
                    icon: Icons.public,
                    iconColor: colors.primary,
                    title: l10n.menuExplore,
                    subtitle: l10n.menuExploreSubtitle,
                    route: Routes.explore,
                  ),
                  _MenuCard(
                    icon: Icons.flag_outlined,
                    iconColor: colors.primary,
                    title: l10n.menuFlagsLearn,
                    subtitle: l10n.menuFlagsLearnSubtitle,
                    route: Routes.flagsLearn,
                  ),
                ],
              ),
              _MenuSection(
                label: l10n.menuSectionPractice,
                color: colors.tertiary,
                cards: [
                  _MenuCard(
                    icon: Icons.travel_explore,
                    iconColor: colors.tertiary,
                    title: l10n.menuMapPractice,
                    subtitle: l10n.menuMapPracticeSubtitle,
                    route: Routes.mapPractice,
                  ),
                  _MenuCard(
                    icon: Icons.quiz_outlined,
                    iconColor: colors.tertiary,
                    title: l10n.menuFlagPractice,
                    subtitle: l10n.menuFlagPracticeSubtitle,
                    route: Routes.flagPractice,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const new({required this.label, required this.color, required this.cards});

  final String label;
  final Color color;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Semantics(
              header: true,
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: color),
              ),
            ),
          ),
          ...cards,
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const new({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card.filled(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 20,
              children: [
                Icon(icon, size: 40, color: iconColor),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      Text(subtitle, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
