import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/ads/ad_banner.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/features/flags_learn/flag_grid_view.dart';
import 'package:globsi/features/flags_learn/flashcards_view.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// Learn Flags: a grouped grid and flashcards.
class FlagsLearnScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(countryCatalogProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: const _ListTabBanner(),
        appBar: AppBar(
          title: Text(l10n.menuFlagsLearn),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.grid_view), text: l10n.flagsTabList),
              Tab(icon: const Icon(Icons.style), text: l10n.flagsTabCards),
            ],
          ),
        ),
        body: switch (catalog) {
          AsyncData(:final value) => TabBarView(
            // Swiping belongs to the flashcards inside the second tab.
            physics: const NeverScrollableScrollPhysics(),
            children: [
              FlagGridView(countries: value.countries),
              FlashcardsView(countries: value.countries),
            ],
          ),
          AsyncError() => Center(
            child: FilledButton(
              onPressed: () => ref.invalidate(countryCatalogProvider),
              child: Text(l10n.retry),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

/// The banner belongs to the flag list only, not the flashcards (§8).
class _ListTabBanner extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final tabs = DefaultTabController.of(context);
    return ListenableBuilder(
      listenable: tabs,
      builder: (context, _) =>
          Offstage(offstage: tabs.index != 0, child: const AdBanner()),
    );
  }
}
