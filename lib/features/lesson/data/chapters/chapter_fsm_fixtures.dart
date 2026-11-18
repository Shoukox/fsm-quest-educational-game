import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';

/// Erzeugt einen Moore-Beispielautomaten aus Ausgaben und Folgezustandstabelle.
/// Zeilen entsprechen q0, q1, ...; Spaltenindizes werden als Eingabesymbole verwendet.
Fsm moore(List<String> outputs, List<List<String>> next) => Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.moore,
  states: [
    for (var i = 0; i < outputs.length; i++)
      FsmState(id: 'q$i', label: 'q$i', output: outputs[i], x: .2 + i * .2),
  ],
  transitions: [
    for (var i = 0; i < next.length; i++)
      for (var a = 0; a < next[i].length; a++)
        FsmTransition(fromStateId: 'q$i', toStateId: next[i][a], symbol: '$a'),
  ],
);

/// Erzeugt einen Mealy-Beispielautomaten aus gleich indizierten Ziel- und Ausgabetabellen.
Fsm mealy(List<List<String>> next, List<List<String>> outputs) => Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.mealy,
  states: [
    for (var i = 0; i < next.length; i++)
      FsmState(id: 'q$i', label: 'q$i', x: .2 + i * .2),
  ],
  transitions: [
    for (var i = 0; i < next.length; i++)
      for (var a = 0; a < next[i].length; a++)
        FsmTransition(
          fromStateId: 'q$i',
          toStateId: next[i][a],
          symbol: '$a / ${outputs[i][a]}',
        ),
  ],
);

// Historische Referenzmodelle für Regressionstests der Umwandlungsfunktionen.
// Diese Modelle gehören nicht zum aktiven Lektionsinhalt.
final chapter3Moore = moore(
  ['0', '1', '0'],
  [
    ['q1', 'q0'],
    ['q2', 'q0'],
    ['q2', 'q1'],
  ],
);
final chapter3Mealy = mealy(
  [
    ['q1', 'q0'],
    ['q1', 'q0'],
  ],
  [
    ['1', '0'],
    ['0', '1'],
  ],
);

/// Münzautomat: 0 = Abbrechen/Zurücksetzen, 1 = eine Münze einwerfen.
/// q2 gibt das Ausgabesignal aus und kehrt danach zu q0 zurück.
final chapter4CoinMachine = moore(
  ['0', '0', '1'],
  [
    ['q0', 'q1'],
    ['q0', 'q2'],
    ['q0', 'q0'],
  ],
);

final chapter4CoinMachinePartial = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.moore,
  states: [
    const FsmState(id: 'q0', label: 'q0', output: '0'),
    const FsmState(id: 'q1', label: 'q1', output: '0'),
  ],
  transitions: [
    const FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '0'),
    const FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: '1'),
    const FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: '0'),
  ],
);

/// Zweistufige Wassersteuerung; Eingabe 1 füllt den Tank, Eingabe 0 leert ihn.
final chapter4WaterLevelMachine = moore(
  ['0', '1'],
  [
    ['q0', 'q1'],
    ['q0', 'q1'],
  ],
);
final chapter4WaterLevelPartial = chapter4WaterLevelMachine.copyWith(
  transitions: [
    for (final transition in chapter4WaterLevelMachine.transitions)
      if (!(transition.fromStateId == 'q1' && transition.symbol == '1'))
        transition,
  ],
);

final chapter4PumpMealyMachine = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.mealy,
  states: [FsmState(id: 'q0', label: 'PUMP CONTROL', x: .5, y: .5)],
  transitions: const [
    FsmTransition(
      fromStateId: 'q0',
      toStateId: 'q0',
      symbol: 'sensor = 1 / START PUMP',
    ),
    FsmTransition(
      fromStateId: 'q0',
      toStateId: 'q0',
      symbol: 'sensor = 0 / STOP PUMP',
    ),
  ],
);
final chapter4PumpMealyPartial = chapter4PumpMealyMachine.copyWith(
  transitions: [chapter4PumpMealyMachine.transitions.first],
);

