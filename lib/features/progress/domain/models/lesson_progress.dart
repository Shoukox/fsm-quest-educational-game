/// Gespeicherter Stand einer Lektion mit Freigabe, Abschluss, Bestwerten und Versuchszahl.
class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    required this.isCompleted,
    this.bestScore = 0,
    this.isUnlocked = false,
    this.attempts = 0,
    this.stars = 0,
  });

  final String lessonId;
  final bool isCompleted;
  final int bestScore;
  final bool isUnlocked;
  final int attempts;
  final int stars;
}
