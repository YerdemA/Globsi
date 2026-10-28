import 'dart:math';
import 'dart:ui';

import 'package:globsi/core/geo/geo_data.dart';
import 'package:globsi/core/geo/globe_camera.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/core/geo/horizon_clipper.dart';
import 'package:globsi/core/geo/level_of_detail.dart';
import 'package:globsi/core/geo/point_in_polygon.dart';

/// Screen-space layout of the globe for a view size and zoom.
class GlobeLayout {
  new(Size size, double zoom)
    : center = size.center(Offset.zero),
      radius = size.shortestSide * 0.45 * zoom,
      _halfDiagonal =
          sqrt(size.width * size.width + size.height * size.height) / 2;

  final Offset center;
  final double radius;
  final double _halfDiagonal;

  /// Angular radius (radians) of the globe area that can be on screen.
  double get viewAngle =>
      _halfDiagonal >= radius ? pi / 2 : asin(_halfDiagonal / radius) + 0.02;

  Offset toScreen(double x, double y) =>
      Offset(center.dx + x * radius, center.dy - y * radius);

  /// Unit-disk coordinates (y up) of a screen point.
  (double, double) toDisk(Offset p) =>
      ((p.dx - center.dx) / radius, (center.dy - p.dy) / radius);
}

/// Paths for one camera position.
class GlobeFrame {
  new({
    required this.layout,
    required this.fills,
    required this.otherLand,
    required this.landBorders,
    required this.coasts,
    required this.selected,
  });

  final GlobeLayout layout;

  /// One even-odd path per color slot.
  final List<Path> fills;
  final Path otherLand;
  final Path landBorders;
  final Path coasts;
  final Path? selected;
}

/// Builds [GlobeFrame]s and reuses the last one while the camera, size and
/// selection are unchanged (e.g. when only colors or overlays repaint).
class GlobePathCache {
  GlobeFrame? _frame;
  Object? _key;

  GlobeFrame frameFor(
    GlobeGeometry geometry,
    GlobeCamera camera,
    Size size,
    String? selectedId,
  ) {
    final key = (
      geometry,
      camera.centerLat,
      camera.centerLon,
      camera.zoom,
      size,
      selectedId,
    );
    final cached = _frame;
    if (cached != null && key == _key) return cached;
    _key = key;
    return _frame = _build(geometry, camera, size, selectedId);
  }

  static GlobeFrame _build(
    GlobeGeometry geometry,
    GlobeCamera camera,
    Size size,
    String? selectedId,
  ) {
    final layout = GlobeLayout(size, camera.zoom);
    final projection = camera.projection;
    final clipper = HorizonClipper(projection, minStep: 0.5 / layout.radius);
    final viewAngle = layout.viewAngle;
    final lod = lodLevelFor(layout.radius);
    final antipodeLat = -camera.centerLat;
    final antipodeLon = wrapLongitude(camera.centerLon + 180);
    final rim = Rect.fromCircle(center: layout.center, radius: layout.radius);

    Path newPath() => Path()..fillType = PathFillType.evenOdd;

    void addFeature(GlobeFeature feature, Path path) {
      final sink = _ScreenSink(path, layout);
      for (final polygon in feature.polygons) {
        if (!polygon.cap.isVisible(projection, viewAngle)) continue;
        for (final (i, ring) in polygon.levels[lod].indexed) {
          final visibility = clipper.ring(ring, sink);
          // A cut ring around the antipode came out inverted; flip it.
          if (visibility == RingVisibility.partial &&
              ringContains(polygon.source.rings[i], antipodeLon, antipodeLat)) {
            path.addOval(rim);
          }
        }
      }
    }

    final fills = List.generate(geometry.colorCount, (_) => newPath());
    final otherLand = newPath();
    Path? selected;
    for (final feature in geometry.features) {
      addFeature(
        feature,
        feature.isCountry ? fills[feature.colorIndex] : otherLand,
      );
      if (feature.id == selectedId) addFeature(feature, selected = newPath());
    }

    final landBorders = Path();
    final coasts = Path();
    final landSink = _ScreenSink(landBorders, layout);
    final coastSink = _ScreenSink(coasts, layout);
    for (final border in geometry.borders) {
      if (!border.cap.isVisible(projection, viewAngle)) continue;
      clipper.polyline(
        border.levels[lod],
        border.source.kind == BorderKind.land ? landSink : coastSink,
      );
    }

    return GlobeFrame(
      layout: layout,
      fills: fills,
      otherLand: otherLand,
      landBorders: landBorders,
      coasts: coasts,
      selected: selected,
    );
  }
}

class _ScreenSink implements PathSink {
  new(this.path, GlobeLayout layout)
    : _cx = layout.center.dx,
      _cy = layout.center.dy,
      _r = layout.radius;

  final Path path;
  final double _cx;
  final double _cy;
  final double _r;

  @override
  void moveTo(double x, double y) => path.moveTo(_cx + x * _r, _cy - y * _r);

  @override
  void lineTo(double x, double y) => path.lineTo(_cx + x * _r, _cy - y * _r);

  @override
  void close() => path.close();
}
