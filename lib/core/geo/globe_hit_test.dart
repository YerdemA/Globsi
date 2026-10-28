import 'package:globsi/core/geo/geo_data.dart';
import 'package:globsi/core/geo/orthographic.dart';
import 'package:globsi/core/geo/point_in_polygon.dart';

/// A small country with a marker point, selectable within a tolerance even
/// when its shape is only a few pixels wide.
typedef TinyTarget = ({String id, double lat, double lon});

/// The country under unit-disk point ([x], [y]) (y up).
///
/// Small countries in [tinyTargets] stay selectable near their marker point:
/// within [tolerance] (unit-disk distance) when the tap misses all countries,
/// and within half of it when the tap lands in a surrounding country, so
/// Vatican City can be picked without making central Rome unreachable.
String? countryAt({
  required GeoDataset data,
  required OrthographicProjection projection,
  required double x,
  required double y,
  Iterable<TinyTarget> tinyTargets = const [],
  double tolerance = 0,
}) {
  if (x * x + y * y > 1) return null;

  String? nearestTiny;
  var tinyDistance2 = double.infinity;
  for (final t in tinyTargets) {
    final (tx, ty, tz) = projection.project(t.lat, t.lon);
    if (tz < 0) continue;
    final d = (tx - x) * (tx - x) + (ty - y) * (ty - y);
    if (d < tinyDistance2) {
      tinyDistance2 = d;
      nearestTiny = t.id;
    }
  }

  final latLon = projection.invert(x, y);
  final index = latLon == null
      ? null
      : countryIndexAt(data, latLon.$1, latLon.$2);
  final under = index == null ? null : data.features[index].id;

  if (nearestTiny != null && nearestTiny != under) {
    final limit = under == null ? tolerance : tolerance / 2;
    if (tinyDistance2 <= limit * limit) return nearestTiny;
  }
  return under;
}
