import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_theme.dart';
import 'package:bachelor/core/widgets/fsm_tables.dart';
import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_validator.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/widgets/fsm_workspace.dart';
import 'package:bachelor/features/lesson/data/chapters/chapter5_bonus_content.dart';
import 'package:bachelor/features/lesson/domain/logic/task_action_alphabet.dart';
import 'package:bachelor/features/lesson/domain/logic/task_evaluator.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_kind.dart';
import 'package:bachelor/features/lesson/domain/models/task_feedback.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:bachelor/features/lesson/domain/models/task_submission.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_task_interaction.dart';
import 'package:bachelor/features/lesson/presentation/widgets/task_feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _machine = Fsm(
  initialStateId: 'q0',
  states: [
    FsmState(id: 'q0', label: 'OFF', output: '0', x: .25, y: .5),
    FsmState(id: 'q1', label: 'ON', output: '1', x: .75, y: .5),
  ],
  transitions: [
    FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '0'),
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: '1'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q1', symbol: '0'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: '1'),
  ],
);

Fsm get _incomplete => _machine.copyWith(
  transitions: _machine.transitions.where((t) => t.id != 'q0::1::q1').toList(),
);

LessonTask _task(Fsm initial) => LessonTask(
  id: 'structure-feedback',
  prompt: 'prompt',
  type: LessonTaskType.buildFsm,
  kind: TaskKind.aa8CompleteAutomaton,
  payload: Aa8CompleteAutomatonPayload(
    partialFsm: initial,
    expectedFsm: _machine,
    inputAlphabet: const ['0', '1'],
    evaluationMode: FsmEvaluationMode.behavioral,
  ),
);

Fsm _renamed(Fsm fsm) {
  String rename(String id) => 'renamed_$id';
  return fsm.copyWith(
    initialStateId: rename(fsm.initialStateId!),
    states: [
      for (final s in fsm.states)
        s.copyWith(id: rename(s.id), label: rename(s.id)),
    ],
    transitions: [
      for (final t in fsm.transitions)
        t.copyWith(
          fromStateId: rename(t.fromStateId),
          toStateId: rename(t.toStateId),
        ),
    ],
  );
}

