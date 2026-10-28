import 'package:flutter/material.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/features/globe/globe_controller.dart';
import 'package:globsi/features/globe/globe_paths.dart';

/// Map colors for light and dark themes.
class GlobeColors {
  const new({
    required this.ocean,
    required this.oceanShade,
    required this.land,
    required this.otherLand,
    required this.landBorder,
    required this.coast,
    required this.highlight,
    required this.highlightBorder,
  });

  factory of(Brightness brightness) =>
      brightness == Brightness.dark ? _dark : _light;

  static const _light = GlobeColors(
    ocean: Color(0xFF9FD0F0),
    oceanShade: Color(0xFF4F93C7),
    land: [
      Color(0xFFE9DCA9),
      Color(0xFFC6DFA3),
      Color(0xFFF2C9A2),
      Color(0xFFD9C6E4),
      Color(0xFFB4D9C9),
    ],
    otherLand: Color(0xFFDCDCD6),
    landBorder: Color(0x8C3D3D3D),
    coast: Color(0xFF3F7DAE),
    highlight: Color(0xFFFFA726),
    highlightBorder: Color(0xFFB45309),
  );

  static const _dark = GlobeColors(
    ocean: Color(0xFF16466B),
    oceanShade: Color(0xFF0A2440),
    land: [
      Color(0xFF8C8461),
      Color(0xFF6F8460),
      Color(0xFF907261),
      Color(0xFF7D6F88),
      Color(0xFF5F8173),
    ],
    otherLand: Color(0xFF6B6B68),
    landBorder: Color(0x99101010),
    coast: Color(0xFF7FB3DA),
    highlight: Color(0xFFFFB74D),
    highlightBorder: Color(0xFFFFE0B2),
  );

  final Color ocean;
  final Color oceanShade;

  /// One color per [GlobeGeometry.colorCount] slot.
  final List<Color> land;
  final Color otherLand;
  final Color landBorder;
  final Color coast;
  final Color highlight;
  final Color highlightBorder;
}

/// Draws the globe for [controller]'s camera. Repaints whenever the camera
/// moves; paths are reused from [cache] when nothing changed.
class GlobePainter extends CustomPainter {
  new({
    required this.controller,
    required this.geometry,
    required this.colors,
    required this.cache,
    this.selectedId,
    this.selectedMarker,
  }) : super(repaint: controller);

  final GlobeController controller;
  final GlobeGeometry geometry;
  final GlobeColors colors;
  final GlobePathCache cache;
  final String? selectedId;

  /// Lat/lon of the selected tiny country, circled so it can be found.
  final ({double lat, double lon})? selectedMarker;

  static const double _markerRadius = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = controller.camera;
    final frame = cache.frameFor(geometry, camera, size, selectedId);
    final layout = frame.layout;
    final rim = Rect.fromCircle(center: layout.center, radius: layout.radius);

    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..drawOval(
        rim,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.4),
            radius: 1.1,
            colors: [colors.ocean, colors.oceanShade],
          ).createShader(rim),
      );

    final fill = Paint()..style = PaintingStyle.fill;
    for (final (i, path) in frame.fills.indexed) {
      canvas.drawPath(path, fill..color = colors.land[i % colors.land.length]);
    }
    canvas.drawPath(frame.otherLand, fill..color = colors.otherLand);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas
      ..drawPath(
        frame.coasts,
        stroke
          ..color = colors.coast
          ..strokeWidth = 0.7,
      )
      ..drawPath(
        frame.landBorders,
        stroke
          ..color = colors.landBorder
          ..strokeWidth = 0.8,
      );

    if (frame.selected case final selected?) {
      canvas
        ..drawPath(selected, fill..color = colors.highlight)
        ..drawPath(
          selected,
          stroke
            ..color = colors.highlightBorder
            ..strokeWidth = 1.5,
        );
    }

    if (selectedMarker case final m?) {
      final (x, y, z) = camera.projection.project(m.lat, m.lon);
      if (z >= 0) {
        canvas.drawCircle(
          layout.toScreen(x, y),
          _markerRadius,
          stroke
            ..color = colors.highlightBorder
            ..strokeWidth = 2.5,
        );
      }
    }

    // Soft limb darkening for a 3D look.
    canvas
      ..drawOval(
        rim,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.18),
            ],
            stops: const [0, 0.82, 1],
          ).createShader(rim),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(GlobePainter old) =>
      old.geometry != geometry ||
      old.colors != colors ||
      old.selectedId != selectedId ||
      old.selectedMarker != selectedMarker ||
      old.controller != controller;
}
