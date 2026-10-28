import 'dart:async';
import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:globsi/core/geo/globe_camera.dart';
import 'package:globsi/core/geo/globe_geometry.dart';

/// Owns the [GlobeCamera] and animates it (fling inertia, [animateTo]).
class GlobeController extends ChangeNotifier {
  new({
    required TickerProvider vsync,
    GlobeCamera initial = const GlobeCamera(centerLat: 39, centerLon: 35),
  }) : _camera = initial {
    _ticker = vsync.createTicker(_onTick);
  }

  /// Fling speed decays by e^-[_friction] per second.
  static const double _friction = 3.5;

  late final Ticker _ticker;
  GlobeCamera _camera;

  // Fling state, in globe radii per second.
  double _vx = 0;
  double _vy = 0;
  Duration _lastTick = Duration.zero;

  // Tween state.
  GlobeCamera? _from;
  GlobeCamera? _to;
  Duration _duration = Duration.zero;
  Completer<void>? _tween;

  GlobeCamera get camera => _camera;

  set camera(GlobeCamera value) {
    if (value.isSameView(_camera)) return;
    _camera = value;
    notifyListeners();
  }

  bool get isAnimating => _ticker.isActive;

  /// Rotates by a drag of [dx], [dy] screen pixels on a globe drawn with
  /// [radius] pixels.
  void dragBy(double dx, double dy, double radius) {
    stop();
    camera = camera.dragged(dx / radius, dy / radius);
  }

  void zoomBy(double factor) {
    stop();
    camera = camera.zoomedBy(factor);
  }

  /// Continues a drag released at [vx], [vy] pixels per second.
  void fling(double vx, double vy, double radius) {
    stop();
    _vx = vx / radius;
    _vy = vy / radius;
    if (_vx.abs() + _vy.abs() < 0.05) return;
    _lastTick = Duration.zero;
    _ticker.start();
  }

  /// Animates the camera to [target]. Completes when done or interrupted.
  Future<void> animateTo(
    GlobeCamera target, {
    Duration duration = const Duration(milliseconds: 700),
  }) {
    stop();
    _from = camera;
    _to = target;
    _duration = duration;
    final completer = _tween = Completer<void>();
    _ticker.start();
    return completer.future;
  }

  /// Rotates to [id]'s centroid and zooms in if the country would be too
  /// small to see; with [fit], zooms exactly to frame it.
  Future<void> focusOn(
    GlobeGeometry geometry,
    String id, {
    required double lat,
    required double lon,
    bool fit = false,
  }) {
    final feature = geometry.featureById(id);
    final double zoom;
    if (feature == null) {
      zoom = camera.zoom;
    } else if (fit) {
      zoom = GlobeCamera.zoomToFit(feature.mainRadius);
    } else {
      // Only zoom in when the country would be hard to see.
      final readable = GlobeCamera.zoomToFit(
        feature.mainRadius,
        screenFraction: 0.1,
      );
      zoom = max(camera.zoom, readable);
    }
    return animateTo(GlobeCamera(centerLat: lat, centerLon: lon, zoom: zoom));
  }

  void stop() {
    if (_ticker.isActive) _ticker.stop();
    _vx = _vy = 0;
    _from = _to = null;
    final tween = _tween;
    _tween = null;
    if (tween != null && !tween.isCompleted) tween.complete();
  }

  void _onTick(Duration elapsed) {
    final from = _from;
    final to = _to;
    if (from != null && to != null) {
      final t = _duration.inMicroseconds == 0
          ? 1.0
          : (elapsed.inMicroseconds / _duration.inMicroseconds).clamp(0.0, 1.0);
      camera = GlobeCamera.lerp(from, to, Curves.easeInOutCubic.transform(t));
      if (t >= 1) stop();
      return;
    }

    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;
    camera = camera.dragged(_vx * dt, _vy * dt);
    final decay = exp(-_friction * dt);
    _vx *= decay;
    _vy *= decay;
    if (_vx.abs() + _vy.abs() < 0.02) stop();
  }

  @override
  void dispose() {
    stop();
    _ticker.dispose();
    super.dispose();
  }
}
