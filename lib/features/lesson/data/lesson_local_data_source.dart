import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:bachelor/features/lesson/domain/models/lesson.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_difficulty.dart';
import 'package:bachelor/features/lesson/domain/models/task_kind.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:bachelor/features/lesson/data/chapters/automata_creation_content.dart';
import 'package:bachelor/features/lesson/data/chapters/chapter4_content.dart';
import 'package:bachelor/features/lesson/data/chapters/chapter5_bonus_content.dart';

const _doorMealyFsm = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.mealy,
  states: [FsmState(id: 'q0', label: 'WAIT', x: 0.50, y: 0.55)],
  transitions: [
    FsmTransition(
      fromStateId: 'q0',
      toStateId: 'q0',
      symbol: 'person = 1 / OPEN DOOR',
    ),
    FsmTransition(
      fromStateId: 'q0',
      toStateId: 'q0',
      symbol: 'person = 0 / CLOSE DOOR',
    ),
  ],
);

/// Der durch die digitale Schaltung in Kapitel 2 dargestellte Automat.
///
/// Die Zustands-IDs entsprechen bewusst den drei gültigen Kodierungen der
/// Lektion: 00 -> S=0, 01 -> S=1 und 10 -> S=2.
const _chapter2CircuitFsm = Fsm(
  initialStateId: 's0',
  outputMode: FsmOutputMode.moore,
  states: [
    FsmState(id: 's0', label: 'S = 0 (00)', output: '0', x: 0.18, y: 0.52),
    FsmState(id: 's1', label: 'S = 1 (01)', output: '0', x: 0.50, y: 0.25),
    FsmState(id: 's2', label: 'S = 2 (10)', output: '1', x: 0.82, y: 0.52),
  ],
  transitions: [
    FsmTransition(fromStateId: 's0', toStateId: 's2', symbol: '0'),
    FsmTransition(fromStateId: 's0', toStateId: 's0', symbol: '1'),
    FsmTransition(fromStateId: 's1', toStateId: 's0', symbol: '0'),
    FsmTransition(fromStateId: 's1', toStateId: 's1', symbol: '1'),
    FsmTransition(fromStateId: 's2', toStateId: 's0', symbol: '0'),
    FsmTransition(fromStateId: 's2', toStateId: 's1', symbol: '1'),
  ],
);

/// Schaltung des Abschlusstests: S₀′ = A ∧ (S₁ ∧ S₀).
const _chapter2FinalAndCircuitFsm = Fsm(
  initialStateId: 's0',
  outputMode: FsmOutputMode.moore,
  states: [
    FsmState(id: 's0', label: 'S = 0 (00)', output: '0', x: 0.18, y: 0.52),
    FsmState(id: 's1', label: 'S = 1 (01)', output: '0', x: 0.50, y: 0.25),
    FsmState(id: 's2', label: 'S = 2 (10)', output: '1', x: 0.82, y: 0.52),
  ],
  transitions: [
    FsmTransition(fromStateId: 's0', toStateId: 's2', symbol: '0'),
    FsmTransition(fromStateId: 's0', toStateId: 's0', symbol: '1'),
    FsmTransition(fromStateId: 's1', toStateId: 's0', symbol: '0'),
    FsmTransition(fromStateId: 's1', toStateId: 's0', symbol: '1'),
    FsmTransition(fromStateId: 's2', toStateId: 's0', symbol: '0'),
    FsmTransition(fromStateId: 's2', toStateId: 's0', symbol: '1'),
  ],
);

/// Schaltung des Abschlusstests: S₁′ = Ā ∧ ¬S₁ ∧ S₀.
const _chapter2FinalMixedCircuitFsm = Fsm(
  initialStateId: 's0',
  outputMode: FsmOutputMode.moore,
  states: [
    FsmState(id: 's0', label: 'S = 0 (00)', output: '0', x: 0.18, y: 0.52),
    FsmState(id: 's1', label: 'S = 1 (01)', output: '0', x: 0.50, y: 0.25),
    FsmState(id: 's2', label: 'S = 2 (10)', output: '1', x: 0.82, y: 0.52),
  ],
  transitions: [
    FsmTransition(fromStateId: 's0', toStateId: 's0', symbol: '0'),
    FsmTransition(fromStateId: 's0', toStateId: 's0', symbol: '1'),
    FsmTransition(fromStateId: 's1', toStateId: 's2', symbol: '0'),
    FsmTransition(fromStateId: 's1', toStateId: 's1', symbol: '1'),
    FsmTransition(fromStateId: 's2', toStateId: 's0', symbol: '0'),
    FsmTransition(fromStateId: 's2', toStateId: 's1', symbol: '1'),
  ],
);

