// Rewrites the Play Store feature graphics and screenshots in docs/store/ as
// 24-bit PNGs: Play accepts them only without an alpha channel. The app icon
// keeps its alpha. Already converted files are left alone.
//
// Run with: dart run tool/store/strip_png_alpha.dart
import 'dart:io';
import 'dart:typed_data';

const _signatureLength = 8;
const _colorTypeRgb = 2;
const _colorTypeRgba = 6;

void main() {
  final files = Directory('docs/store')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.png') && !f.path.contains('icon-512'));
  for (final file in files) {
    final converted = stripAlpha(file.readAsBytesSync());
    if (converted == null) continue;
    file.writeAsBytesSync(converted);
    stdout.writeln('${file.path}: ${converted.length ~/ 1024} KB');
  }
}

/// The PNG without its alpha channel, or null if it has none. Only 8-bit,
/// non-interlaced images are expected; Flutter and `screencap` write these.
Uint8List? stripAlpha(Uint8List png) {
  final view = ByteData.sublistView(png);
  final idat = BytesBuilder(copy: false);
  var offset = _signatureLength;
  late int width;
  late int height;
  while (offset < png.length) {
    final length = view.getUint32(offset);
    final type = String.fromCharCodes(png, offset + 4, offset + 8);
    final dataStart = offset + 8;
    if (type == 'IHDR') {
      width = view.getUint32(dataStart);
      height = view.getUint32(dataStart + 4);
      final depth = png[dataStart + 8];
      final colorType = png[dataStart + 9];
      final interlace = png[dataStart + 12];
      if (colorType == _colorTypeRgb) return null;
      if (depth != 8 || colorType != _colorTypeRgba || interlace != 0) {
        throw FormatException('Unsupported PNG: $depth bit, type $colorType');
      }
    } else if (type == 'IDAT') {
      idat.add(Uint8List.sublistView(png, dataStart, dataStart + length));
    }
    offset = dataStart + length + 4;
  }

  final raw = Uint8List.fromList(zlib.decode(idat.takeBytes()));
  const bpp = 4;
  final stride = width * bpp;
  final rgbStride = width * 3 + 1;
  final out = Uint8List(rgbStride * height);
  var previous = Uint8List(stride);
  for (var y = 0; y < height; y++) {
    final start = y * (stride + 1);
    final filter = raw[start];
    final row = Uint8List.sublistView(raw, start + 1, start + 1 + stride);
    _unfilter(filter, row, previous, bpp);

    // Written with the "sub" filter, which keeps flat colors small.
    final target = y * rgbStride;
    out[target] = 1;
    for (var x = 0; x < width; x++) {
      for (var c = 0; c < 3; c++) {
        final left = x == 0 ? 0 : row[(x - 1) * bpp + c];
        out[target + 1 + x * 3 + c] = (row[x * bpp + c] - left) & 0xFF;
      }
    }
    previous = row;
  }

  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, _colorTypeRgb);
  return (BytesBuilder(copy: false)
        ..add(Uint8List.sublistView(png, 0, _signatureLength))
        ..add(_chunk('IHDR', header.buffer.asUint8List()))
        ..add(_chunk('IDAT', Uint8List.fromList(zlib.encode(out))))
        ..add(_chunk('IEND', Uint8List(0))))
      .takeBytes();
}

void _unfilter(int filter, Uint8List row, Uint8List up, int bpp) {
  for (var i = 0; i < row.length; i++) {
    final a = i >= bpp ? row[i - bpp] : 0;
    final b = up[i];
    final c = i >= bpp ? up[i - bpp] : 0;
    final predictor = switch (filter) {
      0 => 0,
      1 => a,
      2 => b,
      3 => (a + b) ~/ 2,
      4 => _paeth(a, b, c),
      _ => throw FormatException('Bad PNG filter: $filter'),
    };
    row[i] = (row[i] + predictor) & 0xFF;
  }
}

int _paeth(int a, int b, int c) {
  final p = a + b - c;
  final pa = (p - a).abs();
  final pb = (p - b).abs();
  final pc = (p - c).abs();
  if (pa <= pb && pa <= pc) return a;
  return pb <= pc ? b : c;
}

Uint8List _chunk(String type, Uint8List data) {
  final body = Uint8List(4 + data.length)
    ..setAll(0, type.codeUnits)
    ..setAll(4, data);
  final length = ByteData(4)..setUint32(0, data.length);
  final crc = ByteData(4)..setUint32(0, _crc32(body));
  return (BytesBuilder(copy: false)
        ..add(length.buffer.asUint8List())
        ..add(body)
        ..add(crc.buffer.asUint8List()))
      .takeBytes();
}

int _crc32(Uint8List bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      crc = crc.isOdd ? (crc >>> 1) ^ 0xEDB88320 : crc >>> 1;
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
