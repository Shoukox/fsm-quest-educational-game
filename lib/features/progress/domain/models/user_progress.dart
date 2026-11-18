import 'package:bachelor/features/progress/domain/models/lesson_progress.dart';

/// Momentaufnahme der Spielwerte und Lektionsstände; Gesamtsterne werden aus den Lektionen summiert.
class UserProgress {
  const UserProgress({
    required this.totalXp,
    required this.streakDays,
    required this.hearts,
    required this.gems,
    required this.coins,
    this.lessons = const [],
  });

  final int totalXp;
  final int streakDays;
  final int hearts;
  final int gems;
  final int coins;
  final List<LessonProgress> lessons;

  int get totalStars =>
      lessons.fold(0, (total, lesson) => total + lesson.stars);
}
