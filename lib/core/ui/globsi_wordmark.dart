import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:globsi/core/ui/app_logo.dart';

/// The name "Globsi" as a logo: bold letters with a gradient, a round "o"
/// like a planet, with a star above it.
class GlobsiWordmark extends StatelessWidget {
  const new({
    required this.fontSize,
    this.colors,
    this.starColor,
    this.reveal = 1,
    this.starScale = 1,
    super.key,
  });

  static const _name = 'Globsi';

  final double fontSize;

  /// Start and end of the letter gradient; defaults follow the theme.
  final List<Color>? colors;
  final Color? starColor;

  /// 0–1: letters appear one after the other (used by the intro).
  final double reveal;
  final double starScale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final painter = _WordmarkPainter(
      fontSize: fontSize,
      colors: colors ?? [scheme.onSurface, scheme.primary],
      starColor: starColor ?? scheme.tertiary,
      reveal: reveal,
      starScale: starScale,
    );
    return Semantics(
      label: _name,
      child: CustomPaint(size: painter.measure(), painter: painter),
    );
  }
}

class _WordmarkPainter extends CustomPainter {
  new({
    required this.fontSize,
    required this.colors,
    required this.starColor,
    required this.reveal,
    required this.starScale,
  });

  /// Height of lowercase letters in Roboto, as a share of the font size.
  static const _xHeight = 0.528;

  final double fontSize;
  final List<Color> colors;
  final Color starColor;
  final double reveal;
  final double starScale;

  TextStyle get _style => TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: -fontSize * 0.02,
    height: 1.25,
  );

  TextPainter _layout(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout();

  Size measure() {
    final full = _layout(GlobsiWordmark._name, _style);
    final size = full.size;
    full.dispose();
    return size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      colors,
    );
    final full = _layout(GlobsiWordmark._name, _style);
    final baseline = full.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    final letterStyle = _style.copyWith(foreground: Paint()..shader = gradient);

    const name = GlobsiWordmark._name;
    for (var i = 0; i < name.length; i++) {
      final progress = Curves.easeOutCubic.transform(
        ((reveal - i * 0.1) / 0.5).clamp(0.0, 1.0),
      );
      if (progress == 0) continue;
      final x = full.getOffsetForCaret(TextPosition(offset: i), Rect.zero).dx;

      canvas.save();
      if (progress < 1) {
        canvas
          ..translate(0, (1 - progress) * fontSize * 0.25)
          ..saveLayer(
            Offset.zero & size,
            Paint()..color = Color.fromRGBO(0, 0, 0, progress),
          );
      }
      if (name[i] == 'o') {
        final next = full
            .getOffsetForCaret(TextPosition(offset: i + 1), Rect.zero)
            .dx;
        _paintGlobe(canvas, (x + next) / 2, baseline, gradient);
      } else {
        _layout(name[i], letterStyle)
          ..paint(canvas, Offset(x, 0))
          ..dispose();
      }
      if (progress < 1) canvas.restore();
      canvas.restore();
    }
    full.dispose();
  }

  void _paintGlobe(
    Canvas canvas,
    double centerX,
    double baseline,
    ui.Gradient gradient,
  ) {
    final radius = fontSize * _xHeight / 2;
    final center = Offset(centerX, baseline - radius);
    final ringWidth = fontSize * 0.1;
    final ringRadius = radius - ringWidth / 2;
    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth,
    );
    if (starScale > 0) {
      canvas.drawPath(
        AppLogoPainter.starPath(
          center - Offset(0, radius * 1.9),
          radius * 0.72 * starScale,
        ),
        Paint()..color = starColor,
      );
    }
  }

  @override
  bool shouldRepaint(_WordmarkPainter old) =>
      old.fontSize != fontSize ||
      old.colors != colors ||
      old.starColor != starColor ||
      old.reveal != reveal ||
      old.starScale != starScale;
}
