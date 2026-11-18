import 'dart:convert';

import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/simulation_step.dart';

/// Liefert verwendete Eingabesymbole in der Reihenfolge ihres ersten Auftretens.
/// Die freie Sandbox hat kein vorgegebenes Aufgabenalphabet; Tabellen,
/// Strukturprüfung und Simulation verwenden daher die gezeichneten Übergänge.
List<String> deriveInputAlphabet(Fsm fsm) {
  final symbols = <String>[];
  for (final transition in fsm.transitions) {
    final symbol = transition.inputSymbol;
    if (symbol.isNotEmpty && !symbols.contains(symbol)) symbols.add(symbol);
  }
  return symbols;
}

/// Zerlegt eine Eingabefolge anhand von [alphabet] in einzelne Symbole.
/// Leerraum, Kommas und Semikolons trennen Symbole wie `Münze, Durchgang`.
/// Ohne Trennzeichen wird nur dann zeichenweise zerlegt, wenn kein ganzes
/// Alphabetsymbol vorliegt und jedes Zeichen selbst zum Alphabet gehört.
List<String> parseInputSequence(String raw, List<String> alphabet) {
  final tokens = raw
      .split(RegExp(r'[\s,;]+'))
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty)
      .toList();
  if (tokens.length != 1 || alphabet.contains(tokens.single)) return tokens;
  final characters = tokens.single.runes.map(String.fromCharCode).toList();
  final allSingleSymbols = characters.every(alphabet.contains);
  return allSingleSymbols ? characters : tokens;
}

enum FsmSimulationStop {
  /// Alle Symbole wurden verarbeitet.
  completed,

  /// Dem Automaten fehlt ein gültiger Startzustand.
  missingInitialState,

  /// Das Symbol kommt auf keinem Übergang des Automaten vor.
  unknownSymbol,

  /// Am aktuellen Zustand fehlt ein gültiger Übergang für das Symbol.
  missingTransition,

  /// Am aktuellen Zustand gibt es mehrere Übergänge für das Symbol.
  nondeterministicTransition,
}

class FsmSimulationResult {
  const FsmSimulationResult({
    required this.steps,
    required this.stop,
    this.stopSymbol,
    this.stopStateId,
  });

  /// Startzustand, gefolgt von einem Eintrag je verarbeitetem Symbol.
  final List<SimulationStep> steps;
  final FsmSimulationStop stop;

  /// Symbol, das beim vorzeitigen Abbruch nicht verarbeitet werden konnte.
  final String? stopSymbol;

  /// Zustand, an dem der Lauf vorzeitig beendet wurde.
  final String? stopStateId;

  bool get isComplete => stop == FsmSimulationStop.completed;
}

/// Simuliert [symbols] auf [fsm] und liefert bei vorzeitigem Abbruch die Ursache.
FsmSimulationResult simulateWithDiagnosis(Fsm fsm, List<String> symbols) {
  final initialStateId = fsm.initialStateId;
  final initialState = initialStateId == null
      ? null
      : fsm.stateById(initialStateId);
  if (initialState == null) {
    return const FsmSimulationResult(
      steps: [],
      stop: FsmSimulationStop.missingInitialState,
    );
  }

  final alphabet = deriveInputAlphabet(fsm);
  final steps = <SimulationStep>[
    SimulationStep(
      stateId: initialState.id,
      inputIndex: 0,
      consumedSymbol: '',
      output: fsm.outputMode == FsmOutputMode.moore ? initialState.output : '',
    ),
  ];
  var currentStateId = initialState.id;
  for (var index = 0; index < symbols.length; index++) {
    final symbol = symbols[index];
    if (!alphabet.contains(symbol)) {
      return FsmSimulationResult(
        steps: steps,
        stop: FsmSimulationStop.unknownSymbol,
        stopSymbol: symbol,
        stopStateId: currentStateId,
      );
    }
    final matches = fsm.transitions
        .where(
          (transition) =>
              transition.fromStateId == currentStateId &&
              transition.inputSymbol == symbol,
        )
        .toList();
    if (matches.length != 1) {
      return FsmSimulationResult(
        steps: steps,
        stop: matches.isEmpty
            ? FsmSimulationStop.missingTransition
            : FsmSimulationStop.nondeterministicTransition,
        stopSymbol: symbol,
        stopStateId: currentStateId,
      );
    }
    final transition = matches.single;
    final nextState = fsm.stateById(transition.toStateId);
    if (nextState == null) {
      return FsmSimulationResult(
        steps: steps,
        stop: FsmSimulationStop.missingTransition,
        stopSymbol: symbol,
        stopStateId: currentStateId,
      );
    }
    currentStateId = nextState.id;
    steps.add(
      SimulationStep(
        stateId: nextState.id,
        inputIndex: index + 1,
        consumedSymbol: symbol,
        output: fsm.outputMode == FsmOutputMode.mealy
            ? transition.outputValue
            : nextState.output,
      ),
    );
  }
  return FsmSimulationResult(steps: steps, stop: FsmSimulationStop.completed);
}

/// Kodiert und dekodiert Sandbox-Automaten für die lokale JSON-Speicherung.
abstract final class FsmJsonCodec {
  static String encode(Fsm fsm) => jsonEncode({
    'version': 1,
    'mode': fsm.outputMode.name,
    'initial': fsm.initialStateId,
    'states': [
      for (final state in fsm.states)
        {
          'id': state.id,
          'label': state.label,
          'output': state.output,
          'x': state.x,
          'y': state.y,
        },
    ],
    'transitions': [
      for (final transition in fsm.transitions)
        {
          'from': transition.fromStateId,
          'to': transition.toStateId,
          'symbol': transition.symbol,
        },
    ],
  });

  /// Liefert bei fehlenden oder unlesbaren Daten `null` statt einer Ausnahme.
  /// Ein beschädigter Eintrag betrifft so nur den gespeicherten Sandbox-Entwurf.
  static Fsm? decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final states = [
        for (final item in data['states'] as List<dynamic>)
          FsmState(
            id: (item as Map<String, dynamic>)['id'] as String,
            label: item['label'] as String,
            output: item['output'] as String? ?? '',
            x: (item['x'] as num?)?.toDouble() ?? 0.5,
            y: (item['y'] as num?)?.toDouble() ?? 0.5,
          ),
      ];
      final transitions = [
        for (final item in data['transitions'] as List<dynamic>)
          FsmTransition(
            fromStateId: (item as Map<String, dynamic>)['from'] as String,
            toStateId: item['to'] as String,
            symbol: item['symbol'] as String,
          ),
      ];
      final mode = FsmOutputMode.values.firstWhere(
        (value) => value.name == data['mode'],
        orElse: () => FsmOutputMode.moore,
      );
      return Fsm(
        states: states,
        transitions: transitions,
        initialStateId: data['initial'] as String?,
        outputMode: mode,
      );
    } on Object {
      return null;
    }
  }
}
