/// Eintrag einer Simulationsspur mit erreichtem Zustand, Eingabesymbol und Ausgabe.
/// Der Starteintrag hat Eingabeindex 0; spätere Indizes zählen verbrauchte Symbole.
class SimulationStep {
  const SimulationStep({
    required this.stateId,
    required this.inputIndex,
    required this.consumedSymbol,
    required this.output,
  });

  final String stateId;
  final int inputIndex;
  final String consumedSymbol;
  final String output;
}
