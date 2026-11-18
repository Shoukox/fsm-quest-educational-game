import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/lesson/domain/models/lesson.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_difficulty.dart';
import 'package:bachelor/features/lesson/domain/models/task_kind.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';

import 'chapter_fsm_fixtures.dart';

const _buildTools = {
  FsmEditorTool.select,
  FsmEditorTool.addState,
  FsmEditorTool.addTransition,
  FsmEditorTool.setInitial,
  FsmEditorTool.delete,
};

const _completionTools = {..._buildTools, FsmEditorTool.editOutput};

LessonTask _choice({
  required String id,
  required String prompt,
  required String instruction,
  required String hint,
  required List<String> answers,
  required String correct,
  Fsm? illustration,
}) => LessonTask(
  id: id,
  prompt: prompt,
  type: LessonTaskType.multipleChoice,
  kind: TaskKind.aa9Theory,
  difficulty: TaskDifficulty.ss2,
  instruction: instruction,
  hint: hint,
  answers: answers,
  correctAnswerId: correct,
  illustration: illustration,
);

/// Theoriefragen zu Ausgabeabhängigkeit und zeitlichem Verhalten von Moore und Mealy.
List<LessonTask> chapter5TheoryTasks() => [
  _choice(
    id: 'chapter5-theory-moore-output',
    prompt: 'chapter5.theory.mooreOutput.prompt',
    instruction: 'chapter5.theory.instruction',
    hint: 'chapter5.theory.mooreOutput.hint',
    answers: const [
      'chapter5.answer.stateOutput',
      'chapter5.answer.inputOnly',
      'chapter5.answer.nextStateOnly',
    ],
    correct: 'chapter5.answer.stateOutput',
  ),
  _choice(
    id: 'chapter5-theory-mealy-output',
    prompt: 'chapter5.theory.mealyOutput.prompt',
    instruction: 'chapter5.theory.instruction',
    hint: 'chapter5.theory.mealyOutput.hint',
    answers: const [
      'chapter5.answer.transitionInput',
      'chapter5.answer.stateOnly',
      'chapter5.answer.clockOnly',
    ],
    correct: 'chapter5.answer.transitionInput',
  ),
  _choice(
    id: 'chapter5-theory-timing',
    prompt: 'chapter5.theory.timing.prompt',
    instruction: 'chapter5.theory.instruction',
    hint: 'chapter5.theory.timing.hint',
    answers: const [
      'chapter5.answer.mealyImmediate',
      'chapter5.answer.sameTiming',
      'chapter5.answer.mooreImmediate',
    ],
    correct: 'chapter5.answer.mealyImmediate',
  ),
];

Aa4BuildAutomatonPayload _buildPayload(
  Fsm expected, {
  Fsm? source,
  List<String> inputAlphabet = const ['0', '1'],
}) => Aa4BuildAutomatonPayload(
  expectedFsm: expected,
  sourceFsm: source,
  tableRequirement: source != null,
  readyPresetsOnly: true,
  requireTransitionEndpoints: true,
  allowedTools: _buildTools,
  inputAlphabet: inputAlphabet,
  evaluationMode: FsmEvaluationMode.behavioral,
);

/// Aufgaben zum Ableiten von Tabellen aus den hinterlegten Referenzautomaten.
List<LessonTask> chapter5TableTasks() => [
  LessonTask(
    id: 'chapter5-tables-moore',
    prompt: 'chapter5.tables.moore.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'chapter5.tables.instruction',
    hint: 'chapter5.tables.moore.hint',
    payload: _buildPayload(chapter5TableMoore, source: chapter5TableMoore),
  ),
  LessonTask(
    id: 'chapter5-tables-mealy',
    prompt: 'chapter5.tables.mealy.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss4,
    instruction: 'chapter5.tables.instruction',
    hint: 'chapter5.tables.mealy.hint',
    payload: _buildPayload(
      chapter5TableMealy,
      source: chapter5TableMealy,
      inputAlphabet: const ['X=0,Y=0', 'X=0,Y=1', 'X=1'],
    ),
  ),
  LessonTask(
    id: 'chapter5-tables-practice-mealy',
    prompt: 'chapter5.tables.practice.prompt',
    type: LessonTaskType.buildFsm,
    kind: TaskKind.aa4BuildAutomaton,
    difficulty: TaskDifficulty.ss3,
    instruction: 'chapter5.tables.instruction',
    hint: 'chapter5.tables.practice.hint',
    payload: _buildPayload(
      chapter5TablePracticeMealy,
      source: chapter5TablePracticeMealy,
    ),
  ),
];

