import 'dart:typed_data';

/// Axis-aligned bounding box in degrees.
class GeoBounds {
  const new(this.minLon, this.minLat, this.maxLon, this.maxLat);

  /// Bounds of interleaved `[lon, lat, lon, lat, ...]` coordinates.
  factory ofCoords(Iterable<Float32List> rings) {
    var minLon = double.infinity;
    var minLat = double.infinity;
    var maxLon = double.negativeInfinity;
    var maxLat = double.negativeInfinity;
    for (final ring in rings) {
      for (var i = 0; i < ring.length; i += 2) {
        final lon = ring[i];
        final lat = ring[i + 1];
        if (lon < minLon) minLon = lon;
        if (lon > maxLon) maxLon = lon;
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
      }
    }
    return GeoBounds(minLon, minLat, maxLon, maxLat);
  }

  final double minLon;
  final double minLat;
  final double maxLon;
  final double maxLat;

  bool contains(double lon, double lat) =>
      lon >= minLon && lon <= maxLon && lat >= minLat && lat <= maxLat;

  GeoBounds union(GeoBounds other) => GeoBounds(
    minLon < other.minLon ? minLon : other.minLon,
    minLat < other.minLat ? minLat : other.minLat,
    maxLon > other.maxLon ? maxLon : other.maxLon,
    maxLat > other.maxLat ? maxLat : other.maxLat,
  );
}

/// One polygon: the first ring is the outer boundary, the rest are holes.
///
/// Each ring holds interleaved `[lon, lat, ...]` degrees and is implicitly
/// closed (the first point is not repeated at the end).
class GeoPolygon {
  new(this.rings, {GeoBounds? bounds})
    : bounds = bounds ?? GeoBounds.ofCoords(rings.take(1));

  final List<Float32List> rings;
  final GeoBounds bounds;
}

/// A land area: a country (selectable) or other land such as Greenland or
/// Antarctica, drawn but not selectable.
class GeoFeature {
  new({
    required this.id,
    required this.isCountry,
    required this.polygons,
    GeoBounds? bounds,
  }) : bounds = bounds ?? _unionBounds(polygons);

  /// Country id from `countries.json`, or `_` + Natural Earth code for
  /// non-country land.
  final String id;
  final bool isCountry;
  final List<GeoPolygon> polygons;
  final GeoBounds bounds;

  static GeoBounds _unionBounds(List<GeoPolygon> polygons) =>
      polygons.map((p) => p.bounds).reduce((a, b) => a.union(b));
}

enum BorderKind { coast, land }

/// A boundary line drawn on top of the fills. Shared borders are stored once;
/// borders inside a single feature are omitted.
class GeoBorder {
  new({
    required this.kind,
    required this.featureA,
    required this.points,
    this.featureB,
  });

  final BorderKind kind;

  /// Index into [GeoDataset.features].
  final int featureA;

  /// Second feature for land borders, `null` for coastlines.
  final int? featureB;

  /// Interleaved `[lon, lat, ...]` degrees of an open polyline.
  final Float32List points;
}

class GeoDataset {
  new({required this.features, required this.borders})
    : _indexById = {for (final (i, f) in features.indexed) f.id: i};

  final List<GeoFeature> features;
  final List<GeoBorder> borders;
  final Map<String, int> _indexById;

  GeoFeature? featureById(String id) {
    final index = _indexById[id];
    return index == null ? null : features[index];
  }

  int? indexOf(String id) => _indexById[id];
}
