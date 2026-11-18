/// Ordnet Lektionen einem Kapitel zu und beschreibt dessen optionale Freischaltvoraussetzung.
class ChapterDefinition {
  const ChapterDefinition({
    required this.id,
    required this.lessonIds,
    this.unlockAfterLessonId,
    this.isOptional = false,
  });

  final String id;
  final List<String> lessonIds;
  final String? unlockAfterLessonId;
  final bool isOptional;
}
