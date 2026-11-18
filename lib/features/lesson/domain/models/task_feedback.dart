/// Einzelner Bewertungsbefund mit Textschlüssel, Argumenten und optionalem Markierungsziel.
class TaskFeedbackIssue {
  const TaskFeedbackIssue({
    required this.code,
    this.localizationKey,
    this.targetId,
    this.args = const {},
    this.localizedArgs = const {},
  });

  final String code;
  final String? localizationKey;
  final String? targetId;
  final Map<String, String> args;

  /// Argumentnamen, deren Werte selbst Übersetzungsschlüssel sind.
  /// Diese Werte werden vor dem Einsetzen in den Meldungstext übersetzt.
  final Set<String> localizedArgs;
}

/// Bündelt einzelne Befunde und einen optional nutzbaren Vollständigkeitsanteil der Abgabe.
class StructuredTaskFeedback {
  const StructuredTaskFeedback({this.issues = const [], this.completeness = 1});

  final List<TaskFeedbackIssue> issues;
  final double completeness;
}
