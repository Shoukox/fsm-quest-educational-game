import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';

/// Ergänzt fehlende Ereignisübergänge als Selbstschleifen.
/// Ereignisse ohne festgelegten Zustandswechsel behalten damit den Zustand bei;
/// das Modell wird über seinem verwendeten Alphabet vollständig.
Fsm _complete(Fsm machine) {
  final inputs = machine.transitions.map((t) => t.inputSymbol).toSet();
  return machine.copyWith(
    transitions: [
      ...machine.transitions,
      for (final state in machine.states)
        for (final input in inputs)
          if (!machine.transitions.any(
            (t) => t.fromStateId == state.id && t.inputSymbol == input,
          ))
            FsmTransition(
              fromStateId: state.id,
              toStateId: state.id,
              symbol: input,
            ),
    ],
  );
}

final creationBikeRental = _complete(
  Fsm(
    initialStateId: 'q0',
    outputMode: FsmOutputMode.moore,
    states: const [
      FsmState(id: 'q0', label: 'BIKE LOCKED', output: 'WAIT', x: .2, y: .5),
      FsmState(
        id: 'q1',
        label: 'CODE ACCEPTED',
        output: 'UNLOCK',
        x: .5,
        y: .3,
      ),
      FsmState(id: 'q2', label: 'BIKE TAKEN', output: 'RIDE', x: .8, y: .5),
    ],
    transitions: const [
      FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'valid code'),
      FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'wrong code'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: 'take bike'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'timeout'),
      FsmTransition(fromStateId: 'q2', toStateId: 'q0', symbol: 'return bike'),
    ],
  ),
);

/// Paketstation als zusätzliches Übungsszenario: Paket einlegen, Abholcode prüfen
/// und nach dem Schließen der Tür wieder in den leeren Zustand zurückkehren.
final creationParcelKiosk = _complete(
  Fsm(
    initialStateId: 'q0',
    outputMode: FsmOutputMode.moore,
    states: const [
      FsmState(id: 'q0', label: 'EMPTY', output: 'READY', x: .2, y: .5),
      FsmState(
        id: 'q1',
        label: 'PARCEL STORED',
        output: 'LOCKED',
        x: .5,
        y: .3,
      ),
      FsmState(id: 'q2', label: 'PICKUP OPEN', output: 'OPEN', x: .8, y: .5),
    ],
    transitions: const [
      FsmTransition(
        fromStateId: 'q0',
        toStateId: 'q1',
        symbol: 'parcel inserted',
      ),
      FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: 'valid code'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q1', symbol: 'wrong code'),
      FsmTransition(fromStateId: 'q2', toStateId: 'q0', symbol: 'door closed'),
    ],
  ),
);

final creationParkingBarrier = _complete(
  Fsm(
    initialStateId: 'q0',
    outputMode: FsmOutputMode.moore,
    states: const [
      FsmState(id: 'q0', label: 'BARRIER CLOSED', output: 'STOP', x: .2, y: .5),
      FsmState(id: 'q1', label: 'TICKET CHECKED', output: 'WAIT', x: .5, y: .3),
      FsmState(id: 'q2', label: 'BARRIER OPEN', output: 'GO', x: .8, y: .5),
    ],
    transitions: const [
      FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'ticket'),
      FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'timeout'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: 'ticket'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'timeout'),
      FsmTransition(fromStateId: 'q2', toStateId: 'q2', symbol: 'ticket'),
      FsmTransition(fromStateId: 'q2', toStateId: 'q0', symbol: 'timeout'),
    ],
  ),
);

final creationCoffeeMachine = _complete(
  Fsm(
    initialStateId: 'q0',
    outputMode: FsmOutputMode.moore,
    states: const [
      FsmState(id: 'q0', label: 'WAITING', output: 'INSERT COIN', x: .3, y: .5),
      FsmState(id: 'q1', label: 'PAID', output: 'CHOOSE DRINK', x: .7, y: .5),
    ],
    transitions: const [
      FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'coin'),
      FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'cancel'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'drink chosen'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'cancel'),
    ],
  ),
);

final creationLocker = _complete(
  Fsm(
    initialStateId: 'q0',
    outputMode: FsmOutputMode.moore,
    states: const [
      FsmState(
        id: 'q0',
        label: 'LOCKER EMPTY',
        output: 'AVAILABLE',
        x: .2,
        y: .5,
      ),
      FsmState(
        id: 'q1',
        label: 'PARCEL STORED',
        output: 'LOCKED',
        x: .5,
        y: .3,
      ),
      FsmState(id: 'q2', label: 'DOOR OPEN', output: 'OPEN', x: .8, y: .5),
    ],
    transitions: const [
      FsmTransition(
        fromStateId: 'q0',
        toStateId: 'q1',
        symbol: 'parcel inserted',
      ),
      FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: 'correct PIN'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q1', symbol: 'wrong PIN'),
      FsmTransition(fromStateId: 'q2', toStateId: 'q0', symbol: 'door closed'),
    ],
  ),
);

final creationWashCycle = _complete(
  Fsm(
    initialStateId: 'q0',
    outputMode: FsmOutputMode.moore,
    states: const [
      FsmState(id: 'q0', label: 'IDLE', output: 'READY', x: .15, y: .5),
      FsmState(id: 'q1', label: 'WASHING', output: 'WASH', x: .38, y: .25),
      FsmState(id: 'q2', label: 'RINSING', output: 'RINSE', x: .62, y: .25),
      FsmState(id: 'q3', label: 'DONE', output: 'UNLOCK', x: .85, y: .5),
    ],
    transitions: const [
      FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'start'),
      FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: 'wash done'),
      FsmTransition(fromStateId: 'q2', toStateId: 'q3', symbol: 'rinse done'),
      FsmTransition(fromStateId: 'q3', toStateId: 'q0', symbol: 'door opened'),
    ],
  ),
);
