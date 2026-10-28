import 'dart:collection';

import 'geometry.dart';
import 'simplify.dart';

/// A boundary piece between junctions, stored once even when two features
/// share it. Simplifying arcs (instead of rings) keeps shared borders
/// identical on both sides, so no gaps or overlaps appear between neighbours.
class Arc {
  new(this.points, {required this.isLoop}) : simplified = points;

  /// Canonical vertex order. A loop is a closed ring without junctions.
  final List<Pt> points;
  final bool isLoop;

  /// Feature index for every ring that uses this arc.
  final List<int> owners = [];

  /// Locked arcs are never simplified (used for rings that would collapse).
  bool locked = false;
  List<Pt> simplified;
}

class ArcRef {
  const new(this.arc, {required this.reversed});

  final int arc;
  final bool reversed;
}

class Topology {
  new _(this.arcs, this.features);

  /// Splits all rings into shared arcs. [featurePolygons] is indexed by
  /// feature.
  factory build(List<List<Polygon>> featurePolygons) {
    final junctions = _findJunctions(featurePolygons);
    final arcs = <Arc>[];
    final arcIndex = <String, int>{};

    ArcRef addArc(List<Pt> points, int feature, {required bool loop}) {
      final (canonical, reversed) = loop
          ? _canonicalLoop(points)
          : _canonicalLine(points);
      final key =
          (loop ? 'L' : '') + canonical.map((p) => '${p.$1},${p.$2}').join(' ');
      final index = arcIndex.putIfAbsent(key, () {
        arcs.add(Arc(canonical, isLoop: loop));
        return arcs.length - 1;
      });
      arcs[index].owners.add(feature);
      return ArcRef(index, reversed: reversed);
    }

    final features = [
      for (final (f, polygons) in featurePolygons.indexed)
        [
          for (final polygon in polygons)
            [
              for (final ring in polygon)
                _splitRing(ring, junctions, (points, {required loop}) {
                  return addArc(points, f, loop: loop);
                }),
            ],
        ],
    ];
    return Topology._(arcs, features);
  }

  final List<Arc> arcs;

  /// `features[feature][polygon][ring]` lists the arcs forming each ring.
  final List<List<List<List<ArcRef>>>> features;

  /// Simplifies every arc with Douglas–Peucker. Rings that would collapse
  /// or change area by more than half keep their original arcs.
  void simplify(double tolerance) {
    void run(Arc arc) {
      arc.simplified = arc.locked
          ? arc.points
          : arc.isLoop
          ? simplifyLoop(arc.points, tolerance)
          : simplifyLine(arc.points, tolerance);
    }

    arcs.forEach(run);
    for (var pass = 0; pass < 20; pass++) {
      var changed = false;
      for (final ring in features.expand((f) => f).expand((p) => p)) {
        final simplified = _assemble(ring, simplified: true);
        final original = _assemble(ring, simplified: false);
        if (!_isDegenerate(simplified, original)) continue;
        for (final ref in ring) {
          final arc = arcs[ref.arc];
          if (arc.locked) continue;
          arc.locked = true;
          run(arc);
          changed = true;
        }
      }
      if (!changed) break;
    }
  }

  /// Inserts points so no segment is longer than [maxStep] degrees.
  /// Straight lon/lat segments (e.g. borders along a parallel) are curves on
  /// the globe, so long segments would be drawn as visibly wrong chords.
  void densify(double maxStep) {
    for (final arc in arcs) {
      arc.simplified = densifyLine(
        arc.isLoop ? [...arc.simplified, arc.simplified.first] : arc.simplified,
        maxStep,
      );
      if (arc.isLoop) arc.simplified.removeLast();
    }
  }

  List<Polygon> polygonsOf(int feature) => [
    for (final polygon in features[feature])
      [for (final ring in polygon) _assemble(ring, simplified: true)],
  ];

  List<Pt> _assemble(List<ArcRef> refs, {required bool simplified}) {
    final out = <Pt>[];
    for (final ref in refs) {
      final arc = arcs[ref.arc];
      final points = simplified ? arc.simplified : arc.points;
      final ordered = ref.reversed ? points.reversed.toList() : points;
      if (arc.isLoop) return ordered;
      out.addAll(ordered.take(ordered.length - 1));
    }
    return out;
  }

  static bool _isDegenerate(List<Pt> simplified, List<Pt> original) {
    if (simplified.length < 3) return true;
    final a = planarArea(simplified);
    final b = planarArea(original);
    if (b == 0) return false;
    final ratio = a / b;
    return ratio < 0.5 || ratio > 1.5;
  }
}

/// A vertex is a junction when rings disagree about its neighbours, i.e.
/// where a shared border starts or ends.
Set<Pt> _findJunctions(List<List<Polygon>> featurePolygons) {
  final neighbours = HashMap<Pt, (Pt, Pt)>();
  final junctions = HashSet<Pt>();
  for (final ring in featurePolygons.expand((f) => f).expand((p) => p)) {
    final n = ring.length;
    for (var i = 0; i < n; i++) {
      final a = ring[(i - 1 + n) % n];
      final b = ring[(i + 1) % n];
      final pair = comparePt(a, b) <= 0 ? (a, b) : (b, a);
      if (neighbours.putIfAbsent(ring[i], () => pair) != pair) {
        junctions.add(ring[i]);
      }
    }
  }
  return junctions;
}

List<ArcRef> _splitRing(
  Ring ring,
  Set<Pt> junctions,
  ArcRef Function(List<Pt> points, {required bool loop}) addArc,
) {
  final cuts = [
    for (var i = 0; i < ring.length; i++)
      if (junctions.contains(ring[i])) i,
  ];
  if (cuts.isEmpty) return [addArc(ring, loop: true)];
  return [
    for (var k = 0; k < cuts.length; k++)
      addArc(_slice(ring, cuts[k], cuts[(k + 1) % cuts.length]), loop: false),
  ];
}

/// Points from [start] to [end] inclusive, wrapping around the ring.
List<Pt> _slice(Ring ring, int start, int end) => end > start
    ? ring.sublist(start, end + 1)
    : [...ring.sublist(start), ...ring.sublist(0, end + 1)];

(List<Pt>, bool) _canonicalLine(List<Pt> points) {
  var c = comparePt(points.first, points.last);
  if (c == 0 && points.length > 2) {
    c = comparePt(points[1], points[points.length - 2]);
  }
  return c <= 0 ? (points, false) : (points.reversed.toList(), true);
}

(List<Pt>, bool) _canonicalLoop(List<Pt> ring) {
  var min = 0;
  for (var i = 1; i < ring.length; i++) {
    if (comparePt(ring[i], ring[min]) < 0) min = i;
  }
  final rotated = [...ring.sublist(min), ...ring.sublist(0, min)];
  if (comparePt(rotated[1], rotated.last) <= 0) return (rotated, false);
  return ([rotated.first, ...rotated.skip(1).toList().reversed], true);
}
