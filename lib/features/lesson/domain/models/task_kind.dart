/// Fachliche Aufgabenarten mit stabilen AA-Nummern für Anzeige und Inhaltszuordnung.
enum TaskKind {
  aa1MutationOutcome(1),
  aa2FindError(2),
  aa3ValidateAutomaton(3),
  aa4BuildAutomaton(4),
  aa6BuildTable(6),
  aa7TraceState(7),
  aa8CompleteAutomaton(8),
  aa9Theory(9);

  const TaskKind(this.number);

  final int number;

  String get code => 'AA$number';

  String get localizationKey => 'taskKind.aa$number';
}
