import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/geo/level_of_detail.dart';

void main() {
  group('simplifyLonLat', () {
    test('drops points within tolerance on an open line', () {
      final line = Float32List.fromList([0, 0, 1, 0.01, 2, 0, 3, 0.01, 4, 0]);
      expect(simplifyLonLat(line, 0.1, closed: false), [0, 0, 4, 0]);
    });

    test('keeps a closed ring as a shape', () {
      final wiggly = Float32List.fromList([
        0, 0, 1, 0.01, 2, 0, 2, 1, 2, 2, 1, 2.01, 0, 2, 0, 1, //
      ]);
      final simplified = simplifyLonLat(wiggly, 0.1, closed: true);
      expect(simplified.length ~/ 2, 4);
    });

    test('returns tiny rings unchanged instead of collapsing them', () {
      final tiny = Float32List.fromList([0, 0, 0.01, 0, 0.01, 0.01, 0, 0.01]);
      expect(identical(simplifyLonLat(tiny, 0.2, closed: true), tiny), isTrue);
    });

    test('tolerance 0 is the identity', () {
      final line = Float32List.fromList([0, 0, 1, 1, 2, 2, 3, 3]);
      expect(identical(simplifyLonLat(line, 0, closed: false), line), isTrue);
    });
  });

  group('lodLevelFor', () {
    test('uses coarse levels on a small globe and full detail zoomed in', () {
      expect(lodLevelFor(185), lodTolerances.length - 1);
      expect(lodLevelFor(185 * 40), 0);
    });

    test('never exceeds the pixel budget', () {
      for (final radius in [100.0, 400.0, 1000.0, 3000.0]) {
        final level = lodLevelFor(radius);
        final pixels = lodTolerances[level] * 3.14159 / 180 * radius;
        expect(pixels, lessThanOrEqualTo(0.7));
      }
    });
  });
}
