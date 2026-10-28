import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/geometry.dart';
import '../../tool/src/simplify.dart';
import '../../tool/src/topology.dart';

/// Unit square scaled to micro-degrees.
Pt p(double x, double y) =>
    ((x * coordScale).round(), (y * coordScale).round());

void main() {
  group('simplifyLine', () {
    test('drops points within tolerance and keeps endpoints', () {
      final line = [p(0, 0), p(1, 0.001), p(2, 0), p(3, 0.001), p(4, 0)];
      expect(simplifyLine(line, 0.01), [p(0, 0), p(4, 0)]);
    });

    test('keeps points beyond tolerance', () {
      final line = [p(0, 0), p(1, 0.5), p(2, 0)];
      expect(simplifyLine(line, 0.01), line);
    });
  });

  group('Topology', () {
    // Two squares sharing the edge x = 1, with a wiggly shared border.
    final border = [for (var i = 0; i <= 10; i++) p(1, i / 10 + 0)];
    final wiggly = [
      for (final (i, q) in border.indexed) (q.$1 + (i.isOdd ? 1000 : 0), q.$2),
    ];
    final left = [p(0, 0), ...wiggly, p(0, 1)];
    final right = [p(2, 0), p(2, 1), ...wiggly.reversed];

    test('shares one arc between neighbours and simplifies it once', () {
      final topology = Topology.build([
        [
          [left],
        ],
        [
          [right],
        ],
      ])..simplify(0.01);

      final shared = topology.arcs.where((a) => a.owners.toSet().length == 2);
      expect(shared, hasLength(1));
      expect(shared.single.simplified, hasLength(2));

      final a = topology.polygonsOf(0).single.single.toSet();
      final b = topology.polygonsOf(1).single.single.toSet();
      expect(a.intersection(b), {p(1, 0), p(1, 1)});
    });

    test('keeps tiny rings instead of collapsing them', () {
      final tiny = [p(0, 0), p(0.001, 0), p(0.001, 0.001), p(0, 0.001)];
      final topology = Topology.build([
        [
          [tiny],
        ],
      ])..simplify(0.01);
      expect(topology.polygonsOf(0).single.single, hasLength(4));
    });

    test('a hole matching another feature becomes one shared loop', () {
      final outer = [p(0, 0), p(3, 0), p(3, 3), p(0, 3)];
      final hole = [p(1, 1), p(2, 1), p(2, 2), p(1, 2)];
      final topology = Topology.build([
        [
          [outer, hole],
        ],
        [
          [hole.reversed.toList()],
        ],
      ]);
      final loops = topology.arcs.where((a) => a.isLoop).toList();
      expect(loops, hasLength(2));
      expect(loops.where((a) => a.owners.length == 2), hasLength(1));
    });
  });

  group('splitting a country', () {
    // A 4×2 rectangle; the area covers its right half and approximates the
    // outer edges slightly, with an interior line at x = 2.
    final country = [p(0, 0), p(2, 0), p(4, 0), p(4, 2), p(2, 2), p(0, 2)];
    final area = [
      p(2.001, -0.001),
      p(4, 0),
      p(4, 2),
      p(2.001, 2.001),
      p(2.1, 1.5),
      p(1.9, 0.5),
    ];

    test('interiorLine snaps its ends to country vertices', () {
      final cut = interiorLine(area, country);
      expect(cut.first, p(2, 2));
      expect(cut.last, p(2, 0));
      expect(cut.sublist(1, cut.length - 1), [p(2.1, 1.5), p(1.9, 0.5)]);
    });

    test('splitRing produces two rings covering the country', () {
      final (a, b) = splitRing(country, interiorLine(area, country));
      final total = planarArea(country).abs();
      expect(planarArea(a).abs() + planarArea(b).abs(), closeTo(total, 1));
      final right =
          containsPoint([
            [a],
          ], p(3, 1))
          ? a
          : b;
      expect(
        containsPoint([
          [right],
        ], p(1, 1)),
        isFalse,
      );
    });
  });

  test('removeSpikes removes back-and-forth vertices', () {
    final ring = [p(0, 0), p(1, 0), p(1, 1), p(1.5, 1.5), p(1, 1), p(0, 1)];
    expect(removeSpikes(ring), [p(0, 0), p(1, 0), p(1, 1), p(0, 1)]);
  });

  test('snapVertices merges nearly identical points across features', () {
    final a = [p(0, 0), p(1, 0), p(1, 1)];
    final b = [(1000010, 10), p(2, 0), p(1, 1)];
    final snapped = snapVertices([
      [
        [a],
      ],
      [
        [b],
      ],
    ]);
    expect(snapped[1].single.single.first, p(1, 0));
  });

  test('sphericalAreaKm2 of a 1°×1° cell at the equator', () {
    final cell = [p(0, 0), p(1, 0), p(1, 1), p(0, 1)];
    expect(
      sphericalAreaKm2([
        [cell],
      ]),
      closeTo(12364, 50),
    );
  });
}
