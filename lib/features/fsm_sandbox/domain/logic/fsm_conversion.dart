import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';

class FsmConversion {
  const FsmConversion();

  /// Übernimmt die Ausgabe des jeweiligen Zielzustands auf den Übergang.
  /// Die anfängliche Moore-Ausgabe hat dabei keinen eigenen Mealy-Übergang.
  Fsm mooreToMealy(Fsm source) {
    return Fsm(
      initialStateId: source.initialStateId,
      outputMode: FsmOutputMode.mealy,
      states: [for (final state in source.states) state.copyWith(output: '')],
      transitions: [
        for (final transition in source.transitions)
          transition.copyWith(
            symbol:
                '${transition.inputSymbol} / ${source.stateById(transition.toStateId)?.output ?? ''}',
          ),
      ],
    );
  }

  /// Bildet Zustandskopien für die Ausgaben eingehender Mealy-Übergänge.
  /// Als anfängliche Moore-Ausgabe verwendet diese Implementierung `0`.
  Fsm mealyToMoore(Fsm source) {
    final incoming = <String, Set<String>>{};
    for (final transition in source.transitions) {
      incoming
          .putIfAbsent(transition.toStateId, () => {})
          .add(transition.outputValue);
    }
    String cloneId(String state, String output) => '${state}_$output';
    final states = <FsmState>[];
    for (final state in source.states) {
      final outputs = incoming[state.id] ?? {'0'};
      for (final output in outputs) {
        states.add(
          state.copyWith(id: cloneId(state.id, output), output: output),
        );
      }
    }
    final transitions = <FsmTransition>[];
    // Jede ausgabespezifische Kopie vertritt denselben ursprünglichen Zustand
    // und benötigt deshalb sämtliche ausgehenden Übergänge. Andernfalls kann
    // eine Kopie allein wegen ihrer Ausgabe zu einer Sackgasse werden.
    for (final transition in source.transitions) {
      final sourceClones = incoming[transition.fromStateId] ?? {'0'};
      for (final fromOutput in sourceClones) {
        transitions.add(
          FsmTransition(
            fromStateId: cloneId(transition.fromStateId, fromOutput),
            toStateId: cloneId(transition.toStateId, transition.outputValue),
            symbol: transition.inputSymbol,
          ),
        );
      }
    }
    final initial = cloneId(source.initialStateId ?? 'q0', '0');
    if (!states.any((state) => state.id == initial)) {
      states.add(FsmState(id: initial, label: initial, output: '0'));
    }
    return Fsm(
      initialStateId: initial,
      outputMode: FsmOutputMode.moore,
      states: states,
      transitions: transitions,
    );
  }
}
