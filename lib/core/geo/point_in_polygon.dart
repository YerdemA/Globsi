import 'dart:typed_data';

import 'package:globsi/core/geo/geo_data.dart';

/// Even-odd test of ([lon], [lat]) against a ring of `[lon, lat, ...]`.
bool ringContains(Float32List ring, double lon, double lat) {
  var inside = false;
  final n = ring.length;
  for (var i = 0, j = n - 2; i < n; j = i, i += 2) {
    final xi = ring[i];
    final yi = ring[i + 1];
    final xj = ring[j];
    final yj = ring[j + 1];
    if ((yi > lat) != (yj > lat) &&
        lon < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
      inside = !inside;
    }
  }
  return inside;
}

bool polygonContains(GeoPolygon polygon, double lon, double lat) {
  if (!polygon.bounds.contains(lon, lat)) return false;
  if (!ringContains(polygon.rings.first, lon, lat)) return false;
  for (var i = 1; i < polygon.rings.length; i++) {
    if (ringContains(polygon.rings[i], lon, lat)) return false;
  }
  return true;
}

bool featureContains(GeoFeature feature, double lon, double lat) =>
    feature.bounds.contains(lon, lat) &&
    feature.polygons.any((p) => polygonContains(p, lon, lat));

/// Index of the country containing ([lat], [lon]), or `null` (sea or
/// non-country land).
int? countryIndexAt(GeoDataset data, double lat, double lon) {
  for (var i = 0; i < data.features.length; i++) {
    final f = data.features[i];
    if (f.isCountry && featureContains(f, lon, lat)) return i;
  }
  return null;
}