LessonTask _completionTask({
  required String id,
  required String prompt,
  required String hint,
  required Fsm partial,
  required Fsm expected,
}) => LessonTask(
  id: id,
  prompt: prompt,
  type: LessonTaskType.buildFsm,
  kind: TaskKind.aa8CompleteAutomaton,
  difficulty: TaskDifficulty.ss3,
  instruction: 'chapter5.completion.instruction',
  hint: hint,
  payload: Aa8CompleteAutomatonPayload(
    partialFsm: partial,
    expectedFsm: expected,
    readyPresetsOnly: true,
    allowedTools: _completionTools,
    inputAlphabet: const ['0', '1'],
    evaluationMode: FsmEvaluationMode.behavioral,
  ),
);

/// Vervollständigungsübungen mit eingeschränktem Editor und Vergleich zur Referenz.
List<LessonTask> chapter5CompletionTasks() => [
  _completionTask(
    id: 'chapter5-complete-moore',
    prompt: 'chapter5.completion.prompt',
    hint: 'chapter5.completion.hint',
    partial: chapter5MoorePartial,
    expected: chapter5Moore,
  ),
  _completionTask(
    id: 'chapter5-complete-moore-a',
    prompt: 'chapter5.completion.second.prompt',
    hint: 'chapter5.completion.second.hint',
    partial: chapter5CompletionPartialA,
    expected: chapter5CompletionMachineA,
  ),
  _completionTask(
    id: 'chapter5-complete-moore-b',
    prompt: 'chapter5.completion.third.prompt',
    hint: 'chapter5.completion.third.hint',
    partial: chapter5CompletionPartialB,
    expected: chapter5CompletionMachineB,
  ),
];

LessonTask _creationTask({
  required String id,
  required String prompt,
  required String instruction,
  required String hint,
  required Fsm expected,
  List<String> inputAlphabet = const ['0', '1'],
}) => LessonTask(
  id: id,
  prompt: prompt,
  type: LessonTaskType.buildFsm,
  kind: TaskKind.aa4BuildAutomaton,
  difficulty: TaskDifficulty.ss4,
  instruction: instruction,
  hint: hint,
  payload: _buildPayload(expected, inputAlphabet: inputAlphabet),
);

/// Konstruktionsübungen für selbst erstellte Automaten anhand vorgegebener Anforderungen.
List<LessonTask> chapter5CreationTasks() => [
  _creationTask(
    id: 'chapter5-create-mealy',
    prompt: 'chapter5.creation.prompt',
    instruction: 'chapter5.creation.instruction',
    hint: 'chapter5.creation.hint',
    expected: chapter5Mealy,
  ),
  _creationTask(
    id: 'chapter5-create-coffee-machine',
    prompt: 'chapter5.test.coffee.prompt',
    instruction: 'chapter5.test.coffee.instruction',
    hint: 'chapter5.test.coffee.hint',
    expected: chapter5CoffeeMachine,
    inputAlphabet: const ['coin', 'choose drink', 'cancel'],
  ),
  _creationTask(
    id: 'chapter5-create-washing-machine',
    prompt: 'chapter5.test.washingMachine.prompt',
    instruction: 'chapter5.test.washingMachine.instruction',
    hint: 'chapter5.test.washingMachine.hint',
    expected: chapter5WashingMachine,
    inputAlphabet: const ['start', 'wash done', 'rinse done', 'door opened'],
  ),
];

