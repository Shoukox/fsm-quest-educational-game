import 'dart:collection';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_validator.dart';

class FsmBehaviorResult {
  const FsmBehaviorResult(
    this.isEquivalent, {
    this.counterexample = const [],
    this.actualStateId,
    this.actualOutput,
    this.expectedOutput,
  });
  final bool isEquivalent;

  /// Kürzeste gefundene Eingabefolge, deren letzter Schritt eine Abweichung zeigt.
  final List<String> counterexample;

  /// Zustand der Abgabe vor der letzten Eingabe des Gegenbeispiels.
  final String? actualStateId;

  /// Ausgaben von Abgabe und Referenz nach dem Gegenbeispiel.
  final String? actualOutput;
  final String? expectedOutput;
}

/// Vergleicht erreichbares Ausgabeverhalten über Paare von Automatenzuständen.
/// Zustandsnamen und Zeichnungspositionen beeinflussen das Ergebnis nicht.
class FsmBehaviorEquivalence {
  const FsmBehaviorEquivalence();

  FsmBehaviorResult compare(
    Fsm actual,
    Fsm expected, {
    required List<String> inputAlphabet,
  }) {
    if (actual.outputMode != expected.outputMode ||
        actual.initialStateId == null ||
        expected.initialStateId == null) {
      return const FsmBehaviorResult(false);
    }
    // Der Vergleich setzt deterministische, vollständige Automaten über dem
    // vereinbarten Alphabet voraus. Strukturfehler werden deshalb vor der
    // Breitensuche abgefangen und nicht nur entlang einer kurzen Spur geprüft.
    const validator = FsmValidator();
    if (validator
            .validate(actual, inputAlphabet: inputAlphabet, requireTotal: true)
            .isNotEmpty ||
        validator
            .validate(
              expected,
              inputAlphabet: inputAlphabet,
              requireTotal: true,
            )
            .isNotEmpty) {
      return const FsmBehaviorResult(false);
    }
    if (actual.outputMode == FsmOutputMode.moore &&
        actual.stateById(actual.initialStateId!)?.output !=
            expected.stateById(expected.initialStateId!)?.output) {
      return const FsmBehaviorResult(false);
    }
    // Die Breitensuche findet eine kürzeste unterscheidende Eingabefolge.
    // Bereits besuchte Zustandspaare begrenzen die Suche auch bei Zyklen.
    final queue = Queue<_Pair>()
      ..add(_Pair(actual.initialStateId!, expected.initialStateId!, const []));
    final visited = <String>{};
    while (queue.isNotEmpty) {
      final pair = queue.removeFirst();
      final key = '${pair.actual}|${pair.expected}';
      if (!visited.add(key)) {
        continue;
      }
      for (final input in inputAlphabet) {
        final at = _transition(actual, pair.actual, input);
        final et = _transition(expected, pair.expected, input);
        if (at == null || et == null) {
          return FsmBehaviorResult(
            false,
            counterexample: [...pair.trace, input],
            actualStateId: pair.actual,
          );
        }
        final ao = actual.outputMode == FsmOutputMode.moore
            ? actual.stateById(at.toStateId)?.output
            : at.outputValue;
        final eo = expected.outputMode == FsmOutputMode.moore
            ? expected.stateById(et.toStateId)?.output
            : et.outputValue;
        if (ao != eo) {
          return FsmBehaviorResult(
            false,
            counterexample: [...pair.trace, input],
            actualStateId: pair.actual,
            actualOutput: ao,
            expectedOutput: eo,
          );
        }
        queue.add(_Pair(at.toStateId, et.toStateId, [...pair.trace, input]));
      }
    }
    return const FsmBehaviorResult(true);
  }

  dynamic _transition(Fsm fsm, String state, String input) {
    for (final transition in fsm.transitions) {
      if (transition.fromStateId == state && transition.inputSymbol == input) {
        return transition;
      }
    }
    return null;
  }
}

class _Pair {
  const _Pair(this.actual, this.expected, this.trace);
  final String actual;
  final String expected;
  final List<String> trace;
}
