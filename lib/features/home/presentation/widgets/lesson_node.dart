import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

/// Darstellungs- und Zugriffsstatus einer Lektion im Lernpfad.
enum LessonNodeStatus { completed, current, unlocked, locked }

/// Zeigt Lektionssymbol, Titel und Sterne; gesperrte oder deaktivierte Knoten öffnen keine Lektion.
class LessonNode extends StatelessWidget {
  const LessonNode({
    required this.lessonId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    this.stars = 0,
    this.isInteractive = true,
    this.isFocused = false,
    super.key,
  });

  final String lessonId;
  final String title;
  final String subtitle;
  final IconData icon;
  final LessonNodeStatus status;
  final int stars;
  final bool isInteractive;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonNodeStatus.locked;
    final isCompleted = status == LessonNodeStatus.completed;
    final nodeColor = switch (status) {
      LessonNodeStatus.completed => context.colors.primaryDark,
      LessonNodeStatus.current => context.colors.primary,
      LessonNodeStatus.unlocked => context.colors.secondary,
      LessonNodeStatus.locked => context.colors.locked,
    };
    final iconColor = switch (status) {
      LessonNodeStatus.completed => context.colors.text,
      LessonNodeStatus.current => context.colors.onPrimary,
      LessonNodeStatus.unlocked => context.colors.onPrimary,
      LessonNodeStatus.locked => context.colors.mutedText,
    };

    return AnimatedScale(
          scale: isFocused ? 1.08 : 1,
          duration: 220.ms,
          curve: Curves.easeOutBack,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(999)),
            onTap: isLocked || !isInteractive
                ? null
                : AppHaptics.wrapButton(() => context.go('/lesson/$lessonId')),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: 180.ms,
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFocused
                          ? context.colors.warning
                          : isLocked
                          ? context.colors.border
                          : context.colors.surface,
                      width: isFocused ? 6 : 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.lessonNodeShadow(
                          nodeColor,
                          isLocked: isLocked,
                        ),
                        blurRadius: isFocused ? 28 : 14,
                        offset: const Offset(0, 7),
                      ),
                      if (isFocused)
                        BoxShadow(
                          color: context.colors.warning.withValues(alpha: 0.5),
                          blurRadius: 32,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: AnimatedContainer(
                    duration: 180.ms,
                    width: isCompleted ? 68 : 60,
                    height: isCompleted ? 68 : 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? context.colors.warning
                            : context.colors.surface.withValues(alpha: 0.82),
                        width: isCompleted ? 4 : 2,
                      ),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : icon,
                      color: iconColor,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isLocked
                        ? context.colors.mutedText
                        : context.colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: context.textStyles.caption,
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < 3; index++)
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: index < stars
                              ? context.colors.warning
                              : context.colors.locked,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 220.ms)
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: 260.ms,
        );
  }
}