List<LessonTask> chapter5AnalysisTasks() => [
  LessonTask(
    id: 'chapter5-analysis-trace',
    prompt: 'chapter5.analysis.prompt',
    type: LessonTaskType.predictOutput,
    kind: TaskKind.aa7TraceState,
    difficulty: TaskDifficulty.ss3,
    instruction: 'chapter5.analysis.instruction',
    hint: 'chapter5.analysis.hint',
    payload: Aa7TraceStatePayload(
      fsm: chapter5Moore,
      inputSymbols: const ['0', '0', '0'],
      expectedStateIds: const ['q0', 'q1', 'q2', 'q3'],
    ),
  ),
];

/// Übungen zum Finden von Modellierungsfehlern und zum Nachverfolgen von Zustandsspuren.
List<LessonTask> chapter5DiagnosticsTasks() => [
  _choice(
    id: 'chapter5-diagnostics-determinism',
    prompt: 'chapter5.diagnostics.prompt',
    instruction: 'chapter5.diagnostics.instruction',
    hint: 'chapter5.diagnostics.hint',
    answers: const [
      'chapter5.answer.deterministic',
      'chapter5.answer.conflict',
    ],
    correct: 'chapter5.answer.conflict',
    illustration: chapter5Moore.copyWith(
      transitions: [
        ...chapter5Moore.transitions,
        const FsmTransition(fromStateId: 'q0', toStateId: 'q2', symbol: '0'),
      ],
    ),
  ),
  LessonTask(
    id: 'chapter5-diagnostics-missing-transition',
    prompt: 'chapter5.diagnostics.missingTransition.prompt',
    type: LessonTaskType.multipleChoice,
    kind: TaskKind.aa9Theory,
    difficulty: TaskDifficulty.ss3,
    concept: 'concept.transitions',
    answers: const ['q1', 'q2', 'q3'],
    correctAnswerId: 'q2',
    illustration: chapter5Moore.copyWith(
      transitions: [
        for (final transition in chapter5Moore.transitions)
          if (!(transition.fromStateId == 'q2' && transition.symbol == '1'))
            transition,
      ],
    ),
  ),
];

/// Bündelt die Prüfungsübungen in getrennte Themenlektionen ohne eigene Story.
List<Lesson> chapter5BonusLessons() => [
  Lesson(
    id: 'chapter5-theory',
    chapterId: 'chapter5',
    title: 'chapter5.lesson.theory.title',
    subtitle: 'chapter5.lesson.theory.subtitle',
    xpReward: 100,
    coinReward: 50,
    tasks: chapter5TheoryTasks(),
  ),
  Lesson(
    id: 'chapter5-tables',
    chapterId: 'chapter5',
    title: 'chapter5.lesson.tables.title',
    subtitle: 'chapter5.lesson.tables.subtitle',
    xpReward: 140,
    coinReward: 70,
    tasks: chapter5TableTasks(),
  ),
  Lesson(
    id: 'chapter5-completion',
    chapterId: 'chapter5',
    title: 'chapter5.lesson.completion.title',
    subtitle: 'chapter5.lesson.completion.subtitle',
    xpReward: 120,
    coinReward: 60,
    tasks: chapter5CompletionTasks(),
  ),
  Lesson(
    id: 'chapter5-creation',
    chapterId: 'chapter5',
    title: 'chapter5.lesson.creation.title',
    subtitle: 'chapter5.lesson.creation.subtitle',
    xpReward: 140,
    coinReward: 70,
    tasks: chapter5CreationTasks(),
  ),
  Lesson(
    id: 'chapter5-diagnostics',
    chapterId: 'chapter5',
    title: 'chapter5.lesson.diagnostics.title',
    subtitle: 'chapter5.lesson.diagnostics.subtitle',
    xpReward: 110,
    coinReward: 55,
    tasks: [...chapter5AnalysisTasks(), ...chapter5DiagnosticsTasks()],
  ),
];
