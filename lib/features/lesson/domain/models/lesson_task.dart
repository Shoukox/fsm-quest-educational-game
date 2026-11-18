import 'package:bachelor/features/lesson/domain/models/task_difficulty.dart';
import 'package:bachelor/features/lesson/domain/models/task_kind.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';

enum LessonTaskType { multipleChoice, buildFsm, predictOutput }

/// Beschreibt eine Aufgabe einschließlich Textschlüsseln, Hilfen und Bewertungsdaten.
/// Der Payload enthält die Daten der konkreten Interaktion; ältere Aufgaben können
/// weiterhin Typ, Antwortoptionen und korrekte Antwort-ID direkt verwenden.
class LessonTask {
  const LessonTask({
    required this.id,
    required this.prompt,
    required this.type,
    this.answers = const [],
    this.correctAnswerId,
    this.concept,
    this.instruction,
    this.hint,
    this.inputSteps = const [],
    this.feedbackByAnswer = const {},
    this.difficulty = TaskDifficulty.ss1,
    this.kind,
    this.payload,
    this.illustration,
    this.showStateIdentifiers = true,
    this.illustrationLegendKeys = const [],
  });

  final String id;
  final String prompt;
  final LessonTaskType type;
  final List<String> answers;
  final String? correctAnswerId;
  final String? concept;
  final String? instruction;
  final String? hint;
  final List<String> inputSteps;
  final Map<String, String> feedbackByAnswer;
  final TaskDifficulty difficulty;
  final TaskKind? kind;
  final LessonTaskPayload? payload;
  final Fsm? illustration;

  /// Steuert formale Zustands-IDs; einführende Aufgaben verwenden zunächst beschreibende Namen.
  final bool showStateIdentifiers;
  final List<String> illustrationLegendKeys;

  /// Verwendet die explizite Aufgabenart oder leitet sie aus dem älteren Aufgabentyp ab.
  TaskKind get resolvedKind {
    final explicitKind = kind;
    if (explicitKind != null) return explicitKind;
    return switch (type) {
      LessonTaskType.buildFsm => TaskKind.aa4BuildAutomaton,
      LessonTaskType.predictOutput => TaskKind.aa7TraceState,
      LessonTaskType.multipleChoice => TaskKind.aa9Theory,
    };
  }
}
