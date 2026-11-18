import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Animiert einen auf 0 bis 1 begrenzten Fortschritt; Erfolg erhält eine grüne Füllung.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    this.isSuccess = false,
    super.key,
  });

  final double value;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0).toDouble();
    final fillColor = isSuccess
        ? const Color(0xFF42D67A)
        : context.colors.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        final progress = animatedValue.clamp(0.0, 1.0).toDouble();
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: progress,
            backgroundColor: context.colors.border,
            color: fillColor,
          ),
        );
      },
    );
  }
}