/// Schaltung des Abschlusstests mit XOR-Ausgangslogik.
const _chapter2FinalXorOutputCircuitFsm = Fsm(
  initialStateId: 's0',
  outputMode: FsmOutputMode.moore,
  states: [
    FsmState(id: 's0', label: 'S = 0 (00)', output: '0', x: 0.18, y: 0.52),
    FsmState(id: 's1', label: 'S = 1 (01)', output: '1', x: 0.50, y: 0.25),
    FsmState(id: 's2', label: 'S = 2 (10)', output: '1', x: 0.82, y: 0.52),
  ],
  transitions: [
    FsmTransition(fromStateId: 's0', toStateId: 's2', symbol: '0'),
    FsmTransition(fromStateId: 's0', toStateId: 's0', symbol: '1'),
    FsmTransition(fromStateId: 's1', toStateId: 's0', symbol: '0'),
    FsmTransition(fromStateId: 's1', toStateId: 's1', symbol: '1'),
    FsmTransition(fromStateId: 's2', toStateId: 's0', symbol: '0'),
    FsmTransition(fromStateId: 's2', toStateId: 's1', symbol: '1'),
  ],
);

/* Frühere Lektionsdaten der entfernten Kapitel 3-6.
const _turnstileMooreFsm = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.moore,
  states: [
    FsmState(id: 'q0', label: 'LOCKED', output: 'STOP', x: 0.24, y: 0.52),
    FsmState(id: 'q1', label: 'UNLOCKED', output: 'GO', x: 0.76, y: 0.52),
  ],
  transitions: [
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'coin'),
    FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'passage'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q1', symbol: 'coin'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'passage'),
  ],
);

const _turnstileMealyFsm = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.mealy,
  states: [
    FsmState(id: 'q0', label: 'LOCKED', x: 0.24, y: 0.52),
    FsmState(id: 'q1', label: 'UNLOCKED', x: 0.76, y: 0.52),
  ],
  transitions: [
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'coin / OPEN'),
    FsmTransition(
      fromStateId: 'q0',
      toStateId: 'q0',
      symbol: 'passage / ALARM',
    ),
    FsmTransition(
      fromStateId: 'q1',
      toStateId: 'q1',
      symbol: 'coin / KEEP OPEN',
    ),
    FsmTransition(
      fromStateId: 'q1',
      toStateId: 'q0',
      symbol: 'passage / CLOSE',
    ),
  ],
);

const _trafficMooreFsm = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.moore,
  states: [
    FsmState(id: 'q0', label: 'RED', output: 'STOP', x: 0.18, y: 0.52),
    FsmState(id: 'q1', label: 'GREEN', output: 'GO', x: 0.50, y: 0.25),
    FsmState(id: 'q2', label: 'YELLOW', output: 'SLOW', x: 0.82, y: 0.52),
  ],
  transitions: [
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'timer'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: 'timer'),
    FsmTransition(fromStateId: 'q2', toStateId: 'q0', symbol: 'timer'),
  ],
);
*/

// Gilt für alle Einstiegsfragen; die Ausgabenotation wurde noch nicht eingeführt.
const _introTrafficFsm = Fsm(
  initialStateId: 'q0',
  states: [
    FsmState(id: 'q0', label: 'RED', x: 0.18, y: 0.25),
    FsmState(id: 'q1', label: 'RED-YELLOW', x: 0.82, y: 0.25),
    FsmState(id: 'q2', label: 'GREEN', x: 0.82, y: 0.75),
    FsmState(id: 'q3', label: 'YELLOW', x: 0.18, y: 0.75),
  ],
  transitions: [
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: '60s'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: '10s'),
    FsmTransition(fromStateId: 'q2', toStateId: 'q3', symbol: '60s'),
    FsmTransition(fromStateId: 'q3', toStateId: 'q0', symbol: '10s'),
  ],
);

