import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The Globsi icon (a globe at the core of a spiral galaxy), drawn in Flutter.
///
/// Same geometry as the Android adaptive icon
/// (`android/app/src/main/res/drawable/ic_launcher_foreground.xml`) on its
/// 108×108 canvas; used in the About dialog and for the Play Store assets.
class AppLogo extends StatelessWidget {
  const new({this.size = 48, this.rounded = true, super.key});

  final double size;

  /// Clip to a rounded square like a launcher icon (false: full square, as
  /// Play Store icons are uploaded).
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final logo = CustomPaint(
      size: Size.square(size),
      painter: const AppLogoPainter(zoom: 1.45),
    );
    return rounded
        ? ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.22),
            child: logo,
          )
        : logo;
  }
}

class AppLogoPainter extends CustomPainter {
  const new({
    this.background = true,
    this.zoom = 1,
    this.armTurn = 0,
    this.starScale = 1,
  });

  static const backgroundColor = Color(0xFF14194A);
  static const armColor = Color(0xFF35D0C4);
  static const rimColor = Color(0xFFBDF2EB);
  static const starColor = Color(0xFFFFC145);

  static const _center = Offset(54, 54);
  static const _globeRadius = 14.0;
  static const _armReach = 33.0;

  /// Keeps the artwork inside the adaptive icon's 66 dp safe zone.
  static const _contentScale = 0.9;

  final bool background;

  /// Scale around the center; > 1 drops the adaptive-icon padding (e.g. for
  /// the Play Store icon, which is shown full-bleed).
  final double zoom;

  /// Rotation of the spiral arms in radians (used by the intro).
  final double armTurn;

  final double starScale;

  @override
  void paint(Canvas canvas, Size size) {
    if (background) {
      canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    }
    final scale = zoom * _contentScale / 108;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(scale * size.width, scale * size.height)
      ..translate(-54, -54);

    final armPaint = Paint()
      ..shader = ui.Gradient.radial(
        _center,
        _armReach,
        const [rimColor, armColor],
        const [0.42, 0.8],
      );
    final globePaint = Paint()
      ..shader = ui.Gradient.radial(
        _center,
        _globeRadius,
        const [Colors.white, rimColor],
        const [0.45, 1],
      );
    final line = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas
      ..save()
      ..translate(_center.dx, _center.dy)
      ..rotate(armTurn)
      ..translate(-_center.dx, -_center.dy)
      ..drawPath(_arm(150), armPaint)
      ..drawPath(_arm(330), armPaint)
      ..restore()
      ..drawCircle(_center, _globeRadius, globePaint)
      ..drawOval(
        Rect.fromCenter(center: _center, width: 11.6, height: 26.5),
        line,
      )
      ..drawLine(const Offset(40.75, 54), const Offset(67.25, 54), line)
      ..drawPath(
        starPath(const Offset(79, 29), 6.5 * starScale),
        Paint()..color = starColor,
      )
      ..restore();
  }

  /// A spiral arm whose edges both leave the globe's rim tangentially: the
  /// center line departs slowly and the width swells only after that.
  static Path _arm(double startDegrees) {
    const steps = 44;
    final start = startDegrees * math.pi / 180;
    final outer = <Offset>[];
    final inner = <Offset>[];
    for (var k = 0; k <= steps; k++) {
      final t = k / steps;
      final r = _globeRadius + (_armReach - _globeRadius) * math.pow(t, 1.7);
      final angle = start + 0.8 * 2 * math.pi * t;
      final swell = 7 * _smooth(t / 0.42) * math.pow(1 - t, 0.9) + 0.4;
      final width = swell * _smooth(t / 0.06);
      final direction = Offset(math.cos(angle), math.sin(angle));
      outer.add(_center + direction * (r + width / 2));
      inner.add(_center + direction * (r - width / 2));
    }
    return Path()..addPolygon([...outer, ...inner.reversed], true);
  }

  static double _smooth(double x) {
    final v = x.clamp(0.0, 1.0);
    return v * v * (3 - 2 * v);
  }

  /// A four-pointed star.
  static Path starPath(Offset center, double radius) {
    return Path()..addPolygon([
      for (var k = 0; k < 8; k++)
        center +
            Offset(
                  math.cos(k * math.pi / 4 - math.pi / 2),
                  math.sin(k * math.pi / 4 - math.pi / 2),
                ) *
                (k.isEven ? radius : radius * 0.16),
    ], true);
  }

  @override
  bool shouldRepaint(AppLogoPainter old) =>
      old.background != background ||
      old.zoom != zoom ||
      old.armTurn != armTurn ||
      old.starScale != starScale;
}
