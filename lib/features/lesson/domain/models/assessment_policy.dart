/// Vorgaben einer Prüfungssitzung: Aufgabenzahl, Zeitgrenze und benötigte Lösungen.
class AssessmentPolicy {
  const AssessmentPolicy({
    this.taskCount = 3,
    this.timeLimitSeconds = 900,
    this.minimumSolved = 2,
  });

  final int taskCount;
  final int timeLimitSeconds;
  final int minimumSolved;
}
