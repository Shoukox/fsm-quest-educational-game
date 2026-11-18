import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/simulation_step.dart';

/// Verfolgt eine Eingabefolge bis zum ersten nicht eindeutig ausführbaren Schritt.
class FsmSimulator {
  const FsmSimulator();

  /// Behandelt jeden Unicode-Codepunkt von [input] als einzelnes Eingabesymbol.
  List<SimulationStep> simulate(Fsm fsm, String input) {
    return simulateSymbols(fsm, input.runes.map(String.fromCharCode).toList());
  }

  List<SimulationStep> simulateSymbols(Fsm fsm, List<String> inputSymbols) {
    final initialStateId = fsm.initialStateId;
    if (initialStateId == null) return const [];
    final initialState = fsm.stateById(initialStateId);
    if (initialState == null) return const [];

    // Der erste Eintrag zeigt den Startzustand vor dem Verbrauch eines Symbols.
    final steps = <SimulationStep>[
      SimulationStep(
        stateId: initialStateId,
        inputIndex: 0,
        consumedSymbol: '',
        output: initialState.output,
      ),
    ];
    var currentStateId = initialStateId;
    for (var index = 0; index < inputSymbols.length; index++) {
      final symbol = inputSymbols[index];
      final matches = fsm.transitions.where(
        (transition) =>
            transition.fromStateId == currentStateId &&
            transition.inputSymbol == symbol,
      );
      // Fehlende oder mehrdeutige Übergänge beenden die bisher gültige Spur.
      if (matches.length != 1) break;
      currentStateId = matches.single.toStateId;
      final currentState = fsm.stateById(currentStateId);
      if (currentState == null) break;
      steps.add(
        SimulationStep(
          stateId: currentStateId,
          inputIndex: index + 1,
          consumedSymbol: symbol,
          output: fsm.outputMode == FsmOutputMode.mealy
              ? matches.single.outputValue
              : currentState.output,
        ),
      );
    }
    return steps;
  }
}
