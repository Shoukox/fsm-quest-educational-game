import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_sandbox_tools.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:flutter_test/flutter_test.dart';

const _toggle = Fsm(
  initialStateId: 'q0',
  states: [
    FsmState(id: 'q0', label: 'Aus', output: '0', x: .3, y: .4),
    FsmState(id: 'q1', label: 'An', output: '1', x: .7, y: .4),
  ],
  transitions: [
    FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '0'),
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: '1'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q1', symbol: '0'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: '1'),
  ],
);

void main() {
  group('deriveInputAlphabet', () {
    test('lists drawn input symbols once, in order of first use', () {
      expect(deriveInputAlphabet(_toggle), ['0', '1']);
    });

    test('uses only the input part of Mealy labels', () {
      const mealy = Fsm(
        outputMode: FsmOutputMode.mealy,
        states: [FsmState(id: 'q0', label: 'q0')],
        transitions: [
          FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'a / x'),
          FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'b / y'),
        ],
      );
      expect(deriveInputAlphabet(mealy), ['a', 'b']);
    });
  });

  group('parseInputSequence', () {
    test('splits on spaces and commas', () {
      expect(
        parseInputSequence('Münze, Durchgang  Münze', ['Münze', 'Durchgang']),
        ['Münze', 'Durchgang', 'Münze'],
      );
    });

    test('reads a word of single-character symbols character by character', () {
      expect(parseInputSequence('101', ['0', '1']), ['1', '0', '1']);
    });

    test('keeps an unknown word whole so it can be reported', () {
      expect(parseInputSequence('abc', ['0', '1']), ['abc']);
    });

    test('returns no symbols for empty input', () {
      expect(parseInputSequence('  ,  ', ['0']), isEmpty);
    });
  });

  group('simulateWithDiagnosis', () {
    test('Moore run includes the initial output', () {
      final result = simulateWithDiagnosis(_toggle, ['1', '0', '1']);
      expect(result.isComplete, isTrue);
      expect(result.steps.map((s) => s.stateId), ['q0', 'q1', 'q1', 'q0']);
      expect(result.steps.map((s) => s.output), ['0', '1', '1', '0']);
    });

    test('stops at a missing transition and names state and input', () {
      final fsm = _toggle.copyWith(
        transitions: _toggle.transitions
            .where((t) => !(t.fromStateId == 'q1' && t.inputSymbol == '0'))
            .toList(),
      );
      final result = simulateWithDiagnosis(fsm, ['1', '0']);
      expect(result.stop, FsmSimulationStop.missingTransition);
      expect(result.stopStateId, 'q1');
      expect(result.stopSymbol, '0');
      expect(result.steps, hasLength(2));
    });

    test('stops at competing transitions', () {
      final fsm = _toggle.copyWith(
        transitions: [
          ..._toggle.transitions,
          const FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '1'),
        ],
      );
      final result = simulateWithDiagnosis(fsm, ['1']);
      expect(result.stop, FsmSimulationStop.nondeterministicTransition);
    });

    test('reports unknown symbols and a missing initial state', () {
      expect(
        simulateWithDiagnosis(_toggle, ['2']).stop,
        FsmSimulationStop.unknownSymbol,
      );
      expect(
        simulateWithDiagnosis(_toggle.copyWith(clearInitialState: true), [
          '1',
        ]).stop,
        FsmSimulationStop.missingInitialState,
      );
    });

    test('Mealy outputs come from the used transitions', () {
      const mealy = Fsm(
        outputMode: FsmOutputMode.mealy,
        initialStateId: 'q0',
        states: [FsmState(id: 'q0', label: 'q0')],
        transitions: [
          FsmTransition(
            fromStateId: 'q0',
            toStateId: 'q0',
            symbol: '0 / CLOSE',
          ),
          FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '1 / OPEN'),
        ],
      );
      final result = simulateWithDiagnosis(mealy, ['0', '1', '0']);
      expect(result.steps.skip(1).map((s) => s.output), [
        'CLOSE',
        'OPEN',
        'CLOSE',
      ]);
    });
  });

  group('FsmJsonCodec', () {
    test('round-trips states, transitions, initial state and mode', () {
      final decoded = FsmJsonCodec.decode(FsmJsonCodec.encode(_toggle))!;
      expect(decoded.initialStateId, 'q0');
      expect(decoded.outputMode, FsmOutputMode.moore);
      expect(decoded.states.map((s) => s.label), ['Aus', 'An']);
      expect(decoded.states.first.x, .3);
      expect(
        decoded.transitions.map((t) => t.id),
        _toggle.transitions.map((t) => t.id),
      );
    });

    test('returns null for missing or damaged data', () {
      expect(FsmJsonCodec.decode(null), isNull);
      expect(FsmJsonCodec.decode('{not json'), isNull);
      expect(FsmJsonCodec.decode('{"states": 3}'), isNull);
    });
  });
}
