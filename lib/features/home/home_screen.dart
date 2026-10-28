import 'package:flutter/material.dart';
import 'package:globsi/app/router.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
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
            spacing: 12,
            children: [
              _MenuCard(
                icon: Icons.public,
                title: l10n.menuExplore,
                subtitle: l10n.menuExploreSubtitle,
                route: Routes.explore,
              ),
              _MenuCard(
                icon: Icons.flag_outlined,
                title: l10n.menuFlagsLearn,
                subtitle: l10n.menuFlagsLearnSubtitle,
                route: Routes.flagsLearn,
              ),
              _MenuCard(
                icon: Icons.travel_explore,
                title: l10n.menuMapPractice,
                subtitle: l10n.menuMapPracticeSubtitle,
                route: Routes.mapPractice,
              ),
              _MenuCard(
                icon: Icons.quiz_outlined,
                title: l10n.menuFlagPractice,
                subtitle: l10n.menuFlagPracticeSubtitle,
                route: Routes.flagPractice,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
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
                Icon(icon, size: 40, color: theme.colorScheme.primary),
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
