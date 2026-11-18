import 'package:bachelor/features/lesson/domain/models/lesson_story.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_difficulty.dart';
import 'package:bachelor/features/lesson/domain/models/task_kind.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'chapter_fsm_fixtures.dart';

const _chapter4Narration = [
  'chapter4.story.intro',
  'chapter4.story.welcome',
  'chapter4.story.coinMachine',
  'chapter4.story.stateMeaning',
  'chapter4.story.missingTransition',
  'chapter4.story.completenessCheck',
  'chapter4.story.summary',
];

/// Szenenfolge zum Vervollständigen von Automaten im angezeigten Kapitel 3.
/// Die historischen chapter4-IDs bleiben zur Zuordnung vorhandener Daten stabil.
final chapter4MainStory = StoryDefinition(
  id: 'chapter4-completion',
  scenes: [
    for (var i = 0; i < _chapter4Narration.length; i++)
      StorySceneDefinition(
        id: 'c4-main-$i',
        narrationKey: _chapter4Narration[i],
        objectiveId: 'chapter4-objective-$i',
        stage: i == 0
            ? StoryStage.welcome
            : i == _chapter4Narration.length - 1
            ? StoryStage.summary
            : i < 3
            ? StoryStage.demo
            : StoryStage.guided,
      ),
  ],
);

const _completionTools = {
  FsmEditorTool.select,
  FsmEditorTool.addState,
  FsmEditorTool.addTransition,
  FsmEditorTool.setInitial,
  FsmEditorTool.delete,
};

/// Geführte Vervollständigungsaufgaben mit Teilautomat, Referenz und erlaubten Werkzeugen.
List<LessonTask> chapter4MainTasks() => [
  LessonTask(
    id: 'chapter4-guided-complete-coin-machine',
    prompt: 'chapter4.task.coin.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa8CompleteAutomaton,
    difficulty: TaskDifficulty.ss2,
    instruction: 'chapter4.task.coin.instruction',
    hint: 'chapter4.task.coin.hint',
    payload: Aa8CompleteAutomatonPayload(
      partialFsm: chapter4CoinMachinePartial,
      expectedFsm: chapter4CoinMachine,
      inputAlphabet: ['0', '1'],
      evaluationMode: FsmEvaluationMode.behavioral,
      readyPresetsOnly: true,
      allowedTools: _completionTools,
    ),
  ),
  LessonTask(
    id: 'chapter4-guided-complete-water-controller',
    prompt: 'chapter4.task.water.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa8CompleteAutomaton,
    difficulty: TaskDifficulty.ss2,
    instruction: 'chapter4.task.water.instruction',
    hint: 'chapter4.task.water.hint',
    payload: Aa8CompleteAutomatonPayload(
      partialFsm: chapter4WaterLevelPartial,
      expectedFsm: chapter4WaterLevelMachine,
      inputAlphabet: ['0', '1'],
      evaluationMode: FsmEvaluationMode.behavioral,
      readyPresetsOnly: true,
      allowedTools: _completionTools,
    ),
  ),
  LessonTask(
    id: 'chapter4-guided-complete-pump-response',
    prompt: 'chapter4.task.pump.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa8CompleteAutomaton,
    difficulty: TaskDifficulty.ss2,
    instruction: 'chapter4.task.pump.instruction',
    hint: 'chapter4.task.pump.hint',
    payload: Aa8CompleteAutomatonPayload(
      partialFsm: chapter4PumpMealyPartial,
      expectedFsm: chapter4PumpMealyMachine,
      inputAlphabet: ['sensor = 0', 'sensor = 1'],
      evaluationMode: FsmEvaluationMode.behavioral,
      readyPresetsOnly: true,
      allowedTools: _completionTools,
    ),
  ),
];

/// Eigenständige Aufgaben für den Abschlusstest des Vervollständigungskapitels.
List<LessonTask> chapter4FinalTasks() => [
  LessonTask(
    id: 'chapter4-final-switch',
    prompt: 'chapter4.test.switch.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa8CompleteAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'chapter4.test.switch.instruction',
    hint: 'chapter4.test.switch.hint',
    payload: Aa8CompleteAutomatonPayload(
      partialFsm: chapter4SwitchPartial,
      expectedFsm: chapter4SwitchMachine,
      inputAlphabet: ['0', '1'],
      evaluationMode: FsmEvaluationMode.behavioral,
      readyPresetsOnly: true,
      allowedTools: _completionTools,
    ),
  ),
  LessonTask(
    id: 'chapter4-final-ticket',
    prompt: 'chapter4.test.ticket.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa8CompleteAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'chapter4.test.ticket.instruction',
    hint: 'chapter4.test.ticket.hint',
    payload: Aa8CompleteAutomatonPayload(
      partialFsm: chapter4TicketPartial,
      expectedFsm: chapter4TicketMachine,
      inputAlphabet: ['0', '1'],
      evaluationMode: FsmEvaluationMode.behavioral,
      readyPresetsOnly: true,
      allowedTools: _completionTools,
    ),
  ),
  LessonTask(
    id: 'chapter4-final-lock',
    prompt: 'chapter4.test.lock.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa8CompleteAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'chapter4.test.lock.instruction',
    hint: 'chapter4.test.lock.hint',
    payload: Aa8CompleteAutomatonPayload(
      partialFsm: chapter4LockPartial,
      expectedFsm: chapter4LockMachine,
      inputAlphabet: ['0', '1'],
      evaluationMode: FsmEvaluationMode.behavioral,
      readyPresetsOnly: true,
      allowedTools: _completionTools,
    ),
  ),
  LessonTask(
    id: 'chapter4-final-completeness-rule',
    prompt: 'chapter4.final.completeness.prompt',
    type: LessonTaskType.multipleChoice,
    kind: TaskKind.aa9Theory,
    difficulty: TaskDifficulty.ss2,
    concept: 'concept.transitions',
    answers: const ['answer.true', 'answer.false'],
    correctAnswerId: 'answer.false',
  ),
  LessonTask(
    id: 'chapter4-final-transition-count',
    prompt: 'chapter4.final.transitionCount.prompt',
    type: LessonTaskType.multipleChoice,
    kind: TaskKind.aa9Theory,
    difficulty: TaskDifficulty.ss2,
    concept: 'concept.determinism',
    answers: const [
      'chapter4.answer.fiveTransitions',
      'chapter4.answer.sixTransitions',
      'chapter4.answer.sevenTransitions',
    ],
    correctAnswerId: 'chapter4.answer.sixTransitions',
  ),
];
