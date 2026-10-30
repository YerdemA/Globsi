import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:globsi/core/ui/app_logo.dart';
import 'package:globsi/core/ui/globsi_wordmark.dart';

/// Plays once per app start above [child], which is already built behind it.
///
/// The first frame matches the Android splash (same icon, size and
/// background), so the system splash seems to come alive: the galaxy makes a
/// turn while the name appears under it. A tap skips to the fade out.
class IntroOverlay extends StatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  State<IntroOverlay> createState() => _IntroOverlayState();
}

class _IntroOverlayState extends State<IntroOverlay>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2200);
  static const _fadeStart = 0.88;

  /// The longest step of one frame. The first frames of an app start can take
  /// long; without this limit the intro would be over before it is seen.
  static const _maxStep = Duration(milliseconds: 50);

  final _progress = ValueNotifier<double>(0);
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  var _done = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ticker.stop();
      _done = true;
    } else if (!_done && !_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final step = elapsed - _lastTick;
    _lastTick = elapsed;
    final capped = step > _maxStep ? _maxStep : step;
    final next =
        _progress.value + capped.inMicroseconds / _duration.inMicroseconds;
    if (next >= 1) {
      _ticker.stop();
      setState(() => _done = true);
    } else {
      _progress.value = next;
    }
  }

  void _skip() {
    if (_progress.value < _fadeStart) _progress.value = _fadeStart;
  }

  double _at(double begin, double end, Curve curve) => curve.transform(
    ((_progress.value - begin) / (end - begin)).clamp(0.0, 1.0),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_done)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _skip,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => _frame(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _frame() {
    final lift = _at(0.12, 0.55, Curves.easeOutCubic);
    final turn = _at(0, 0.62, Curves.easeInOutCubic);
    final pulse = math.sin(_at(0.55, 0.75, Curves.linear) * math.pi);

    return Opacity(
      opacity: 1 - _at(_fadeStart, 1, Curves.easeIn),
      child: ColoredBox(
        color: AppLogoPainter.backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -48 * lift),
              child: Transform.scale(
                scale: 1 + 0.25 * lift,
                child: CustomPaint(
                  size: const Size.square(160),
                  painter: AppLogoPainter(
                    background: false,
                    // Backwards, so the arms trail like a real galaxy's.
                    armTurn: -2 * math.pi * turn,
                    starScale: 1 + 0.4 * pulse,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 56),
              child: GlobsiWordmark(
                fontSize: 52,
                colors: const [Colors.white, AppLogoPainter.armColor],
                starColor: AppLogoPainter.starColor,
                reveal: _at(0.3, 0.72, Curves.linear),
                starScale: _at(0.68, 0.82, Curves.easeOutBack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
