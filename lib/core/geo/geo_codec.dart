import 'dart:convert';
import 'dart:typed_data';

import 'package:globsi/core/geo/geo_data.dart';

/// Compact little-endian binary format for [GeoDataset] (`*.geo.bin`).
///
/// ```text
/// header   u32 magic 'GLBS' | u16 version | u16 reserved
///          u32 featureCount | u32 borderCount
/// feature  u8 idLength | ascii id | u8 flags (bit 0: country)
///          bounds | u32 polygonCount
///   polygon  bounds | u16 ringCount
///     ring     u32 pointCount | pointCount × (f32 lon, f32 lat)
/// border   u8 kind | u16 featureA | u16 featureB (0xFFFF: none)
///          u32 pointCount | pointCount × (f32 lon, f32 lat)
/// bounds   4 × f32: minLon, minLat, maxLon, maxLat
/// ```
abstract final class GeoCodec {
  static const int magic = 0x53424C47; // 'GLBS'
  static const int version = 1;
  static const int _noFeature = 0xFFFF;

  static Uint8List encode(GeoDataset data) {
    final w = _Writer()
      ..u32(magic)
      ..u16(version)
      ..u16(0)
      ..u32(data.features.length)
      ..u32(data.borders.length);
    for (final f in data.features) {
      final id = ascii.encode(f.id);
      w
        ..u8(id.length)
        ..bytes(id)
        ..u8(f.isCountry ? 1 : 0)
        ..bounds(f.bounds)
        ..u32(f.polygons.length);
      for (final p in f.polygons) {
        w
          ..bounds(p.bounds)
          ..u16(p.rings.length);
        p.rings.forEach(w.coords);
      }
    }
    for (final b in data.borders) {
      w
        ..u8(b.kind.index)
        ..u16(b.featureA)
        ..u16(b.featureB ?? _noFeature)
        ..coords(b.points);
    }
    return w.takeBytes();
  }

  static GeoDataset decode(ByteData data) {
    final r = _Reader(data);
    if (r.u32() != magic) {
      throw const FormatException('Not a Globsi geo file');
    }
    final fileVersion = r.u16();
    if (fileVersion != version) {
      throw FormatException('Unsupported geo file version $fileVersion');
    }
    r.u16();
    final featureCount = r.u32();
    final borderCount = r.u32();

    final features = List.generate(featureCount, (_) {
      final id = ascii.decode(r.bytes(r.u8()));
      final isCountry = r.u8() & 1 == 1;
      final bounds = r.bounds();
      final polygons = List.generate(r.u32(), (_) {
        final bounds = r.bounds();
        final rings = List.generate(r.u16(), (_) => r.coords());
        return GeoPolygon(rings, bounds: bounds);
      });
      return GeoFeature(
        id: id,
        isCountry: isCountry,
        polygons: polygons,
        bounds: bounds,
      );
    });

    final borders = List.generate(borderCount, (_) {
      final kind = BorderKind.values[r.u8()];
      final a = r.u16();
      final b = r.u16();
      return GeoBorder(
        kind: kind,
        featureA: a,
        featureB: b == _noFeature ? null : b,
        points: r.coords(),
      );
    });

    return GeoDataset(features: features, borders: borders);
  }
}

class _Writer {
  ByteData _data = ByteData(1 << 16);
  int _offset = 0;

  void _ensure(int n) {
    if (_offset + n <= _data.lengthInBytes) return;
    var size = _data.lengthInBytes * 2;
    while (size < _offset + n) {
      size *= 2;
    }
    final grown = ByteData(size);
    grown.buffer.asUint8List().setRange(0, _offset, _data.buffer.asUint8List());
    _data = grown;
  }

  void u8(int v) {
    _ensure(1);
    _data.setUint8(_offset, v);
    _offset += 1;
  }

  void u16(int v) {
    _ensure(2);
    _data.setUint16(_offset, v, Endian.little);
    _offset += 2;
  }

  void u32(int v) {
    _ensure(4);
    _data.setUint32(_offset, v, Endian.little);
    _offset += 4;
  }

  void f32(double v) {
    _ensure(4);
    _data.setFloat32(_offset, v, Endian.little);
    _offset += 4;
  }

  void bytes(List<int> v) {
    _ensure(v.length);
    _data.buffer.asUint8List().setRange(_offset, _offset + v.length, v);
    _offset += v.length;
  }

  void bounds(GeoBounds b) {
    f32(b.minLon);
    f32(b.minLat);
    f32(b.maxLon);
    f32(b.maxLat);
  }

  void coords(Float32List c) {
    u32(c.length ~/ 2);
    c.forEach(f32);
  }

  Uint8List takeBytes() => _data.buffer.asUint8List(0, _offset);
}

class _Reader {
  new(this._data);

  final ByteData _data;
  int _offset = 0;

  int u8() => _data.getUint8(_offset++);

  int u16() {
    final v = _data.getUint16(_offset, Endian.little);
    _offset += 2;
    return v;
  }

  int u32() {
    final v = _data.getUint32(_offset, Endian.little);
    _offset += 4;
    return v;
  }

  double f32() {
    final v = _data.getFloat32(_offset, Endian.little);
    _offset += 4;
    return v;
  }

  Uint8List bytes(int n) {
    final v = Uint8List.sublistView(_data, _offset, _offset + n);
    _offset += n;
    return v;
  }

  GeoBounds bounds() => GeoBounds(f32(), f32(), f32(), f32());

  Float32List coords() {
    final n = u32() * 2;
    final out = Float32List(n);
    for (var i = 0; i < n; i++) {
      out[i] = f32();
    }
    return out;
  }
}
