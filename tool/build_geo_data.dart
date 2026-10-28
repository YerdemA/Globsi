// Converts Natural Earth 1:50m GeoJSON into assets/geo/countries.geo.bin and
// refreshes the generated fields of assets/data/countries.json.
//
// Usage: dart run tool/build_geo_data.dart [--raw=tool/raw] [--tolerance=0.01]
// See README.md for downloading the raw files.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:globsi/core/geo/geo_codec.dart';
import 'package:globsi/core/geo/geo_data.dart';

import 'src/geometry.dart';
import 'src/topology.dart';

const _countriesPath = 'assets/data/countries.json';
const _outputPath = 'assets/geo/countries.geo.bin';

/// Countries smaller than this get `isTiny: true` (circle marker, zoom).
const _tinyAreaKm2 = 3000;

/// countries.json `iso3` → Natural Earth `ADM0_A3`, where they differ.
const _neCodes = {
  'SSD': 'SDS',
  'PSE': 'PSX',
  'XKX': 'KOS',
  'ESH': 'SAH',
  'NCY': 'CYN',
  'SML': 'SOL',
};

/// Breakaway areas used as their own countries (label point source).
const _breakawayLabels = {'ABH': 'B35', 'OST': 'B37'};

Future<void> main(List<String> args) async {
  final options = {
    for (final a in args)
      if (a.startsWith('--') && a.contains('='))
        a.substring(2, a.indexOf('=')): a.substring(a.indexOf('=') + 1),
  };
  final rawDir = options['raw'] ?? 'tool/raw';
  final tolerance = double.parse(options['tolerance'] ?? '0.01');

  final rawSubunits = readGeoJson(
    '$rawDir/ne_50m_admin_0_map_subunits.geojson',
  );
  final rawBreakaway = readGeoJson(
    '$rawDir/ne_50m_admin_0_breakaway_disputed_areas.geojson',
  );
  // Subunits come first so breakaway areas snap onto their vertices.
  final snapped = snapVertices([
    for (final f in [...rawSubunits, ...rawBreakaway]) f.polygons,
  ]);
  final subunits = [
    for (final (i, f) in rawSubunits.indexed)
      RawFeature(f.properties, snapped[i]),
  ];
  final breakaway = {
    for (final (i, f) in rawBreakaway.indexed)
      f.prop('BRK_A3'): RawFeature(
        f.properties,
        snapped[rawSubunits.length + i],
      ),
  };
  final labels = {
    for (final f in readGeoJson('$rawDir/ne_50m_admin_0_countries.geojson'))
      f.prop('ADM0_A3'): _labelOf(f),
    for (final MapEntry(:key, :value) in _breakawayLabels.entries)
      key: _labelOf(breakaway[value]!),
  };

  final groups = _buildGroups(subunits, breakaway);

  final countries = (jsonDecode(
    File(_countriesPath).readAsStringSync(),
  ) as List).cast<Map<String, Object?>>();
  final countryByCode = {
    for (final c in countries) _neCodes[c['iso3']] ?? c['iso3']! as String: c,
  };
  final missing = countryByCode.keys.where((k) => !groups.containsKey(k));
  if (missing.isNotEmpty) {
    stderr.writeln('No geometry for: ${missing.join(', ')}');
    exitCode = 1;
    return;
  }

  // Countries first (sorted by id), then other land.
  final codes = groups.keys.toList()
    ..sort((a, b) {
      final ca = countryByCode[a];
      final cb = countryByCode[b];
      if ((ca == null) != (cb == null)) return ca == null ? 1 : -1;
      return _featureId(a, ca).compareTo(_featureId(b, cb));
    });

  final topology = Topology.build([for (final c in codes) groups[c]!])
    ..simplify(tolerance);

  final features = <GeoFeature>[];
  for (final (i, code) in codes.indexed) {
    final country = countryByCode[code];
    features.add(
      GeoFeature(
        id: _featureId(code, country),
        isCountry: country != null,
        polygons: [
          for (final polygon in topology.polygonsOf(i))
            GeoPolygon([for (final ring in polygon) _toFloat32(ring)]),
        ],
      ),
    );
  }
  final borders = _buildBorders(topology);
  final bytes = GeoCodec.encode(
    GeoDataset(features: features, borders: borders),
  );
  File(_outputPath).writeAsBytesSync(bytes);

  // Neighbours: land borders between two countries.
  final neighbours = {
    for (final c in countries) c['id']! as String: <String>{},
  };
  for (final b in borders) {
    final a = features[b.featureA];
    final other = b.featureB == null ? null : features[b.featureB!];
    if (other == null || !a.isCountry || !other.isCountry) continue;
    neighbours[a.id]!.add(other.id);
    neighbours[other.id]!.add(a.id);
  }

  final tiny = <String>[];
  for (final (i, code) in codes.indexed) {
    final country = countryByCode[code];
    if (country == null) continue;
    final id = country['id']! as String;
    final area = sphericalAreaKm2(groups[code]!);
    final polygons = topology.polygonsOf(i);
    var (lat, lon) = labels[code]!;
    final label = ((lon * coordScale).round(), (lat * coordScale).round());
    // NE label points of small islands are often offset into the sea.
    if (!containsPoint(polygons, label)) {
      final (x, y) = interiorPoint(polygons);
      (lat, lon) = (y / coordScale, x / coordScale);
      stdout.writeln('note: $id label point moved onto land');
    }
    country['centroid'] = [_round(lat), _round(lon)];
    country['isTiny'] = area < _tinyAreaKm2;
    country['neighbors'] = neighbours[id]!.toList()..sort();
    if (area < _tinyAreaKm2) tiny.add(id);
  }
  File(_countriesPath).writeAsStringSync(_formatJson(countries));

  final points = features
      .expand((f) => f.polygons)
      .expand((p) => p.rings)
      .fold(0, (n, r) => n + r.length ~/ 2);
  stdout
    ..writeln(
      'features: ${features.length} '
      '(${countryByCode.length} countries), borders: ${borders.length}',
    )
    ..writeln('fill points: $points, tolerance: $tolerance°')
    ..writeln('tiny (<$_tinyAreaKm2 km²): ${tiny.join(' ')}')
    ..writeln(
      'non-country land: '
      '${codes.where((c) => !countryByCode.containsKey(c)).join(' ')}',
    )
    ..writeln(
      'wrote $_outputPath (${(bytes.length / 1024).toStringAsFixed(0)} KB)',
    );
}

