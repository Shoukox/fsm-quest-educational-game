/// Berechnet den angezeigten Fortschritt einer Lektion.
/// Der Lernteil belegt 80 % des Balkens. Bei Lektionen mit Story füllen deren
/// Szenen diesen Anteil; die anschließenden Aufgaben füllen die übrigen 20 %.
/// Eigenständige praktische Tests beginnen ebenfalls bei 80 %. Aufgaben ohne
/// Story und ohne Testkennzeichnung füllen nur den Lernanteil.
abstract final class LessonProgressCalculator {
  static const double learningWeight = 0.8;
  static const double testWeight = 0.2;

  static double calculate({
    required bool isPracticalTest,
    required bool hasStory,
    required bool storyCompleted,
    required double storyProgress,
    required int completedTaskCount,
    required int taskCount,
  }) {
    final taskProgress = taskCount == 0
        ? 0.0
        : (completedTaskCount / taskCount).clamp(0.0, 1.0).toDouble();

    if (isPracticalTest) {
      return learningWeight + taskProgress * testWeight;
    }

    if (!hasStory) return taskProgress * learningWeight;

    if (!storyCompleted) {
      return storyProgress.clamp(0.0, 1.0).toDouble() * learningWeight;
    }

    return learningWeight + taskProgress * testWeight;
  }
}
