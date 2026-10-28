import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _oceanBlue = Color(0xFF0077B6);

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _oceanBlue,
        brightness: brightness,
      ),
    );
  }
}
