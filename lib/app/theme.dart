import 'package:flutter/material.dart';

/// Colors of the app icon: night indigo surfaces, turquoise for the main
/// color and amber as the second one. The light theme uses darker versions so
/// text in these colors stays readable on a light background.
abstract final class AppTheme {
  static const _turquoise = Color(0xFF35D0C4);

  static final ThemeData light = _build(
    ColorScheme.fromSeed(seedColor: _turquoise).copyWith(
      primary: const Color(0xFF0B7A72),
      onPrimary: Colors.white,
      tertiary: const Color(0xFF8F5B00),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFE3AE),
      onTertiaryContainer: const Color(0xFF2E1D00),
      surface: const Color(0xFFF4F8FA),
      onSurface: const Color(0xFF141B33),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFEEF4F6),
      surfaceContainer: const Color(0xFFE8F0F3),
      surfaceContainerHigh: const Color(0xFFE2ECEF),
      surfaceContainerHighest: const Color(0xFFDCE8EC),
    ),
  );

  static final ThemeData dark = _build(
    ColorScheme.fromSeed(
      seedColor: _turquoise,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF5FE0D4),
      onPrimary: const Color(0xFF00332F),
      tertiary: const Color(0xFFFFC145),
      onTertiary: const Color(0xFF3F2A00),
      tertiaryContainer: const Color(0xFF5B4100),
      onTertiaryContainer: const Color(0xFFFFE3AE),
      surface: const Color(0xFF0F1433),
      onSurface: const Color(0xFFE6EAF5),
      surfaceContainerLowest: const Color(0xFF0A0E26),
      surfaceContainerLow: const Color(0xFF151B3D),
      surfaceContainer: const Color(0xFF192044),
      surfaceContainerHigh: const Color(0xFF1E264D),
      surfaceContainerHighest: const Color(0xFF242D57),
    ),
  );

  static ThemeData _build(ColorScheme colorScheme) {
    return ThemeData(colorScheme: colorScheme);
  }
}