/// Lichtschalter mit zwei Zuständen: Eingabe 0 schaltet um, Eingabe 1 behält die Einstellung.
final chapter4SwitchMachine = moore(
  ['0', '1'],
  [
    ['q1', 'q0'],
    ['q0', 'q1'],
  ],
);
final chapter4SwitchPartial = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.moore,
  states: [
    const FsmState(id: 'q0', label: 'q0', output: '0'),
    const FsmState(id: 'q1', label: 'q1', output: '1'),
  ],
  transitions: [
    const FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: '0'),
    const FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '1'),
    const FsmTransition(fromStateId: 'q1', toStateId: 'q1', symbol: '1'),
  ],
);

/// Fahrkartenautomat mit drei Zuständen. In der Teilversion fehlt q2 absichtlich.
final chapter4TicketMachine = moore(
  ['0', '0', '1'],
  [
    ['q1', 'q0'],
    ['q1', 'q2'],
    ['q0', 'q2'],
  ],
);
final chapter4TicketPartial = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.moore,
  states: [
    const FsmState(id: 'q0', label: 'q0', output: '0'),
    const FsmState(id: 'q1', label: 'q1', output: '0'),
  ],
  transitions: [
    const FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: '0'),
    const FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '1'),
    const FsmTransition(fromStateId: 'q1', toStateId: 'q1', symbol: '0'),
  ],
);

/// Codeschloss mit vier Zuständen: q3 gibt nach der Sequenz das Entriegelungssignal aus.
final chapter4LockMachine = moore(
  ['0', '0', '0', '1'],
  [
    ['q1', 'q0'],
    ['q2', 'q0'],
    ['q3', 'q1'],
    ['q0', 'q0'],
  ],
);
final chapter4LockPartial = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.moore,
  states: [
    const FsmState(id: 'q0', label: 'q0', output: '0'),
    const FsmState(id: 'q1', label: 'q1', output: '0'),
    const FsmState(id: 'q2', label: 'q2', output: '0'),
    const FsmState(id: 'q3', label: 'q3', output: '1'),
  ],
  transitions: [
    const FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: '0'),
    const FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '1'),
    const FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: '0'),
    const FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: '1'),
    const FsmTransition(fromStateId: 'q2', toStateId: 'q1', symbol: '1'),
  ],
);

