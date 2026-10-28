import 'dart:math';
import 'dart:typed_data';

const double degToRad = pi / 180;
const double radToDeg = 180 / pi;

/// Converts interleaved `[lon, lat, ...]` degrees to interleaved unit
/// vectors `[x, y, z, ...]`: x toward (0°, 0°), y toward (0°, 90°E), z toward
/// the north pole.
Float32List toUnitVectors(Float32List lonLat) {
  final n = lonLat.length ~/ 2;
  final out = Float32List(n * 3);
  for (var i = 0; i < n; i++) {
    final lon = lonLat[i * 2] * degToRad;
    final lat = lonLat[i * 2 + 1] * degToRad;
    final c = cos(lat);
    out[i * 3] = c * cos(lon);
    out[i * 3 + 1] = c * sin(lon);
    out[i * 3 + 2] = sin(lat);
  }
  return out;
}

/// Orthographic projection of the unit sphere seen from above
/// ([centerLat], [centerLon]).
///
/// View coordinates: x to the right (east at the center), y up (north at the
/// center), z toward the viewer. A point is on the visible hemisphere when
/// z >= 0, and (x, y) are its position in the unit disk.
class OrthographicProjection {
  new({required this.centerLat, required this.centerLon}) {
    final phi = centerLat * degToRad;
    final lambda = centerLon * degToRad;
    final sinPhi = sin(phi);
    final cosPhi = cos(phi);
    final sinLambda = sin(lambda);
    final cosLambda = cos(lambda);
    // East, north and forward basis vectors of the view.
    _ex = -sinLambda;
    _ey = cosLambda;
    _nx = -sinPhi * cosLambda;
    _ny = -sinPhi * sinLambda;
    _nz = cosPhi;
    _fx = cosPhi * cosLambda;
    _fy = cosPhi * sinLambda;
    _fz = sinPhi;
  }

  final double centerLat;
  final double centerLon;

  late final double _ex;
  late final double _ey;
  late final double _nx;
  late final double _ny;
  late final double _nz;
  late final double _fx;
  late final double _fy;
  late final double _fz;

  double viewX(double x, double y) => x * _ex + y * _ey;
  double viewY(double x, double y, double z) => x * _nx + y * _ny + z * _nz;
  double viewZ(double x, double y, double z) => x * _fx + y * _fy + z * _fz;

  /// View coordinates of a lat/lon point.
  (double, double, double) project(double lat, double lon) {
    final phi = lat * degToRad;
    final lambda = lon * degToRad;
    final c = cos(phi);
    final x = c * cos(lambda);
    final y = c * sin(lambda);
    final z = sin(phi);
    return (viewX(x, y), viewY(x, y, z), viewZ(x, y, z));
  }

  /// The lat/lon under unit-disk point ([x], [y]), or `null` outside the disk.
  (double, double)? invert(double x, double y) {
    final r2 = x * x + y * y;
    if (r2 > 1) return null;
    final z = sqrt(1 - r2);
    final wx = x * _ex + y * _nx + z * _fx;
    final wy = x * _ey + y * _ny + z * _fy;
    final wz = y * _nz + z * _fz;
    return (asin(wz.clamp(-1.0, 1.0)) * radToDeg, atan2(wy, wx) * radToDeg);
  }

  /// Cosine of the angle between the view center and unit vector (x, y, z).
  double cosAngleTo(double x, double y, double z) => viewZ(x, y, z);
}
