import 'dart:math' as math;

import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/router.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_message.dart';
import 'package:bachelor/features/mascot/presentation/controllers/mascot_controller.dart';
import 'package:bachelor/features/mascot/presentation/mascot_guide_anchors.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_widget.dart';
import 'package:bachelor/features/mascot/presentation/widgets/speech_bubble.dart';
import 'package:bachelor/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Legt Maskottchen-Nachrichten über den aktuellen Seiteninhalt.
/// Die Einführung richtet Figur und Sprechblase an der tatsächlich verwendeten
/// Navigation aus; Antippen des abgedunkelten Hintergrunds führt die Folge weiter.
class MascotOverlay extends ConsumerWidget {
  const MascotOverlay({required this.child, super.key});

  // Die Führung bleibt oberhalb der 82 Pixel hohen unteren Navigation.
  // Der zusätzliche Abstand hält deren Beschriftungen während der Tour frei.
  static const _bottomGuideInset = 120.0;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<MascotMessage>(mascotControllerProvider, (previous, next) {
      if (!next.isVisible) return;
      final isNewMessage =
          previous?.isVisible != true || previous?.text != next.text;
      if (isNewMessage) AppHaptics.mascotMessage();
    });

    final mascot = ref.watch(mascotControllerProvider);
    const mascotSize = 150.0;
    final screen = MediaQuery.sizeOf(context);
    final railAnchor = mascot.isVisible
        ? _sideRailAnchor(mascot.target, screen)
        : null;

    return Stack(
      children: [
        child,
        if (mascot.isVisible) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _advanceGuide(context, ref),
              child: ColoredBox(color: context.colors.mascotScrim),
            ).animate().fadeIn(duration: 180.ms),
          ),
          if (railAnchor != null)
            ..._besideRail(mascot, railAnchor, screen, mascotSize)
          else
            Positioned(
              left: 16,
              right: 16,
              bottom: _bottomGuideInset,
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final targetX =
                        constraints.maxWidth * _targetFraction(mascot.target);
                    final mascotLeft = (targetX - mascotSize / 2)
                        .clamp(0.0, constraints.maxWidth - mascotSize)
                        .toDouble();
                    final bubbleWidth = math.min(360.0, constraints.maxWidth);
                    final bubbleLeft =
                        (targetX + mascotSize * 0.35 - bubbleWidth * 0.62)
                            .clamp(
                              0.0,
                              math.max(0.0, constraints.maxWidth - bubbleWidth),
                            )
                            .toDouble();
                    final tailAlignment =
                        ((mascotLeft + mascotSize * 0.48 - bubbleLeft) /
                                bubbleWidth)
                            .clamp(0.08, 0.92)
                            .toDouble();

                    return SizedBox(
                      height: 270,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: bubbleLeft,
                            width: bubbleWidth,
                            bottom: 148,
                            child:
                                SpeechBubble(
                                      message: mascot.text,
                                      tailAlignment: tailAlignment,
                                    )
                                    .animate(key: ValueKey(mascot.text))
                                    .fadeIn(delay: 160.ms, duration: 220.ms)
                                    .slide(
                                      begin: const Offset(0.06, 0.14),
                                      end: Offset.zero,
                                      curve: Curves.easeOutCubic,
                                      duration: 260.ms,
                                    ),
                          ),
                          AnimatedPositioned(
                            duration: 320.ms,
                            curve: Curves.easeOutCubic,
                            left: mascotLeft,
                            bottom: 0,
                            child:
                                MascotWidget(
                                      pose: mascot.pose,
                                      size: mascotSize,
                                    )
                                    .animate(key: ValueKey(mascot.target))
                                    .fadeIn(duration: 220.ms)
                                    .slideY(
                                      begin: 0.22,
                                      end: 0,
                                      curve: Curves.easeOutCubic,
                                      duration: 280.ms,
                                    )
                                    .scale(
                                      begin: const Offset(0.92, 0.92),
                                      end: const Offset(1, 1),
                                      curve: Curves.easeOutBack,
                                      duration: 320.ms,
                                    ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ],
    );
  }

  /// Der Eintrag des Ziels in der seitlichen Navigationsleiste (breites Web-Layout) oder
  /// `null`, wenn die App die untere Navigationsleiste anzeigt.
  Rect? _sideRailAnchor(MascotGuideTarget target, Size screen) {
    final rail = MascotGuideAnchors.railRect();
    final entry = MascotGuideAnchors.rectFor(target);
    if (rail == null || entry == null) return null;
    // Höhe des Eintrags über die volle Leistenbreite: Fini steht direkt rechts
    // neben der Leiste, auf Höhe des Eintrags, über den sie spricht.
    return Rect.fromLTRB(rail.left, entry.top, rail.right, entry.bottom);
  }

  /// Platziert Fini neben dem Leisteneintrag mit der Sprechblase rechts von ihr, sodass sie
  /// auf die linke Navigation zeigt und nicht auf eine nicht vorhandene untere Leiste.
  List<Widget> _besideRail(
    MascotMessage mascot,
    Rect anchor,
    Size screen,
    double mascotSize,
  ) {
    const gap = 12.0;
    const margin = 8.0;
    final mascotLeft = anchor.right + gap;
    final mascotTop = (anchor.center.dy - mascotSize / 2)
        .clamp(margin, math.max(margin, screen.height - mascotSize - margin))
        .toDouble();
    final bubbleLeft = mascotLeft + mascotSize * 0.85;
    final bubbleWidth = math.max(
      200.0,
      math.min(360.0, screen.width - bubbleLeft - 16),
    );

    return [
      AnimatedPositioned(
        key: const ValueKey('mascot-rail-guide'),
        duration: 320.ms,
        curve: Curves.easeOutCubic,
        left: mascotLeft,
        top: mascotTop,
        child: IgnorePointer(
          child: MascotWidget(pose: mascot.pose, size: mascotSize)
              .animate(key: ValueKey(mascot.target))
              .fadeIn(duration: 220.ms)
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
                duration: 320.ms,
              ),
        ),
      ),
      AnimatedPositioned(
        duration: 320.ms,
        curve: Curves.easeOutCubic,
        left: bubbleLeft,
        top: math.max(margin, mascotTop - 12),
        width: bubbleWidth,
        child: IgnorePointer(
          child: SpeechBubble(message: mascot.text, tailAlignment: 0.08)
              .animate(key: ValueKey(mascot.text))
              .fadeIn(delay: 160.ms, duration: 220.ms),
        ),
      ),
    ];
  }

  double _targetFraction(MascotGuideTarget target) {
    return switch (target) {
      MascotGuideTarget.lessonPath => 0.13,
      MascotGuideTarget.sandbox => 0.38,
      MascotGuideTarget.progress => 0.63,
      MascotGuideTarget.settings => 0.90,
    };
  }

  void _advanceGuide(BuildContext context, WidgetRef ref) {
    AppHaptics.button();
    final next = ref.read(mascotControllerProvider.notifier).advanceOrHide();
    if (next == null) return;

    final route = next.route;
    if (route != null) {
      appRouter.go(route);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appRouter.go(route);
      });
    }

    if (next.openLanguagePicker) {
      ref.read(settingsLanguageDropdownOpenProvider.notifier).requestOpen();
    }
  }
}