final chapter5Mealy = mealy(
  [
    ['q0', 'q1'],
    ['q0', 'q1'],
  ],
  [
    ['0', '1'],
    ['0', '0'],
  ],
);
final chapter5TablePracticeMealy = mealy(
  [
    ['q2', 'q1'],
    ['q0', 'q2'],
    ['q1', 'q0'],
  ],
  [
    ['1', '1'],
    ['0', '1'],
    ['0', '1'],
  ],
);
final chapter5CompletionMachineA = moore(
  ['1', '0', '1'],
  [
    ['q1', 'q2'],
    ['q2', 'q0'],
    ['q0', 'q1'],
  ],
);
final chapter5CompletionPartialA = chapter5CompletionMachineA.copyWith(
  transitions: [
    for (final transition in chapter5CompletionMachineA.transitions)
      if (!(transition.fromStateId == 'q2' && transition.symbol == '1'))
        transition,
  ],
);
final chapter5CompletionMachineB = moore(
  ['0', '1'],
  [
    ['q1', 'q0'],
    ['q0', 'q1'],
  ],
);
final chapter5CompletionPartialB = chapter5CompletionMachineB.copyWith(
  states: [
    for (final state in chapter5CompletionMachineB.states)
      state.id == 'q0' ? state.copyWith(output: '') : state,
  ],
  transitions: [
    for (final transition in chapter5CompletionMachineB.transitions)
      if (!(transition.fromStateId == 'q1' && transition.symbol == '1'))
        transition,
  ],
);
final chapter5CoffeeMachine = Fsm(
  initialStateId: 'q0',
  states: [
    FsmState(id: 'q0', label: 'WAITING', output: 'WAIT', x: .25, y: .5),
    FsmState(id: 'q1', label: 'PAID', output: 'CHOOSE', x: .75, y: .5),
  ],
  transitions: const [
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'coin'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'choose drink'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'cancel'),
    FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'choose drink'),
    FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'cancel'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q1', symbol: 'coin'),
  ],
);
final chapter5WashingMachine = Fsm(
  initialStateId: 'q0',
  states: [
    FsmState(id: 'q0', label: 'IDLE', output: 'READY', x: .12, y: .5),
    FsmState(id: 'q1', label: 'WASHING', output: 'WASH', x: .38, y: .25),
    FsmState(id: 'q2', label: 'RINSING', output: 'RINSE', x: .66, y: .25),
    FsmState(id: 'q3', label: 'DONE', output: 'DONE', x: .88, y: .5),
  ],
  transitions: [
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'start'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: 'wash done'),
    FsmTransition(fromStateId: 'q2', toStateId: 'q3', symbol: 'rinse done'),
    FsmTransition(fromStateId: 'q3', toStateId: 'q0', symbol: 'door opened'),
    for (final state in ['q0', 'q1', 'q2', 'q3'])
      for (final input in ['start', 'wash done', 'rinse done', 'door opened'])
        if (!const {
          'q0::start',
          'q1::wash done',
          'q2::rinse done',
          'q3::door opened',
        }.contains('$state::$input'))
          FsmTransition(fromStateId: state, toStateId: state, symbol: input),
  ],
);
final chapter5Moore = moore(
  ['0', '1', '0', '0'],
  [
    ['q1', 'q0'],
    ['q2', 'q0'],
    ['q3', 'q1'],
    ['q0', 'q1'],
  ],
);
final chapter5MoorePartial = chapter5Moore.copyWith(
  states: [
    for (final state in chapter5Moore.states)
      state.id == 'q3' ? state.copyWith(output: '') : state,
  ],
  transitions: [
    for (final transition in chapter5Moore.transitions)
      if (transition.id != 'q1::0::q2' && transition.id != 'q3::1::q1')
        transition,
  ],
);

/// Moore-Automat, der durch die Zustandsübergangs- und Ausgabetabellen der
/// Bonusaufgabe beschrieben wird. Er hat drei Zustände und zwei binäre Eingänge.
final chapter5TableMoore = moore(
  ['1', '0', '1'],
  [
    ['q1', 'q2'],
    ['q1', 'q0'],
    ['q2', 'q0'],
  ],
);

/// Mealy-Automat, der durch die zweite Tabelle der Bonusaufgabe beschrieben wird.
final chapter5TableMealy = Fsm(
  initialStateId: 'q0',
  outputMode: FsmOutputMode.mealy,
  states: const [
    FsmState(id: 'q0', label: 'S0', x: .18, y: .5),
    FsmState(id: 'q1', label: 'S1', x: .5, y: .25),
    FsmState(id: 'q2', label: 'S2', x: .82, y: .5),
  ],
  transitions: const [
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'X=0,Y=0 / 0'),
    FsmTransition(fromStateId: 'q0', toStateId: 'q2', symbol: 'X=0,Y=1 / 1'),
    FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: 'X=1 / 1'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'X=0,Y=0 / 1'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: 'X=0,Y=1 / 1'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q2', symbol: 'X=1 / 0'),
    FsmTransition(fromStateId: 'q2', toStateId: 'q2', symbol: 'X=0,Y=0 / 1'),
    FsmTransition(fromStateId: 'q2', toStateId: 'q0', symbol: 'X=0,Y=1 / 0'),
    FsmTransition(fromStateId: 'q2', toStateId: 'q1', symbol: 'X=1 / 0'),
  ],
);
