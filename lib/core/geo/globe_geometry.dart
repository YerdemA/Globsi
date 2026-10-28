import 'dart:math';
import 'dart:typed_data';

import 'package:globsi/core/geo/geo_data.dart';
import 'package:globsi/core/geo/level_of_detail.dart';
import 'package:globsi/core/geo/orthographic.dart';

/// A spherical cap enclosing some geometry, used to skip what is off-screen.
class BoundingCap {
  new(this.x, this.y, this.z, this.radius);

  /// Smallest-ish cap around unit vectors [xyz]: centered on their mean
  /// direction, reaching the farthest point.
  factory around(Iterable<Float32List> xyz) {
    var sx = 0.0;
    var sy = 0.0;
    var sz = 0.0;
    for (final v in xyz) {
      for (var i = 0; i < v.length; i += 3) {
        sx += v[i];
        sy += v[i + 1];
        sz += v[i + 2];
      }
    }
    final len = sqrt(sx * sx + sy * sy + sz * sz);
    if (len < 1e-9) return BoundingCap(0, 0, 1, pi);
    sx /= len;
    sy /= len;
    sz /= len;
    var minDot = 1.0;
    for (final v in xyz) {
      for (var i = 0; i < v.length; i += 3) {
        final d = sx * v[i] + sy * v[i + 1] + sz * v[i + 2];
        if (d < minDot) minDot = d;
      }
    }
    return BoundingCap(sx, sy, sz, acos(minDot.clamp(-1.0, 1.0)));
  }

  final double x;
  final double y;
  final double z;

  /// Angular radius in radians.
  final double radius;

  /// Whether any part may lie within [viewAngle] radians of the view center.
  bool isVisible(OrthographicProjection projection, double viewAngle) {
    final limit = viewAngle + radius;
    if (limit >= pi) return true;
    return projection.cosAngleTo(x, y, z) > cos(limit);
  }
}

class GlobePolygon {
  new(this.source)
    : levels = [
        for (final tolerance in lodTolerances)
          [
            for (final r in source.rings)
              toUnitVectors(simplifyLonLat(r, tolerance, closed: true)),
          ],
      ] {
    cap = BoundingCap.around(rings.take(1));
  }

  final GeoPolygon source;

  /// `levels[lod][ring]`: unit vectors of each ring (outer first),
  /// interleaved `[x, y, z, ...]`, per [lodTolerances] level.
  final List<List<Float32List>> levels;
  late final BoundingCap cap;

  /// Full-detail rings.
  List<Float32List> get rings => levels.first;
}

class GlobeFeature {
  new(this.source, {required this.colorIndex})
    : polygons = [for (final p in source.polygons) GlobePolygon(p)];

  final GeoFeature source;
  final List<GlobePolygon> polygons;

  /// Fill color slot; neighbouring features never share one.
  final int colorIndex;

  String get id => source.id;
  bool get isCountry => source.isCountry;

  /// Angular radius of the largest part (ignores far-away islands).
  double get mainRadius => polygons.map((p) => p.cap.radius).reduce(max);
}

class GlobeBorder {
  new(this.source)
    : levels = [
        for (final tolerance in lodTolerances)
          toUnitVectors(
            simplifyLonLat(source.points, tolerance, closed: false),
          ),
      ] {
    cap = BoundingCap.around([xyz]);
  }

  final GeoBorder source;

  /// Unit vectors per [lodTolerances] level.
  final List<Float32List> levels;
  late final BoundingCap cap;

  /// Full-detail unit vectors.
  Float32List get xyz => levels.first;
}

/// [GeoDataset] prepared for drawing on a globe: coordinates converted to
/// unit vectors once, bounding caps for culling, and a map coloring.
class GlobeGeometry {
  new(this.data, {this.colorCount = 5})
    : borders = [for (final b in data.borders) GlobeBorder(b)] {
    final colors = colorFeatures(data, colorCount);
    features = [
      for (final (i, f) in data.features.indexed)
        GlobeFeature(f, colorIndex: colors[i]),
    ];
  }

  final GeoDataset data;
  final int colorCount;
  late final List<GlobeFeature> features;
  final List<GlobeBorder> borders;

  GlobeFeature? featureById(String id) {
    final i = data.indexOf(id);
    return i == null ? null : features[i];
  }
}

/// Assigns each feature one of [colorCount] colors so that features sharing
/// a land border differ (DSatur greedy coloring). Falls back to the least
/// used neighbouring color if a feature cannot get a free one.
List<int> colorFeatures(GeoDataset data, int colorCount) {
  final n = data.features.length;
  final neighbours = List.generate(n, (_) => <int>{});
  for (final b in data.borders) {
    final other = b.featureB;
    if (other == null || other == b.featureA) continue;
    neighbours[b.featureA].add(other);
    neighbours[other].add(b.featureA);
  }

  final colors = List.filled(n, -1);
  final saturation = List.generate(n, (_) => <int>{});
  for (var step = 0; step < n; step++) {
    var pick = -1;
    for (var i = 0; i < n; i++) {
      if (colors[i] >= 0) continue;
      if (pick < 0 ||
          saturation[i].length > saturation[pick].length ||
          (saturation[i].length == saturation[pick].length &&
              neighbours[i].length > neighbours[pick].length)) {
        pick = i;
      }
    }
    var color = -1;
    for (var c = 0; c < colorCount; c++) {
      if (!saturation[pick].contains(c)) {
        color = c;
        break;
      }
    }
    if (color < 0) {
      final counts = List.filled(colorCount, 0);
      for (final nb in neighbours[pick]) {
        if (colors[nb] >= 0) counts[colors[nb]]++;
      }
      color = counts.indexOf(counts.reduce(min));
    }
    colors[pick] = color;
    for (final nb in neighbours[pick]) {
      saturation[nb].add(color);
    }
  }
  return colors;
}
