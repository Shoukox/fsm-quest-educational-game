import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Bündelt Schriftgrößen und Gewichte mit den Textfarben der aktuellen Palette.
class AppTextStyleSet {
  const AppTextStyleSet(this._colors);

  final AppColorPalette _colors;

  TextStyle get title {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: _colors.text,
    );
  }

  TextStyle get heading {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: _colors.text,
    );
  }

  TextStyle get body {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: _colors.text,
    );
  }

  TextStyle get caption {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: _colors.mutedText,
    );
  }
}

extension AppTextStylesX on BuildContext {
  AppTextStyleSet get textStyles => AppTextStyleSet(colors);
}
