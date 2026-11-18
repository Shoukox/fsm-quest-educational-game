import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';

enum FsmOutputMode { moore, mealy }

/// Beschreibt Zustände, Übergänge, Startzustand und Ausgabemodus eines Automaten.
class Fsm {
  static const empty = Fsm(states: [], transitions: []);

  const Fsm({
    required this.states,
    required this.transitions,
    this.initialStateId,
    this.outputMode = FsmOutputMode.moore,
  });

  final List<FsmState> states;
  final List<FsmTransition> transitions;
  final String? initialStateId;
  final FsmOutputMode outputMode;

  /// Erzeugt eine Kopie mit ausgewählten Änderungen.
  /// Nur [clearInitialState] entfernt den Startzustand; `null` behält ihn bei.
  Fsm copyWith({
    List<FsmState>? states,
    List<FsmTransition>? transitions,
    String? initialStateId,
    bool clearInitialState = false,
    FsmOutputMode? outputMode,
  }) {
    return Fsm(
      states: states ?? this.states,
      transitions: transitions ?? this.transitions,
      initialStateId: clearInitialState
          ? null
          : initialStateId ?? this.initialStateId,
      outputMode: outputMode ?? this.outputMode,
    );
  }

  FsmState? stateById(String id) {
    for (final state in states) {
      if (state.id == id) return state;
    }
    return null;
  }
}
