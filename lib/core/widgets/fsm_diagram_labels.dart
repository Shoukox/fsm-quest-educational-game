/// Technische Beschriftungen für die Automatenzeichnungen der Lernbeispiele.
/// Sie bleiben unabhängig von der Oberflächensprache stabil; die erklärenden Texte
/// um die Diagramme werden separat übersetzt.
abstract final class FsmDiagramLabels {
  static const reset = 'Reset';

  static const red = 'RED';
  static const redYellow = 'RED-YELLOW';
  static const green = 'GREEN';
  static const yellow = 'YELLOW';
  static const duration60 = '60 s';
  static const duration10 = '10 sec';

  static const locked = 'Locked';
  static const unlocked = 'Unlocked';
  static const coin = 'coin';
  static const passage = 'passage';
  static const stateStopOutput = 'y = STOP';
  static const stateGoOutput = 'y = GO';
  static const mealyCoinGo = 'coin / GO';
}
