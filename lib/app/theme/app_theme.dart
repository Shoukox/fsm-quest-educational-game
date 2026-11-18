import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Erzeugt Material-Themes mit gemeinsamer Farbpalette und einheitlichen Komponentenformen.
abstract final class AppTheme {
  static const _dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(19)),
  );
  static const _sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
  );
  static const _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  static const _chipShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  );
  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(13)),
  );
  static const _indicatorShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(11)),
  );

  static ThemeData light() {
    return _build(Brightness.light);
  }

  static ThemeData dark() {
    return _build(Brightness.dark);
  }

  static ThemeData _build(Brightness brightness) {
    final colors = AppColors.forBrightness(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: colors.primary,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.text,
        error: colors.danger,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
      ),
      // Kleinere Eckenradien als in Material 3 halten Dialoge, Karten und
      // Bedienelemente trotz unterschiedlicher Größen gestalterisch zusammen.
      dialogTheme: const DialogThemeData(shape: _dialogShape),
      bottomSheetTheme: const BottomSheetThemeData(shape: _sheetShape),
      cardTheme: const CardThemeData(shape: _cardShape),
      chipTheme: const ChipThemeData(shape: _chipShape),
      // Kompakte Beschriftungen für Material-Schaltflächen. Die gemeinsamen
      // App-Schaltflächen verkleinern einzeilige Texte bei Bedarf zusätzlich.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 13),
          shape: _buttonShape,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 13),
          shape: _buttonShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 13),
          shape: _buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 13),
          shape: _buttonShape,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(shape: _buttonShape),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary,
        indicatorShape: _indicatorShape,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? colors.onPrimary : colors.mutedText,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            color: isSelected ? colors.text : colors.mutedText,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            // Navigationsbeschriftungen sollen in jeder Sprache einzeilig
            // bleiben, auch bei längeren deutschen Übersetzungen.
            fontSize: 10,
          );
        }),
      ),
    );
  }
}
