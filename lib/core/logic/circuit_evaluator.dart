import 'package:bachelor/core/models/circuit_definition.dart';
import 'package:bachelor/core/logic/digital_gate_logic.dart';

class CircuitEvaluation {
  const CircuitEvaluation({required this.nextState, required this.output});
  final int nextState;
  final int output;
}

/// Berechnet Folgezustand und Moore-Ausgabe für die hinterlegten Schaltungsvarianten.
class CircuitEvaluator {
  const CircuitEvaluator();

  CircuitEvaluation evaluate(
    CircuitDefinition definition, {
    required int state,
    required int input,
  }) {
    // Der Zustand ist binär als S1 S0 kodiert; S0 ist das niederwertige Bit.
    final s0 = state & 1;
    final s1 = (state >> 1) & 1;
    int read(CircuitInput signal) {
      final value = switch (signal.signal) {
        'A' || 'B' || 'X' => input,
        'S0' => s0,
        'S1' => s1,
        _ => 0,
      };
      return signal.inverted ? 1 - value : value;
    }

    final values = <String, int>{};
    for (final gate in definition.gates) {
      values[gate.id] = DigitalGateLogic.evaluate(
        gate.type,
        gate.inputs.map(read).toList(),
      );
    }
    final d0 = definition.variant == CircuitDiagramVariant.finalAndNextState
        ? DigitalGateLogic.evaluate(DigitalGateType.and, [s1, s0, input])
        : DigitalGateLogic.evaluate(DigitalGateType.and, [
            input,
            DigitalGateLogic.evaluate(DigitalGateType.xor, [s1, s0]),
          ]);
    final d1 = DigitalGateLogic.evaluate(DigitalGateType.and, [
      1 - input,
      1 - s1,
      definition.variant == CircuitDiagramVariant.finalMixedState ? s0 : 1 - s0,
    ]);
    // Die Ausgabe gehört zum aktuellen Speicherzustand, vor der nächsten Taktflanke.
    final y = definition.variant == CircuitDiagramVariant.finalXorOutput
        ? s1 ^ s0
        : s1 & (1 - s0);
    return CircuitEvaluation(nextState: (d1 << 1) | d0, output: y);
  }
}
