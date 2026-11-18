import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';

/// Vorgabe für einen hinzufügbaren Zustand mit Bezeichnung, Ausgabe und optional stabiler ID.
class FsmStatePreset {
  const FsmStatePreset({required this.label, required this.output, this.id});

  factory FsmStatePreset.fromState(FsmState state) {
    return FsmStatePreset(
      id: state.id,
      label: state.label,
      output: state.output,
    );
  }

  final String label;
  final String? id;
  final String output;
}

/// Übergangsvorgabe mit Symbol und optional vorgegebenen Namen der Endzustände.
class FsmTransitionPreset {
  const FsmTransitionPreset({
    required this.symbol,
    this.fromLabel,
    this.toLabel,
  });

  factory FsmTransitionPreset.fromTransition(
    Fsm fsm,
    FsmTransition transition, {
    bool includeEndpoints = true,
  }) {
    return FsmTransitionPreset(
      symbol: transition.symbol,
      fromLabel: includeEndpoints
          ? fsm.stateById(transition.fromStateId)?.label
          : null,
      toLabel: includeEndpoints
          ? fsm.stateById(transition.toStateId)?.label
          : null,
    );
  }

  final String symbol;
  final String? fromLabel;
  final String? toLabel;

  /// Ergänzt das Symbol nur dann um Endzustandsnamen, wenn beide Namen vorhanden sind.
  String get displayLabel {
    final from = fromLabel;
    final to = toLabel;
    if (from == null || to == null) return symbol;
    return '$from - $symbol → $to';
  }
}

List<FsmStatePreset> statePresetsFromFsm(Fsm fsm) {
  return [for (final state in fsm.states) FsmStatePreset.fromState(state)];
}

List<FsmTransitionPreset> transitionPresetsFromFsm(
  Fsm fsm, {
  bool includeEndpoints = true,
}) {
  return [
    for (final transition in fsm.transitions)
      FsmTransitionPreset.fromTransition(
        fsm,
        transition,
        includeEndpoints: includeEndpoints,
      ),
  ];
}
