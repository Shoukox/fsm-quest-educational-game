import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/assessment_policy.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.xpReward,
    required this.coinReward,
    this.chapterId = 'chapter1',
    this.subtitle,
    this.tasks = const [],
    this.isPracticalTest = false,
    this.minimumCorrectRatio = 0,
    this.timeLimitSeconds,
    this.storyId,
    this.assessmentPolicy,
  });

  final String id;
  final String title;
  final int xpReward;
  final int coinReward;
  final String chapterId;
  final String? subtitle;
  final List<LessonTask> tasks;
  final bool isPracticalTest;
  final double minimumCorrectRatio;
  final int? timeLimitSeconds;
  final String? storyId;
  final AssessmentPolicy? assessmentPolicy;

  /// Rundet die Bestehensgrenze auf ganze Aufgaben auf.
  int get minimumCorrectAnswers => (tasks.length * minimumCorrectRatio).ceil();

  bool isPassingScore(int correctAnswers) {
    return correctAnswers.clamp(0, tasks.length) >= minimumCorrectAnswers;
  }

  /// Vergibt drei Sterne ohne Fehler, zwei bei einem und sonst einen Stern.
  /// Maßgeblich ist die Zahl der im ersten Versuch richtig gelösten Aufgaben.
  int starsForFirstTryAnswers(int correctAnswers) {
    if (tasks.isEmpty) return 1;
    final mistakes = tasks.length - correctAnswers.clamp(0, tasks.length);
    if (mistakes == 0) return 3;
    if (mistakes == 1) return 2;
    return 1;
  }

  int xpForStars(int stars) => (xpReward * rewardMultiplier(stars)).round();

  int coinsForStars(int stars) =>
      (coinReward * rewardMultiplier(stars)).round();

  /// Skaliert die Grundbelohnung auf 50 %, 75 % oder 100 % bei einem bis drei Sternen.
  static double rewardMultiplier(int stars) {
    return switch (stars.clamp(1, 3)) {
      1 => 0.5,
      2 => 0.75,
      _ => 1,
    };
  }
}
