import 'dart:math';
import 'dart:typed_data';

import 'package:globsi/core/geo/orthographic.dart';

/// Receives clipped geometry in unit-disk coordinates (y up).
abstract interface class PathSink {
  void moveTo(double x, double y);
  void lineTo(double x, double y);
  void close();
}

enum RingVisibility { hidden, visible, partial }

/// Projects rings and polylines of unit vectors, cutting them at the horizon.
///
/// Parts of a ring on the far side follow the horizon circle, so a ring that
/// crosses the horizon is emitted as a closed shape bounded by the rim.
class HorizonClipper {
  new(this.projection, {this.minStep = 0});

  final OrthographicProjection projection;

  /// Visible points closer than this (unit-disk distance) to the previously
  /// emitted point are skipped; set it to about half a pixel so detail that
  /// cannot be seen at the current zoom costs nothing.
  final double minStep;

  double _lastX = 0;
  double _lastY = 0;

  void _moveTo(PathSink sink, double x, double y) {
    sink.moveTo(x, y);
    _lastX = x;
    _lastY = y;
  }

  void _lineTo(PathSink sink, double x, double y) {
    sink.lineTo(x, y);
    _lastX = x;
    _lastY = y;
  }

  /// Emits a visible point unless it is within [minStep] of the last one.
  void _detailTo(PathSink sink, double x, double y) {
    final dx = x - _lastX;
    final dy = y - _lastY;
    if (dx * dx + dy * dy >= minStep * minStep) _lineTo(sink, x, y);
  }

  /// Maximum angle between interpolated points along the rim.
  static const double _rimStep = 5 * degToRad;

  Float64List _buffer = Float64List(0);

  /// Projects [xyz] (interleaved unit vectors) into the scratch buffer as
  /// `[x, y, z, ...]` view coordinates and returns the visible point count.
  int _projectAll(Float32List xyz) {
    final n = xyz.length ~/ 3;
    if (_buffer.length < n * 3) _buffer = Float64List(n * 3);
    final p = projection;
    var visible = 0;
    for (var i = 0; i < n; i++) {
      final x = xyz[i * 3];
      final y = xyz[i * 3 + 1];
      final z = xyz[i * 3 + 2];
      _buffer[i * 3] = p.viewX(x, y);
      _buffer[i * 3 + 1] = p.viewY(x, y, z);
      final vz = p.viewZ(x, y, z);
      _buffer[i * 3 + 2] = vz;
      if (vz >= 0) visible++;
    }
    return visible;
  }

  /// Emits a closed ring. Returns whether it was visible, hidden or cut.
  ///
  /// A cut ring that encloses the antipode of the view center traces the rim
  /// the wrong way round; callers detect this and add the full rim circle
  /// (with even-odd filling) to invert it.
  RingVisibility ring(Float32List xyz, PathSink sink) {
    final n = xyz.length ~/ 3;
    final visible = _projectAll(xyz);
    final b = _buffer;
    if (visible == 0) return RingVisibility.hidden;
    if (visible == n) {
      _moveTo(sink, b[0], b[1]);
      for (var i = 1; i < n; i++) {
        _detailTo(sink, b[i * 3], b[i * 3 + 1]);
      }
      sink.close();
      return RingVisibility.visible;
    }

    var start = 0;
    while (b[start * 3 + 2] < 0) {
      start++;
    }
    _moveTo(sink, b[start * 3], b[start * 3 + 1]);
    var prev = start;
    var rimAngle = 0.0;
    for (var k = 1; k <= n; k++) {
      final cur = (start + k) % n;
      final prevVisible = b[prev * 3 + 2] >= 0;
      final curVisible = b[cur * 3 + 2] >= 0;
      if (prevVisible && curVisible) {
        _detailTo(sink, b[cur * 3], b[cur * 3 + 1]);
      } else if (prevVisible) {
        final (cx, cy) = _crossing(prev, cur);
        _lineTo(sink, cx, cy);
        rimAngle = atan2(cy, cx);
      } else if (curVisible) {
        final (cx, cy) = _crossing(prev, cur);
        rimAngle = _rimTo(sink, rimAngle, atan2(cy, cx));
        _lineTo(sink, cx, cy);
        _lineTo(sink, b[cur * 3], b[cur * 3 + 1]);
      } else {
        final x = b[cur * 3];
        final y = b[cur * 3 + 1];
        // Points straight behind the center have no direction on the rim.
        if (x * x + y * y > 1e-12) {
          rimAngle = _rimTo(sink, rimAngle, atan2(y, x));
        }
      }
      prev = cur;
    }
    sink.close();
    return RingVisibility.partial;
  }

  /// Emits the visible runs of an open polyline.
  void polyline(Float32List xyz, PathSink sink) {
    final n = xyz.length ~/ 3;
    final visible = _projectAll(xyz);
    final b = _buffer;
    if (visible == 0) return;
    var drawing = false;
    for (var i = 0; i < n; i++) {
      final curVisible = b[i * 3 + 2] >= 0;
      if (i > 0) {
        final prevVisible = b[(i - 1) * 3 + 2] >= 0;
        if (prevVisible != curVisible) {
          final (cx, cy) = _crossing(i - 1, i);
          if (curVisible) {
            _moveTo(sink, cx, cy);
            drawing = true;
          } else {
            _lineTo(sink, cx, cy);
            drawing = false;
          }
        }
      }
      if (!curVisible) continue;
      if (!drawing) {
        _moveTo(sink, b[i * 3], b[i * 3 + 1]);
        drawing = true;
      } else if (i == n - 1 || b[(i + 1) * 3 + 2] < 0) {
        // Always reach the end of a visible run.
        _lineTo(sink, b[i * 3], b[i * 3 + 1]);
      } else {
        _detailTo(sink, b[i * 3], b[i * 3 + 1]);
      }
    }
  }

  /// Rim point where the segment between buffered points [a] and [b]
  /// crosses the horizon.
  (double, double) _crossing(int a, int b) {
    final buf = _buffer;
    final za = buf[a * 3 + 2];
    final zb = buf[b * 3 + 2];
    final t = za / (za - zb);
    final x = buf[a * 3] + (buf[b * 3] - buf[a * 3]) * t;
    final y = buf[a * 3 + 1] + (buf[b * 3 + 1] - buf[a * 3 + 1]) * t;
    final len = sqrt(x * x + y * y);
    return len == 0 ? (1.0, 0.0) : (x / len, y / len);
  }

  /// Follows the rim the short way from angle [from] to [to].
  double _rimTo(PathSink sink, double from, double to) {
    var delta = to - from;
    while (delta > pi) {
      delta -= 2 * pi;
    }
    while (delta < -pi) {
      delta += 2 * pi;
    }
    final steps = max(1, (delta.abs() / _rimStep).ceil());
    for (var s = 1; s <= steps; s++) {
      final a = from + delta * s / steps;
      _lineTo(sink, cos(a), sin(a));
    }
    return to;
  }
}
