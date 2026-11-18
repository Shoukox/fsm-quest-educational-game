import 'package:bachelor/features/lesson/domain/models/chapter_definition.dart';

/// Legt Kapitelreihenfolge, zugehörige Lektionen und Freischaltvoraussetzungen fest.
class ChapterCatalog {
  const ChapterCatalog._();

  static const chapters = <ChapterDefinition>[
    ChapterDefinition(
      id: 'chapter1',
      lessonIds: ['intro', 'states', 'transitions', 'chapter_test'],
    ),
    ChapterDefinition(
      id: 'chapter2',
      lessonIds: ['chapter2-gates-review', 'chapter_2', 'chapter_2_test'],
      unlockAfterLessonId: 'chapter_test',
    ),
    ChapterDefinition(
      id: 'chapter3',
      // Stabile Lektions-IDs erhalten gespeicherten Fortschritt nach einer Umsortierung.
      lessonIds: ['chapter4-completion', 'chapter_4_test'],
      unlockAfterLessonId: 'chapter_2_test',
    ),
    ChapterDefinition(
      id: 'chapter4',
      lessonIds: [
        'automata-creation-description',
        'automata-creation-tables',
        'automata-creation-test',
      ],
      unlockAfterLessonId: 'chapter_4_test',
    ),
    ChapterDefinition(
      id: 'chapter5',
      lessonIds: [
        'chapter5-theory',
        'chapter5-tables',
        'chapter5-completion',
        'chapter5-creation',
        'chapter5-diagnostics',
      ],
      unlockAfterLessonId: 'automata-creation-test',
    ),
  ];

  static List<String> get lessonIds => [
    for (final chapter in chapters) ...chapter.lessonIds,
  ];
}
