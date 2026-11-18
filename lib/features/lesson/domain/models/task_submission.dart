import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';

/// Typisierte Abgabe einer Aufgabeninteraktion zur anschließenden fachlichen Bewertung.
sealed class TaskSubmission {
  const TaskSubmission();
}

/// Abgabe der stabilen ID einer gewählten Antwortoption.
class ChoiceTaskSubmission extends TaskSubmission {
  const ChoiceTaskSubmission(this.answerId);

  final String answerId;
}

/// Noch nicht normalisierter Freitext; die Bewertungslogik berücksichtigt die Aufgabenvorgaben.
class TextTaskSubmission extends TaskSubmission {
  const TextTaskSubmission(this.text);

  final String text;
}

/// Menge ausgewählter Element-IDs; die Reihenfolge der Auswahl hat keine Bedeutung.
class ElementSelectionTaskSubmission extends TaskSubmission {
  const ElementSelectionTaskSubmission(this.elementIds);

  final Set<String> elementIds;
}

/// Abgegebener Automat mit optionaler Ausgabespur und zusätzlicher Tabellenzeile.
class FsmTaskSubmission extends TaskSubmission {
  const FsmTaskSubmission(this.fsm, {this.outputTrace, this.table});

  final Fsm fsm;
  final List<String>? outputTrace;
  final FsmTableRow? table;
}

/// Abgegebene Zeilen einer Übergangs- beziehungsweise Ausgabetabelle.
class FsmTableTaskSubmission extends TaskSubmission {
  const FsmTableTaskSubmission(this.rows);

  final List<FsmTableRow> rows;
}

/// Geordnete Zustands-IDs einer nachverfolgten Eingabefolge.
class StateTraceTaskSubmission extends TaskSubmission {
  const StateTraceTaskSubmission(this.stateIds);

  final List<String> stateIds;
}
