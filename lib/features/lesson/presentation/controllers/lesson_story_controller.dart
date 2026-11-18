import 'package:flutter/foundation.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_story.dart';

class SceneDraft {
  const SceneDraft(this.value);
  final Object? value;
}

enum StoryNextResult { advanced, blocked, finished }

/// Verwaltet Szenenwechsel, Entwürfe und erfüllte Interaktionsanforderungen einer Story.
class LessonStoryController extends ChangeNotifier {
  LessonStoryController(this.definition)
    : _currentSceneId = definition.scenes.first.id;
  final StoryDefinition definition;
  String _currentSceneId;
  final drafts = <String, SceneDraft>{};
  final evaluations = <String, bool>{};
  final completed = <String>{};
  final hintLevels = <String, int>{};
  String get currentSceneId => _currentSceneId;
  bool get canAdvance =>
      completed.contains(_currentSceneId) ||
      definition.scenes
              .firstWhere((s) => s.id == _currentSceneId)
              .interactionRequirement ==
          InteractionRequirement.none;
  /// Ersetzt den Entwurf und verwirft dessen letzte Bewertung.
  /// Ein bereits erreichter Szenenabschluss bleibt dabei erhalten.
  void updateDraft(String sceneId, SceneDraft draft) {
    drafts[sceneId] = draft;
    evaluations.remove(sceneId);
    notifyListeners();
  }

  void submitEvaluation(String sceneId, bool correct) {
    evaluations[sceneId] = correct;
    if (correct) completed.add(sceneId);
    notifyListeners();
  }

  void completeDemonstration(String sceneId) {
    completed.add(sceneId);
    notifyListeners();
  }

  bool next() {
    return nextResult == StoryNextResult.advanced;
  }

  /// Versucht beim Lesen zur nächsten Szene zu wechseln und meldet das Ergebnis.
  /// An der letzten Szene wird `finished` geliefert, ohne die Szene zu wechseln.
  StoryNextResult get nextResult {
    if (!canAdvance) return StoryNextResult.blocked;
    final index = definition.scenes.indexWhere((s) => s.id == _currentSceneId);
    if (index + 1 >= definition.scenes.length) return StoryNextResult.finished;
    _currentSceneId = definition.scenes[index + 1].id;
    notifyListeners();
    return StoryNextResult.advanced;
  }

  bool previous() {
    final index = definition.scenes.indexWhere((s) => s.id == _currentSceneId);
    if (index <= 0) return false;
    _currentSceneId = definition.scenes[index - 1].id;
    notifyListeners();
    return true;
  }
}
