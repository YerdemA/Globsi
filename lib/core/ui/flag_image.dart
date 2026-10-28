import 'package:flutter/material.dart';
import 'package:globsi/core/data/country.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// A country's flag with a hairline outline (so white flags stay visible).
///
/// Flags are compiled to the vector_graphics format at build time (see the
/// asset transformer in pubspec.yaml) and drawn as cached rasters, which
/// keeps long flag grids smooth while scrolling.
class FlagImage extends StatelessWidget {
  const new({
    required this.country,
    this.width,
    this.height,
    this.semanticsLabel,
    super.key,
  });

  final Country country;
  final double? width;
  final double? height;

  /// Spoken label; `null` hides the flag from screen readers (use when the
  /// country name is shown next to it).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: VectorGraphic(
        loader: AssetBytesLoader(country.flagAsset),
        width: width,
        height: height,
        semanticsLabel: semanticsLabel,
        excludeFromSemantics: semanticsLabel == null,
      ),
    );
  }
}
