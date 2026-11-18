import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:flutter/foundation.dart';

/// Verwaltet Zeichenwerkzeuge, Auswahl und bis zu 50 rückgängig machbare Änderungen.
class FsmEditorController extends ChangeNotifier {
  FsmEditorController({Fsm initialFsm = Fsm.empty, this.boundedCanvas = true})
    : _fsm = initialFsm;

  /// Begrenzt Zustandspositionen auf die sichtbare Zeichenfläche.
  /// Die Sandbox deaktiviert dies für eine verschiebbare, größere Arbeitsfläche.
  final bool boundedCanvas;

  double _clampX(double x) => boundedCanvas ? x.clamp(0.08, 0.92) : x;
  double _clampY(double y) => boundedCanvas ? y.clamp(0.10, 0.90) : y;

  static const _maxHistoryLength = 50;

  Fsm _fsm;
  FsmEditorTool _tool = FsmEditorTool.select;
  String? _selectedStateId;
  final List<Fsm> _undoHistory = [];
  Fsm? _moveStartFsm;

  Fsm get fsm => _fsm;
  FsmEditorTool get tool => _tool;
  String? get selectedStateId => _selectedStateId;
  bool get canUndo => _undoHistory.isNotEmpty;

  /// Lädt einen Automaten und verwirft Auswahl sowie bisherige Rückgängig-Schritte.
  void replaceFsm(Fsm value) {
    _fsm = value;
    _selectedStateId = null;
    _undoHistory.clear();
    _moveStartFsm = null;
    notifyListeners();
  }

  void clear() {
    if (_fsm.states.isEmpty &&
        _fsm.transitions.isEmpty &&
        _fsm.initialStateId == null) {
      return;
    }
    _commit(
      _fsm.copyWith(
        states: const [],
        transitions: const [],
        clearInitialState: true,
      ),
    );
    _selectedStateId = null;
  }

  void undo() {
    if (_undoHistory.isEmpty) return;
    _fsm = _undoHistory.removeLast();
    _selectedStateId = null;
    _moveStartFsm = null;
    notifyListeners();
  }

  void setTool(FsmEditorTool value) {
    _tool = value;
    _selectedStateId = null;
    notifyListeners();
  }

  /// Beim Wechsel zu Moore verlieren Übergänge ihre Mealy-Ausgabe, sodass nur
  /// die Eingabe als Beschriftung bleibt. Dadurch entstehende Duplikate werden
  /// zusammengefasst; Rückgängig stellt die Ausgaben wieder her.
  void setOutputMode(FsmOutputMode value) {
    if (_fsm.outputMode == value) return;
    if (value != FsmOutputMode.moore) {
      _commit(_fsm.copyWith(outputMode: value));
      return;
    }
    final seenIds = <String>{};
    final transitions = [
      for (final transition in _fsm.transitions)
        if (transition.copyWith(symbol: transition.inputSymbol)
            case final stripped
            when stripped.symbol.isNotEmpty && seenIds.add(stripped.id))
          stripped,
    ];
    _commit(_fsm.copyWith(outputMode: value, transitions: transitions));
  }

  void selectState(String? stateId) {
    _selectedStateId = stateId;
    notifyListeners();
  }

  void addState({
    required double x,
    required double y,
    String? label,
    String? id,
    String output = '',
  }) {
    final index = _nextStateIndex();
    final normalizedLabel = label?.trim();
    final state = FsmState(
      id: id ?? 'q$index',
      label: normalizedLabel == null || normalizedLabel.isEmpty
          ? 'q$index'
          : normalizedLabel,
      output: output.trim(),
      x: _clampX(x),
      y: _clampY(y),
    );
    _selectedStateId = state.id;
    _commit(_fsm.copyWith(states: [..._fsm.states, state]));
  }

  void arrangeStatesZigzag() {
    final states = _fsm.states;
    if (states.length < 2) return;

    const statesPerRow = 4;
    final rowCount = (states.length + statesPerRow - 1) ~/ statesPerRow;
    final arrangedStates = <FsmState>[];

    for (var index = 0; index < states.length; index++) {
      final row = index ~/ statesPerRow;
      final offsetInRow = index % statesPerRow;
      final remainingStates = states.length - row * statesPerRow;
      final statesInRow = remainingStates < statesPerRow
          ? remainingStates
          : statesPerRow;
      final column = row.isEven ? offsetInRow : statesInRow - 1 - offsetInRow;
      final x = statesInRow == 1
          ? 0.5
          : 0.14 + column * (0.72 / (statesInRow - 1));
      final y = rowCount == 1
          ? (offsetInRow.isEven ? 0.36 : 0.64)
          : 0.16 +
                row * (0.68 / (rowCount - 1)) +
                (offsetInRow.isEven ? -0.035 : 0.035);

      arrangedStates.add(
        states[index].copyWith(
          x: x.clamp(0.08, 0.92).toDouble(),
          y: y.clamp(0.10, 0.90).toDouble(),
        ),
      );
    }

    _commit(_fsm.copyWith(states: arrangedStates));
  }

