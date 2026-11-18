enum StoryStage { welcome, recall, demo, guided, practice, summary }

/// Legt fest, welche Interaktion vor dem Weitergehen einer Szene erforderlich ist.
enum InteractionRequirement { none, demonstration, correctEvaluation }

class StorySceneDefinition {
  const StorySceneDefinition({
    required this.id,
    required this.narrationKey,
    required this.objectiveId,
    required this.stage,
    this.interactionRequirement = InteractionRequirement.none,
  });
  final String id, narrationKey, objectiveId;
  final StoryStage stage;
  final InteractionRequirement interactionRequirement;
}

/// Enthält die geordnete Szenenfolge einer Story; der Controller erwartet mindestens eine Szene.
class StoryDefinition {
  const StoryDefinition({required this.id, required this.scenes});
  final String id;
  final List<StorySceneDefinition> scenes;
}