/// Stellt den lokalen Lektionskatalog mit Aufgaben und Beispielautomaten zusammen.
/// Texte werden überwiegend über Übersetzungsschlüssel referenziert; stabile IDs
/// verbinden den Katalog mit Navigation und gespeichertem Lernfortschritt.
class LessonLocalDataSource {
  const LessonLocalDataSource();

  Lesson? getLessonById(String lessonId) {
    for (final lesson in getLessons()) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  List<Lesson> getLessons() {
    final chapterLessons = const [
      Lesson(
        id: 'intro',
        title: 'lesson.intro.title',
        subtitle: 'lesson.intro.subtitle',
        xpReward: 100,
        coinReward: 60,
        tasks: [
          LessonTask(
            id: 'intro-state-count',
            showStateIdentifiers: false,
            illustration: _introTrafficFsm,
            prompt: 'task.intro.stateCount.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss1,
            answers: ['answer.3', 'answer.4', 'answer.5'],
            correctAnswerId: 'answer.4',
            concept: 'concept.states',
            instruction: 'task.intro.stateCount.instruction',
            hint: 'task.intro.stateCount.hint',
            feedbackByAnswer: {
              'answer.3': 'task.intro.stateCount.feedback.3',
              'answer.5': 'task.intro.stateCount.feedback.5',
            },
          ),
          LessonTask(
            id: 'intro-reset',
            showStateIdentifiers: false,
            prompt: 'task.intro.reset.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss1,
            kind: TaskKind.aa3ValidateAutomaton,
            concept: 'concept.startState',
            instruction: 'task.intro.reset.instruction',
            hint: 'task.intro.reset.hint',
            payload: Aa3ValidateAutomatonPayload(
              fsm: _introTrafficFsm,
              isCorrectAutomaton: true,
            ),
          ),
          LessonTask(
            id: 'intro-follow-transition',
            showStateIdentifiers: false,
            illustration: _introTrafficFsm,
            prompt: 'task.intro.followTransition.prompt',
            type: LessonTaskType.predictOutput,
            difficulty: TaskDifficulty.ss2,
            answers: [
              'answer.redYellowState',
              'answer.greenState',
              'answer.yellowState',
            ],
            correctAnswerId: 'answer.redYellowState',
            concept: 'concept.currentState',
            instruction: 'task.intro.followTransition.instruction',
            hint: 'task.intro.followTransition.hint',
            feedbackByAnswer: {
              'answer.greenState': 'task.intro.followTransition.feedback.green',
              'answer.yellowState':
                  'task.intro.followTransition.feedback.yellow',
            },
          ),
        ],
      ),
      Lesson(
        id: 'states',
        title: 'lesson.states.title',
        subtitle: 'lesson.states.subtitle',
        xpReward: 80,
        coinReward: 40,
        tasks: [
          LessonTask(
            id: 'states-diagram-nodes',
            prompt: 'task.states.nodes.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss1,
            kind: TaskKind.aa9Theory,
            concept: 'concept.states',
            instruction: 'task.states.nodes.instruction',
            hint: 'task.states.nodes.hint',
            payload: DiagramSelectionPayload(
              fsm: Fsm(
                initialStateId: 'q0',
                states: [
                  FsmState(id: 'q0', label: 'FIRST', x: 0.18, y: 0.28),
                  FsmState(id: 'q1', label: 'SECOND', x: 0.82, y: 0.28),
                  FsmState(id: 'q2', label: 'THIRD', x: 0.50, y: 0.80),
                ],
                transitions: [
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q1',
                    symbol: 'a',
                  ),
                  FsmTransition(
                    fromStateId: 'q1',
                    toStateId: 'q2',
                    symbol: 'b',
                  ),
                ],
              ),
              targets: [
                DiagramSelectionTarget(id: 'q0', label: 'answer.nodeQ0'),
                DiagramSelectionTarget(
                  id: 'transition-a',
                  label: 'answer.transitionA',
                ),
                DiagramSelectionTarget(id: 'q1', label: 'answer.nodeQ1'),
                DiagramSelectionTarget(id: 'reset', label: 'answer.resetArrow'),
                DiagramSelectionTarget(id: 'q2', label: 'answer.nodeQ2'),
              ],
              correctTargetIds: {'q0', 'q1', 'q2'},
            ),
          ),
          LessonTask(
            id: 'states-initial',
            prompt: 'task.states.initial.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss2,
            kind: TaskKind.aa3ValidateAutomaton,
            concept: 'concept.startState',
            instruction: 'task.states.initial.instruction',
            hint: 'task.states.initial.hint',
            answers: ['answer.false', 'answer.true'],
            payload: Aa3ValidateAutomatonPayload(
              fsm: Fsm(
                initialStateId: 'q0',
                states: [
                  FsmState(id: 'q0', label: 'LOCKED', output: 'STOP', x: 0.25),
                  FsmState(id: 'q1', label: 'UNLOCKED', output: 'GO', x: 0.75),
                ],
                transitions: [
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q1',
                    symbol: 'coin',
                  ),
                  FsmTransition(
                    fromStateId: 'q1',
                    toStateId: 'q0',
                    symbol: 'passage',
                  ),
                ],
              ),
              isCorrectAutomaton: true,
            ),
          ),
          LessonTask(
            id: 'states-trace',
            prompt: 'task.states.trace.prompt',
            type: LessonTaskType.predictOutput,
            difficulty: TaskDifficulty.ss2,
            answers: [
              'answer.unlockedState',
              'answer.bothStates',
              'answer.lockedState',
            ],
            correctAnswerId: 'answer.lockedState',
            concept: 'concept.currentState',
            instruction: 'task.states.trace.instruction',
            hint: 'task.states.trace.hint',
            illustration: Fsm(
              initialStateId: 'q0',
              states: [
                FsmState(id: 'q0', label: 'LOCKED', x: 0.25, y: 0.55),
                FsmState(id: 'q1', label: 'UNLOCKED', x: 0.75, y: 0.55),
              ],
              transitions: [
                FsmTransition(
                  fromStateId: 'q0',
                  toStateId: 'q1',
                  symbol: 'coin',
                ),
                FsmTransition(
                  fromStateId: 'q1',
                  toStateId: 'q0',
                  symbol: 'passage',
                ),
              ],
            ),
            illustrationLegendKeys: [
              'statesStory.meaning.q0',
              'statesStory.meaning.q1',
            ],
            feedbackByAnswer: {
              'answer.unlockedState': 'task.states.trace.feedback.unlocked',
              'answer.bothStates': 'task.states.trace.feedback.both',
            },
          ),
        ],
      ),
      Lesson(
        id: 'transitions',
        title: 'lesson.transitions.title',
        subtitle: 'lesson.transitions.subtitle',
        xpReward: 100,
        coinReward: 50,
        tasks: [
          LessonTask(
            id: 'transitions-output-placement',
            prompt: 'task.transitions.outputPlacement.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss1,
            kind: TaskKind.aa9Theory,
            concept: 'concept.mooreMealy',
            instruction: 'task.transitions.outputPlacement.instruction',
            hint: 'task.transitions.outputPlacement.hint',
            answers: [
              'answer.outputBelongsToTransition',
              'answer.outputBelongsToState',
              'answer.outputOnlyAtEnd',
            ],
            correctAnswerId: 'answer.outputBelongsToState',
          ),
          LessonTask(
            id: 'transitions-find-mealy-errors',
            prompt: 'task.transitions.findErrors.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss2,
            kind: TaskKind.aa2FindError,
            concept: 'concept.errorDiagnosis',
            instruction: 'task.transitions.findErrors.instruction',
            hint: 'task.transitions.findErrors.hint',
            payload: Aa2FindErrorPayload(
              fsm: Fsm(
                initialStateId: 'q0',
                states: [FsmState(id: 'q0', label: 'WAIT', x: 0.50, y: 0.55)],
                transitions: [
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q0',
                    symbol: 'person = 1 / CLOSE DOOR',
                  ),
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q0',
                    symbol: 'person = 0 / OPEN DOOR',
                  ),
                ],
              ),
              targets: [
                FsmErrorTarget(
                  id: 'q0::person = 1 / CLOSE DOOR::q0',
                  type: FsmElementType.transition,
                  label: 'answer.personOneCloseTransition',
                ),
                FsmErrorTarget(
                  id: 'q0::person = 0 / OPEN DOOR::q0',
                  type: FsmElementType.transition,
                  label: 'answer.personZeroOpenTransition',
                ),
                FsmErrorTarget(
                  id: 'q0',
                  type: FsmElementType.state,
                  label: 'answer.waitState',
                ),
                FsmErrorTarget(
                  id: 'reset',
                  type: FsmElementType.initialMarker,
                  label: 'answer.resetArrow',
                ),
              ],
              errorTargetIds: {
                'q0::person = 1 / CLOSE DOOR::q0',
                'q0::person = 0 / OPEN DOOR::q0',
              },
            ),
          ),
          LessonTask(
            id: 'transitions-complete-mealy',
            prompt: 'task.transitions.completeMealy.prompt',
            type: LessonTaskType.buildFsm,
            difficulty: TaskDifficulty.ss3,
            kind: TaskKind.aa8CompleteAutomaton,
            concept: 'concept.mooreMealy',
            instruction: 'task.transitions.completeMealy.instruction',
            hint: 'task.transitions.completeMealy.hint',
            payload: Aa8CompleteAutomatonPayload(
              partialFsm: Fsm(
                initialStateId: 'q0',
                outputMode: FsmOutputMode.mealy,
                states: [FsmState(id: 'q0', label: 'WAIT', x: 0.50, y: 0.55)],
                transitions: [
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q0',
                    symbol: 'person = 1 / OPEN DOOR',
                  ),
                ],
              ),
              expectedFsm: _doorMealyFsm,
              allowedTools: {
                FsmEditorTool.select,
                FsmEditorTool.addTransition,
                FsmEditorTool.delete,
              },
              readyPresetsOnly: true,
            ),
          ),
        ],
      ),
    ];

    final chapter2Lessons = const [
      Lesson(
        id: 'chapter2-gates-review',
        chapterId: 'chapter2',
        title: 'lesson.chapter2.gates.title',
        subtitle: 'lesson.chapter2.gates.subtitle',
        xpReward: 70,
        coinReward: 35,
        storyId: 'chapter2-gates-review',
        tasks: [
          LessonTask(
            id: 'chapter2-gates-check',
            prompt: 'task.chapter2.gatesCheck.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss1,
            kind: TaskKind.aa9Theory,
            concept: 'concept.digitalGates',
            instruction: 'task.chapter2.gatesCheck.instruction',
            hint: 'task.chapter2.gatesCheck.hint',
            answers: ['answer.xorOne', 'answer.xorZero', 'answer.andOne'],
            feedbackByAnswer: {
              'answer.xorZero': 'task.chapter2.gatesCheck.feedback.xorZero',
              'answer.andOne': 'task.chapter2.gatesCheck.feedback.andOne',
            },
            correctAnswerId: 'answer.xorOne',
          ),
          LessonTask(
            id: 'chapter2-gates-and',
            prompt: 'task.chapter2.gatesAnd.prompt',
            type: LessonTaskType.multipleChoice,
            kind: TaskKind.aa9Theory,
            concept: 'concept.digitalGates',
            instruction: 'task.chapter2.gatesAnd.instruction',
            hint: 'task.chapter2.gatesAnd.hint',
            answers: ['answer.false', 'answer.true'],
            correctAnswerId: 'answer.false',
          ),
          LessonTask(
            id: 'chapter2-gates-or',
            prompt: 'task.chapter2.gatesOr.prompt',
            type: LessonTaskType.multipleChoice,
            kind: TaskKind.aa9Theory,
            concept: 'concept.digitalGates',
            instruction: 'task.chapter2.gatesOr.instruction',
            hint: 'task.chapter2.gatesOr.hint',
            answers: ['answer.false', 'answer.true'],
            correctAnswerId: 'answer.true',
          ),
        ],
      ),
      Lesson(
        id: 'chapter_2',
        chapterId: 'chapter2',
        title: 'lesson.chapter2.diagram.title',
        subtitle: 'lesson.chapter2.diagram.subtitle',
        xpReward: 110,
        coinReward: 60,
        storyId: 'chapter_2',
        tasks: [
          LessonTask(
            id: 'chapter2-state-code',
            prompt: 'task.chapter2.stateCode.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss1,
            kind: TaskKind.aa9Theory,
            concept: 'concept.states',
            instruction: 'task.chapter2.stateCode.instruction',
            hint: 'task.chapter2.stateCode.hint',
            answers: [
              'answer.stateCodeTwo',
              'answer.stateCodeOne',
              'answer.stateCodeInvalid',
            ],
            correctAnswerId: 'answer.stateCodeTwo',
          ),
          LessonTask(
            id: 'chapter2-trace',
            prompt: 'task.chapter2.trace.prompt',
            type: LessonTaskType.predictOutput,
            difficulty: TaskDifficulty.ss2,
            kind: TaskKind.aa7TraceState,
            concept: 'concept.currentState',
            instruction: 'task.chapter2.trace.instruction',
            hint: 'task.chapter2.trace.hint',
            payload: Aa7TraceStatePayload(
              fsm: _chapter2CircuitFsm,
              inputSymbols: ['0', '1', '0', '1'],
              expectedStateIds: ['s0', 's2', 's1', 's0', 's0'],
            ),
          ),
          LessonTask(
            id: 'chapter2-build-table',
            prompt: 'task.chapter2.buildTable.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss2,
            kind: TaskKind.aa6BuildTable,
            concept: 'concept.transitionTable',
            instruction: 'task.chapter2.buildTable.instruction',
            hint: 'task.chapter2.buildTable.hint',
            payload: Aa6BuildTablePayload(
              sourceFsm: _chapter2CircuitFsm,
              circuitDiagramId: 'practice-x',
              inputSymbols: ['0', '1'],
              expectedRows: [
                FsmTableRow(
                  stateId: 's0',
                  transitions: {'0': 's2', '1': 's0'},
                  output: '0',
                ),
                FsmTableRow(
                  stateId: 's1',
                  transitions: {'0': 's0', '1': 's1'},
                  output: '0',
                ),
                FsmTableRow(
                  stateId: 's2',
                  transitions: {'0': 's0', '1': 's1'},
                  output: '1',
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    return [
      ...chapterLessons,
      Lesson(
        id: 'chapter_test',
        title: 'lesson.chapterTest.title',
        subtitle: 'lesson.chapterTest.subtitle',
        xpReward: 150,
        coinReward: 100,
        isPracticalTest: true,
        minimumCorrectRatio: 0.6667,
        timeLimitSeconds: 300,
        tasks: [
          LessonTask(
            id: 'chapter1-final-determinism',
            prompt: 'chapter1.final.determinism.prompt',
            type: LessonTaskType.multipleChoice,
            kind: TaskKind.aa9Theory,
            concept: 'concept.determinism',
            answers: [
              'answer.oneTransitionPerInput',
              'answer.anyNumberTransitions',
              'answer.noTransitionsNeeded',
            ],
            correctAnswerId: 'answer.oneTransitionPerInput',
          ),
          LessonTask(
            id: 'chapter1-final-moore-output',
            prompt: 'chapter1.final.mooreOutput.prompt',
            type: LessonTaskType.multipleChoice,
            kind: TaskKind.aa9Theory,
            concept: 'concept.mooreOutput',
            answers: ['answer.0', 'answer.1'],
            correctAnswerId: 'answer.1',
          ),
          LessonTask(
            id: 'chapter1-final-trace',
            prompt: 'chapter1.final.trace.prompt',
            type: LessonTaskType.predictOutput,
            kind: TaskKind.aa7TraceState,
            concept: 'concept.currentState',
            payload: Aa7TraceStatePayload(
              fsm: Fsm(
                initialStateId: 'q0',
                states: [
                  FsmState(id: 'q0', label: 'IDLE'),
                  FsmState(id: 'q1', label: 'PREPARED'),
                  FsmState(id: 'q2', label: 'ACTIVE'),
                ],
                transitions: [
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q0',
                    symbol: '0',
                  ),
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q1',
                    symbol: '1',
                  ),
                  FsmTransition(
                    fromStateId: 'q1',
                    toStateId: 'q2',
                    symbol: '0',
                  ),
                  FsmTransition(
                    fromStateId: 'q1',
                    toStateId: 'q1',
                    symbol: '1',
                  ),
                  FsmTransition(
                    fromStateId: 'q2',
                    toStateId: 'q0',
                    symbol: '0',
                  ),
                  FsmTransition(
                    fromStateId: 'q2',
                    toStateId: 'q0',
                    symbol: '1',
                  ),
                ],
              ),
              inputSymbols: ['1', '0'],
              expectedStateIds: ['q0', 'q1', 'q2'],
            ),
          ),
          LessonTask(
            id: 'chapter1-final-completeness',
            prompt: 'chapter1.final.complete.prompt',
            type: LessonTaskType.multipleChoice,
            kind: TaskKind.aa3ValidateAutomaton,
            concept: 'concept.transitions',
            answers: ['answer.true', 'answer.false'],
            correctAnswerId: 'answer.false',
            payload: Aa3ValidateAutomatonPayload(
              fsm: Fsm(
                initialStateId: 'q0',
                states: [
                  FsmState(id: 'q0', label: 'READY'),
                  FsmState(id: 'q1', label: 'RUNNING'),
                ],
                transitions: [
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q1',
                    symbol: 'start',
                  ),
                  FsmTransition(
                    fromStateId: 'q1',
                    toStateId: 'q0',
                    symbol: 'stop',
                  ),
                ],
              ),
              isCorrectAutomaton: false,
            ),
          ),
          LessonTask(
            id: 'chapter1-final-conflict',
            prompt: 'chapter1.final.conflict.prompt',
            type: LessonTaskType.multipleChoice,
            kind: TaskKind.aa2FindError,
            concept: 'concept.determinism',
            payload: Aa2FindErrorPayload(
              fsm: Fsm(
                initialStateId: 'q0',
                states: [
                  FsmState(id: 'q0', label: 'IDLE'),
                  FsmState(id: 'q1', label: 'READY'),
                  FsmState(id: 'q2', label: 'ACTIVE'),
                ],
                transitions: [
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q1',
                    symbol: '0',
                  ),
                  FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q2',
                    symbol: '0',
                  ),
                  FsmTransition(
                    fromStateId: 'q1',
                    toStateId: 'q2',
                    symbol: '1',
                  ),
                ],
              ),
              targets: [
                FsmErrorTarget(
                  id: 'q0::0::q1',
                  type: FsmElementType.transition,
                  label: 'chapter1.final.edge.q0q1',
                ),
                FsmErrorTarget(
                  id: 'q0::0::q2',
                  type: FsmElementType.transition,
                  label: 'chapter1.final.edge.q0q2',
                ),
                FsmErrorTarget(
                  id: 'q1::1::q2',
                  type: FsmElementType.transition,
                  label: 'chapter1.final.edge.q1q2',
                ),
              ],
              errorTargetIds: {'q0::0::q1', 'q0::0::q2'},
            ),
          ),
        ],
      ),
      ...chapter2Lessons,
      Lesson(
        id: 'chapter_2_test',
        chapterId: 'chapter2',
        title: 'lesson.chapterTest.title',
        subtitle: 'lesson.chapter2.testSubtitle',
        xpReward: 180,
        coinReward: 120,
        isPracticalTest: true,
        minimumCorrectRatio: 0.6667,
        timeLimitSeconds: 900,
        tasks: [
          LessonTask(
            id: 'chapter2-final-and-table',
            prompt: 'chapter2.final.andTable.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss3,
            kind: TaskKind.aa6BuildTable,
            concept: 'concept.transitionTable',
            instruction: 'task.chapter2.buildTable.instruction',
            hint: 'task.chapter2.buildTable.hint',
            payload: Aa6BuildTablePayload(
              sourceFsm: _chapter2FinalAndCircuitFsm,
              circuitDiagramId: 'final-and-next-state',
              inputSymbols: ['0', '1'],
              expectedRows: [
                FsmTableRow(
                  stateId: 's0',
                  transitions: {'0': 's2', '1': 's0'},
                  output: '0',
                ),
                FsmTableRow(
                  stateId: 's1',
                  transitions: {'0': 's0', '1': 's0'},
                  output: '0',
                ),
                FsmTableRow(
                  stateId: 's2',
                  transitions: {'0': 's0', '1': 's0'},
                  output: '1',
                ),
              ],
            ),
          ),
          LessonTask(
            id: 'chapter2-final-mixed-table',
            prompt: 'chapter2.final.mixedTable.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss3,
            kind: TaskKind.aa6BuildTable,
            concept: 'concept.transitionTable',
            instruction: 'task.chapter2.buildTable.instruction',
            hint: 'task.chapter2.buildTable.hint',
            payload: Aa6BuildTablePayload(
              sourceFsm: _chapter2FinalMixedCircuitFsm,
              circuitDiagramId: 'final-mixed-state',
              inputSymbols: ['0', '1'],
              expectedRows: [
                FsmTableRow(
                  stateId: 's0',
                  transitions: {'0': 's0', '1': 's0'},
                  output: '0',
                ),
                FsmTableRow(
                  stateId: 's1',
                  transitions: {'0': 's2', '1': 's1'},
                  output: '0',
                ),
                FsmTableRow(
                  stateId: 's2',
                  transitions: {'0': 's0', '1': 's1'},
                  output: '1',
                ),
              ],
            ),
          ),
          LessonTask(
            id: 'chapter2-final-xor-output-table',
            prompt: 'chapter2.final.xorTable.prompt',
            type: LessonTaskType.multipleChoice,
            difficulty: TaskDifficulty.ss3,
            kind: TaskKind.aa6BuildTable,
            concept: 'concept.transitionTable',
            instruction: 'task.chapter2.buildTable.instruction',
            hint: 'task.chapter2.buildTable.hint',
            payload: Aa6BuildTablePayload(
              sourceFsm: _chapter2FinalXorOutputCircuitFsm,
              circuitDiagramId: 'final-xor-output',
              inputSymbols: ['0', '1'],
              expectedRows: [
                FsmTableRow(
                  stateId: 's0',
                  transitions: {'0': 's2', '1': 's0'},
                  output: '0',
                ),
                FsmTableRow(
                  stateId: 's1',
                  transitions: {'0': 's0', '1': 's1'},
                  output: '1',
                ),
                FsmTableRow(
                  stateId: 's2',
                  transitions: {'0': 's0', '1': 's1'},
                  output: '1',
                ),
              ],
            ),
          ),
          LessonTask(
            id: 'chapter2-final-state-bits',
            prompt: 'chapter2.final.stateBits.prompt',
            type: LessonTaskType.multipleChoice,
            kind: TaskKind.aa9Theory,
            concept: 'concept.states',
            answers: ['2', '3', '4'],
            correctAnswerId: '4',
          ),
          LessonTask(
            id: 'chapter2-final-xor-equal-inputs',
            prompt: 'chapter2.final.xor.prompt',
            type: LessonTaskType.multipleChoice,
            kind: TaskKind.aa9Theory,
            concept: 'concept.digitalGates',
            answers: ['answer.xorOne', 'answer.xorZero', 'answer.andOne'],
            correctAnswerId: 'answer.xorZero',
          ),
        ],
      ),
      Lesson(
        id: 'chapter4-completion',
        chapterId: 'chapter3',
        title: 'lesson.chapter4.title',
        subtitle: 'lesson.chapter4.subtitle',
        xpReward: 150,
        coinReward: 80,
        storyId: 'chapter4-completion',
        tasks: chapter4MainTasks(),
      ),
      Lesson(
        id: 'chapter_4_test',
        chapterId: 'chapter3',
        title: 'lesson.chapterTest.title',
        subtitle: 'lesson.chapter4.testSubtitle',
        xpReward: 220,
        coinReward: 140,
        isPracticalTest: true,
        minimumCorrectRatio: 0.6667,
        timeLimitSeconds: 900,
        tasks: chapter4FinalTasks(),
      ),
      ...automataCreationLessons(),
      ...chapter5BonusLessons(),
    ];
  }
}
