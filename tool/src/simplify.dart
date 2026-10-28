import 'dart:math';

import 'geometry.dart';

/// Douglas–Peucker simplification of an open polyline. Endpoints are kept.
///
/// [tolerance] is in degrees; longitude differences are scaled by cos(lat)
/// so the tolerance is roughly uniform in ground distance.
List<Pt> simplifyLine(List<Pt> points, double tolerance) {
  if (points.length <= 2) return points;
  final keep = List.filled(points.length, false);
  keep[0] = keep[points.length - 1] = true;
  final tol = tolerance * coordScale;
  final tol2 = tol * tol;

  final stack = [(0, points.length - 1)];
  while (stack.isNotEmpty) {
    final (a, b) = stack.removeLast();
    final midLat = (points[a].$2 + points[b].$2) / 2 / coordScale;
    final k = cos(midLat * pi / 180);
    var maxDist = -1.0;
    var index = -1;
    for (var i = a + 1; i < b; i++) {
      final d = _segmentDistance2(points[i], points[a], points[b], k);
      if (d > maxDist) {
        maxDist = d;
        index = i;
      }
    }
    if (maxDist > tol2) {
      keep[index] = true;
      stack
        ..add((a, index))
        ..add((index, b));
    }
  }
  return [
    for (var i = 0; i < points.length; i++)
      if (keep[i]) points[i],
  ];
}

/// Simplifies a closed ring (open representation, no repeated first point).
/// The first point and the point farthest from it are kept as anchors.
List<Pt> simplifyLoop(List<Pt> ring, double tolerance) {
  if (ring.length <= 3) return ring;
  var far = 1;
  var farDist = -1.0;
  for (var i = 1; i < ring.length; i++) {
    final dx = (ring[i].$1 - ring[0].$1).toDouble();
    final dy = (ring[i].$2 - ring[0].$2).toDouble();
    final d = dx * dx + dy * dy;
    if (d > farDist) {
      farDist = d;
      far = i;
    }
  }
  final first = simplifyLine(ring.sublist(0, far + 1), tolerance);
  final second = simplifyLine([...ring.sublist(far), ring[0]], tolerance);
  return [...first, ...second.sublist(1, second.length - 1)];
}

double _segmentDistance2(Pt p, Pt a, Pt b, double k) {
  final ax = a.$1 * k;
  final ay = a.$2.toDouble();
  final dx = b.$1 * k - ax;
  final dy = b.$2 - ay;
  final px = p.$1 * k - ax;
  final py = p.$2 - ay;
  final len2 = dx * dx + dy * dy;
  var t = len2 == 0 ? 0.0 : (px * dx + py * dy) / len2;
  t = t.clamp(0.0, 1.0);
  final ex = px - t * dx;
  final ey = py - t * dy;
  return ex * ex + ey * ey;
}
