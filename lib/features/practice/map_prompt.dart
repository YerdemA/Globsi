import 'dart:async';

import 'package:flutter/material.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/core/geo/globe_camera.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/features/globe/globe_controller.dart';
import 'package:globsi/features/globe/globe_view.dart';

/// The globe turned to the asked country, which is highlighted (and circled
/// when tiny). Users can still drag and zoom to look around, but tapping
/// does not select anything.
class MapPrompt extends StatefulWidget {
  const new({required this.geometry, required this.country, super.key});

  final GlobeGeometry geometry;
  final Country country;

  @override
  State<MapPrompt> createState() => _MapPromptState();
}

class _MapPromptState extends State<MapPrompt>
    with SingleTickerProviderStateMixin {
  late final GlobeController _controller = GlobeController(
    vsync: this,
    initial: _cameraFor(widget.country),
  );

  GlobeCamera _cameraFor(Country c) {
    final feature = widget.geometry.featureById(c.id);
    return GlobeCamera(
      centerLat: c.centroidLat,
      centerLon: c.centroidLon,
      zoom: feature == null ? 1 : GlobeCamera.zoomToFit(feature.mainRadius),
    );
  }

  @override
  void didUpdateWidget(MapPrompt old) {
    super.didUpdateWidget(old);
    if (old.country.id != widget.country.id) {
      final c = widget.country;
      unawaited(
        _controller.focusOn(
          widget.geometry,
          c.id,
          lat: c.centroidLat,
          lon: c.centroidLon,
          fit: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.country;
    return GlobeView(
      controller: _controller,
      geometry: widget.geometry,
      selectedId: c.id,
      selectedMarker: c.isTiny
          ? (lat: c.centroidLat, lon: c.centroidLon)
          : null,
    );
  }
}
