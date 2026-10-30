import 'dart:math';

import 'package:globsi/core/geo/orthographic.dart';

/// A country that can get a name on the globe. `radius` is the angular radius
/// (radians) of its largest part.
typedef LabelTarget = ({String id, double lat, double lon, double radius});

/// A label to draw, centered on ([x], [y]) in screen coordinates.
class PlacedLabel {
  const new({
    required this.id,
    required this.x,
    required this.y,
    required this.opacity,
  });

  final String id;
  final double x;
  final double y;
  final double opacity;
}

/// Chooses which country names to show around the center of the view.
///
/// Nothing is shown until the globe is zoomed in; names then fade in and also
/// fade towards the edge of the central region, so they do not pop while the
/// globe turns. When two names would overlap, the one nearer the center stays.
///
/// A country whose marker point is outside the region still gets a name if
/// it covers part of the region (e.g. Russia when looking at Siberia): the name
/// sits in the middle of that part. [countryUnder] gives the country at a
/// screen point.
List<PlacedLabel> placeCountryLabels({
  required List<LabelTarget> targets,
  required OrthographicProjection projection,
  required double zoom,
  required double globeRadius,
  required double viewWidth,
  required double viewHeight,
  required (double, double) Function(String id) sizeOf,
  required String? Function(double x, double y) countryUnder,
}) {
  const fadeInStart = 1.5;
  const fadeInEnd = 2.0;
  const minApparentRadius = 8.0;
  // From here on few countries fit the view, so even Vatican City gets a name.
  const anySizeZoom = 12.0;
  const minFacing = 0.15;
  const edgeFade = 0.25;
  const gap = 4.0;
  const gridColumns = 5;
  const gridRows = 4;
  const gridExtent = 0.8;

  final zoomFade = ((zoom - fadeInStart) / (fadeInEnd - fadeInStart)).clamp(
    0.0,
    1.0,
  );
  if (zoomFade == 0) return const [];

  final centerX = viewWidth / 2;
  final centerY = viewHeight / 2;
  final halfWidth = viewWidth * 0.46;
  final halfHeight = viewHeight * 0.4;
  double edgeDistance(double x, double y) {
    final dx = (x - centerX) / halfWidth;
    final dy = (y - centerY) / halfHeight;
    return sqrt(dx * dx + dy * dy);
  }

  final eligible = <String>{};
  final anchors = <String, (double, double)>{};
  for (final t in targets) {
    if (zoom < anySizeZoom && t.radius * globeRadius < minApparentRadius) {
      continue;
    }
    eligible.add(t.id);
    final (px, py, pz) = projection.project(t.lat, t.lon);
    if (pz < minFacing) continue;
    final x = centerX + px * globeRadius;
    final y = centerY - py * globeRadius;
    if (edgeDistance(x, y) < 1) anchors[t.id] = (x, y);
  }

  final hits = <String, (double, double, int)>{};
  for (var row = 0; row < gridRows; row++) {
    for (var column = 0; column < gridColumns; column++) {
      final x =
          centerX +
          halfWidth * gridExtent * (2 * column / (gridColumns - 1) - 1);
      final y =
          centerY + halfHeight * gridExtent * (2 * row / (gridRows - 1) - 1);
      final id = countryUnder(x, y);
      if (id == null || !eligible.contains(id) || anchors.containsKey(id)) {
        continue;
      }
      final (sumX, sumY, count) = hits[id] ?? (0.0, 0.0, 0);
      hits[id] = (sumX + x, sumY + y, count + 1);
    }
  }
  for (final MapEntry(key: id, value: (sumX, sumY, count)) in hits.entries) {
    anchors[id] = (sumX / count, sumY / count);
  }

  final ordered =
      anchors.entries
          .map((e) => (id: e.key, x: e.value.$1, y: e.value.$2))
          .toList()
        ..sort(
          (a, b) => edgeDistance(a.x, a.y).compareTo(edgeDistance(b.x, b.y)),
        );

  final placed = <PlacedLabel>[];
  final boxes = <(double, double, double, double)>[];
  for (final c in ordered) {
    final opacity =
        zoomFade * ((1 - edgeDistance(c.x, c.y)) / edgeFade).clamp(0.0, 1.0);
    if (opacity < 0.05) continue;
    final (width, height) = sizeOf(c.id);
    final left = c.x - width / 2 - gap;
    final top = c.y - height / 2 - gap;
    final right = c.x + width / 2 + gap;
    final bottom = c.y + height / 2 + gap;
    final overlaps = boxes.any(
      (b) => left < b.$3 && right > b.$1 && top < b.$4 && bottom > b.$2,
    );
    if (overlaps) continue;
    boxes.add((left, top, right, bottom));
    placed.add(PlacedLabel(id: c.id, x: c.x, y: c.y, opacity: opacity));
  }
  return placed;
}
