import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_widget.dart';
import 'package:bachelor/features/mascot/presentation/widgets/speech_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Zeigt eine Lektionserklärung als animierte Maskottchen-Sprechblase.
/// Die Blase nutzt die verfügbare Breite über der Figur; neue Texte oder Animations-IDs
/// lösen eine haptische Rückmeldung aus.
class MascotLessonSpeech extends StatefulWidget {
  const MascotLessonSpeech({
    required this.message,
    required this.pose,
    required this.animationId,
    this.mascotSize = 118,
    super.key,
  });

  final String message;
  final MascotPose pose;
  final String animationId;
  final double mascotSize;

  @override
  State<MascotLessonSpeech> createState() => _MascotLessonSpeechState();
}

class _MascotLessonSpeechState extends State<MascotLessonSpeech> {
  @override
  void initState() {
    super.initState();
    AppHaptics.mascotMessage();
  }

  @override
  void didUpdateWidget(covariant MascotLessonSpeech oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationId != oldWidget.animationId ||
        widget.message != oldWidget.message) {
      AppHaptics.mascotMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpeechBubble(message: widget.message, tailAlignment: 0.5)
            .animate(key: ValueKey('${widget.animationId}-bubble'))
            .fadeIn(duration: 180.ms)
            .slideY(begin: -0.05, end: 0, duration: 220.ms),
        const SizedBox(height: 2),
        Center(
          child: MascotWidget(pose: widget.pose, size: widget.mascotSize)
              .animate(key: ValueKey('${widget.animationId}-mascot'))
              .fadeIn(duration: 220.ms)
              .scale(
                begin: const Offset(0.4, 0.4),
                end: const Offset(1, 1),
                duration: 420.ms,
                curve: Curves.easeOutBack,
              ),
        ),
      ],
    );
  }
}
