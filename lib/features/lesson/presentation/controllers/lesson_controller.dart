import 'package:flutter_riverpod/flutter_riverpod.dart';

final lessonControllerProvider = NotifierProvider<LessonController, int>(
  LessonController.new,
);

/// Einfacher Riverpod-Zähler für den aktuellen Aufgabenindex mit Rücksetzung auf die erste Aufgabe.
class LessonController extends Notifier<int> {
  @override
  int build() => 0;

  void goToNextTask() {
    state++;
  }

  void reset() {
    state = 0;
  }
}
