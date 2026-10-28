import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Coordinates are snapped to integer micro-degrees so that vertices shared
/// by neighbouring polygons compare exactly.
const coordScale = 1000000;

typedef Pt = (int, int);
typedef Ring = List<Pt>;

/// First ring is the outer boundary, the rest are holes. Rings are open: the
/// first point is not repeated at the end.
typedef Polygon = List<Ring>;

int comparePt(Pt a, Pt b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2;

class RawFeature {
  new(this.properties, this.polygons);

  final Map<String, Object?> properties;
  final List<Polygon> polygons;

  String prop(String key) => properties[key]! as String;
}

List<RawFeature> readGeoJson(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map;
  return [
    for (final f in (json['features'] as List).cast<Map<String, Object?>>())
      _parseFeature(f),
  ];
}

RawFeature _parseFeature(Map<String, Object?> feature) {
  final geometry = feature['geometry']! as Map<String, Object?>;
  final coords = geometry['coordinates']! as List;
  final polygons = switch (geometry['type']) {
    'Polygon' => [coords],
    'MultiPolygon' => coords,
    final type => throw FormatException('Unsupported geometry $type'),
  };
  return RawFeature(feature['properties']! as Map<String, Object?>, [
    for (final p in polygons.cast<List<Object?>>()) ?_parsePolygon(p),
  ]);
}

Polygon? _parsePolygon(List<Object?> rings) {
  final parsed = [for (final r in rings.cast<List<Object?>>()) _parseRing(r)];
  if (parsed.first.length < 3) return null;
  return [parsed.first, ...parsed.skip(1).where((r) => r.length >= 3)];
}

Ring _parseRing(List<Object?> coords) {
  final ring = <Pt>[];
  for (final c in coords.cast<List<Object?>>()) {
    final p = (
      ((c[0]! as num) * coordScale).round(),
      ((c[1]! as num) * coordScale).round(),
    );
    if (ring.isEmpty || ring.last != p) ring.add(p);
  }
  if (ring.length > 1 && ring.first == ring.last) ring.removeLast();
  return ring;
}

/// Merges vertices closer than [tolerance] micro-degrees across all
/// [polygons], so near-identical points of neighbouring borders become
/// identical. The first vertex seen in each cluster wins.
List<List<Polygon>> snapVertices(
  List<List<Polygon>> polygons, {
  int tolerance = 30,
}) {
  final cells = <(int, int), List<Pt>>{};
  Pt snap(Pt p) {
    final cx = p.$1 ~/ tolerance;
    final cy = p.$2 ~/ tolerance;
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        for (final q in cells[(cx + dx, cy + dy)] ?? const <Pt>[]) {
          if ((p.$1 - q.$1).abs() <= tolerance &&
              (p.$2 - q.$2).abs() <= tolerance) {
            return q;
          }
        }
      }
    }
    cells.putIfAbsent((cx, cy), () => []).add(p);
    return p;
  }

  Ring snapRing(Ring ring) {
    final out = <Pt>[];
    for (final p in ring.map(snap)) {
      if (out.isEmpty || out.last != p) out.add(p);
    }
    if (out.length > 1 && out.first == out.last) out.removeLast();
    return removeSpikes(out);
  }

  return [
    for (final feature in polygons)
      [
        for (final polygon in feature)
          if (snapRing(polygon.first) case final outer when outer.length >= 3)
            [
              outer,
              for (final hole in polygon.skip(1).map(snapRing))
                if (hole.length >= 3) hole,
            ],
      ],
  ];
}

/// Removes zero-width spikes (`a, b, a`) that boolean operations can leave
/// where inputs touch along a line.
Ring removeSpikes(Ring ring) {
  final out = [...ring];
  var changed = true;
  while (changed && out.length > 3) {
    changed = false;
    for (var i = 0; i < out.length && out.length > 3; i++) {
      final n = out.length;
      if (out[(i - 1 + n) % n] == out[(i + 1) % n]) {
        // Drop the spike tip and one copy of its base.
        final tip = i;
        final base = (i + 1) % n;
        out
          ..removeAt(tip > base ? tip : base)
          ..removeAt(tip > base ? base : tip);
        changed = true;
      }
    }
  }
  return out;
}

/// Signed planar area in square micro-degrees (positive: counter-clockwise).
double planarArea(Ring ring) {
  var sum = 0.0;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    sum +=
        ring[j].$1.toDouble() * ring[i].$2 - ring[i].$1.toDouble() * ring[j].$2;
  }
  return sum / 2;
}

/// Approximate area on the sphere in km².
double sphericalAreaKm2(List<Polygon> polygons) {
  const earthRadiusKm = 6371.0;
  double ringArea(Ring ring) {
    var sum = 0.0;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final lon1 = ring[j].$1 / coordScale * pi / 180;
      final lon2 = ring[i].$1 / coordScale * pi / 180;
      final lat1 = ring[j].$2 / coordScale * pi / 180;
      final lat2 = ring[i].$2 / coordScale * pi / 180;
      sum += (lon2 - lon1) * (2 + sin(lat1) + sin(lat2));
    }
    return (sum * earthRadiusKm * earthRadiusKm / 2).abs();
  }

  var total = 0.0;
  for (final p in polygons) {
    total += ringArea(p.first);
    for (final hole in p.skip(1)) {
      total -= ringArea(hole);
    }
  }
  return total;
}

