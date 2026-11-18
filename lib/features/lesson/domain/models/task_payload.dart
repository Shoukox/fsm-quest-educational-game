import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';

/// Gemeinsamer Basistyp für die fachlichen Daten der verschiedenen Aufgabeninteraktionen.
sealed class LessonTaskPayload {
  const LessonTaskPayload();
}

/// Vergleicht einen Automaten vor und nach einer Änderung für eine vorgegebene Eingabe.
class Aa1MutationOutcomePayload extends LessonTaskPayload {
  const Aa1MutationOutcomePayload({
    required this.before,
    required this.after,
    required this.input,
    required this.correctAnswerId,
  });

  final Fsm before;
  final Fsm after;
  final String input;
  final String correctAnswerId;
}

enum FsmElementType { state, transition, initialMarker, automaton }

/// Auswählbares Fehlersuchziel mit stabiler Element-ID, Typ und sichtbarer Beschriftung.
class FsmErrorTarget {
  const FsmErrorTarget({
    required this.id,
    required this.type,
    required this.label,
  });

  final String id;
  final FsmElementType type;
  final String label;
}

/// Enthält den zu untersuchenden Automaten und die Menge der fehlerhaften Ziel-IDs.
class Aa2FindErrorPayload extends LessonTaskPayload {
  const Aa2FindErrorPayload({
    required this.fsm,
    required this.targets,
    required this.errorTargetIds,
  });

  final Fsm fsm;
  final List<FsmErrorTarget> targets;
  final Set<String> errorTargetIds;
}

/// Vorgabe für die Beurteilung, ob ein dargestellter Automat korrekt ist.
class Aa3ValidateAutomatonPayload extends LessonTaskPayload {
  const Aa3ValidateAutomatonPayload({
    required this.fsm,
    required this.isCorrectAutomaton,
    this.reasonKey,
  });

  final Fsm fsm;
  final bool isCorrectAutomaton;
  final String? reasonKey;
}

/// Bearbeitungsaktionen, die eine Aufgabe im gemeinsamen Automateneditor freigeben kann.
enum FsmEditorTool {
  select,
  addState,
  addTransition,
  setInitial,
  editOutput,
  delete,
}

/// Konfiguriert eine Konstruktionsaufgabe mit Startmodell, Referenz, Werkzeugen und Bewertungsmodus.
class Aa4BuildAutomatonPayload extends LessonTaskPayload {
  const Aa4BuildAutomatonPayload({
    required this.expectedFsm,
    this.initialFsm = Fsm.empty,
    this.readyPresetsOnly = false,
    this.requireTransitionEndpoints = false,
    this.allowedTools = const {
      FsmEditorTool.select,
      FsmEditorTool.addState,
      FsmEditorTool.addTransition,
      FsmEditorTool.setInitial,
      FsmEditorTool.editOutput,
      FsmEditorTool.delete,
    },
    this.sourceFsm,
    this.inputAlphabet = const [],
    this.evaluationMode = FsmEvaluationMode.legacyStructural,
    this.outputTrace,
    this.tableRequirement = false,
  });

  final Fsm initialFsm;
  final Fsm expectedFsm;
  final bool readyPresetsOnly;
  final bool requireTransitionEndpoints;
  final Set<FsmEditorTool> allowedTools;
  final Fsm? sourceFsm;
  final List<String> inputAlphabet;
  final FsmEvaluationMode evaluationMode;
  final List<String>? outputTrace;
  final bool tableRequirement;
}

/// Wählt zwischen Vergleich der konkreten Struktur und Vergleich des erreichbaren Ausgabeverhaltens.
enum FsmEvaluationMode { legacyStructural, behavioral }

/// Tabellenzeile mit Zustands-ID, Folgezuständen je Eingabe und zustandsabhängiger Ausgabe.
class FsmTableRow {
  const FsmTableRow({
    required this.stateId,
    required this.transitions,
    required this.output,
  });

  final String stateId;
  final Map<String, String> transitions;
  final String output;
}

/// Daten einer Tabellenaufgabe mit Beschreibung oder Quellautomat und erwarteten Ergebniszeilen.
class Aa6BuildTablePayload extends LessonTaskPayload {
  const Aa6BuildTablePayload({
    required this.inputSymbols,
    required this.expectedRows,
    this.sourceDescriptionKey,
    this.sourceFsm,
    this.circuitDiagramId,
  }) : assert(sourceDescriptionKey != null || sourceFsm != null);

  final String? sourceDescriptionKey;
  final Fsm? sourceFsm;

  /// Optionale ID der zu den Tabellenzeilen passenden Schaltung aus Kapitel 2.
  final String? circuitDiagramId;
  final List<String> inputSymbols;
  final List<FsmTableRow> expectedRows;
}

/// Legt Automat, Eingabefolge und erwartete Zustandsspur für eine Nachverfolgungsaufgabe fest.
class Aa7TraceStatePayload extends LessonTaskPayload {
  const Aa7TraceStatePayload({
    required this.fsm,
    required this.inputSymbols,
    required this.expectedStateIds,
  });

  final Fsm fsm;
  final List<String> inputSymbols;
  final List<String> expectedStateIds;
}

/// Vervollständigungsaufgabe mit Teilmodell, Referenzautomat und begrenzbaren Bearbeitungsaktionen.
class Aa8CompleteAutomatonPayload extends LessonTaskPayload {
  const Aa8CompleteAutomatonPayload({
    required this.partialFsm,
    required this.expectedFsm,
    this.readyPresetsOnly = false,
    this.allowedTools = const {
      FsmEditorTool.select,
      FsmEditorTool.addState,
      FsmEditorTool.addTransition,
      FsmEditorTool.setInitial,
      FsmEditorTool.editOutput,
      FsmEditorTool.delete,
    },
    this.inputAlphabet = const [],
    this.evaluationMode = FsmEvaluationMode.legacyStructural,
  });

  final Fsm partialFsm;
  final Fsm expectedFsm;
  final bool readyPresetsOnly;
  final Set<FsmEditorTool> allowedTools;
  final List<String> inputAlphabet;
  final FsmEvaluationMode evaluationMode;
}

/// Beschriftetes Diagrammelement, das bei einer Auswahlaufgabe als Antwort markiert werden kann.
class DiagramSelectionTarget {
  const DiagramSelectionTarget({required this.id, required this.label});

  final String id;
  final String label;
}

/// Verknüpft einen Automaten mit auswählbaren Diagrammzielen und den korrekten Ziel-IDs.
class DiagramSelectionPayload extends LessonTaskPayload {
  const DiagramSelectionPayload({
    required this.fsm,
    required this.targets,
    required this.correctTargetIds,
  });

  final Fsm fsm;
  final List<DiagramSelectionTarget> targets;
  final Set<String> correctTargetIds;
}

enum TheoryResponseType { multipleChoice, trueFalse, freeText }

/// Konfiguriert das Antwortformat einer Theorieaufgabe und gegebenenfalls akzeptierte Freitexte.
class Aa9TheoryPayload extends LessonTaskPayload {
  const Aa9TheoryPayload({
    required this.responseType,
    this.acceptedTextAnswers = const [],
    this.caseSensitive = false,
  });

  final TheoryResponseType responseType;
  final List<String> acceptedTextAnswers;
  final bool caseSensitive;
}
