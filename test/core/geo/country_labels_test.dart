import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/geo/country_labels.dart';
import 'package:globsi/core/geo/orthographic.dart';

void main() {
  const size = 400.0;
  final projection = OrthographicProjection(centerLat: 0, centerLon: 0);

  List<PlacedLabel> place(
    List<LabelTarget> targets, {
    double zoom = 4,
    String? Function(double x, double y)? under,
  }) => placeCountryLabels(
    targets: targets,
    projection: projection,
    zoom: zoom,
    globeRadius: size * 0.45 * zoom,
    viewWidth: size,
    viewHeight: size,
    sizeOf: (_) => (60, 16),
    countryUnder: under ?? (_, _) => null,
  );

  LabelTarget target(
    String id,
    double lat,
    double lon, {
    double radius = 0.2,
  }) => (id: id, lat: lat, lon: lon, radius: radius);

  test('no names on the whole globe', () {
    expect(place([target('A', 0, 0)], zoom: 1), isEmpty);
  });

  test('names fade in with zoom', () {
    final partial = place([target('A', 0, 0)], zoom: 1.75).single;
    final full = place([target('A', 0, 0)]).single;
    expect(partial.opacity, closeTo(0.5, 0.01));
    expect(full.opacity, 1);
  });

  test('a centered country is named at its marker point', () {
    final label = place([target('A', 0, 0)]).single;
    expect(label.id, 'A');
    expect(label.x, closeTo(size / 2, 0.01));
    expect(label.y, closeTo(size / 2, 0.01));
  });

  test('countries behind the globe or outside the center are skipped', () {
    expect(place([target('BACK', 0, 180)]), isEmpty);
    expect(place([target('FAR', 0, 60)]), isEmpty);
  });

  test('countries that look very small are skipped until zoomed in', () {
    final tiny = target('TINY', 0, 0, radius: 0.00007);
    expect(place([tiny]), isEmpty);
    expect(place([tiny], zoom: 40).single.id, 'TINY');
  });

  test('of two overlapping names the one nearer the center stays', () {
    final labels = place([target('NEAR', 0.2, 0.2), target('NEARER', 0, 0)]);
    expect(labels.map((l) => l.id), ['NEARER']);
  });

  test('a country covering the center gets a name without its marker', () {
    final label = place([target('BIG', 0, 60)], under: (x, y) => 'BIG').single;
    expect(label.id, 'BIG');
    expect(label.x, closeTo(size / 2, 0.01));
    expect(label.y, closeTo(size / 2, 0.01));
  });

  test('labels never overlap', () {
    final labels = place([
      for (var lat = -8; lat <= 8; lat += 2)
        for (var lon = -8; lon <= 8; lon += 2)
          target('$lat/$lon', lat.toDouble(), lon.toDouble()),
    ]);
    expect(labels, isNotEmpty);
    for (final a in labels) {
      for (final b in labels) {
        if (identical(a, b)) continue;
        final apart =
            (a.x - b.x).abs() >= 60 + 8 || (a.y - b.y).abs() >= 16 + 8;
        expect(apart, isTrue, reason: '${a.id} and ${b.id}');
      }
    }
  });
}
