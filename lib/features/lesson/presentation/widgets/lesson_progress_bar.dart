import 'package:bachelor/core/widgets/app_progress_bar.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Kombiniert animierten Fortschrittsbalken, Prozentanzeige und optionales Erfolgssymbol.
class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    required this.value,
    this.isSuccess = false,
    super.key,
  });

  final double value;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final percentage = (value.clamp(0.0, 1.0) * 100).round();

    return Semantics(
      container: true,
      label: 'Lesson progress',
      value: '$percentage%',
      child: Row(
        children: [
          Expanded(
            child: AppProgressBar(value: value, isSuccess: isSuccess),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$percentage%',
              key: ValueKey(percentage),
              style: context.textStyles.caption.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: isSuccess
                ? const Padding(
                    key: ValueKey('lesson-progress-success'),
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF42D67A),
                    ),
                  )
                : const SizedBox.shrink(
                    key: ValueKey('lesson-progress-active'),
                  ),
          ),
        ],
      ),
    );
  }
}
