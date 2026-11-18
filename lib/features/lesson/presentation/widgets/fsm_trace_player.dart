import 'package:flutter/material.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_simulator.dart';

/// Zeigt die Simulationsspur textuell mit Eingabe, erreichtem Zustand und Ausgabe je Schritt.
class FsmTracePlayer extends StatelessWidget {
  const FsmTracePlayer({required this.fsm, required this.inputs, super.key});
  final Fsm fsm;
  final List<String> inputs;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final step in const FsmSimulator().simulateSymbols(fsm, inputs))
        Text('${step.consumedSymbol} → ${step.stateId} / ${step.output}'),
    ],
  );
}
