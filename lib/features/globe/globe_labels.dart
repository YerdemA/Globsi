import 'package:flutter/material.dart';
import 'package:globsi/core/geo/country_labels.dart';
import 'package:globsi/core/geo/geo_data.dart';
import 'package:globsi/core/geo/globe_camera.dart';
import 'package:globsi/core/geo/globe_hit_test.dart';
import 'package:globsi/features/globe/globe_paths.dart';

/// Draws country names on the globe; [placeCountryLabels] decides which ones.
class GlobeLabels {
  new({
    required this.targets,
    required this.names,
    required this.style,
    required this.color,
    required this.haloColor,
    required this.textScaler,
  });

  static const double _maxWidth = 110;

  final List<LabelTarget> targets;
  final Map<String, String> names;
  final TextStyle style;
  final Color color;
  final Color haloColor;
  final TextScaler textScaler;

  final _painters = <String, (TextPainter, TextPainter)>{};

  (TextPainter, TextPainter) _paintersFor(String id) => _painters[id] ??= (
    _layout(
      id,
      style.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..color = haloColor,
      ),
    ),
    _layout(id, style.copyWith(color: color)),
  );

  TextPainter _layout(String id, TextStyle textStyle) => TextPainter(
    text: TextSpan(text: names[id] ?? '', style: textStyle),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout(maxWidth: _maxWidth);

  void paint(
    Canvas canvas,
    GeoDataset data,
    GlobeCamera camera,
    GlobeLayout layout,
    Size size,
  ) {
    final projection = camera.projection;
    final labels = placeCountryLabels(
      targets: targets,
      projection: projection,
      zoom: camera.zoom,
      globeRadius: layout.radius,
      viewWidth: size.width,
      viewHeight: size.height,
      sizeOf: (id) {
        final textSize = _paintersFor(id).$2.size;
        return (textSize.width, textSize.height);
      },
      countryUnder: (x, y) {
        final (diskX, diskY) = layout.toDisk(Offset(x, y));
        return countryAt(
          data: data,
          projection: projection,
          x: diskX,
          y: diskY,
        );
      },
    );

    for (final label in labels) {
      final (halo, text) = _paintersFor(label.id);
      final offset =
          Offset(label.x, label.y) - Offset(text.width / 2, text.height / 2);
      final faded = label.opacity < 1;
      if (faded) {
        canvas.saveLayer(
          (offset & text.size).inflate(4),
          Paint()..color = Color.fromRGBO(0, 0, 0, label.opacity),
        );
      }
      halo.paint(canvas, offset);
      text.paint(canvas, offset);
      if (faded) canvas.restore();
    }
  }

  void dispose() {
    for (final (halo, text) in _painters.values) {
      halo.dispose();
      text.dispose();
    }
    _painters.clear();
  }
}
