import 'dart:math';
import 'dart:typed_data';

/// Coarser copies of the geometry for low zoom levels, where the full
/// detail is far below a pixel and only costs drawing time.
///
/// Tolerances are in degrees. Level 0 is always the full data.
const List<double> lodTolerances = [0, 0.03, 0.1, 0.2];

/// Picks the coarsest level whose tolerance stays under [maxPixels] on a
/// globe drawn with [radius] pixels.
int lodLevelFor(double radius, {double maxPixels = 0.7}) {
  for (var level = lodTolerances.length - 1; level > 0; level--) {
    if (lodTolerances[level] * pi / 180 * radius <= maxPixels) return level;
  }
  return 0;
}

/// Douglas–Peucker simplification of interleaved `[lon, lat, ...]` degrees.
///
/// A [closed] ring keeps its first point and the point farthest from it as
/// anchors. Returns [points] itself when nothing can be dropped, or when a
/// ring would collapse below three points.
Float32List simplifyLonLat(
  Float32List points,
  double tolerance, {
  required bool closed,
}) {
  final n = points.length ~/ 2;
  if (n <= 3 || tolerance <= 0) return points;
  final keep = List.filled(n, false);
  final tol2 = tolerance * tolerance;

  void simplifyRange(int a, int b) {
    final stack = [(a, b)];
    while (stack.isNotEmpty) {
      final (i0, i1) = stack.removeLast();
      final ax = points[(i0 % n) * 2];
      final ay = points[(i0 % n) * 2 + 1];
      final bx = points[(i1 % n) * 2];
      final by = points[(i1 % n) * 2 + 1];
      final dx = bx - ax;
      final dy = by - ay;
      final len2 = dx * dx + dy * dy;
      var maxDist = -1.0;
      var index = -1;
      for (var i = i0 + 1; i < i1; i++) {
        final px = points[(i % n) * 2] - ax;
        final py = points[(i % n) * 2 + 1] - ay;
        final t = len2 == 0
            ? 0.0
            : ((px * dx + py * dy) / len2).clamp(0.0, 1.0);
        final ex = px - t * dx;
        final ey = py - t * dy;
        final d = ex * ex + ey * ey;
        if (d > maxDist) {
          maxDist = d;
          index = i;
        }
      }
      if (maxDist > tol2) {
        keep[index % n] = true;
        stack
          ..add((i0, index))
          ..add((index, i1));
      }
    }
  }

  keep[0] = true;
  if (closed) {
    var far = 1;
    var farDist = -1.0;
    for (var i = 1; i < n; i++) {
      final dx = points[i * 2] - points[0];
      final dy = points[i * 2 + 1] - points[1];
      final d = dx * dx + dy * dy;
      if (d > farDist) {
        farDist = d;
        far = i;
      }
    }
    keep[far] = true;
    simplifyRange(0, far);
    simplifyRange(far, n);
  } else {
    keep[n - 1] = true;
    simplifyRange(0, n - 1);
  }

  final count = keep.where((k) => k).length;
  if (count == n || (closed && count < 3)) return points;
  final out = Float32List(count * 2);
  var j = 0;
  for (var i = 0; i < n; i++) {
    if (!keep[i]) continue;
    out[j++] = points[i * 2];
    out[j++] = points[i * 2 + 1];
  }
  return out;
}
