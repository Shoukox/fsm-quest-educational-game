import 'dart:math' as math;

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Meldet eine noch erforderliche Interaktion und scrollt zu den Bedienelementen am Szenenende.
void showLessonInteractionPrompt(
  BuildContext context,
  ScrollController scrollController,
) {
  AppHaptics.warning();
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.l10n.t('lesson.completeInteractionFirst')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 84),
      ),
    );

  if (!scrollController.hasClients) return;
  scrollController.animateTo(
    scrollController.position.maxScrollExtent,
    duration: 420.ms,
    curve: Curves.easeOutCubic,
  );
}

/// Hebt ein Bedienelement animiert hervor, sobald sich das positive Hinweissignal ändert.
class LessonInteractionHint extends StatefulWidget {
  const LessonInteractionHint({
    required this.signal,
    required this.child,
    this.circular = false,
    super.key,
  });

  final int signal;
  final Widget child;
  final bool circular;

  @override
  State<LessonInteractionHint> createState() => _LessonInteractionHintState();
}

class _LessonInteractionHintState extends State<LessonInteractionHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: 900.ms,
  );

  @override
  void didUpdateWidget(covariant LessonInteractionHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.signal != oldWidget.signal && widget.signal > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final pulse = math.sin(_controller.value * math.pi * 5).abs();
        return KeyedSubtree(
          key: ValueKey(
            _controller.isAnimating
                ? 'interaction-hint-active'
                : 'interaction-hint-idle',
          ),
          child: Transform.scale(
            scale: 1 + pulse * 0.055,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: widget.circular ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: widget.circular
                    ? null
                    : BorderRadius.circular(9),
                boxShadow: [
                  if (pulse > 0)
                    BoxShadow(
                      color: context.colors.primary.withValues(
                        alpha: 0.46 * pulse,
                      ),
                      blurRadius: 18 * pulse,
                      spreadRadius: 4 * pulse,
                    ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
