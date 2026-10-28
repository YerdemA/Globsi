import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/core/geo/globe_geometry.dart';

/// Boundary data prepared for drawing; built once, off the UI isolate
/// (~100 ms), and shared by the globe screens.
final globeGeometryProvider = FutureProvider<GlobeGeometry>((ref) async {
  final data = await ref.watch(geoDatasetProvider.future);
  return await Isolate.run(() => GlobeGeometry(data));
});
