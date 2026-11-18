import 'package:flutter/material.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_scroll_continue_button.dart';

/// Ordnet Sprechtext und Szene in einer scrollbaren Ansicht mit fester Navigation darunter an.
class LessonStoryScaffold extends StatelessWidget {
  const LessonStoryScaffold({
    required this.speech,
    required this.content,
    required this.controller,
    required this.onContinue,
    this.onBack,
    this.canGoBack = true,
    this.isLast = false,
    this.finishLabel,
    super.key,
  });
  final Widget speech, content;
  final ScrollController controller;
  final VoidCallback? onContinue, onBack;
  final bool canGoBack, isLast;
  final String? finishLabel;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          controller: controller,
          children: [speech, const SizedBox(height: 12), content],
        ),
      ),
      Row(
        children: [
          if (canGoBack)
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          Expanded(
            child: LessonScrollContinueButton(
              controller: controller,
              onContinue: onContinue,
            ),
          ),
        ],
      ),
    ],
  );
}
