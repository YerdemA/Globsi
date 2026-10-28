import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/features/globe/country_info_card.dart';
import 'package:globsi/features/globe/globe_controller.dart';
import 'package:globsi/features/globe/globe_providers.dart';
import 'package:globsi/features/globe/globe_view.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// Explore: free globe with an info card for the tapped country.
class GlobeScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<GlobeScreen> createState() => _GlobeScreenState();
}

class _GlobeScreenState extends ConsumerState<GlobeScreen>
    with SingleTickerProviderStateMixin {
  late final GlobeController _controller = GlobeController(vsync: this);
  String? _selectedId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(String? id, CountryCatalog catalog, GlobeGeometry geometry) {
    setState(() => _selectedId = id);
    final country = id == null ? null : catalog[id];
    if (country == null) return;
    unawaited(
      _controller.focusOn(
        geometry,
        country.id,
        lat: country.centroidLat,
        lon: country.centroidLon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(countryCatalogProvider);
    final geometry = ref.watch(globeGeometryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuExplore)),
      body: switch ((catalog, geometry)) {
        (AsyncData(value: final catalog), AsyncData(value: final geometry)) =>
          _buildGlobe(catalog, geometry),
        (AsyncError(), _) || (_, AsyncError()) => _LoadError(
          onRetry: () => ref
            ..invalidate(countryCatalogProvider)
            ..invalidate(geoDatasetProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildGlobe(CountryCatalog catalog, GlobeGeometry geometry) {
    final l10n = AppLocalizations.of(context);
    final selected = _selectedId == null ? null : catalog[_selectedId!];
    return Stack(
      children: [
        Positioned.fill(
          child: GlobeView(
            controller: _controller,
            geometry: geometry,
            tinyTargets: [
              for (final c in catalog.countries)
                if (c.isTiny)
                  (id: c.id, lat: c.centroidLat, lon: c.centroidLon),
            ],
            selectedId: _selectedId,
            selectedMarker: selected != null && selected.isTiny
                ? (lat: selected.centroidLat, lon: selected.centroidLon)
                : null,
            onCountryTap: (id) => _select(id, catalog, geometry),
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Column(
            spacing: 8,
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                tooltip: l10n.zoomIn,
                onPressed: () => _controller.animateTo(
                  _controller.camera.zoomedBy(2),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.remove),
                tooltip: l10n.zoomOut,
                onPressed: () => _controller.animateTo(
                  _controller.camera.zoomedBy(0.5),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
              child: selected == null
                  ? const SizedBox.shrink()
                  : CountryInfoCard(
                      key: ValueKey(selected.id),
                      country: selected,
                      onClose: () => setState(() => _selectedId = null),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const new({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(l10n.loadError),
          FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
