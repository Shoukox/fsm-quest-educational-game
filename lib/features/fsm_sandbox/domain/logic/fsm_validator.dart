import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';

enum FsmValidationIssueType {
  noStates,
  missingInitialState,
  unknownInitialState,
  duplicateStateId,
  missingStateOutput,
  missingTransitionOutput,
  emptyTransitionSymbol,
  unknownTransitionEndpoint,
  nondeterministicTransition,
  missingTransition,
  unknownInputSymbol,
}

class FsmValidationIssue {
  const FsmValidationIssue({
    required this.type,
    required this.elementId,
    this.stateId,
    this.inputSymbol,
  });

  final FsmValidationIssueType type;
  final String elementId;
  final String? stateId;
  final String? inputSymbol;
}

/// Prüft die Struktur eines Automaten und ordnet Befunde betroffenen Elementen zu.
class FsmValidator {
  const FsmValidator();

  bool hasInitialState(Fsm fsm) => fsm.initialStateId != null;

  bool isValid(Fsm fsm) => validate(fsm).isEmpty;

  /// Prüft unter anderem Startzustand, Ausgaben und deterministische Übergänge.
  /// Mit [requireTotal] und [inputAlphabet] muss jeder Zustand für jede Eingabe
  /// einen Übergang besitzen; ohne Alphabet wird diese Vollständigkeit nicht geprüft.
  List<FsmValidationIssue> validate(
    Fsm fsm, {
    List<String>? inputAlphabet,
    bool requireTotal = false,
  }) {
    final issues = <FsmValidationIssue>[];
    if (fsm.states.isEmpty) {
      issues.add(
        const FsmValidationIssue(
          type: FsmValidationIssueType.noStates,
          elementId: 'fsm',
        ),
      );
    }

    final stateIds = <String>{};
    for (final state in fsm.states) {
      if (!stateIds.add(state.id)) {
        issues.add(
          FsmValidationIssue(
            type: FsmValidationIssueType.duplicateStateId,
            elementId: state.id,
            stateId: state.id,
          ),
        );
      }
      if (fsm.outputMode == FsmOutputMode.moore &&
          state.output.trim().isEmpty) {
        issues.add(
          FsmValidationIssue(
            type: FsmValidationIssueType.missingStateOutput,
            elementId: state.id,
            stateId: state.id,
          ),
        );
      }
    }

    final initialStateId = fsm.initialStateId;
    if (initialStateId == null) {
      issues.add(
        const FsmValidationIssue(
          type: FsmValidationIssueType.missingInitialState,
          elementId: 'initial',
        ),
      );
    } else if (!stateIds.contains(initialStateId)) {
      issues.add(
        FsmValidationIssue(
          type: FsmValidationIssueType.unknownInitialState,
          elementId: initialStateId,
        ),
      );
    }

    // Mehrere Übergänge für dieselbe Kombination aus Zustand und Eingabe sind
    // auch dann nicht deterministisch, wenn sie zum selben Ziel führen.
    final groups = <String, Map<String, List<FsmTransition>>>{};
    final alphabet = inputAlphabet?.toSet();
    for (final transition in fsm.transitions) {
      if (transition.symbol.trim().isEmpty) {
        issues.add(
          FsmValidationIssue(
            type: FsmValidationIssueType.emptyTransitionSymbol,
            elementId: transition.id,
            stateId: transition.fromStateId,
            inputSymbol: transition.inputSymbol,
          ),
        );
      }
      if (fsm.outputMode == FsmOutputMode.mealy &&
          transition.outputValue.isEmpty) {
        issues.add(
          FsmValidationIssue(
            type: FsmValidationIssueType.missingTransitionOutput,
            elementId: transition.id,
            stateId: transition.fromStateId,
            inputSymbol: transition.inputSymbol,
          ),
        );
      }
      if (!stateIds.contains(transition.fromStateId) ||
          !stateIds.contains(transition.toStateId)) {
        issues.add(
          FsmValidationIssue(
            type: FsmValidationIssueType.unknownTransitionEndpoint,
            elementId: transition.id,
            stateId: transition.fromStateId,
            inputSymbol: transition.inputSymbol,
          ),
        );
      }
      if (alphabet != null &&
          !alphabet.contains(transition.inputSymbol) &&
          transition.inputSymbol.isNotEmpty) {
        issues.add(
          FsmValidationIssue(
            type: FsmValidationIssueType.unknownInputSymbol,
            elementId: transition.id,
            stateId: transition.fromStateId,
            inputSymbol: transition.inputSymbol,
          ),
        );
      }
      groups
          .putIfAbsent(transition.fromStateId, () => {})
          .putIfAbsent(transition.inputSymbol, () => [])
          .add(transition);
    }
    for (final state in groups.entries) {
      for (final input in state.value.entries) {
        if (input.value.length > 1) {
          issues.add(
            FsmValidationIssue(
              type: FsmValidationIssueType.nondeterministicTransition,
              elementId: input.value.first.id,
              stateId: state.key,
              inputSymbol: input.key,
            ),
          );
        }
      }
    }
    if (requireTotal && inputAlphabet != null) {
      for (final state in fsm.states) {
        for (final input in inputAlphabet) {
          if (!fsm.transitions.any(
            (t) => t.fromStateId == state.id && t.inputSymbol == input,
          )) {
            issues.add(
              FsmValidationIssue(
                type: FsmValidationIssueType.missingTransition,
                elementId: '${state.id}::$input',
                stateId: state.id,
                inputSymbol: input,
              ),
            );
          }
        }
      }
    }
    return issues;
  }
}