/// Natural Earth subunits grouped into features, with the boundary choices
/// recorded in CLAUDE.md §4.2 applied on top of the NE default view.
Map<String, List<Polygon>> _buildGroups(
  List<RawFeature> subunits,
  Map<String, RawFeature> breakaway,
) {
  // Crimea is a subunit of Russia in NE; assign it to Ukraine (UN view).
  const reassignedSubunits = {'RUC': 'UKR'};
  final groups = <String, List<Polygon>>{};
  for (final f in subunits) {
    final code = reassignedSubunits[f.prop('SU_A3')] ?? f.prop('ADM0_A3');
    groups.putIfAbsent(code, () => []).addAll(f.polygons);
  }

  // NE breakaway polygons only approximate the outline of the country they
  // lie in, so instead of clipping, the country is split along the
  // breakaway area's interior line. Both parts then reuse the country's own
  // vertices and still match its neighbours exactly.

  // Golan Heights: part of Israel in NE; assign to Syria (UN view).
  final (golan, israel) = _splitOff(groups['ISR']!, breakaway['B16']!);
  groups['ISR'] = israel;
  groups['SYR']!.addAll(golan);

  // Abkhazia and South Ossetia are carved out of Georgia.
  final (abkhazia, georgia) = _splitOff(groups['GEO']!, breakaway['B35']!);
  final (southOssetia, rest) = _splitOff(georgia, breakaway['B37']!);
  groups
    ..['ABH'] = abkhazia
    ..['OST'] = southOssetia
    ..['GEO'] = rest;
  return groups;
}

/// Border polylines, with the artificial cut lines along the antimeridian
/// and the south pole removed.
List<GeoBorder> _buildBorders(Topology topology) {
  bool isCut(Pt a, Pt b) {
    const lon180 = 180 * coordScale;
    const southPole = -89.99 * coordScale;
    return (a.$1.abs() == lon180 && a.$1 == b.$1) ||
        (a.$2 <= southPole && b.$2 <= southPole);
  }

  final borders = <GeoBorder>[];
  for (final arc in topology.arcs) {
    final owners = arc.owners.toSet();
    // Used twice by the same feature: an internal line (e.g. Crimea).
    if (owners.length == 1 && arc.owners.length > 1) continue;
    final a = owners.first;
    final b = owners.length > 1 ? owners.elementAt(1) : null;
    final points = arc.isLoop
        ? [...arc.simplified, arc.simplified.first]
        : arc.simplified;

    var run = <Pt>[points.first];
    void flush() {
      if (run.length >= 2) {
        borders.add(
          GeoBorder(
            kind: b == null ? BorderKind.coast : BorderKind.land,
            featureA: a,
            featureB: b,
            points: _toFloat32(run),
          ),
        );
      }
    }

    for (var i = 1; i < points.length; i++) {
      if (isCut(points[i - 1], points[i])) {
        flush();
        run = [points[i]];
      } else {
        run.add(points[i]);
      }
    }
    flush();
  }
  return borders;
}

/// Splits a single-ring [country] into the part covered by [area] and the
/// rest.
(List<Polygon>, List<Polygon>) _splitOff(
  List<Polygon> country,
  RawFeature area,
) {
  if (country.length != 1 || country.single.length != 1) {
    throw StateError('Expected a single ring to split');
  }
  final ring = country.single.first;
  final cut = interiorLine(area.polygons.single.first, ring);
  final (a, b) = splitRing(ring, cut);
  final (lat, lon) = _labelOf(area);
  final label = ((lon * coordScale).round(), (lat * coordScale).round());
  final aIsArea = containsPoint([
    [a],
  ], label);
  return (
    [
      [if (aIsArea) a else b],
    ],
    [
      [if (aIsArea) b else a],
    ],
  );
}

String _featureId(String code, Map<String, Object?>? country) =>
    country?['id'] as String? ?? '_$code';

(double, double) _labelOf(RawFeature f) => (
  (f.properties['LABEL_Y']! as num).toDouble(),
  (f.properties['LABEL_X']! as num).toDouble(),
);

double _round(double v) => (v * 1000).round() / 1000;

Float32List _toFloat32(List<Pt> points) {
  final out = Float32List(points.length * 2);
  for (final (i, (x, y)) in points.indexed) {
    out[i * 2] = x / coordScale;
    out[i * 2 + 1] = y / coordScale;
  }
  return out;
}

/// Pretty JSON with short arrays kept on one line.
String _formatJson(Object json) {
  final pretty = const JsonEncoder.withIndent('  ').convert(json);
  final inlined = pretty.replaceAllMapped(
    RegExp(r'\[([^\[\]{}]*)\]'),
    (m) => '[${m[1]!.trim().replaceAll(RegExp(r',\s+'), ', ')}]',
  );
  return '$inlined\n';
}
