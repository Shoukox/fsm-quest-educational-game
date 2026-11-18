import 'package:bachelor/features/lesson/domain/models/lesson.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_story.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_difficulty.dart';
import 'package:bachelor/features/lesson/domain/models/task_kind.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';

import 'automata_creation_fixtures.dart';

const _buildTools = {
  FsmEditorTool.select,
  FsmEditorTool.addState,
  FsmEditorTool.addTransition,
  FsmEditorTool.setInitial,
  FsmEditorTool.delete,
};

final creationDescriptionStory = _story(
  'automata-creation-description',
  includeWelcome: true,
);
final creationTableStory = _story('automata-creation-tables');

/// Erzeugt die Szenenfolge für das Erstellen von Automaten aus Beschreibungen oder Tabellen.
StoryDefinition _story(String id, {bool includeWelcome = false}) =>
    StoryDefinition(
      id: id,
      scenes: [
        if (includeWelcome)
          const StorySceneDefinition(
            id: 'automata-creation-description-welcome',
            narrationKey: 'automata-creation-description.welcome',
            objectiveId: 'automata-creation-description-welcome-objective',
            stage: StoryStage.welcome,
          ),
        for (var index = 0; index < 4; index++)
          StorySceneDefinition(
            id: '$id-${includeWelcome ? index + 1 : index}',
            narrationKey: '$id.story.$index',
            objectiveId: '$id-objective-$index',
            stage: index == 0
                ? (includeWelcome ? StoryStage.demo : StoryStage.welcome)
                : index == 3
                ? StoryStage.summary
                : StoryStage.demo,
          ),
      ],
    );

/// Konfiguriert Konstruktionsaufgaben mit vorgegebenen Bausteinen und Verhaltensvergleich.
/// Bei Tabellenaufgaben wird derselbe Referenzautomat zusätzlich als Datenquelle verwendet.
Aa4BuildAutomatonPayload _buildPayload(
  Fsm expectedFsm, {
  bool fromTables = false,
}) => Aa4BuildAutomatonPayload(
  expectedFsm: expectedFsm,
  sourceFsm: fromTables ? expectedFsm : null,
  tableRequirement: fromTables,
  inputAlphabet: expectedFsm.transitions
      .map((t) => t.inputSymbol)
      .toSet()
      .toList(),
  readyPresetsOnly: true,
  requireTransitionEndpoints: true,
  allowedTools: _buildTools,
  evaluationMode: FsmEvaluationMode.behavioral,
);

List<LessonTask> creationDescriptionTasks() => [
  LessonTask(
    id: 'creation-build-bike-rental',
    prompt: 'creation.description.task.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss2,
    instruction: 'creation.description.task.instruction',
    hint: 'creation.description.task.hint',
    payload: _buildPayload(creationBikeRental),
  ),
  LessonTask(
    id: 'automata-creation-description-test-parcel-kiosk',
    prompt: 'creation.description.test.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'creation.description.test.instruction',
    hint: 'creation.description.test.hint',
    payload: _buildPayload(creationParcelKiosk),
  ),
];

List<LessonTask> creationTableTasks() => [
  LessonTask(
    id: 'creation-build-parking-barrier',
    prompt: 'creation.tables.task.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss2,
    instruction: 'creation.tables.task.instruction',
    hint: 'creation.tables.task.hint',
    payload: _buildPayload(creationParkingBarrier, fromTables: true),
  ),
];

List<LessonTask> creationFinalTasks() => [
  LessonTask(
    id: 'creation-final-coffee',
    prompt: 'creation.test.coffee.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'creation.test.coffee.instruction',
    hint: 'creation.test.coffee.hint',
    payload: _buildPayload(creationCoffeeMachine),
  ),
  LessonTask(
    id: 'creation-final-locker',
    prompt: 'creation.test.locker.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'creation.test.locker.instruction',
    hint: 'creation.test.locker.hint',
    payload: _buildPayload(creationLocker),
  ),
  LessonTask(
    id: 'creation-final-washing-machine',
    prompt: 'creation.test.washingMachine.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'creation.test.washingMachine.instruction',
    hint: 'creation.test.washingMachine.hint',
    payload: _buildPayload(creationWashCycle),
  ),
];

/// Bündelt Beschreibung, Tabelleneinstieg und Abschlusstest zum Erstellungskapitel.
List<Lesson> automataCreationLessons() => [
  Lesson(
    id: 'automata-creation-description',
    chapterId: 'chapter4',
    title: 'creation.description.title',
    subtitle: 'creation.description.subtitle',
    storyId: 'automata-creation-description',
    xpReward: 150,
    coinReward: 80,
    tasks: creationDescriptionTasks(),
  ),
  Lesson(
    id: 'automata-creation-tables',
    chapterId: 'chapter4',
    title: 'creation.tables.title',
    subtitle: 'creation.tables.subtitle',
    storyId: 'automata-creation-tables',
    xpReward: 140,
    coinReward: 70,
    tasks: creationTableTasks(),
  ),
  Lesson(
    id: 'automata-creation-test',
    chapterId: 'chapter4',
    title: 'lesson.chapterTest.title',
    subtitle: 'creation.test.subtitle',
    isPracticalTest: true,
    minimumCorrectRatio: 2 / 3,
    timeLimitSeconds: 900,
    xpReward: 220,
    coinReward: 140,
    tasks: creationFinalTasks(),
  ),
];