  /// Merkt den Stand vor einer Ziehbewegung, sodass die gesamte Bewegung
  /// beim Loslassen als ein einziger Rückgängig-Schritt gespeichert wird.
  void beginStateMove() {
    _moveStartFsm ??= _fsm;
  }

  void moveState(String stateId, {required double x, required double y}) {
    final movedFsm = _fsm.copyWith(
      states: [
        for (final state in _fsm.states)
          if (state.id == stateId)
            state.copyWith(x: _clampX(x), y: _clampY(y))
          else
            state,
      ],
    );
    if (_moveStartFsm == null) {
      _commit(movedFsm);
      return;
    }
    _fsm = movedFsm;
    notifyListeners();
  }

  void endStateMove() {
    final startFsm = _moveStartFsm;
    _moveStartFsm = null;
    if (startFsm == null || identical(startFsm, _fsm)) return;
    _pushUndo(startFsm);
    notifyListeners();
  }

  void renameState(String stateId, String label) {
    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty) return;
    final current = _fsm.stateById(stateId);
    if (current == null || current.label == normalizedLabel) return;
    _commit(
      _fsm.copyWith(
        states: [
          for (final state in _fsm.states)
            state.id == stateId
                ? state.copyWith(label: normalizedLabel)
                : state,
        ],
      ),
    );
  }

  void setInitialState(String stateId) {
    if (_fsm.initialStateId == stateId) return;
    _selectedStateId = stateId;
    _commit(_fsm.copyWith(initialStateId: stateId));
  }

  void setStateOutput(String stateId, String output) {
    final normalizedOutput = output.trim();
    final current = _fsm.stateById(stateId);
    if (current == null || current.output == normalizedOutput) return;
    _commit(
      _fsm.copyWith(
        states: [
          for (final state in _fsm.states)
            state.id == stateId
                ? state.copyWith(output: normalizedOutput)
                : state,
        ],
      ),
    );
  }

  void addTransition({
    required String fromStateId,
    required String toStateId,
    required String symbol,
  }) {
    final normalizedSymbol = symbol.trim();
    if (normalizedSymbol.isEmpty) return;
    final transition = FsmTransition(
      fromStateId: fromStateId,
      toStateId: toStateId,
      symbol: normalizedSymbol,
    );
    if (_fsm.transitions.any((item) => item.id == transition.id)) return;
    _selectedStateId = null;
    _commit(_fsm.copyWith(transitions: [..._fsm.transitions, transition]));
  }

  void setTransitionSymbol(String transitionId, String symbol) {
    final normalizedSymbol = symbol.trim();
    if (normalizedSymbol.isEmpty) return;
    final matches = _fsm.transitions.where(
      (transition) => transition.id == transitionId,
    );
    if (matches.isEmpty) return;
    final current = matches.first;
    if (current.symbol == normalizedSymbol) return;
    if (_fsm.transitions.any(
      (transition) =>
          transition.id != transitionId &&
          transition.fromStateId == current.fromStateId &&
          transition.toStateId == current.toStateId &&
          transition.symbol == normalizedSymbol,
    )) {
      return;
    }
    _commit(
      _fsm.copyWith(
        transitions: [
          for (final transition in _fsm.transitions)
            transition.id == transitionId
                ? transition.copyWith(symbol: normalizedSymbol)
                : transition,
        ],
      ),
    );
  }

  void removeTransition(String transitionId) {
    if (!_fsm.transitions.any((transition) => transition.id == transitionId)) {
      return;
    }
    _commit(
      _fsm.copyWith(
        transitions: [
          for (final transition in _fsm.transitions)
            if (transition.id != transitionId) transition,
        ],
      ),
    );
  }

  /// Entfernt auch verbundene Übergänge und gegebenenfalls die Startmarkierung.
  void removeState(String stateId) {
    if (_fsm.stateById(stateId) == null) return;
    if (_selectedStateId == stateId) _selectedStateId = null;
    _commit(
      _fsm.copyWith(
        states: [
          for (final state in _fsm.states)
            if (state.id != stateId) state,
        ],
        transitions: [
          for (final transition in _fsm.transitions)
            if (transition.fromStateId != stateId &&
                transition.toStateId != stateId)
              transition,
        ],
        clearInitialState: _fsm.initialStateId == stateId,
      ),
    );
  }

  void _commit(Fsm value) {
    _pushUndo(_fsm);
    _fsm = value;
    _moveStartFsm = null;
    notifyListeners();
  }

  void _pushUndo(Fsm value) {
    _undoHistory.add(value);
    if (_undoHistory.length > _maxHistoryLength) {
      _undoHistory.removeAt(0);
    }
  }

  int _nextStateIndex() {
    var index = 0;
    final ids = _fsm.states.map((state) => state.id).toSet();
    while (ids.contains('q$index')) {
      index++;
    }
    return index;
  }
}
