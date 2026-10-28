import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/geo/geo_codec.dart';
import 'package:globsi/core/geo/geo_data.dart';
import 'package:globsi/core/geo/globe_camera.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/core/geo/globe_hit_test.dart';
import 'package:globsi/core/geo/orthographic.dart';
import 'package:globsi/core/geo/point_in_polygon.dart';

void main() {
  final data = GeoCodec.decode(
    ByteData.sublistView(
      File('assets/geo/countries.geo.bin').readAsBytesSync(),
    ),
  );

  group('GlobeCamera', () {
    const camera = GlobeCamera(centerLat: 10, centerLon: 170, zoom: 2);

    test('dragging clamps latitude and wraps longitude', () {
      final moved = camera.dragged(-30 * degToRad, 200 * degToRad);
      expect(moved.centerLat, 90);
      expect(moved.centerLon, closeTo(-160, 1e-9));
      expect(moved.zoom, 2);
    });

    test('zoom is limited to 1–40', () {
      expect(camera.zoomedBy(100).zoom, GlobeCamera.maxZoom);
      expect(camera.zoomedBy(0.01).zoom, GlobeCamera.minZoom);
    });

    test('lerp follows the great circle and ends on the target', () {
      const a = GlobeCamera(centerLat: 0, centerLon: 170);
      const b = GlobeCamera(centerLat: 0, centerLon: -170, zoom: 4);
      final mid = GlobeCamera.lerp(a, b, 0.5);
      expect(mid.centerLon.abs(), closeTo(180, 1e-6));
      expect(mid.zoom, closeTo(2, 1e-9));
      final end = GlobeCamera.lerp(a, b, 1);
      expect(end.centerLon, closeTo(-170, 1e-6));
      expect(end.zoom, closeTo(4, 1e-9));
    });

    test('zoomToFit zooms in on small areas only', () {
      expect(GlobeCamera.zoomToFit(60 * degToRad), GlobeCamera.minZoom);
      expect(GlobeCamera.zoomToFit(0.001 * degToRad), GlobeCamera.maxZoom);
      expect(GlobeCamera.zoomToFit(2 * degToRad), closeTo(10, 0.1));
    });

    test('isSameView compares all fields', () {
      expect(camera.isSameView(camera.withZoom(2)), isTrue);
      expect(camera.isSameView(camera.withZoom(3)), isFalse);
    });
  });

  group('point in polygon', () {
    test('finds countries at their capitals', () {
      String? at(double lat, double lon) {
        final i = countryIndexAt(data, lat, lon);
        return i == null ? null : data.features[i].id;
      }

      expect(at(39.93, 32.86), 'TR'); // Ankara
      expect(at(41.89, 12.49), 'IT'); // Rome, outside the Vatican hole
      // Centroids from countries.json; NE 1:50m shapes are ~1 km off here.
      expect(at(41.902, 12.434), 'VA');
      expect(at(43.75, 7.40), 'MC');
      expect(at(-29.31, 27.48), 'LS'); // Maseru, a hole in South Africa
      expect(at(-26.2, 28.04), 'ZA'); // Johannesburg
      expect(at(35, 18), isNull); // Mediterranean Sea
      expect(at(72, -40), isNull); // Greenland is not a country
    });

    test('ringContains handles a simple square', () {
      final square = Float32List.fromList([0, 0, 2, 0, 2, 2, 0, 2]);
      expect(ringContains(square, 1, 1), isTrue);
      expect(ringContains(square, 3, 1), isFalse);
    });
  });

  group('countryAt', () {
    test('picks the country under a disk point', () {
      final p = OrthographicProjection(centerLat: 39, centerLon: 35);
      expect(countryAt(data: data, projection: p, x: 0, y: 0), 'TR');
      expect(countryAt(data: data, projection: p, x: 0.99, y: 0.99), isNull);
    });

    test('a tiny country near the tap wins over its surroundings', () {
      final p = OrthographicProjection(centerLat: 41.95, centerLon: 12.5);
      const vatican = (id: 'VA', lat: 41.9035, lon: 12.452);
      final (vx, vy, _) = p.project(vatican.lat, vatican.lon);
      // A tap 0.01 disk units away is inside Italy.
      expect(countryAt(data: data, projection: p, x: vx + 0.01, y: vy), 'IT');
      expect(
        countryAt(
          data: data,
          projection: p,
          x: vx + 0.015,
          y: vy,
          tinyTargets: [vatican],
          tolerance: 0.02,
        ),
        'IT',
        reason: 'over land only half the tolerance applies',
      );
      expect(
        countryAt(
          data: data,
          projection: p,
          x: vx + 0.008,
          y: vy,
          tinyTargets: [vatican],
          tolerance: 0.02,
        ),
        'VA',
      );
    });
  });

  group('GlobeGeometry', () {
    final geometry = GlobeGeometry(data);

    test('unit vectors have length 1', () {
      final ring = geometry.featureById('TR')!.polygons.first.rings.first;
      for (var i = 0; i < ring.length; i += 3) {
        final len = sqrt(
          ring[i] * ring[i] +
              ring[i + 1] * ring[i + 1] +
              ring[i + 2] * ring[i + 2],
        );
        expect(len, closeTo(1, 1e-6));
      }
    });

    test('bounding caps contain their polygon and cull the far side', () {
      final turkey = geometry.featureById('TR')!;
      final cap = turkey.polygons
          .reduce((a, b) => a.cap.radius > b.cap.radius ? a : b)
          .cap;
      expect(cap.radius * radToDeg, inInclusiveRange(5, 15));
      final front = OrthographicProjection(centerLat: 39, centerLon: 35);
      final back = OrthographicProjection(centerLat: -39, centerLon: -145);
      expect(cap.isVisible(front, pi / 2), isTrue);
      expect(cap.isVisible(back, pi / 2), isFalse);
    });

    test('neighbouring features never share a color', () {
      for (final b in data.borders) {
        final other = b.featureB;
        if (b.kind != BorderKind.land || other == null) continue;
        expect(
          geometry.features[b.featureA].colorIndex,
          isNot(geometry.features[other].colorIndex),
          reason: '${data.features[b.featureA].id}-${data.features[other].id}',
        );
      }
    });
  });
}
