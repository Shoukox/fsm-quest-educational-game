import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:bachelor/features/lesson/domain/models/task_submission.dart';
import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_behavior_equivalence.dart';
import 'package:bachelor/features/lesson/domain/models/task_feedback.dart';
import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_validator.dart';
import 'package:bachelor/features/lesson/domain/logic/task_action_alphabet.dart';
import 'package:bachelor/features/lesson/domain/logic/task_feedback_keys.dart';

class TaskEvaluation {
  const TaskEvaluation({
    required this.isCorrect,
    this.feedbackKey,
    this.feedback,
  });

  final bool isCorrect;

  /// Schlüssel für aufgabenspezifisches Fehlerfeedback; die Lektionsseite löst ihn auf.
  final String? feedbackKey;
  final StructuredTaskFeedback? feedback;
}

/// Bewertet typisierte Aufgabenabgaben und erzeugt strukturierte Fehlerhinweise.
class TaskEvaluator {
  const TaskEvaluator();

  TaskEvaluation evaluate(LessonTask task, TaskSubmission submission) {
    final payload = task.payload;

    if (submission is ChoiceTaskSubmission) {
      final expected = switch (payload) {
        Aa1MutationOutcomePayload() => payload.correctAnswerId,
        Aa3ValidateAutomatonPayload() =>
          payload.isCorrectAutomaton ? 'answer.true' : 'answer.false',
        _ => task.correctAnswerId,
      };
      final isCorrect = submission.answerId == expected;
      return TaskEvaluation(
        isCorrect: isCorrect,
        feedbackKey: isCorrect
            ? null
            : task.feedbackByAnswer[submission.answerId] ??
                  TaskFeedbackKeys.answer(task.id, submission.answerId),
      );
    }

    if (payload is Aa2FindErrorPayload &&
        submission is ElementSelectionTaskSubmission) {
      return _selection(task, submission.elementIds, payload.errorTargetIds, {
        for (final target in payload.targets) target.id: target.label,
      });
    }

    if (payload is DiagramSelectionPayload &&
        submission is ElementSelectionTaskSubmission) {
      return _selection(task, submission.elementIds, payload.correctTargetIds, {
        for (final target in payload.targets) target.id: target.label,
      });
    }

    if (submission is FsmTaskSubmission) {
      final expected = switch (payload) {
        Aa4BuildAutomatonPayload() => payload.expectedFsm,
        Aa8CompleteAutomatonPayload() => payload.expectedFsm,
        _ => null,
      };
      if (expected == null) return const TaskEvaluation(isCorrect: false);
      final behavioral = switch (payload) {
        Aa4BuildAutomatonPayload() =>
          payload.evaluationMode == FsmEvaluationMode.behavioral,
        Aa8CompleteAutomatonPayload() =>
          payload.evaluationMode == FsmEvaluationMode.behavioral,
        _ => false,
      };
      final alphabet = switch (payload) {
        Aa4BuildAutomatonPayload() => payload.inputAlphabet,
        Aa8CompleteAutomatonPayload() => payload.inputAlphabet,
        _ => const <String>[],
      };
      // Vor dem Lösungsvergleich werden Strukturfehler gezielt zurückgemeldet.
      // Für den Verhaltensvergleich muss das deklarierte Alphabet vollständig sein.
      final shapeIssues = const FsmValidator().validate(
        submission.fsm,
        inputAlphabet: alphabet.isEmpty ? null : alphabet,
        requireTotal: behavioral && alphabet.isNotEmpty,
      );
      if (shapeIssues.isNotEmpty) {
        return TaskEvaluation(
          isCorrect: false,
          feedback: StructuredTaskFeedback(
            issues: [
              for (final issue in shapeIssues)
                TaskFeedbackIssue(
                  code: issue.type.name,
                  localizationKey: 'fsmFeedback.${issue.type.name}',
                  targetId: issue.stateId,
                  args: {
                    if (issue.stateId != null) 'state': issue.stateId!,
                    if (issue.inputSymbol != null) 'input': issue.inputSymbol!,
                  },
                ),
            ],
          ),
        );
      }
      final behavior = behavioral && alphabet.isNotEmpty
          ? const FsmBehaviorEquivalence().compare(
              submission.fsm,
              expected,
              inputAlphabet: alphabet,
            )
          : null;
      // Je nach Aufgabe zählt das erreichbare Ausgabeverhalten oder die genaue
      // Struktur. Eine geforderte Ausgabespur wird zusätzlich geprüft.
      final correct =
          behavior?.isEquivalent ?? structurallyEqual(submission.fsm, expected);
      final traceCorrect = switch (payload) {
        Aa4BuildAutomatonPayload(outputTrace: final expectedTrace?) =>
          submission.outputTrace != null &&
              _sameList(submission.outputTrace!, expectedTrace),
        _ => true,
      };
      final allCorrect = correct && traceCorrect;
      return TaskEvaluation(
        isCorrect: allCorrect,
        feedback: StructuredTaskFeedback(
          issues: allCorrect
              ? const []
              : [
                  if (!correct)
                    _behaviorIssue(submission.fsm, behavior)
                  else
                    const TaskFeedbackIssue(
                      code: 'incompleteTrace',
                      localizationKey: 'fsmFeedback.incompleteTrace',
                    ),
                ],
        ),
      );
    }

    if (payload is Aa6BuildTablePayload &&
        submission is FsmTableTaskSubmission) {
      final issues = _tableIssues(submission.rows, payload);
      return TaskEvaluation(
        isCorrect: issues.isEmpty,
        feedbackKey: issues.isEmpty ? null : TaskFeedbackKeys.wrong(task.id),
        feedback: issues.isEmpty
            ? null
            : StructuredTaskFeedback(issues: issues),
      );
    }

    if (payload is Aa7TraceStatePayload &&
        submission is StateTraceTaskSubmission) {
      final issue = _traceIssue(submission.stateIds, payload);
      return TaskEvaluation(
        isCorrect: issue == null,
        feedbackKey: issue == null ? null : TaskFeedbackKeys.wrong(task.id),
        feedback: issue == null
            ? null
            : StructuredTaskFeedback(issues: [issue]),
      );
    }

    if (payload is Aa9TheoryPayload && submission is TextTaskSubmission) {
      final actual = _normalizeText(
        submission.text,
        caseSensitive: payload.caseSensitive,
      );
      return TaskEvaluation(
        isCorrect: payload.acceptedTextAnswers.any(
          (answer) =>
              _normalizeText(answer, caseSensitive: payload.caseSensitive) ==
              actual,
        ),
      );
    }

    return const TaskEvaluation(isCorrect: false);
  }

