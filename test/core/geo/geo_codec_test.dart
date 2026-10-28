import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/geo/geo_codec.dart';
import 'package:globsi/core/geo/geo_data.dart';

void main() {
  GeoDataset sample() {
    final square = Float32List.fromList([0, 0, 2, 0, 2, 2, 0, 2]);
    final hole = Float32List.fromList([0.5, 0.5, 1, 0.5, 1, 1]);
    final island = Float32List.fromList([10, 10, 11, 10, 11, 11]);
    return GeoDataset(
      features: [
        GeoFeature(
          id: 'TR',
          isCountry: true,
          polygons: [
            GeoPolygon([square, hole]),
            GeoPolygon([island]),
          ],
        ),
        GeoFeature(
          id: '_GRL',
          isCountry: false,
          polygons: [
            GeoPolygon([island]),
          ],
        ),
      ],
      borders: [
        GeoBorder(
          kind: BorderKind.land,
          featureA: 0,
          featureB: 1,
          points: Float32List.fromList([2, 0, 2, 2]),
        ),
        GeoBorder(
          kind: BorderKind.coast,
          featureA: 0,
          points: Float32List.fromList([0, 0, 2, 0]),
        ),
      ],
    );
  }

  test('round-trips features, polygons, holes and borders', () {
    final bytes = GeoCodec.encode(sample());
    final decoded = GeoCodec.decode(ByteData.sublistView(bytes));

    expect(decoded.features.map((f) => f.id), ['TR', '_GRL']);
    final tr = decoded.featureById('TR')!;
    expect(tr.isCountry, isTrue);
    expect(tr.polygons, hasLength(2));
    expect(tr.polygons[0].rings, hasLength(2));
    expect(tr.polygons[0].rings[1], [0.5, 0.5, 1, 0.5, 1, 1]);
    expect(tr.bounds.minLon, 0);
    expect(tr.bounds.maxLat, 11);
    expect(tr.polygons[1].bounds.minLon, 10);
    expect(decoded.featureById('_GRL')!.isCountry, isFalse);
    expect(decoded.indexOf('_GRL'), 1);

    expect(decoded.borders, hasLength(2));
    expect(decoded.borders[0].kind, BorderKind.land);
    expect(decoded.borders[0].featureB, 1);
    expect(decoded.borders[1].kind, BorderKind.coast);
    expect(decoded.borders[1].featureB, isNull);
    expect(decoded.borders[1].points, [0, 0, 2, 0]);
  });

  test('rejects data that is not a geo file', () {
    expect(
      () => GeoCodec.decode(ByteData(16)),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects an unknown version', () {
    final bytes = GeoCodec.encode(sample());
    ByteData.sublistView(bytes).setUint16(4, 99, Endian.little);
    expect(
      () => GeoCodec.decode(ByteData.sublistView(bytes)),
      throwsA(isA<FormatException>()),
    );
  });
}
