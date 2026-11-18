import 'package:bachelor/core/logic/digital_gate_logic.dart';

/// Unterscheidet die Schaltungsvarianten anhand stabiler IDs in den Lektionsdaten.
enum CircuitDiagramVariant {
  base('base'),
  practiceX('practice-x'),
  finalAndNextState('final-and-next-state'),
  finalMixedState('final-mixed-state'),
  finalXorOutput('final-xor-output');

  const CircuitDiagramVariant(this.id);
  final String id;

  static CircuitDiagramVariant? fromId(String? id) {
    for (final variant in values) {
      if (variant.id == id) return variant;
    }
    return null;
  }
}

/// Beschreibt ein Eingangssignal einschließlich einer optionalen logischen Negation.
class CircuitInput {
  const CircuitInput(this.signal, {this.inverted = false});
  final String signal;
  final bool inverted;
}

/// Verknüpft eine Gatter-ID mit Gattertyp und den zugehörigen Eingangssignalen.
class CircuitGateSpec {
  const CircuitGateSpec(this.id, this.type, this.inputs);
  final String id;
  final DigitalGateType type;
  final List<CircuitInput> inputs;
}

/// Bündelt die Gatter einer Schaltungsvariante für Darstellung und Auswertung.
class CircuitDefinition {
  const CircuitDefinition({required this.variant, required this.gates});
  final CircuitDiagramVariant variant;
  final List<CircuitGateSpec> gates;

  /// Erzeugt die Gatterbelegung der gewählten Variante.
  /// Varianten ändern gezielt Eingangsnamen, Folgezustandslogik oder Ausgangsgatter.
  static CircuitDefinition forVariant(CircuitDiagramVariant variant) {
    final inputSignal = switch (variant) {
      CircuitDiagramVariant.base => 'A',
      CircuitDiagramVariant.practiceX => 'X',
      _ => 'B',
    };
    final top = variant == CircuitDiagramVariant.finalAndNextState
        ? DigitalGateType.and
        : DigitalGateType.xor;
    final lowerLast = variant == CircuitDiagramVariant.finalMixedState
        ? CircuitInput('S0')
        : const CircuitInput('S0', inverted: true);
    final output = variant == CircuitDiagramVariant.finalXorOutput
        ? DigitalGateType.xor
        : DigitalGateType.and;
    final outputLowBit = variant == CircuitDiagramVariant.finalXorOutput
        ? const CircuitInput('S0')
        : const CircuitInput('S0', inverted: true);
    return CircuitDefinition(
      variant: variant,
      gates: [
        CircuitGateSpec('d0-logic', top, [
          const CircuitInput('S1'),
          const CircuitInput('S0'),
        ]),
        CircuitGateSpec('d0', DigitalGateType.and, [
          CircuitInput(inputSignal),
          const CircuitInput('d0-logic'),
        ]),
        CircuitGateSpec('d1', DigitalGateType.and, [
          CircuitInput(inputSignal, inverted: true),
          const CircuitInput('S1', inverted: true),
          lowerLast,
        ]),
        CircuitGateSpec('y', output, [const CircuitInput('S1'), outputLowBit]),
      ],
    );
  }
}