  /// Benennt falsch ausgewählte Elemente und zählt fehlende Ziele.
  /// Welche Elemente noch fehlen, wird dabei nicht verraten.
  TaskEvaluation _selection(
    LessonTask task,
    Set<String> selected,
    Set<String> expected,
    Map<String, String> labels,
  ) {
    if (_sameSet(selected, expected)) {
      return const TaskEvaluation(isCorrect: true);
    }
    final missing = expected.difference(selected).length;
    return TaskEvaluation(
      isCorrect: false,
      feedbackKey: TaskFeedbackKeys.wrong(task.id),
      feedback: StructuredTaskFeedback(
        completeness: expected.isEmpty
            ? 0
            : expected.intersection(selected).length / expected.length,
        issues: [
          for (final id in selected.difference(expected))
            TaskFeedbackIssue(
              code: 'selectionExtra',
              localizationKey: 'taskFeedback.selectionExtra',
              targetId: id,
              args: {'label': labels[id] ?? id},
              localizedArgs: const {'label'},
            ),
          if (missing > 0)
            TaskFeedbackIssue(
              code: 'selectionMissing',
              localizationKey: 'taskFeedback.selectionMissing',
              args: {'count': '$missing'},
            ),
        ],
      ),
    );
  }

  /// Bereitet eine Verhaltensabweichung als Gegenbeispiel für das Feedback auf.
  /// Bei einer unterscheidenden Eingabefolge wird der Ausgangszustand ihres
  /// letzten Schritts markiert; ohne Eingabe betrifft der Hinweis die Startausgabe.
  TaskFeedbackIssue _behaviorIssue(Fsm submitted, FsmBehaviorResult? result) {
    if (result == null) {
      return const TaskFeedbackIssue(
        code: 'behaviorMismatch',
        localizationKey: 'fsmFeedback.behaviorMismatch',
      );
    }
    if (result.counterexample.isEmpty) {
      final initial = submitted.initialStateId;
      return TaskFeedbackIssue(
        code: 'behaviorMismatch',
        localizationKey: initial == null
            ? 'fsmFeedback.behaviorMismatch'
            : 'fsmFeedback.initialOutputMismatch',
        targetId: initial,
        args: {'state': ?initial},
      );
    }
    final hasOutputs =
        result.actualOutput != null && result.expectedOutput != null;
    return TaskFeedbackIssue(
      code: 'behaviorMismatch',
      localizationKey: hasOutputs
          ? 'fsmFeedback.counterexample'
          : 'fsmFeedback.counterexampleNoOutput',
      targetId: result.actualStateId,
      args: {
        'sequence': result.counterexample.join(
          TaskActionAlphabet.sequenceSeparator,
        ),
        'input': result.counterexample.last,
        'state': ?result.actualStateId,
        'actual': ?result.actualOutput,
        'expected': ?result.expectedOutput,
      },
    );
  }

