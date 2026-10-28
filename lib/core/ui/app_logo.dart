import 'package:flutter/material.dart';

/// The Globsi icon (a globe with a flag planted on it), drawn in Flutter.
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
  const new({this.background = true, this.zoom = 1});

  static const backgroundColor = Color(0xFF0A5E8C);
  static const globeColor = Color(0xFF1F86C4);
  static const flagColor = Color(0xFFFFA726);

  final bool background;

  /// Scale around the center; > 1 drops the adaptive-icon padding (e.g. for
  /// the Play Store icon, which is shown full-bleed).
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    if (background) {
      canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    }
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(zoom * size.width / 108, zoom * size.height / 108)
      ..translate(-54, -54);

    const center = Offset(50, 58);
    canvas.drawCircle(center, 19, Paint()..color = globeColor);

    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawCircle(center, 19, line)
      ..drawOval(Rect.fromCenter(center: center, width: 16, height: 38), line)
      ..drawLine(const Offset(31, 58), const Offset(69, 58), line)
      ..drawLine(const Offset(33.55, 48.5), const Offset(66.45, 48.5), line)
      ..drawLine(const Offset(33.55, 67.5), const Offset(66.45, 67.5), line)
      ..drawLine(const Offset(63.4, 44.6), const Offset(63.4, 29), line)
      ..drawPath(
        Path()
          ..moveTo(63.4, 29)
          ..lineTo(76, 33.5)
          ..lineTo(63.4, 38)
          ..close(),
        Paint()..color = flagColor,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(AppLogoPainter old) =>
      old.background != background || old.zoom != zoom;
}
