import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:bachelor/features/lesson/domain/models/task_submission.dart';
import 'package:bachelor/features/lesson/domain/models/task_feedback.dart';

/// Bildet Eingabeaktionen für die Anzeige eindeutig auf Buchstaben ab.
/// Alle Diagramme und Tabellen einer Aufgabe verwenden dieselbe Zuordnung;
/// vor der Bewertung wird sie umgekehrt. Zustand-IDs, Ausgaben und die Bits
/// von Schaltungstabellen behalten ihre ursprünglichen Werte.
class TaskActionAlphabet {
  TaskActionAlphabet(LessonTask task) {
    final payload = task.payload;
    if (payload is Aa6BuildTablePayload && payload.circuitDiagramId != null) {
      return;
    }
    final machines = <Fsm>[
      if (task.illustration != null) task.illustration!,
      ...switch (payload) {
        Aa1MutationOutcomePayload p => [p.before, p.after],
        Aa2FindErrorPayload p => [p.fsm],
        Aa3ValidateAutomatonPayload p => [p.fsm],
        Aa4BuildAutomatonPayload p => [
          p.expectedFsm,
          p.initialFsm,
          if (p.sourceFsm != null) p.sourceFsm!,
        ],
        Aa6BuildTablePayload p => [if (p.sourceFsm != null) p.sourceFsm!],
        Aa7TraceStatePayload p => [p.fsm],
        Aa8CompleteAutomatonPayload p => [p.expectedFsm, p.partialFsm],
        DiagramSelectionPayload p => [p.fsm],
        _ => <Fsm>[],
      },
    ];
    final inputs = {
      for (final fsm in machines)
        for (final t in fsm.transitions) t.inputSymbol,
      ...switch (payload) {
        Aa4BuildAutomatonPayload p => p.inputAlphabet,
        Aa6BuildTablePayload p => p.inputSymbols,
        Aa7TraceStatePayload p => p.inputSymbols,
        Aa8CompleteAutomatonPayload p => p.inputAlphabet,
        _ => <String>[],
      },
    }.toList()..sort();
    for (var i = 0; i < inputs.length; i++) {
      final letter = i < 26 ? String.fromCharCode(97 + i) : 'a${i - 25}';
      actions[inputs[i]] = letter;
      originals[letter] = inputs[i];
    }
  }

  /// Trennt die Eingaben eines Gegenbeispiels in Feedback-Argumenten.
  static const sequenceSeparator = ' → ';

  final Map<String, String> actions = {};
  final Map<String, String> originals = {};
  String input(String value) => actions[value] ?? value;

  /// Passt Diagnosesymbole an die im Editor angezeigten Aktionsbuchstaben an.
  StructuredTaskFeedback? feedback(StructuredTaskFeedback? feedback) =>
      feedback == null
      ? null
      : StructuredTaskFeedback(
          completeness: feedback.completeness,
          issues: [
            for (final issue in feedback.issues)
              TaskFeedbackIssue(
                code: issue.code,
                localizationKey: issue.localizationKey,
                targetId: issue.targetId,
                localizedArgs: issue.localizedArgs,
                args: {
                  ...issue.args,
                  if (issue.args['input'] case final symbol?)
                    'input': input(symbol),
                  if (issue.args['sequence'] case final sequence?)
                    'sequence': sequence
                        .split(sequenceSeparator)
                        .map(input)
                        .join(sequenceSeparator),
                },
              ),
          ],
        );
  String _symbol(String symbol, Map<String, String> map) {
    final parts = symbol.split('/');
    final action = map[parts.first.trim()] ?? parts.first.trim();
    return parts.length == 1
        ? action
        : '$action / ${parts.skip(1).join('/').trim()}';
  }

  Fsm machine(Fsm fsm, {bool reverse = false}) => fsm.copyWith(
    transitions: [
      for (final t in fsm.transitions)
        t.copyWith(symbol: _symbol(t.symbol, reverse ? originals : actions)),
    ],
  );

  FsmTableRow _row(FsmTableRow row, Map<String, String> map) => FsmTableRow(
    stateId: row.stateId,
    output: row.output,
    transitions: {
      for (final e in row.transitions.entries) map[e.key] ?? e.key: e.value,
    },
  );

  LessonTaskPayload? payload(LessonTaskPayload? p) => switch (p) {
    Aa1MutationOutcomePayload p => Aa1MutationOutcomePayload(
      before: machine(p.before),
      after: machine(p.after),
      input: input(p.input),
      correctAnswerId: p.correctAnswerId,
    ),
    Aa2FindErrorPayload p => Aa2FindErrorPayload(
      fsm: machine(p.fsm),
      targets: p.targets,
      errorTargetIds: p.errorTargetIds,
    ),
    Aa3ValidateAutomatonPayload p => Aa3ValidateAutomatonPayload(
      fsm: machine(p.fsm),
      isCorrectAutomaton: p.isCorrectAutomaton,
      reasonKey: p.reasonKey,
    ),
    Aa4BuildAutomatonPayload p => Aa4BuildAutomatonPayload(
      expectedFsm: machine(p.expectedFsm),
      initialFsm: machine(p.initialFsm),
      sourceFsm: p.sourceFsm == null ? null : machine(p.sourceFsm!),
      inputAlphabet: p.inputAlphabet.map(input).toList(),
      allowedTools: p.allowedTools,
      readyPresetsOnly: p.readyPresetsOnly,
      requireTransitionEndpoints: p.requireTransitionEndpoints,
      evaluationMode: p.evaluationMode,
      outputTrace: p.outputTrace,
      tableRequirement: p.tableRequirement,
    ),
    Aa6BuildTablePayload p => Aa6BuildTablePayload(
      sourceDescriptionKey: p.sourceDescriptionKey,
      sourceFsm: p.sourceFsm == null ? null : machine(p.sourceFsm!),
      circuitDiagramId: p.circuitDiagramId,
      inputSymbols: p.inputSymbols.map(input).toList(),
      expectedRows: [for (final row in p.expectedRows) _row(row, actions)],
    ),
    Aa7TraceStatePayload p => Aa7TraceStatePayload(
      fsm: machine(p.fsm),
      inputSymbols: p.inputSymbols.map(input).toList(),
      expectedStateIds: p.expectedStateIds,
    ),
    Aa8CompleteAutomatonPayload p => Aa8CompleteAutomatonPayload(
      partialFsm: machine(p.partialFsm),
      expectedFsm: machine(p.expectedFsm),
      allowedTools: p.allowedTools,
      readyPresetsOnly: p.readyPresetsOnly,
      inputAlphabet: p.inputAlphabet.map(input).toList(),
      evaluationMode: p.evaluationMode,
    ),
    DiagramSelectionPayload p => DiagramSelectionPayload(
      fsm: machine(p.fsm),
      targets: p.targets,
      correctTargetIds: p.correctTargetIds,
    ),
    _ => p,
  };

  /// Übersetzt angezeigte Buchstaben vor der Bewertung in die Originalsymbole zurück.
  TaskSubmission restore(TaskSubmission submission) => switch (submission) {
    FsmTaskSubmission s => FsmTaskSubmission(
      machine(s.fsm, reverse: true),
      outputTrace: s.outputTrace,
      table: s.table == null ? null : _row(s.table!, originals),
    ),
    FsmTableTaskSubmission s => FsmTableTaskSubmission([
      for (final row in s.rows) _row(row, originals),
    ]),
    _ => submission,
  };
}