  /// Meldet falsche Übergangs- und Ausgabeeinträge einzeln für die Zeilenmarkierung.
  /// Die korrekten Werte werden dabei nicht vorgegeben.
  List<TaskFeedbackIssue> _tableIssues(
    List<FsmTableRow> actual,
    Aa6BuildTablePayload payload,
  ) {
    final actualByState = {for (final row in actual) row.stateId: row};
    final issues = <TaskFeedbackIssue>[];
    for (final expectedRow in payload.expectedRows) {
      final actualRow = actualByState[expectedRow.stateId];
      final state = _tableState(expectedRow.stateId);
      for (final input in payload.inputSymbols) {
        // Ein fehlender und ein leerer Eintrag bedeuten beide: kein Folgezustand.
        final value = actualRow?.transitions[input] ?? '';
        if (value == (expectedRow.transitions[input] ?? '')) continue;
        final empty = value.isEmpty;
        issues.add(
          TaskFeedbackIssue(
            code: empty ? 'tableTransitionEmpty' : 'tableTransitionWrong',
            localizationKey: empty
                ? 'taskFeedback.tableTransitionEmpty'
                : 'taskFeedback.tableTransitionWrong',
            targetId: expectedRow.stateId,
            args: {'state': state, 'input': input},
          ),
        );
      }
      final output = (actualRow?.output ?? '').trim();
      if (output != expectedRow.output.trim()) {
        issues.add(
          TaskFeedbackIssue(
            code: output.isEmpty ? 'tableOutputEmpty' : 'tableOutputWrong',
            localizationKey: output.isEmpty
                ? 'taskFeedback.tableOutputEmpty'
                : 'taskFeedback.tableOutputWrong',
            targetId: expectedRow.stateId,
            args: {'state': state},
          ),
        );
      }
    }
    return issues;
  }

  /// Schaltungstabellen zeigen Zustandsnummern (S = 2) statt interner IDs (s2).
  String _tableState(String stateId) =>
      RegExp(r'^s\d+$').hasMatch(stateId) ? stateId.substring(1) : stateId;

  /// Sucht den ersten falschen oder fehlenden Eintrag der erwarteten Zustandsspur.
  /// Der Hinweis lenkt die Prüfung dadurch auf den ersten abweichenden Schritt.
  TaskFeedbackIssue? _traceIssue(
    List<String> actual,
    Aa7TraceStatePayload payload,
  ) {
    final expected = payload.expectedStateIds;
    for (var index = 0; index < expected.length; index++) {
      if (index < actual.length && actual[index] == expected[index]) continue;
      if (index == 0) {
        return const TaskFeedbackIssue(
          code: 'traceStart',
          localizationKey: 'taskFeedback.traceStart',
          targetId: '0',
        );
      }
      final previous = expected[index - 1];
      return TaskFeedbackIssue(
        code: 'traceStep',
        localizationKey: 'taskFeedback.traceStep',
        targetId: '$index',
        args: {
          'step': '$index',
          'input': payload.inputSymbols[index - 1],
          'state': payload.fsm.stateById(previous)?.label ?? previous,
        },
      );
    }
    return null;
  }

  /// Vergleicht Modus, Startzustand, Zustandsdaten und Übergangs-IDs.
  /// Reihenfolge und Zeichenpositionen werden dabei nicht berücksichtigt.
  bool structurallyEqual(Fsm actual, Fsm expected) {
    if (actual.outputMode != expected.outputMode) return false;
    if (actual.initialStateId != expected.initialStateId) return false;
    if (actual.states.length != expected.states.length ||
        actual.transitions.length != expected.transitions.length) {
      return false;
    }

    final actualStates = {
      for (final state in actual.states)
        state.id: '${state.label}|${state.output}',
    };
    final expectedStates = {
      for (final state in expected.states)
        state.id: '${state.label}|${state.output}',
    };
    if (!_sameMap(actualStates, expectedStates)) return false;

    final actualTransitions = {
      for (final transition in actual.transitions) transition.id,
    };
    final expectedTransitions = {
      for (final transition in expected.transitions) transition.id,
    };
    return _sameSet(actualTransitions, expectedTransitions);
  }

  bool _sameList<T>(List<T> first, List<T> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  bool _sameSet<T>(Set<T> first, Set<T> second) {
    return first.length == second.length && first.containsAll(second);
  }

  bool _sameMap<K, V>(Map<K, V> first, Map<K, V> second) {
    if (first.length != second.length) return false;
    for (final entry in first.entries) {
      if (!second.containsKey(entry.key) || second[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  String _normalizeText(String value, {required bool caseSensitive}) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return caseSensitive ? trimmed : trimmed.toLowerCase();
  }
}
