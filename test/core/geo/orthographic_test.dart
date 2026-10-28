import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/geo/horizon_clipper.dart';
import 'package:globsi/core/geo/orthographic.dart';

class _RecordingSink implements PathSink {
  final points = <(double, double)>[];
  int moves = 0;
  int closes = 0;

  @override
  void moveTo(double x, double y) {
    moves++;
    points.add((x, y));
  }

  @override
  void lineTo(double x, double y) => points.add((x, y));

  @override
  void close() => closes++;
}

Float32List _vectors(List<(double, double)> lonLat) => toUnitVectors(
  Float32List.fromList([
    for (final (lon, lat) in lonLat) ...[lon, lat],
  ]),
);

void main() {
  group('OrthographicProjection', () {
    final p = OrthographicProjection(centerLat: 39, centerLon: 35);

    test(
      'the center projects to the middle of the disk, facing the viewer',
      () {
        final (x, y, z) = p.project(39, 35);
        expect(x, closeTo(0, 1e-9));
        expect(y, closeTo(0, 1e-9));
        expect(z, closeTo(1, 1e-9));
      },
    );

    test('east is right and north is up', () {
      final (ex, ey, _) = p.project(39, 40);
      final (nx, ny, _) = p.project(44, 35);
      expect(ex, greaterThan(0));
      expect(ey.abs(), lessThan(ex));
      expect(ny, greaterThan(0));
      expect(nx.abs(), lessThan(1e-9));
    });

    test('points 90° away lie on the horizon; the antipode is behind', () {
      final (x, y, z) = OrthographicProjection(
        centerLat: 0,
        centerLon: 0,
      ).project(0, 90);
      expect(z, closeTo(0, 1e-9));
      expect(sqrt(x * x + y * y), closeTo(1, 1e-9));
      expect(p.project(-39, -145).$3, closeTo(-1, 1e-9));
    });

    test('invert is the inverse of project on the visible side', () {
      for (final (lat, lon) in [(39.0, 35.0), (41.9, 12.45), (60.0, 80.0)]) {
        final (x, y, z) = p.project(lat, lon);
        expect(z, greaterThanOrEqualTo(0));
        final (ilat, ilon) = p.invert(x, y)!;
        expect(ilat, closeTo(lat, 1e-6));
        expect(ilon, closeTo(lon, 1e-6));
      }
    });

    test('invert outside the disk is null', () {
      expect(p.invert(0.9, 0.9), isNull);
    });

    test('works at the poles', () {
      final pole = OrthographicProjection(centerLat: 90, centerLon: 0);
      expect(pole.project(90, 123).$3, closeTo(1, 1e-9));
      expect(pole.invert(0, 0)!.$1, closeTo(90, 1e-9));
    });
  });

  group('HorizonClipper', () {
    final clipper = HorizonClipper(
      OrthographicProjection(centerLat: 0, centerLon: 0),
    );

    test('a ring on the visible side is emitted as is', () {
      final sink = _RecordingSink();
      final ring = _vectors([(-10, -10), (10, -10), (10, 10), (-10, 10)]);
      expect(clipper.ring(ring, sink), RingVisibility.visible);
      expect(sink.points, hasLength(4));
      expect(sink.closes, 1);
    });

    test('a ring on the far side is dropped', () {
      final sink = _RecordingSink();
      final ring = _vectors([(170, -10), (-170, -10), (-170, 10), (170, 10)]);
      expect(clipper.ring(ring, sink), RingVisibility.hidden);
      expect(sink.points, isEmpty);
    });

    test('a ring across the horizon is cut along the rim', () {
      final sink = _RecordingSink();
      final ring = _vectors([(60, -20), (120, -20), (120, 20), (60, 20)]);
      expect(clipper.ring(ring, sink), RingVisibility.partial);
      for (final (x, y) in sink.points) {
        expect(x * x + y * y, lessThanOrEqualTo(1 + 1e-9));
      }
      final onRim = sink.points.where(
        (q) => (q.$1 * q.$1 + q.$2 * q.$2 - 1).abs() < 1e-9,
      );
      expect(onRim.length, greaterThanOrEqualTo(2));
      // Nothing is drawn on the left half: the ring is east of the view.
      expect(sink.points.every((q) => q.$1 > 0), isTrue);
    });

    test('polylines are split at the horizon', () {
      final sink = _RecordingSink();
      final line = _vectors([(0, 0), (60, 0), (120, 0), (180, 0), (-120, 0)]);
      clipper.polyline(line, sink);
      expect(sink.moves, 1);
      final (lastX, lastY) = sink.points.last;
      expect(lastX, closeTo(1, 1e-9));
      expect(lastY, closeTo(0, 1e-9));
    });
  });
}
