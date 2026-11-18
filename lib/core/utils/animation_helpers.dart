import 'package:bachelor/core/constants/app_constants.dart';
import 'package:flutter/animation.dart';

/// Gemeinsame Animationskurve und Dauer für konsistente Übergänge.
abstract final class AnimationHelpers {
  static const defaultCurve = Curves.easeOutCubic;
  static const defaultDuration = AppConstants.defaultAnimationDuration;
}
