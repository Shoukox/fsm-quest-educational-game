import 'package:flutter/material.dart';

/// Semantische Farbpalette für helle und dunkle Darstellung.
/// Als ThemeExtension kann sie beim Designwechsel zwischen beiden Paletten interpolieren.
@immutable
class AppColorPalette extends ThemeExtension<AppColorPalette> {
  const AppColorPalette({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.secondary,
    required this.warning,
    required this.danger,
    required this.xp,
    required this.heart,
    required this.locked,
    required this.text,
    required this.mutedText,
    required this.border,
    required this.stateHighlight,
    required this.onDarkAccent,
    required this.onDarkAccentMuted,
    required this.mascotScrim,
    required this.shadow,
    required this.courseHeaderShadow,
    required this.courseHeaderIconBackground,
  });

  factory AppColorPalette.light() {
    return const AppColorPalette(
      background: Color(0xFFF8F3ED),
      surface: Color(0xFFF8F3ED),
      surfaceRaised: Color(0xFFFFF7EF),
      primary: Color(0xFFFF8A1F),
      primaryDark: Color(0xFFB84A08),
      onPrimary: Color(0xFF261100),
      secondary: Color(0xFFE06E00),
      warning: Color(0xFFB77900),
      danger: Color(0xFFD93025),
      xp: Color(0xFF7A55D8),
      heart: Color(0xFFD43F68),
      locked: Color(0xFFE7DCD1),
      text: Color(0xFF231A14),
      mutedText: Color(0xFF75685F),
      border: Color(0xFFE3D7CC),
      stateHighlight: Color(0x55FFC857),
      onDarkAccent: Color(0xFFFFFFFF),
      onDarkAccentMuted: Color(0xD6FFFFFF),
      mascotScrim: Color(0x7A000000),
      shadow: Color(0x29000000),
      courseHeaderShadow: Color(0x3DFF8A1F),
      courseHeaderIconBackground: Color(0x38FF8A1F),
    );
  }

  factory AppColorPalette.dark() {
    return const AppColorPalette(
      background: Color(0xFF111013),
      surface: Color(0xFF1C1816),
      surfaceRaised: Color(0xFF26211E),
      primary: Color(0xFFFF8A1F),
      primaryDark: Color(0xFFC84A0E),
      onPrimary: Color(0xFF17110C),
      secondary: Color(0xFFFFB15C),
      warning: Color(0xFFFFC857),
      danger: Color(0xFFFF5C4D),
      xp: Color(0xFFB78CFF),
      heart: Color(0xFFFF6B92),
      locked: Color(0xFF3A3431),
      text: Color(0xFFF7F2EC),
      mutedText: Color(0xFFB8ACA3),
      border: Color(0xFF342C27),
      stateHighlight: Color(0x47FFC857),
      onDarkAccent: Color(0xFFFFFFFF),
      onDarkAccentMuted: Color(0xD6FFFFFF),
      mascotScrim: Color(0x7A000000),
      shadow: Color(0x29000000),
      courseHeaderShadow: Color(0x3DFF8A1F),
      courseHeaderIconBackground: Color(0x38FF8A1F),
    );
  }

  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color secondary;
  final Color warning;
  final Color danger;
  final Color xp;
  final Color heart;
  final Color locked;
  final Color text;
  final Color mutedText;
  final Color border;
  final Color stateHighlight;
  final Color onDarkAccent;
  final Color onDarkAccentMuted;
  final Color mascotScrim;
  final Color shadow;
  final Color courseHeaderShadow;
  final Color courseHeaderIconBackground;

  Color lessonNodeShadow(Color color, {required bool isLocked}) {
    return color.withValues(alpha: isLocked ? 0.18 : 0.32);
  }

  @override
  AppColorPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? primary,
    Color? primaryDark,
    Color? onPrimary,
    Color? secondary,
    Color? warning,
    Color? danger,
    Color? xp,
    Color? heart,
    Color? locked,
    Color? text,
    Color? mutedText,
    Color? border,
    Color? stateHighlight,
    Color? onDarkAccent,
    Color? onDarkAccentMuted,
    Color? mascotScrim,
    Color? shadow,
    Color? courseHeaderShadow,
    Color? courseHeaderIconBackground,
  }) {
    return AppColorPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      xp: xp ?? this.xp,
      heart: heart ?? this.heart,
      locked: locked ?? this.locked,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      stateHighlight: stateHighlight ?? this.stateHighlight,
      onDarkAccent: onDarkAccent ?? this.onDarkAccent,
      onDarkAccentMuted: onDarkAccentMuted ?? this.onDarkAccentMuted,
      mascotScrim: mascotScrim ?? this.mascotScrim,
      shadow: shadow ?? this.shadow,
      courseHeaderShadow: courseHeaderShadow ?? this.courseHeaderShadow,
      courseHeaderIconBackground:
          courseHeaderIconBackground ?? this.courseHeaderIconBackground,
    );
  }

  @override
  AppColorPalette lerp(ThemeExtension<AppColorPalette>? other, double t) {
    if (other is! AppColorPalette) return this;

    return AppColorPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      xp: Color.lerp(xp, other.xp, t)!,
      heart: Color.lerp(heart, other.heart, t)!,
      locked: Color.lerp(locked, other.locked, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      border: Color.lerp(border, other.border, t)!,
      stateHighlight: Color.lerp(stateHighlight, other.stateHighlight, t)!,
      onDarkAccent: Color.lerp(onDarkAccent, other.onDarkAccent, t)!,
      onDarkAccentMuted: Color.lerp(
        onDarkAccentMuted,
        other.onDarkAccentMuted,
        t,
      )!,
      mascotScrim: Color.lerp(mascotScrim, other.mascotScrim, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      courseHeaderShadow: Color.lerp(
        courseHeaderShadow,
        other.courseHeaderShadow,
        t,
      )!,
      courseHeaderIconBackground: Color.lerp(
        courseHeaderIconBackground,
        other.courseHeaderIconBackground,
        t,
      )!,
    );
  }
}

/// Wählt die Farbpalette anhand der Helligkeit beziehungsweise des aktuellen Themes.
abstract final class AppColors {
  static AppColorPalette forBrightness(Brightness brightness) {
    return brightness == Brightness.light
        ? AppColorPalette.light()
        : AppColorPalette.dark();
  }

  static AppColorPalette of(BuildContext context) {
    return Theme.of(context).extension<AppColorPalette>()!;
  }
}

extension AppColorsX on BuildContext {
  AppColorPalette get colors => AppColors.of(this);
}