/// A point guaranteed to lie inside the largest polygon: its centroid if
/// inside, otherwise the middle of the widest interior span on the
/// horizontal line through the centroid.
Pt interiorPoint(List<Polygon> polygons) {
  final largest = polygons.reduce(
    (a, b) => planarArea(a.first).abs() >= planarArea(b.first).abs() ? a : b,
  );
  final outer = largest.first;
  var cx = 0.0;
  var cy = 0.0;
  var area2 = 0.0;
  for (var i = 0, j = outer.length - 1; i < outer.length; j = i++) {
    final (x0, y0) = outer[j];
    final (x1, y1) = outer[i];
    final cross = x0.toDouble() * y1 - x1.toDouble() * y0;
    area2 += cross;
    cx += (x0 + x1) * cross;
    cy += (y0 + y1) * cross;
  }
  final centroid = ((cx / (3 * area2)).round(), (cy / (3 * area2)).round());
  if (containsPoint([largest], centroid)) return centroid;

  // Nudge off vertex latitudes so the scan line never hits a vertex exactly.
  final y = centroid.$2 + 0.5;
  final xs = <double>[];
  for (final ring in largest) {
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final (x0, y0) = ring[j];
      final (x1, y1) = ring[i];
      if ((y0 > y) != (y1 > y)) xs.add(x0 + (x1 - x0) * (y - y0) / (y1 - y0));
    }
  }
  xs.sort();
  var best = 0;
  for (var k = 2; k + 1 < xs.length; k += 2) {
    if (xs[k + 1] - xs[k] > xs[best + 1] - xs[best]) best = k;
  }
  return (((xs[best] + xs[best + 1]) / 2).round(), y.round());
}

/// The part of [area]'s outline that runs through the interior of [ring]:
/// the longest run of [area] vertices away from [ring], plus the two [ring]
/// vertices it starts and ends at.
///
/// [area] traces [ring] only approximately, so a vertex within [tolerance]
/// micro-degrees of a [ring] edge counts as on the ring. The endpoints snap
/// to the nearest [ring] vertex so that no new vertex is added to [ring]'s
/// borders with other countries.
List<Pt> interiorLine(Ring area, Ring ring, {int tolerance = 5000}) {
  final tol2 = tolerance.toDouble() * tolerance;
  bool onRing(Pt p) {
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      if (_segmentDistance2(p, ring[j], ring[i]) <= tol2) return true;
    }
    return false;
  }

  Pt nearestVertex(Pt p) =>
      ring.reduce((a, b) => _distance2(p, a) <= _distance2(p, b) ? a : b);

  final n = area.length;
  final start = area.indexWhere(onRing);
  if (start < 0) throw StateError('Area does not touch the ring');
  var best = <Pt>[];
  var run = <Pt>[];
  var runStart = area[start];
  for (var k = 1; k <= n; k++) {
    final p = area[(start + k) % n];
    if (!onRing(p)) {
      run.add(p);
      continue;
    }
    if (run.length > best.length) {
      best = [nearestVertex(runStart), ...run, nearestVertex(p)];
    }
    run = [];
    runStart = p;
  }
  if (best.isEmpty) throw StateError('No interior line found');
  return best;
}

double _distance2(Pt a, Pt b) {
  final dx = (a.$1 - b.$1).toDouble();
  final dy = (a.$2 - b.$2).toDouble();
  return dx * dx + dy * dy;
}

double _segmentDistance2(Pt p, Pt a, Pt b) {
  final dx = (b.$1 - a.$1).toDouble();
  final dy = (b.$2 - a.$2).toDouble();
  final len2 = dx * dx + dy * dy;
  final t = len2 == 0
      ? 0.0
      : (((p.$1 - a.$1) * dx + (p.$2 - a.$2) * dy) / len2).clamp(0.0, 1.0);
  return _distance2(p, (a.$1 + (t * dx).round(), a.$2 + (t * dy).round()));
}

/// Splits [ring] along [cut], whose endpoints are vertices of [ring].
(Ring, Ring) splitRing(Ring ring, List<Pt> cut) {
  final i1 = ring.indexOf(cut.first);
  final i2 = ring.indexOf(cut.last);
  List<Pt> walk(int from, int to) => to > from
      ? ring.sublist(from, to + 1)
      : [...ring.sublist(from), ...ring.sublist(0, to + 1)];
  final inner = cut.sublist(1, cut.length - 1);
  return ([...walk(i1, i2), ...inner.reversed], [...walk(i2, i1), ...inner]);
}

/// Even-odd point-in-polygon test in micro-degrees.
bool containsPoint(List<Polygon> polygons, Pt p) {
  bool inRing(Ring r) {
    var inside = false;
    for (var i = 0, j = r.length - 1; i < r.length; j = i++) {
      final (xi, yi) = r[i];
      final (xj, yj) = r[j];
      if ((yi > p.$2) != (yj > p.$2) &&
          p.$1 < (xj - xi) * (p.$2 - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }

  return polygons.any(
    (poly) => inRing(poly.first) && !poly.skip(1).any(inRing),
  );
}
