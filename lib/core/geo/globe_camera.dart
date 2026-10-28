import 'dart:math';

import 'package:globsi/core/geo/orthographic.dart';

/// Where the globe is looking: the lat/lon at the screen center and the zoom
/// factor (1 = whole globe fits the view).
class GlobeCamera {
  const new({required this.centerLat, required this.centerLon, this.zoom = 1});

  /// Interpolates along the great circle between the two centers and
  /// geometrically between the zooms.
  factory lerp(GlobeCamera a, GlobeCamera b, double t) {
    final (ax, ay, az) = _unit(a.centerLat, a.centerLon);
    final (bx, by, bz) = _unit(b.centerLat, b.centerLon);
    final dot = (ax * bx + ay * by + az * bz).clamp(-1.0, 1.0);
    final omega = acos(dot);
    double x;
    double y;
    double z;
    if (omega < 1e-6) {
      (x, y, z) = (bx, by, bz);
    } else {
      final s = sin(omega);
      final wa = sin((1 - t) * omega) / s;
      final wb = sin(t * omega) / s;
      (x, y, z) = (wa * ax + wb * bx, wa * ay + wb * by, wa * az + wb * bz);
    }
    final lat = asin(z.clamp(-1.0, 1.0)) * radToDeg;
    // Keep the longitude steady when passing over a pole.
    final lon = x.abs() + y.abs() < 1e-9 ? b.centerLon : atan2(y, x) * radToDeg;
    final zoom = a.zoom * pow(b.zoom / a.zoom, t);
    return GlobeCamera(centerLat: lat, centerLon: lon, zoom: zoom);
  }

  static const double minZoom = 1;
  static const double maxZoom = 40;

  final double centerLat;
  final double centerLon;
  final double zoom;

  OrthographicProjection get projection =>
      OrthographicProjection(centerLat: centerLat, centerLon: centerLon);

  /// Rotates so the surface follows a drag of ([dx], [dy]), measured in
  /// units of the on-screen globe radius (y down, as on screen).
  GlobeCamera dragged(double dx, double dy) => GlobeCamera(
    centerLat: (centerLat + dy * radToDeg).clamp(-90.0, 90.0),
    centerLon: wrapLongitude(centerLon - dx * radToDeg),
    zoom: zoom,
  );

  GlobeCamera zoomedBy(double factor) => withZoom(zoom * factor);

  GlobeCamera withZoom(double value) => GlobeCamera(
    centerLat: centerLat,
    centerLon: centerLon,
    zoom: value.clamp(minZoom, maxZoom),
  );

  /// Zoom at which an area of angular radius [radius] (radians) spans about
  /// [screenFraction] of the view's shorter side.
  static double zoomToFit(double radius, {double screenFraction = 0.35}) {
    final size = sin(min(radius, pi / 2));
    if (size <= 0) return maxZoom;
    return (screenFraction / size).clamp(minZoom, maxZoom);
  }

  static (double, double, double) _unit(double lat, double lon) {
    final phi = lat * degToRad;
    final lambda = lon * degToRad;
    return (cos(phi) * cos(lambda), cos(phi) * sin(lambda), sin(phi));
  }

  /// Whether both cameras show exactly the same view.
  bool isSameView(GlobeCamera other) =>
      other.centerLat == centerLat &&
      other.centerLon == centerLon &&
      other.zoom == zoom;

  @override
  String toString() => 'GlobeCamera($centerLat, $centerLon, x$zoom)';
}

/// Wraps a longitude into [-180, 180).
double wrapLongitude(double lon) => (lon + 180) % 360 - 180;