void main() {
  const validator = FsmValidator();
  const evaluator = TaskEvaluator();

  test('an incomplete deterministic model is not called nondeterministic', () {
    expect(validator.validate(_incomplete), isEmpty);
    final issues = validator.validate(
      _incomplete,
      inputAlphabet: ['0', '1'],
      requireTotal: true,
    );
    expect(issues, hasLength(1));
    expect(issues.single.type, FsmValidationIssueType.missingTransition);
    expect(issues.single.stateId, 'q0');
    expect(issues.single.inputSymbol, '1');
  });

  test('two alternatives for one state and input form one conflict', () {
    final conflict = _machine.copyWith(
      transitions: [
        ..._machine.transitions,
        const FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '1'),
      ],
    );
    final issues = validator.validate(
      conflict,
      inputAlphabet: ['0', '1'],
      requireTotal: true,
    );
    expect(issues, hasLength(1));
    expect(
      issues.single.type,
      FsmValidationIssueType.nondeterministicTransition,
    );
    expect(issues.single.stateId, 'q0');
    expect(issues.single.inputSymbol, '1');
  });

  test('an extra symbol outside the declared alphabet cannot pass', () {
    final actual = _machine.copyWith(
      transitions: [
        ..._machine.transitions,
        const FsmTransition(
          fromStateId: 'q0',
          toStateId: 'q0',
          symbol: 'other',
        ),
      ],
    );
    final result = evaluator.evaluate(
      _task(_machine),
      FsmTaskSubmission(actual),
    );
    expect(result.isCorrect, isFalse);
    expect(result.feedback!.issues.single.code, 'unknownInputSymbol');
  });

  test('diagnosis survives evaluation and uses displayed letter actions', () {
    final task = _task(_incomplete);
    final result = evaluator.evaluate(task, FsmTaskSubmission(_incomplete));
    expect(result.isCorrect, isFalse);
    final issue = TaskActionAlphabet(
      task,
    ).feedback(result.feedback)!.issues.single;
    expect(issue.code, 'missingTransition');
    expect(issue.targetId, 'q0');
    expect(issue.args, {'state': 'q0', 'input': 'b'});
    for (final language in AppLanguage.values) {
      final message = translate(
        language,
        issue.localizationKey!,
        args: issue.args,
      );
      expect(message, contains('q0'));
      expect(message, contains('b'));
      expect(message, isNot(contains('{input}')));
      expect(
        message,
        isNot(contains('q1')),
        reason: 'Do not reveal the target state.',
      );
    }
  });

  test(
    'valid equivalent models pass, output errors remain different from shape errors',
    () {
      final task = _task(_machine);
      expect(
        evaluator
            .evaluate(task, FsmTaskSubmission(_renamed(_machine)))
            .isCorrect,
        isTrue,
      );
      final wrongInitialOutput = _machine.copyWith(
        states: [
          _machine.states.first.copyWith(output: '1'),
          _machine.states.last,
        ],
      );
      final result = evaluator.evaluate(
        task,
        FsmTaskSubmission(wrongInitialOutput),
      );
      expect(result.isCorrect, isFalse);
      expect(result.feedback!.issues.single.code, 'behaviorMismatch');
    },
  );

  test(
    'Mealy outputs belong to transitions and conflicts are grouped by input',
    () {
      final mealy = _machine.copyWith(
        outputMode: FsmOutputMode.mealy,
        transitions: [
          for (final t in _machine.transitions)
            t.copyWith(symbol: '${t.inputSymbol} / 0'),
        ],
      );
      expect(
        validator.validate(
          mealy,
          inputAlphabet: ['0', '1'],
          requireTotal: true,
        ),
        isEmpty,
      );
      final conflict = mealy.copyWith(
        transitions: [
          ...mealy.transitions,
          const FsmTransition(
            fromStateId: 'q0',
            toStateId: 'q0',
            symbol: '1 / 1',
          ),
        ],
      );
      expect(
        validator.validate(conflict).single.type,
        FsmValidationIssueType.nondeterministicTransition,
      );
    },
  );

  for (final task in [
    ...chapter5TableTasks(),
    ...chapter5CompletionTasks(),
    ...chapter5CreationTasks(),
  ]) {
    test(
      '${task.id}: complete reference and renamed equivalent solution pass',
      () {
        final payload = task.payload!;
        final (expected, alphabet, mode) = switch (payload) {
          Aa4BuildAutomatonPayload p => (
            p.expectedFsm,
            p.inputAlphabet,
            p.evaluationMode,
          ),
          Aa8CompleteAutomatonPayload p => (
            p.expectedFsm,
            p.inputAlphabet,
            p.evaluationMode,
          ),
          _ => throw StateError('Expected an FSM task'),
        };
        expect(mode, FsmEvaluationMode.behavioral);
        expect(
          validator.validate(
            expected,
            inputAlphabet: alphabet,
            requireTotal: true,
          ),
          isEmpty,
        );
        expect(
          evaluator
              .evaluate(task, FsmTaskSubmission(_renamed(expected)))
              .isCorrect,
          isTrue,
        );
        final missing = expected.copyWith(
          transitions: expected.transitions.skip(1).toList(),
        );
        final result = evaluator.evaluate(task, FsmTaskSubmission(missing));
        expect(result.isCorrect, isFalse);
        expect(
          result.feedback!.issues.map((i) => i.code),
          contains('missingTransition'),
        );
      },
    );
  }

  test('every table construction task actually requests tables', () {
    for (final task in chapter5TableTasks()) {
      expect(
        (task.payload! as Aa4BuildAutomatonPayload).tableRequirement,
        isTrue,
      );
    }
  });

  testWidgets('Mealy source tables include the transition outputs', (
    tester,
  ) async {
    final mealy = _machine.copyWith(
      outputMode: FsmOutputMode.mealy,
      transitions: [
        for (final t in _machine.transitions)
          t.copyWith(
            symbol:
                '${t.inputSymbol} / ${t.inputSymbol == '0' ? 'WAIT' : 'OPEN'}',
          ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: FsmTransitionTable(fsm: mealy, inputAlphabet: const ['0', '1']),
        ),
      ),
    );
    expect(find.text('Y'), findsOneWidget);
    expect(find.text('WAIT'), findsNWidgets(2));
    expect(find.text('OPEN'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  for (final conflict in [false, true]) {
    testWidgets(
      'feedback after submission marks ${conflict ? 'all conflicting transitions' : 'the incomplete state'} and clears after editing',
      (tester) async {
        final initial = conflict
            ? _machine.copyWith(
                transitions: [
                  ..._machine.transitions,
                  const FsmTransition(
                    fromStateId: 'q0',
                    toStateId: 'q0',
                    symbol: '1',
                  ),
                ],
              )
            : _incomplete;
        final task = _task(initial);
        StructuredTaskFeedback? feedback;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: AppLocalizations(
              language: AppLanguage.en,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (context, setState) => LessonTaskInteraction(
                      task: task,
                      enabled: true,
                      feedback: feedback,
                      onEdited: () => setState(() => feedback = null),
                      onSubmitted: (submission) => setState(() {
                        feedback = evaluator
                            .evaluate(task, submission)
                            .feedback;
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TaskFeedbackView), findsNothing);
        expect(
          tester
              .widget<FsmWorkspace>(find.byType(FsmWorkspace))
              .highlightedStateIds,
          isEmpty,
        );
        await tester.ensureVisible(find.text('Check automaton'));
        await tester.tap(find.text('Check automaton'));
        await tester.pumpAndSettle();
        final workspace = tester.widget<FsmWorkspace>(
          find.byType(FsmWorkspace),
        );
        expect(workspace.highlightedStateIds, {'q0'});
        expect(
          workspace.highlightedTransitionIds,
          conflict ? {'q0::b::q1', 'q0::b::q0'} : isEmpty,
        );
        expect(find.textContaining('input b'), findsOneWidget);
        final node = tester.widget<Container>(
          find.byKey(const ValueKey('fsm-workspace-state-q0')),
        );
        expect(
          ((node.decoration! as BoxDecoration).border! as Border).top.width,
          4,
        );
        // Die Auswahl eines Werkzeugs ändert das Modell nicht und muss die Diagnose erhalten.
        workspace.controller.setTool(FsmEditorTool.setInitial);
        await tester.pump();
        expect(find.byType(TaskFeedbackView), findsOneWidget);
        if (conflict) {
          workspace.controller.removeTransition('q0::b::q0');
        } else {
          workspace.controller.addTransition(
            fromStateId: 'q0',
            toStateId: 'q1',
            symbol: 'b',
          );
        }
        await tester.pumpAndSettle();
        expect(find.byType(TaskFeedbackView), findsNothing);
        expect(
          tester
              .widget<FsmWorkspace>(find.byType(FsmWorkspace))
              .highlightedStateIds,
          isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
