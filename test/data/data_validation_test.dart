import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/core/geo/geo_codec.dart';
import 'package:globsi/core/geo/geo_data.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

/// Validates the shipped assets against each other (CLAUDE.md §4).
void main() {
  final countries = [
    for (final c in (jsonDecode(
      File('assets/data/countries.json').readAsStringSync(),
    ) as List).cast<Map<String, Object?>>())
      Country.fromJson(c),
  ];
  final ids = {for (final c in countries) c.id};
  final geoFile = File('assets/geo/countries.geo.bin');
  final geo = GeoCodec.decode(ByteData.sublistView(geoFile.readAsBytesSync()));

  group('countries.json', () {
    test('has 193 UN members, 2 observers and 7 partially recognized', () {
      expect(countries, hasLength(202));
      int count(CountryStatus s) =>
          countries.where((c) => c.status == s).length;
      expect(count(CountryStatus.unMember), 193);
      expect(count(CountryStatus.observer), 2);
      expect(count(CountryStatus.partiallyRecognized), 7);
    });

    test('ids and iso3 codes are unique', () {
      expect(ids, hasLength(countries.length));
      expect(countries.map((c) => c.iso3).toSet(), hasLength(countries.length));
    });

    test('every country has names and capitals in both languages', () {
      for (final c in countries) {
        for (final text in [c.name.tr, c.name.en, c.capital.tr, c.capital.en]) {
          expect(text.trim(), isNotEmpty, reason: c.id);
        }
      }
    });

    test('difficulty and centroid are in range', () {
      for (final c in countries) {
        expect(c.difficulty, inInclusiveRange(1, 3), reason: c.id);
        expect(c.centroidLat, inInclusiveRange(-90, 90), reason: c.id);
        expect(c.centroidLon, inInclusiveRange(-180, 180), reason: c.id);
        expect(
          c.centroidLat == 0 && c.centroidLon == 0,
          isFalse,
          reason: '${c.id} centroid not generated',
        );
      }
    });

    test('similarTo and neighbors reference other known countries', () {
      for (final c in countries) {
        for (final other in [...c.similarTo, ...c.neighbors]) {
          expect(ids, contains(other), reason: c.id);
          expect(other, isNot(c.id));
        }
      }
    });

    test('neighbors are symmetric', () {
      final byId = {for (final c in countries) c.id: c};
      for (final c in countries) {
        for (final n in c.neighbors) {
          expect(byId[n]!.neighbors, contains(c.id), reason: '${c.id}-$n');
        }
      }
    });

    test('the smallest countries are marked tiny', () {
      final tiny = {
        for (final c in countries)
          if (c.isTiny) c.id,
      };
      expect(tiny, containsAll(['VA', 'MC', 'SM', 'LI', 'MT', 'SG']));
      expect(tiny, isNot(contains('TR')));
    });
  });

  group('flags', () {
    test('each flag file is named after its country code', () {
      for (final c in countries) {
        expect(c.flag, '${c.id.toLowerCase()}.svg', reason: c.id);
      }
    });

    test('every country has a parseable flag and no flag is unused', () {
      final files = {
        for (final f in Directory('assets/flags').listSync().whereType<File>())
          f.uri.pathSegments.last,
      };
      expect(files, {for (final c in countries) c.flag});
      for (final c in countries) {
        final xml = File(c.flagAsset).readAsStringSync();
        expect(
          () => parseWithoutOptimizers(xml, key: c.flag),
          returnsNormally,
          reason: c.flag,
        );
      }
    });
  });

  group('geo data', () {
    test('stays under 1.5 MB', () {
      expect(geoFile.lengthSync(), lessThan(1536 * 1024));
    });

    test('every country has boundaries and every selectable area is a '
        'country', () {
      for (final c in countries) {
        final feature = geo.featureById(c.id);
        expect(feature, isNotNull, reason: c.id);
        expect(feature!.isCountry, isTrue, reason: c.id);
        expect(feature.polygons, isNotEmpty, reason: c.id);
      }
      for (final f in geo.features.where((f) => f.isCountry)) {
        expect(ids, contains(f.id));
      }
    });

    test('each centroid lies inside its own country', () {
      for (final c in countries) {
        final feature = geo.featureById(c.id)!;
        expect(
          _contains(feature, c.centroidLon, c.centroidLat),
          isTrue,
          reason: c.id,
        );
      }
    });

    test('borders reference valid features', () {
      for (final b in geo.borders) {
        expect(b.featureA, lessThan(geo.features.length));
        if (b.featureB case final other?) {
          expect(other, lessThan(geo.features.length));
          expect(b.kind, BorderKind.land);
        }
        expect(b.points.length, greaterThanOrEqualTo(4));
      }
    });

    test('UN boundary view: Crimea in Ukraine, Golan in Syria', () {
      // Simferopol and Quneitra.
      expect(_contains(geo.featureById('UA')!, 34.10, 44.95), isTrue);
      expect(_contains(geo.featureById('RU')!, 34.10, 44.95), isFalse);
      expect(_contains(geo.featureById('SY')!, 35.82, 33.13), isTrue);
      expect(_contains(geo.featureById('IL')!, 35.82, 33.13), isFalse);
      // Sukhumi and Tskhinvali are not in Georgia.
      expect(_contains(geo.featureById('ABH')!, 41.02, 43), isTrue);
      expect(_contains(geo.featureById('OST')!, 43.96, 42.23), isTrue);
      expect(_contains(geo.featureById('GE')!, 41.02, 43), isFalse);
      // Northern Nicosia is in Northern Cyprus.
      expect(_contains(geo.featureById('NCY')!, 33.36, 35.20), isTrue);
    });
  });
}

bool _contains(GeoFeature feature, double lon, double lat) {
  bool inRing(Float32List r) {
    var inside = false;
    for (var i = 0, j = r.length - 2; i < r.length; j = i, i += 2) {
      final (xi, yi, xj, yj) = (r[i], r[i + 1], r[j], r[j + 1]);
      if ((yi > lat) != (yj > lat) &&
          lon < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }

  return feature.polygons.any(
    (p) =>
        p.bounds.contains(lon, lat) &&
        inRing(p.rings.first) &&
        !p.rings.skip(1).any(inRing),
  );
}
