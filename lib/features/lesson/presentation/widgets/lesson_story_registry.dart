import 'package:flutter/widgets.dart';
import 'package:bachelor/features/lesson/presentation/widgets/automata_creation_story.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter4/chapter4_story.dart';

typedef LessonStoryBuilder =
    Widget Function({
      required VoidCallback onFinished,
      required ValueChanged<double> onProgressChanged,
    });

/// Ordnet Story-IDs ihren Widget-Fabriken zu und erlaubt die Registrierung weiterer Darstellungen.
class LessonStoryRegistry {
  static final Map<String, LessonStoryBuilder> builders = {
    'automata-creation-description':
        ({required onFinished, required onProgressChanged}) =>
            AutomataCreationStory(
              fromTables: false,
              onFinished: onFinished,
              onProgressChanged: onProgressChanged,
            ),
    'automata-creation-tables':
        ({required onFinished, required onProgressChanged}) =>
            AutomataCreationStory(
              fromTables: true,
              onFinished: onFinished,
              onProgressChanged: onProgressChanged,
            ),
    'chapter4-completion':
        ({required onFinished, required onProgressChanged}) => Chapter4Story(
          onFinished: onFinished,
          onProgressChanged: onProgressChanged,
        ),
  };
  static void register(String id, LessonStoryBuilder builder) =>
      builders[id] = builder;
  static LessonStoryBuilder? builderFor(String? id) =>
      id == null ? null : builders[id];
}
