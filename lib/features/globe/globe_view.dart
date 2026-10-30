import 'package:flutter/material.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/core/geo/globe_hit_test.dart';
import 'package:globsi/features/globe/globe_controller.dart';
import 'package:globsi/features/globe/globe_labels.dart';
import 'package:globsi/features/globe/globe_painter.dart';
import 'package:globsi/features/globe/globe_paths.dart';

/// Interactive globe: drag to rotate (with inertia), pinch to zoom, tap to
/// pick a country.
class GlobeView extends StatefulWidget {
  const new({
    required this.controller,
    required this.geometry,
    this.tinyTargets = const [],
    this.selectedId,
    this.selectedMarker,
    this.labels,
    this.onCountryTap,
    this.interactive = true,
    super.key,
  });

  final GlobeController controller;
  final GlobeGeometry geometry;

  /// Small countries that stay selectable near their marker point.
  final List<TinyTarget> tinyTargets;
  final String? selectedId;
  final ({double lat, double lon})? selectedMarker;

  /// Country names; left out in map practice, where they would give away the
  /// answer.
  final GlobeLabels? labels;

  /// Called with the tapped country id, or `null` for sea and other land.
  final ValueChanged<String?>? onCountryTap;

  /// When false, gestures are ignored (e.g. map practice).
  final bool interactive;

  @override
  State<GlobeView> createState() => _GlobeViewState();
}

class _GlobeViewState extends State<GlobeView> {
  /// Tap tolerance around tiny countries, in logical pixels.
  static const double _tinyTolerance = 24;

  final _cache = GlobePathCache();
  double _lastScale = 1;
  int _pointers = 0;
  Size _size = Size.zero;

  GlobeLayout get _layout => GlobeLayout(_size, widget.controller.camera.zoom);

  void _onScaleStart(ScaleStartDetails details) {
    widget.controller.stop();
    _lastScale = 1;
    _pointers = details.pointerCount;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _pointers = details.pointerCount;
    final controller = widget.controller;
    if (details.scale != _lastScale) {
      controller.zoomBy(details.scale / _lastScale);
      _lastScale = details.scale;
    }
    final delta = details.focalPointDelta;
    if (delta != Offset.zero) {
      controller.dragBy(delta.dx, delta.dy, _layout.radius);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_pointers > 1) return;
    final v = details.velocity.pixelsPerSecond;
    widget.controller.fling(v.dx, v.dy, _layout.radius);
  }

  void _onTapUp(TapUpDetails details) {
    final layout = _layout;
    final (x, y) = layout.toDisk(details.localPosition);
    widget.onCountryTap?.call(
      countryAt(
        data: widget.geometry.data,
        projection: widget.controller.camera.projection,
        x: x,
        y: y,
        tinyTargets: widget.tinyTargets,
        tolerance: _tinyTolerance / layout.radius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      size: Size.infinite,
      painter: GlobePainter(
        controller: widget.controller,
        geometry: widget.geometry,
        colors: GlobeColors.of(Theme.of(context).brightness),
        cache: _cache,
        selectedId: widget.selectedId,
        selectedMarker: widget.selectedMarker,
        labels: widget.labels,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        return RepaintBoundary(
          child: widget.interactive
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  onTapUp: _onTapUp,
                  child: painter,
                )
              : painter,
        );
      },
    );
  }
}
