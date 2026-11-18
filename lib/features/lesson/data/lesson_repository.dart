import 'package:bachelor/features/lesson/data/lesson_local_data_source.dart';
import 'package:bachelor/features/lesson/domain/models/lesson.dart';

/// Bietet Zugriff auf lokale Lektionen nach ID und Kapitel in Inhaltsreihenfolge.
class LessonRepository {
  const LessonRepository(this._localDataSource);

  final LessonLocalDataSource _localDataSource;

  List<Lesson> getLessons() {
    return _localDataSource.getLessons();
  }

  Lesson? getLessonById(String lessonId) {
    for (final lesson in getLessons()) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  List<Lesson> getLessonsForChapter(String chapterId) {
    return getLessons()
        .where((lesson) => lesson.chapterId == chapterId)
        .toList();
  }

  List<String> get chapterIds {
    return getLessons()
        .map((lesson) => lesson.chapterId)
        .toSet()
        .toList(growable: false);
  }
}
