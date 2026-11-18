// Aufgabenspezifische Rückmeldungen als Ergänzung der zentralen Übersetzungstabelle.
//
// Die Schlüssel folgen TaskFeedbackKeys: `feedback.<taskId>.correct` begründet
// eine richtige Antwort, `feedback.<taskId>.<answerId>` reagiert auf eine falsche
// Option und `feedback.<taskId>.wrong` ergänzt berechnetes Feedback um einen Hinweis.
// Fehlerhinweise benennen den zu prüfenden Zusammenhang, ohne die Lösung zu verraten.

const taskFeedbackEn = {
  'lesson.correctWithReason': 'Correct. {reason}',
  'taskFeedback.selectionExtra':
      '"{label}" does not belong to the requested elements.',
  'taskFeedback.selectionMissing': 'Matching elements still missing: {count}.',
  'taskFeedback.tableTransitionEmpty':
      'State {state}, input {input}: the next state is still empty.',
  'taskFeedback.tableTransitionWrong':
      'State {state}, input {input}: this next state does not follow from the circuit. Evaluate the gates for this row again.',
  'taskFeedback.tableOutputEmpty': 'State {state}: the output is still empty.',
  'taskFeedback.tableOutputWrong':
      'State {state}: this output does not follow from the output logic. Insert the state bits of this row again.',
  'taskFeedback.traceStart':
      'The first entry is not correct. It is the initial state, before any input is applied.',
  'taskFeedback.traceStep':
      'Step {step} is not correct. Up to {state} your trace is right. Follow the transition from {state} for input {input} again.',
  'taskFeedback.traceCheckHere': 'Check this step',
  'fsmFeedback.counterexample':
      'Counterexample: after the inputs {sequence}, your automaton outputs {actual}, but the task requires {expected}. Trace this sequence; check the transition from {state} for input {input} and the output it leads to.',
  'fsmFeedback.counterexampleNoOutput':
      'Counterexample: the inputs {sequence} cannot be followed to the end. Check the transition from {state} for input {input}.',
  'fsmFeedback.initialOutputMismatch':
      'Already the initial state {state} has a different output than the task requires. Check its output.',

  // Kapitel 1
  'feedback.intro-state-count.correct':
      'Each distinct traffic-light situation is one state: red, red-yellow, green and yellow.',
  'feedback.intro-reset.correct':
      'RESET points to exactly one existing state, so the machine knows where it starts.',
  'feedback.intro-reset.answer.false':
      'Check what an initial state needs: RESET must point to exactly one state of this machine. Does the arrow do that here?',
  'feedback.intro-follow-transition.correct':
      'The outgoing 60 s arrow of red leads to red-yellow. The next state follows from the current state and the event together.',
  'feedback.states-diagram-nodes.correct':
      'Only the circles are nodes. Arrows connect nodes, and the RESET marker only shows where the machine starts.',
  'feedback.states-diagram-nodes.wrong':
      'Nodes are the states drawn as circles. Arrows and the RESET marker belong to the diagram but are not nodes.',
  'feedback.states-initial.correct':
      'The RESET arrow points to q0, so q0 is the initial node.',
  'feedback.states-initial.answer.false':
      'Look for the RESET arrow: the node it points to is the initial node. Which node is that?',
  'feedback.states-trace.correct':
      '"coin" leads from Locked to Unlocked, and "passage" leads back to Locked. Each input moves the one current state along one arrow.',
  'feedback.transitions-output-placement.correct':
      'In a Moore machine every state carries its output, so the output changes only when the state changes.',
  'feedback.transitions-output-placement.answer.outputBelongsToTransition':
      'An output on the transition arrow is the Mealy notation. Where does a Moore machine write y = …?',
  'feedback.transitions-output-placement.answer.outputOnlyAtEnd':
      'A Moore machine has an output in every state, already before the first input. Where is it written?',
  'feedback.transitions-find-mealy-errors.correct':
      'Both labels pair an input with the wrong door reaction. In Mealy notation input and output belong together on one transition.',
  'feedback.transitions-find-mealy-errors.wrong':
      'Read every label as "input / output" and ask which door reaction this input requires.',
  'feedback.transitions-complete-mealy.correct':
      'WAIT now reacts to both values of person; each self-loop combines one input with the matching door output.',
  'feedback.chapter1-final-determinism.correct':
      'Deterministic means: for every state and input exactly one next state. Then each input sequence has exactly one path.',
  'feedback.chapter1-final-determinism.answer.anyNumberTransitions':
      'If one state had two arrows for the same input, which of them would the machine follow? Think about what deterministic rules out.',
  'feedback.chapter1-final-determinism.answer.noTransitionsNeeded':
      'Without transitions the machine could not react to any input. What must be defined for every state and input?',
  'feedback.chapter1-final-moore-output.correct':
      'After the move q1 is the current state, and a Moore output belongs to the current state: 1.',
  'feedback.chapter1-final-moore-output.answer.0':
      'Output 0 belongs to q0, which the machine has just left. Which state is current after input 1, and which output does it carry?',
  'feedback.chapter1-final-trace.correct':
      'Input 1 leads from IDLE to PREPARED and input 0 from there to ACTIVE. Each step starts in the state reached before.',
  'feedback.chapter1-final-trace.wrong':
      'Apply the inputs one after another, and start each step in the state reached by the previous one.',
  'feedback.chapter1-final-completeness.correct':
      'READY has no transition for stop and RUNNING none for start. Complete means a transition for every state and every input.',
  'feedback.chapter1-final-completeness.answer.true':
      'Check every state against both inputs of {start, stop}. Does each state have a transition for each input?',
  'feedback.chapter1-final-conflict.correct':
      'Both transitions leave q0 with input 0 but lead to different states. That pair breaks determinism; q1 --1--> q2 does not.',
  'feedback.chapter1-final-conflict.wrong':
      'A conflict needs the same start state and the same input, but different targets. Compare the transitions leaving each state input by input.',

  // Kapitel 2
  'feedback.chapter2-gates-check.correct':
      'XOR outputs 1 exactly when its inputs differ, and 0 and 1 differ.',
  'feedback.chapter2-gates-and.correct':
      'AND outputs 1 only if both inputs are 1. With one input 0 the output is 0.',
  'feedback.chapter2-gates-and.answer.true':
      'Check the rule of AND: does it need one input or both inputs to be 1?',
  'feedback.chapter2-gates-or.correct':
      'OR outputs 1 as soon as at least one input is 1, so 0 and 1 give 1.',
  'feedback.chapter2-gates-or.answer.false':
      'Check the rule of OR: how many inputs must be 1 for the output to become 1?',
  'feedback.chapter2-state-code.correct':
      'S₁ has the value 2 and S₀ the value 1, so 10 means 2 + 0 = 2. The two bits together encode the state.',
  'feedback.chapter2-state-code.answer.stateCodeOne':
      'Check the weight of each bit: which one is the 2-value bit, and which bit is 1 in 10?',
  'feedback.chapter2-state-code.answer.stateCodeInvalid':
      'This circuit uses the codes 00, 01 and 10. Is 10 among them?',
  'feedback.chapter2-trace.correct':
      'Each CLK step stores the next state from the current bits and input: S = 0, 2, 1, 0, 0.',
  'feedback.chapter2-trace.wrong':
      'Each step starts with the stored bits of the previous step. Evaluate the gates with these bits and the current input, then apply CLK.',
  'feedback.chapter2-build-table.correct':
      'Every row combines the stored bits S₁S₀ with input A; the gates give S′, which CLK stores. The output depends only on the state.',
  'feedback.chapter2-build-table.wrong':
      'Fill the table row by row: insert the bits of S and the value of A into the gates, then read S′.',
  'feedback.chapter2-final-and-table.correct':
      'For every state and input you evaluated the AND gates and read the next state; the output logic gives Y for each state.',
  'feedback.chapter2-final-and-table.wrong':
      'An AND gate gives 1 only if all its inputs are 1. Evaluate the marked rows with the bits of S and the value of A.',
  'feedback.chapter2-final-mixed-table.correct':
      'You combined the different gates correctly for every row, and the outputs follow from the state bits.',
  'feedback.chapter2-final-mixed-table.wrong':
      'Evaluate the marked rows gate by gate, including any negated input, before you read S′.',
  'feedback.chapter2-final-xor-output-table.correct':
      'The next states follow from the gates, and the XOR output logic gives 1 exactly when the two state bits differ.',
  'feedback.chapter2-final-xor-output-table.wrong':
      'For the output, compare the two state bits of the marked row: XOR gives 1 only when they differ.',
  'feedback.chapter2-final-state-bits.correct':
      'Each bit has two values, so two bits give 2 × 2 = 4 patterns: 00, 01, 10 and 11.',
  'feedback.chapter2-final-state-bits.2':
      'That is the number of bits. How many different combinations of two bits can you write down?',
  'feedback.chapter2-final-state-bits.3':
      'That is the number of codes the circuit uses. The question asks for all patterns before unused codes are excluded.',
  'feedback.chapter2-final-xor-equal-inputs.correct':
      'Both inputs are 1, so they are equal, and XOR outputs 0 for equal inputs.',
  'feedback.chapter2-final-xor-equal-inputs.answer.xorOne':
      'Compare the two inputs again: are 1 and 1 different?',
  'feedback.chapter2-final-xor-equal-inputs.answer.andOne':
      'This option describes another gate. What does XOR compare?',

  // Kapitel 3: Automaten vervollständigen
  'feedback.chapter4-guided-complete-coin-machine.correct':
      'Your automaton shows the described behaviour for every input sequence: two coins lead to q2 with output 1, cancelling returns to q0, and q2 always returns to q0.',
  'feedback.chapter4-guided-complete-water-controller.correct':
      'Filling a full tank keeps HIGH, so the output stays 1. Now every state reacts to both inputs.',
  'feedback.chapter4-guided-complete-pump-response.correct':
      'The single state now reacts to both sensor values; each self-loop pairs an input with its pump output.',
  'feedback.chapter4-final-switch.correct':
      'Input 0 now toggles in both directions and input 1 keeps each state. Every state reacts to every input.',
  'feedback.chapter4-final-ticket.correct':
      'The cycle is complete: payment and confirmation lead to q2 with output 1, and every state reacts to both inputs.',
  'feedback.chapter4-final-lock.correct':
      'Input 0 advances the lock step by step to q3, the only state with output 1; input 1 falls back as described, and q3 always returns to q0.',
  'feedback.chapter4-final-completeness-rule.correct':
      'Complete means a transition for every state/input pair. One missing pair is enough to make the FSM incomplete.',
  'feedback.chapter4-final-completeness-rule.answer.true':
      'What happens if the machine is in that state and receives that input? Complete must cover every state/input pair.',
  'feedback.chapter4-final-transition-count.correct':
      'Each of the 3 states needs exactly one transition for each of the 2 inputs: 3 × 2 = 6.',
  'feedback.chapter4-final-transition-count.chapter4.answer.fiveTransitions':
      'With five transitions one state/input pair stays undefined. How many pairs do 3 states and 2 inputs form?',
  'feedback.chapter4-final-transition-count.chapter4.answer.sevenTransitions':
      'With seven transitions one pair would get two targets, so the FSM would no longer be deterministic. Count the state/input pairs.',

  // Kapitel 4: Automaten erstellen
  'feedback.creation-build-bike-rental.correct':
      'Your automaton shows the described behaviour for every event sequence: code, taking and returning the bike form the cycle, and all other events keep the state.',
  'feedback.automata-creation-description-test-parcel-kiosk.correct':
      'Your kiosk reacts to every event as described: storing, opening with a valid code and emptying form the cycle, and all other events keep the state.',
  'feedback.creation-build-parking-barrier.correct':
      'Every table row became exactly one transition, and every state carries the output from the output table.',
  'feedback.creation-final-coffee.correct':
      'Only a coin changes WAITING to PAID, both actions in PAID return to WAITING, and all other events keep the state.',
  'feedback.creation-final-locker.correct':
      'Your locker reacts to every event as described: a wrong PIN keeps PARCEL STORED, and closing the door leads back to LOCKER EMPTY.',
  'feedback.creation-final-washing-machine.correct':
      'The four events lead through the washing cycle in order, and every other event keeps the current state.',

  // Kapitel 5: Prüfungsaufgaben
  'feedback.chapter5-theory-moore-output.correct':
      'A Moore output is assigned to the current state. It therefore changes only together with the state.',
  'feedback.chapter5-theory-moore-output.chapter5.answer.inputOnly':
      'An output that follows the input directly is typical of Mealy. Where is the output written in a Moore automaton?',
  'feedback.chapter5-theory-moore-output.chapter5.answer.nextStateOnly':
      'The next state only matters once it has become the current state. To which state does a Moore output belong?',
  'feedback.chapter5-theory-mealy-output.correct':
      'A Mealy output is written on the transition, so it depends on the current state together with the input.',
  'feedback.chapter5-theory-mealy-output.chapter5.answer.stateOnly':
      'An output that depends only on the state describes Moore. Where is a Mealy output written?',
  'feedback.chapter5-theory-mealy-output.chapter5.answer.clockOnly':
      'The clock only decides when a new state is stored. Which two pieces of information appear on a Mealy transition?',
  'feedback.chapter5-theory-timing.correct':
      'Because a Mealy output also depends on the input, it can react immediately; a Moore output waits for the next state.',
  'feedback.chapter5-theory-timing.chapter5.answer.sameTiming':
      'Compare what each output depends on. Can a Moore output change while the state stays the same?',
  'feedback.chapter5-theory-timing.chapter5.answer.mooreImmediate':
      'Which output depends directly on the input, and which one only on the state?',
  'feedback.chapter5-tables-moore.correct':
      'Every row of the transition table is one transition, and every state carries the output from the output table.',
  'feedback.chapter5-tables-mealy.correct':
      'Every table entry became one transition with its input and output on the arrow.',
  'feedback.chapter5-tables-practice-mealy.correct':
      'Each of the three states reacts to both inputs exactly as the table states, with input and output on each arrow.',
  'feedback.chapter5-complete-moore.correct':
      'Your detector follows the specification for every input sequence: input 0 advances, input 1 falls back as described, and only q1 outputs 1.',
  'feedback.chapter5-complete-moore-a.correct':
      'Input 0 cycles through all three states, input 1 follows its own order, and the outputs match the specification.',
  'feedback.chapter5-complete-moore-b.correct':
      'Input 0 toggles between q0 and q1, input 1 keeps each state, and both outputs are set.',
  'feedback.chapter5-create-mealy.correct':
      'A valid ticket in q0 opens the gate with output 1; a further ticket in q1 keeps q1 with output 0, and input 0 closes the gate.',
  'feedback.chapter5-create-coffee-machine.correct':
      'Only a coin leads to PAID, choosing or cancelling returns to WAITING, and every other event keeps the state.',
  'feedback.chapter5-create-washing-machine.correct':
      'The four events lead through the cycle in order, each state carries its output, and other events keep the state.',
  'feedback.chapter5-analysis-trace.correct':
      'Each 0 moves the automaton one state further: q0, q1, q2, q3.',
  'feedback.chapter5-analysis-trace.wrong':
      'Follow exactly one transition per input, always starting from the state you reached in the step before.',
  'feedback.chapter5-diagnostics-determinism.correct':
      'q0 has two transitions for input 0, to q1 and to q2. So the next state is not unique.',
  'feedback.chapter5-diagnostics-determinism.chapter5.answer.deterministic':
      'Compare the arrows leaving each state input by input. Is there a state with two arrows for the same input?',
  'feedback.chapter5-diagnostics-missing-transition.correct':
      'q2 only has a transition for input 0. For a complete automaton it also needs one for input 1.',
  'feedback.chapter5-diagnostics-missing-transition.q1':
      'q1 has an outgoing arrow for input 1. Check the other states for both inputs.',
  'feedback.chapter5-diagnostics-missing-transition.q3':
      'q3 has an outgoing arrow for input 1. Check the other states for both inputs.',
};

const taskFeedbackDe = {
  'lesson.correctWithReason': 'Richtig. {reason}',
  'taskFeedback.selectionExtra':
      '"{label}" gehört nicht zu den gesuchten Elementen.',
  'taskFeedback.selectionMissing': 'Noch fehlende passende Elemente: {count}.',
  'taskFeedback.tableTransitionEmpty':
      'Zustand {state}, Eingang {input}: Der Folgezustand ist noch leer.',
  'taskFeedback.tableTransitionWrong':
      'Zustand {state}, Eingang {input}: Dieser Folgezustand ergibt sich nicht aus der Schaltung. Werte die Gatter für diese Zeile erneut aus.',
  'taskFeedback.tableOutputEmpty':
      'Zustand {state}: Die Ausgabe ist noch leer.',
  'taskFeedback.tableOutputWrong':
      'Zustand {state}: Diese Ausgabe ergibt sich nicht aus der Ausgangslogik. Setze die Zustandsbits dieser Zeile erneut ein.',
  'taskFeedback.traceStart':
      'Der erste Eintrag stimmt nicht. Er ist der Anfangszustand, bevor eine Eingabe verarbeitet wird.',
  'taskFeedback.traceStep':
      'Schritt {step} stimmt nicht. Bis {state} ist deine Folge richtig. Verfolge den Übergang aus {state} für Eingabe {input} noch einmal.',
  'taskFeedback.traceCheckHere': 'Prüfe diesen Schritt',
  'fsmFeedback.counterexample':
      'Gegenbeispiel: Nach den Eingaben {sequence} gibt dein Automat {actual} aus, verlangt ist {expected}. Verfolge diese Folge; prüfe den Übergang aus {state} für Eingabe {input} und die Ausgabe, zu der er führt.',
  'fsmFeedback.counterexampleNoOutput':
      'Gegenbeispiel: Die Eingaben {sequence} lassen sich nicht bis zum Ende verfolgen. Prüfe den Übergang aus {state} für Eingabe {input}.',
  'fsmFeedback.initialOutputMismatch':
      'Schon der Anfangszustand {state} hat eine andere Ausgabe als verlangt. Prüfe seine Ausgabe.',

  // Kapitel 1
  'feedback.intro-state-count.correct':
      'Jede unterscheidbare Ampelsituation ist ein Zustand: Rot, Rot-gelb, Grün und Gelb.',
  'feedback.intro-reset.correct':
      'RESET zeigt auf genau einen vorhandenen Zustand. Damit ist festgelegt, wo der Automat startet.',
  'feedback.intro-reset.answer.false':
      'Prüfe, was ein Anfangszustand braucht: RESET muss auf genau einen Zustand dieses Automaten zeigen. Ist das hier der Fall?',
  'feedback.intro-follow-transition.correct':
      'Der ausgehende 60-s-Pfeil von Rot führt zu Rot-gelb. Der Folgezustand ergibt sich aus aktuellem Zustand und Ereignis zusammen.',
  'feedback.states-diagram-nodes.correct':
      'Nur die Kreise sind Knoten. Pfeile verbinden Knoten, und die RESET-Markierung zeigt nur, wo der Automat startet.',
  'feedback.states-diagram-nodes.wrong':
      'Knoten sind die als Kreise gezeichneten Zustände. Pfeile und die RESET-Markierung gehören zum Diagramm, sind aber keine Knoten.',
  'feedback.states-initial.correct':
      'Der RESET-Pfeil zeigt auf q0, also ist q0 der Anfangsknoten.',
  'feedback.states-initial.answer.false':
      'Suche den RESET-Pfeil: Der Knoten, auf den er zeigt, ist der Anfangsknoten. Welcher ist das?',
  'feedback.states-trace.correct':
      '"coin" führt von Locked nach Unlocked, "passage" zurück nach Locked. Jede Eingabe bewegt den einen aktuellen Zustand entlang eines Pfeils.',
  'feedback.transitions-output-placement.correct':
      'Beim Moore-Automaten trägt jeder Zustand seine Ausgabe. Die Ausgabe ändert sich also nur mit dem Zustand.',
  'feedback.transitions-output-placement.answer.outputBelongsToTransition':
      'Eine Ausgabe am Übergangspfeil ist die Mealy-Schreibweise. Wo steht y = … bei einem Moore-Automaten?',
  'feedback.transitions-output-placement.answer.outputOnlyAtEnd':
      'Ein Moore-Automat hat in jedem Zustand eine Ausgabe, schon vor der ersten Eingabe. Wo wird sie eingetragen?',
  'feedback.transitions-find-mealy-errors.correct':
      'Beide Beschriftungen ordnen einer Eingabe die falsche Türreaktion zu. In der Mealy-Schreibweise gehören Eingabe und Ausgabe an einem Übergang zusammen.',
  'feedback.transitions-find-mealy-errors.wrong':
      'Lies jede Beschriftung als "Eingabe / Ausgabe" und frage dich, welche Türreaktion diese Eingabe verlangt.',
  'feedback.transitions-complete-mealy.correct':
      'WAIT reagiert jetzt auf beide Werte von person; jede Selbstschleife verbindet eine Eingabe mit der passenden Türausgabe.',
  'feedback.chapter1-final-determinism.correct':
      'Deterministisch heißt: Für jeden Zustand und jede Eingabe gibt es genau einen Folgezustand. Dann hat jede Eingabefolge genau einen Weg.',
  'feedback.chapter1-final-determinism.answer.anyNumberTransitions':
      'Hätte ein Zustand zwei Pfeile für dieselbe Eingabe, welchem würde der Automat folgen? Überlege, was "deterministisch" ausschließt.',
  'feedback.chapter1-final-determinism.answer.noTransitionsNeeded':
      'Ohne Übergänge könnte der Automat auf keine Eingabe reagieren. Was muss für jeden Zustand und jede Eingabe festgelegt sein?',
  'feedback.chapter1-final-moore-output.correct':
      'Nach dem Übergang ist q1 der aktuelle Zustand, und eine Moore-Ausgabe gehört zum aktuellen Zustand: 1.',
  'feedback.chapter1-final-moore-output.answer.0':
      'Die Ausgabe 0 gehört zu q0, den der Automat gerade verlassen hat. Welcher Zustand ist nach Eingabe 1 aktuell, und welche Ausgabe trägt er?',
  'feedback.chapter1-final-trace.correct':
      'Eingabe 1 führt von IDLE nach PREPARED, Eingabe 0 von dort nach ACTIVE. Jeder Schritt beginnt im zuvor erreichten Zustand.',
  'feedback.chapter1-final-trace.wrong':
      'Verarbeite die Eingaben nacheinander und beginne jeden Schritt in dem Zustand, den der vorige erreicht hat.',
  'feedback.chapter1-final-completeness.correct':
      'READY hat keinen Übergang für stop und RUNNING keinen für start. Vollständig heißt: ein Übergang für jeden Zustand und jede Eingabe.',
  'feedback.chapter1-final-completeness.answer.true':
      'Prüfe jeden Zustand mit beiden Eingaben aus {start, stop}. Hat jeder Zustand für jede Eingabe einen Übergang?',
  'feedback.chapter1-final-conflict.correct':
      'Beide Übergänge verlassen q0 mit Eingabe 0, führen aber zu verschiedenen Zuständen. Dieses Paar verletzt den Determinismus, q1 --1--> q2 nicht.',
  'feedback.chapter1-final-conflict.wrong':
      'Ein Konflikt braucht denselben Ausgangszustand und dieselbe Eingabe, aber verschiedene Ziele. Vergleiche die Übergänge jedes Zustands Eingabe für Eingabe.',

  // Kapitel 2
  'feedback.chapter2-gates-check.correct':
      'XOR gibt genau dann 1 aus, wenn die Eingänge verschieden sind, und 0 und 1 sind verschieden.',
  'feedback.chapter2-gates-and.correct':
      'AND gibt nur 1 aus, wenn beide Eingänge 1 sind. Ist ein Eingang 0, ist der Ausgang 0.',
  'feedback.chapter2-gates-and.answer.true':
      'Prüfe die Regel von AND: Muss ein Eingang oder müssen beide Eingänge 1 sein?',
  'feedback.chapter2-gates-or.correct':
      'OR gibt 1 aus, sobald mindestens ein Eingang 1 ist. 0 und 1 ergeben also 1.',
  'feedback.chapter2-gates-or.answer.false':
      'Prüfe die Regel von OR: Wie viele Eingänge müssen 1 sein, damit der Ausgang 1 wird?',
  'feedback.chapter2-state-code.correct':
      'S₁ hat den Wert 2 und S₀ den Wert 1. 10 bedeutet also 2 + 0 = 2. Erst beide Bits zusammen kodieren den Zustand.',
  'feedback.chapter2-state-code.answer.stateCodeOne':
      'Prüfe die Wertigkeit der Bits: Welches ist das 2er-Bit, und welches Bit ist in 10 gleich 1?',
  'feedback.chapter2-state-code.answer.stateCodeInvalid':
      'Diese Schaltung verwendet die Codes 00, 01 und 10. Ist 10 darunter?',
  'feedback.chapter2-trace.correct':
      'Jeder CLK-Schritt speichert den Folgezustand aus den aktuellen Bits und der Eingabe: S = 0, 2, 1, 0, 0.',
  'feedback.chapter2-trace.wrong':
      'Jeder Schritt beginnt mit den gespeicherten Bits des vorigen Schritts. Werte mit diesen Bits und der aktuellen Eingabe die Gatter aus und wende dann CLK an.',
  'feedback.chapter2-build-table.correct':
      'Jede Zeile verbindet die gespeicherten Bits S₁S₀ mit dem Eingang A; die Gatter liefern S′, das CLK speichert. Die Ausgabe hängt nur vom Zustand ab.',
  'feedback.chapter2-build-table.wrong':
      'Fülle die Tabelle Zeile für Zeile: Setze die Bits von S und den Wert von A in die Gatter ein und lies dann S′ ab.',
  'feedback.chapter2-final-and-table.correct':
      'Für jeden Zustand und Eingang hast du die AND-Gatter ausgewertet und den Folgezustand abgelesen; die Ausgangslogik liefert Y für jeden Zustand.',
  'feedback.chapter2-final-and-table.wrong':
      'Ein AND-Gatter liefert nur 1, wenn alle seine Eingänge 1 sind. Werte die markierten Zeilen mit den Bits von S und dem Wert von A aus.',
  'feedback.chapter2-final-mixed-table.correct':
      'Du hast die verschiedenen Gatter für jede Zeile richtig verknüpft, und die Ausgaben ergeben sich aus den Zustandsbits.',
  'feedback.chapter2-final-mixed-table.wrong':
      'Werte die markierten Zeilen Gatter für Gatter aus, auch negierte Eingänge, bevor du S′ abliest.',
  'feedback.chapter2-final-xor-output-table.correct':
      'Die Folgezustände ergeben sich aus den Gattern, und die XOR-Ausgangslogik liefert genau dann 1, wenn die beiden Zustandsbits verschieden sind.',
  'feedback.chapter2-final-xor-output-table.wrong':
      'Vergleiche für die Ausgabe die beiden Zustandsbits der markierten Zeile: XOR liefert nur 1, wenn sie verschieden sind.',
  'feedback.chapter2-final-state-bits.correct':
      'Jedes Bit hat zwei Werte, zwei Bits ergeben also 2 × 2 = 4 Muster: 00, 01, 10 und 11.',
  'feedback.chapter2-final-state-bits.2':
      'Das ist die Zahl der Bits. Wie viele verschiedene Kombinationen aus zwei Bits kannst du aufschreiben?',
  'feedback.chapter2-final-state-bits.3':
      'Das ist die Zahl der Codes, die die Schaltung verwendet. Gefragt sind alle Muster, bevor ungenutzte Codes ausgeschlossen werden.',
  'feedback.chapter2-final-xor-equal-inputs.correct':
      'Beide Eingänge sind 1, also gleich, und XOR gibt bei gleichen Eingängen 0 aus.',
  'feedback.chapter2-final-xor-equal-inputs.answer.xorOne':
      'Vergleiche die beiden Eingänge noch einmal: Sind 1 und 1 verschieden?',
  'feedback.chapter2-final-xor-equal-inputs.answer.andOne':
      'Diese Option beschreibt ein anderes Gatter. Was vergleicht XOR?',

  // Kapitel 3: Automaten vervollständigen
  'feedback.chapter4-guided-complete-coin-machine.correct':
      'Dein Automat zeigt für jede Eingabefolge das beschriebene Verhalten: Zwei Münzen führen nach q2 mit Ausgabe 1, Abbrechen führt nach q0, und q2 kehrt immer nach q0 zurück.',
  'feedback.chapter4-guided-complete-water-controller.correct':
      'Ein voller Tank bleibt beim Füllen in HIGH, die Ausgabe bleibt also 1. Jetzt reagiert jeder Zustand auf beide Eingaben.',
  'feedback.chapter4-guided-complete-pump-response.correct':
      'Der einzige Zustand reagiert jetzt auf beide Sensorwerte; jede Selbstschleife verbindet eine Eingabe mit ihrer Pumpenausgabe.',
  'feedback.chapter4-final-switch.correct':
      'Eingabe 0 schaltet jetzt in beide Richtungen um, Eingabe 1 hält jeden Zustand. Jeder Zustand reagiert auf jede Eingabe.',
  'feedback.chapter4-final-ticket.correct':
      'Der Zyklus ist vollständig: Zahlung und Bestätigung führen nach q2 mit Ausgabe 1, und jeder Zustand reagiert auf beide Eingaben.',
  'feedback.chapter4-final-lock.correct':
      'Eingabe 0 führt das Schloss Schritt für Schritt nach q3, den einzigen Zustand mit Ausgabe 1; Eingabe 1 fällt wie beschrieben zurück, und q3 kehrt immer nach q0 zurück.',
  'feedback.chapter4-final-completeness-rule.correct':
      'Vollständig heißt: ein Übergang für jedes Zustand-Eingabe-Paar. Schon ein fehlendes Paar macht den FSM unvollständig.',
  'feedback.chapter4-final-completeness-rule.answer.true':
      'Was passiert, wenn der Automat in diesem Zustand ist und genau diese Eingabe erhält? Vollständig muss jedes Zustand-Eingabe-Paar abdecken.',
  'feedback.chapter4-final-transition-count.correct':
      'Jeder der 3 Zustände braucht für jedes der 2 Eingabesymbole genau einen Übergang: 3 × 2 = 6.',
  'feedback.chapter4-final-transition-count.chapter4.answer.fiveTransitions':
      'Mit fünf Übergängen bleibt ein Zustand-Eingabe-Paar undefiniert. Wie viele Paare bilden 3 Zustände und 2 Eingaben?',
  'feedback.chapter4-final-transition-count.chapter4.answer.sevenTransitions':
      'Mit sieben Übergängen hätte ein Paar zwei Ziele, der FSM wäre also nicht mehr deterministisch. Zähle die Zustand-Eingabe-Paare.',

  // Kapitel 4: Automaten erstellen
  'feedback.creation-build-bike-rental.correct':
      'Dein Automat zeigt für jede Ereignisfolge das beschriebene Verhalten: Code, Entnahme und Rückgabe bilden den Zyklus, alle anderen Ereignisse halten den Zustand.',
  'feedback.automata-creation-description-test-parcel-kiosk.correct':
      'Dein Paketautomat reagiert auf jedes Ereignis wie beschrieben: Einlegen, Öffnen mit gültigem Code und Leeren bilden den Zyklus, alle anderen Ereignisse halten den Zustand.',
  'feedback.creation-build-parking-barrier.correct':
      'Jede Tabellenzeile wurde zu genau einem Übergang, und jeder Zustand trägt die Ausgabe aus der Ausgabetabelle.',
  'feedback.creation-final-coffee.correct':
      'Nur eine Münze führt von WAITING nach PAID, beide Aktionen in PAID führen zurück nach WAITING, alle anderen Ereignisse halten den Zustand.',
  'feedback.creation-final-locker.correct':
      'Dein Schließfach reagiert auf jedes Ereignis wie beschrieben: Eine falsche PIN hält PARCEL STORED, das Schließen der Tür führt zurück nach LOCKER EMPTY.',
  'feedback.creation-final-washing-machine.correct':
      'Die vier Ereignisse führen der Reihe nach durch den Waschzyklus, und jedes andere Ereignis hält den aktuellen Zustand.',

  // Kapitel 5: Prüfungsaufgaben
  'feedback.chapter5-theory-moore-output.correct':
      'Eine Moore-Ausgabe ist dem aktuellen Zustand zugeordnet. Sie ändert sich deshalb nur zusammen mit dem Zustand.',
  'feedback.chapter5-theory-moore-output.chapter5.answer.inputOnly':
      'Eine Ausgabe, die direkt der Eingabe folgt, ist typisch für Mealy. Wo steht die Ausgabe bei einem Moore-Automaten?',
  'feedback.chapter5-theory-moore-output.chapter5.answer.nextStateOnly':
      'Der Folgezustand zählt erst, wenn er zum aktuellen Zustand geworden ist. Zu welchem Zustand gehört eine Moore-Ausgabe?',
  'feedback.chapter5-theory-mealy-output.correct':
      'Eine Mealy-Ausgabe steht am Übergang. Sie hängt daher vom aktuellen Zustand zusammen mit der Eingabe ab.',
  'feedback.chapter5-theory-mealy-output.chapter5.answer.stateOnly':
      'Eine Ausgabe, die nur vom Zustand abhängt, beschreibt Moore. Wo steht eine Mealy-Ausgabe?',
  'feedback.chapter5-theory-mealy-output.chapter5.answer.clockOnly':
      'Der Takt entscheidet nur, wann ein neuer Zustand gespeichert wird. Welche zwei Angaben stehen an einem Mealy-Übergang?',
  'feedback.chapter5-theory-timing.correct':
      'Weil eine Mealy-Ausgabe auch von der Eingabe abhängt, kann sie sofort reagieren; eine Moore-Ausgabe wartet auf den nächsten Zustand.',
  'feedback.chapter5-theory-timing.chapter5.answer.sameTiming':
      'Vergleiche, wovon die Ausgaben jeweils abhängen. Kann sich eine Moore-Ausgabe ändern, während der Zustand gleich bleibt?',
  'feedback.chapter5-theory-timing.chapter5.answer.mooreImmediate':
      'Welche Ausgabe hängt direkt von der Eingabe ab, und welche nur vom Zustand?',
  'feedback.chapter5-tables-moore.correct':
      'Jede Zeile der Übergangstabelle ist ein Übergang, und jeder Zustand trägt die Ausgabe aus der Ausgabetabelle.',
  'feedback.chapter5-tables-mealy.correct':
      'Jeder Tabelleneintrag wurde zu einem Übergang mit Eingabe und Ausgabe am Pfeil.',
  'feedback.chapter5-tables-practice-mealy.correct':
      'Jeder der drei Zustände reagiert genau wie in der Tabelle auf beide Eingaben, mit Eingabe und Ausgabe an jedem Pfeil.',
  'feedback.chapter5-complete-moore.correct':
      'Dein Detektor folgt der Spezifikation für jede Eingabefolge: Eingabe 0 schaltet weiter, Eingabe 1 fällt wie beschrieben zurück, und nur q1 gibt 1 aus.',
  'feedback.chapter5-complete-moore-a.correct':
      'Eingabe 0 durchläuft alle drei Zustände im Kreis, Eingabe 1 folgt ihrer eigenen Reihenfolge, und die Ausgaben entsprechen der Spezifikation.',
  'feedback.chapter5-complete-moore-b.correct':
      'Eingabe 0 wechselt zwischen q0 und q1, Eingabe 1 hält jeden Zustand, und beide Ausgaben sind gesetzt.',
  'feedback.chapter5-create-mealy.correct':
      'Ein gültiges Ticket in q0 öffnet das Tor mit Ausgabe 1; ein weiteres Ticket in q1 hält q1 mit Ausgabe 0, und Eingang 0 schließt das Tor.',
  'feedback.chapter5-create-coffee-machine.correct':
      'Nur eine Münze führt nach PAID, Auswahl oder Abbruch führen zurück nach WAITING, und jedes andere Ereignis hält den Zustand.',
  'feedback.chapter5-create-washing-machine.correct':
      'Die vier Ereignisse führen der Reihe nach durch den Zyklus, jeder Zustand trägt seine Ausgabe, und andere Ereignisse halten den Zustand.',
  'feedback.chapter5-analysis-trace.correct':
      'Jede 0 bringt den Automaten einen Zustand weiter: q0, q1, q2, q3.',
  'feedback.chapter5-analysis-trace.wrong':
      'Folge pro Eingabe genau einem Übergang und beginne immer in dem Zustand, den du im Schritt davor erreicht hast.',
  'feedback.chapter5-diagnostics-determinism.correct':
      'q0 hat für Eingabe 0 zwei Übergänge, nach q1 und nach q2. Der Folgezustand ist also nicht eindeutig.',
  'feedback.chapter5-diagnostics-determinism.chapter5.answer.deterministic':
      'Vergleiche die Pfeile jedes Zustands Eingabe für Eingabe. Gibt es einen Zustand mit zwei Pfeilen für dieselbe Eingabe?',
  'feedback.chapter5-diagnostics-missing-transition.correct':
      'q2 hat nur einen Übergang für Eingabe 0. Für einen vollständigen Automaten braucht er auch einen für Eingabe 1.',
  'feedback.chapter5-diagnostics-missing-transition.q1':
      'q1 hat einen ausgehenden Pfeil für Eingabe 1. Prüfe die anderen Zustände mit beiden Eingaben.',
  'feedback.chapter5-diagnostics-missing-transition.q3':
      'q3 hat einen ausgehenden Pfeil für Eingabe 1. Prüfe die anderen Zustände mit beiden Eingaben.',
};

const taskFeedbackRu = {
  'lesson.correctWithReason': 'Точно! {reason}',
  'taskFeedback.selectionExtra': '"{label}" не относится к искомым элементам.',
  'taskFeedback.selectionMissing':
      'Ещё не выбраны подходящие элементы: {count}.',
  'taskFeedback.tableTransitionEmpty':
      'Состояние {state}, вход {input}: следующее состояние ещё не заполнено.',
  'taskFeedback.tableTransitionWrong':
      'Состояние {state}, вход {input}: это следующее состояние не следует из схемы. Ещё раз вычисли логические элементы для этой строки.',
  'taskFeedback.tableOutputEmpty': 'Состояние {state}: выход ещё не заполнен.',
  'taskFeedback.tableOutputWrong':
      'Состояние {state}: этот выход не следует из логики выхода. Ещё раз подставь биты состояния этой строки.',
  'taskFeedback.traceStart':
      'Первая запись неверна. Это начальное состояние, до обработки первого входа.',
  'taskFeedback.traceStep':
      'Шаг {step} неверен. До {state} твоя последовательность правильная. Ещё раз пройди переход из {state} по входу {input}.',
  'taskFeedback.traceCheckHere': 'Проверь этот шаг',
  'fsmFeedback.counterexample':
      'Контрпример: после входов {sequence} твой автомат выдаёт {actual}, а по условию нужно {expected}. Пройди эту последовательность; проверь переход из {state} по входу {input} и выход, к которому он ведёт.',
  'fsmFeedback.counterexampleNoOutput':
      'Контрпример: входы {sequence} нельзя пройти до конца. Проверь переход из {state} по входу {input}.',
  'fsmFeedback.initialOutputMismatch':
      'Уже у начального состояния {state} другой выход, чем требует условие. Проверь его выход.',

  // Kapitel 1
  'feedback.intro-state-count.correct':
      'Каждая отдельная ситуация светофора - это состояние: красный, красный-жёлтый, зелёный и жёлтый.',
  'feedback.intro-reset.correct':
      'Стрелка "СБРОС" указывает ровно на одно существующее состояние, поэтому понятно, где автомат начинает работу.',
  'feedback.intro-reset.answer.false':
      'Проверь, что нужно начальному состоянию: стрелка "СБРОС" должна указывать ровно на одно состояние этого автомата. Так ли это здесь?',
  'feedback.intro-follow-transition.correct':
      'Исходящая стрелка 60 с из красного ведёт в красный-жёлтый. Следующее состояние зависит от текущего состояния и события вместе.',
  'feedback.states-diagram-nodes.correct':
      'Ноды - это только круги. Стрелки соединяют ноды, а отметка "СБРОС" лишь показывает, где автомат начинает работу.',
  'feedback.states-diagram-nodes.wrong':
      'Ноды - это состояния, нарисованные кругами. Стрелки и отметка "СБРОС" есть на схеме, но нодами не являются.',
  'feedback.states-initial.correct':
      'Стрелка "СБРОС" указывает на q0, значит, q0 - начальная нода.',
  'feedback.states-initial.answer.false':
      'Найди стрелку "СБРОС": нода, на которую она указывает, и есть начальная. Какая это нода?',
  'feedback.states-trace.correct':
      '"coin" ведёт из Locked в Unlocked, а "passage" обратно в Locked. Каждый вход переводит единственное текущее состояние по одной стрелке.',
  'feedback.transitions-output-placement.correct':
      'В автомате Мура выход записан в каждом состоянии, поэтому он меняется только вместе с состоянием.',
  'feedback.transitions-output-placement.answer.outputBelongsToTransition':
      'Выход на стрелке перехода - это запись автомата Мили. Где записывается y = … в автомате Мура?',
  'feedback.transitions-output-placement.answer.outputOnlyAtEnd':
      'У автомата Мура выход есть в каждом состоянии, ещё до первого входа. Где он записан?',
  'feedback.transitions-find-mealy-errors.correct':
      'Обе подписи сопоставляют входу не ту реакцию двери. В записи Мили вход и выход вместе стоят на одном переходе.',
  'feedback.transitions-find-mealy-errors.wrong':
      'Читай каждую подпись как "вход / выход" и спроси себя, какая реакция двери нужна для этого входа.',
  'feedback.transitions-complete-mealy.correct':
      'Теперь WAIT реагирует на оба значения person; каждая петля связывает один вход с подходящим выходом двери.',
  'feedback.chapter1-final-determinism.correct':
      'Детерминированный значит: для каждого состояния и входа ровно одно следующее состояние. Тогда у каждой последовательности входов ровно один путь.',
  'feedback.chapter1-final-determinism.answer.anyNumberTransitions':
      'Если бы у состояния было две стрелки с одним входом, по какой пошёл бы автомат? Подумай, что исключает детерминированность.',
  'feedback.chapter1-final-determinism.answer.noTransitionsNeeded':
      'Без переходов автомат не смог бы реагировать ни на один вход. Что должно быть задано для каждого состояния и входа?',
  'feedback.chapter1-final-moore-output.correct':
      'После перехода текущим стало q1, а выход Мура принадлежит текущему состоянию: 1.',
  'feedback.chapter1-final-moore-output.answer.0':
      'Выход 0 принадлежит q0, которое автомат только что покинул. Какое состояние текущее после входа 1 и какой у него выход?',
  'feedback.chapter1-final-trace.correct':
      'Вход 1 ведёт из IDLE в PREPARED, а вход 0 оттуда в ACTIVE. Каждый шаг начинается в состоянии, достигнутом перед ним.',
  'feedback.chapter1-final-trace.wrong':
      'Обрабатывай входы по очереди и начинай каждый шаг в состоянии, которого достиг предыдущий шаг.',
  'feedback.chapter1-final-completeness.correct':
      'У READY нет перехода по stop, а у RUNNING нет перехода по start. Полный значит: переход для каждого состояния и каждого входа.',
  'feedback.chapter1-final-completeness.answer.true':
      'Проверь каждое состояние с обоими входами из {start, stop}. Есть ли у каждого состояния переход по каждому входу?',
  'feedback.chapter1-final-conflict.correct':
      'Оба перехода выходят из q0 по входу 0, но ведут в разные состояния. Эта пара нарушает детерминированность, а q1 --1--> q2 нет.',
  'feedback.chapter1-final-conflict.wrong':
      'Для конфликта нужны одно и то же исходное состояние и один и тот же вход, но разные цели. Сравни переходы каждого состояния вход за входом.',

  // Kapitel 2
  'feedback.chapter2-gates-check.correct':
      'XOR выдаёт 1 ровно тогда, когда входы различаются, а 0 и 1 различаются.',
  'feedback.chapter2-gates-and.correct':
      'AND выдаёт 1, только если оба входа равны 1. Если один вход равен 0, выход равен 0.',
  'feedback.chapter2-gates-and.answer.true':
      'Вспомни правило AND: должен быть равен 1 один вход или оба входа?',
  'feedback.chapter2-gates-or.correct':
      'OR выдаёт 1, как только хотя бы один вход равен 1, поэтому 0 и 1 дают 1.',
  'feedback.chapter2-gates-or.answer.false':
      'Вспомни правило OR: сколько входов должно быть равно 1, чтобы выход стал 1?',
  'feedback.chapter2-state-code.correct':
      'У S₁ вес 2, у S₀ вес 1, значит, 10 - это 2 + 0 = 2. Состояние кодируют оба бита вместе.',
  'feedback.chapter2-state-code.answer.stateCodeOne':
      'Проверь вес каждого бита: какой бит имеет вес 2 и какой бит в 10 равен 1?',
  'feedback.chapter2-state-code.answer.stateCodeInvalid':
      'Эта схема использует коды 00, 01 и 10. Есть ли среди них 10?',
  'feedback.chapter2-trace.correct':
      'Каждый шаг CLK сохраняет следующее состояние из текущих битов и входа: S = 0, 2, 1, 0, 0.',
  'feedback.chapter2-trace.wrong':
      'Каждый шаг начинается с битов, сохранённых на предыдущем шаге. Вычисли логические элементы с этими битами и текущим входом, затем примени CLK.',
  'feedback.chapter2-build-table.correct':
      'Каждая строка связывает сохранённые биты S₁S₀ со входом A; логические элементы дают S′, которое сохраняет CLK. Выход зависит только от состояния.',
  'feedback.chapter2-build-table.wrong':
      'Заполняй таблицу строка за строкой: подставь биты S и значение A в логические элементы и затем прочитай S′.',
  'feedback.chapter2-final-and-table.correct':
      'Для каждого состояния и входа ты вычислил элементы AND и прочитал следующее состояние; логика выхода даёт Y для каждого состояния.',
  'feedback.chapter2-final-and-table.wrong':
      'Элемент AND даёт 1, только если все его входы равны 1. Вычисли отмеченные строки с битами S и значением A.',
  'feedback.chapter2-final-mixed-table.correct':
      'Ты правильно объединил разные логические элементы для каждой строки, а выходы следуют из битов состояния.',
  'feedback.chapter2-final-mixed-table.wrong':
      'Вычисли отмеченные строки элемент за элементом, включая инвертированные входы, прежде чем читать S′.',
  'feedback.chapter2-final-xor-output-table.correct':
      'Следующие состояния следуют из логических элементов, а логика выхода с XOR даёт 1 ровно тогда, когда два бита состояния различаются.',
  'feedback.chapter2-final-xor-output-table.wrong':
      'Для выхода сравни два бита состояния в отмеченной строке: XOR даёт 1, только если они различаются.',
  'feedback.chapter2-final-state-bits.correct':
      'У каждого бита два значения, поэтому два бита дают 2 × 2 = 4 комбинации: 00, 01, 10 и 11.',
  'feedback.chapter2-final-state-bits.2':
      'Это число битов. Сколько разных комбинаций из двух битов можно записать?',
  'feedback.chapter2-final-state-bits.3':
      'Это число кодов, которые использует схема. Вопрос о всех комбинациях до исключения неиспользуемых кодов.',
  'feedback.chapter2-final-xor-equal-inputs.correct':
      'Оба входа равны 1, то есть одинаковые, а для одинаковых входов XOR выдаёт 0.',
  'feedback.chapter2-final-xor-equal-inputs.answer.xorOne':
      'Ещё раз сравни оба входа: различаются ли 1 и 1?',
  'feedback.chapter2-final-xor-equal-inputs.answer.andOne':
      'Этот вариант описывает другой гейт. Что сравнивает XOR?',

  // Kapitel 3: Automaten vervollständigen
  'feedback.chapter4-guided-complete-coin-machine.correct':
      'Твой автомат ведёт себя так, как описано, для любой последовательности входов: две монеты ведут в q2 с выходом 1, отмена возвращает в q0, а из q2 автомат всегда возвращается в q0.',
  'feedback.chapter4-guided-complete-water-controller.correct':
      'При наполнении полного бака автомат остаётся в HIGH, поэтому выход остаётся 1. Теперь каждое состояние реагирует на оба входа.',
  'feedback.chapter4-guided-complete-pump-response.correct':
      'Единственное состояние теперь реагирует на оба значения датчика; каждая петля связывает вход с выходом насоса.',
  'feedback.chapter4-final-switch.correct':
      'Вход 0 теперь переключает в обе стороны, а вход 1 сохраняет каждое состояние. Каждое состояние реагирует на каждый вход.',
  'feedback.chapter4-final-ticket.correct':
      'Цикл полный: оплата и подтверждение ведут в q2 с выходом 1, и каждое состояние реагирует на оба входа.',
  'feedback.chapter4-final-lock.correct':
      'Вход 0 шаг за шагом ведёт замок в q3, единственное состояние с выходом 1; вход 1 возвращает назад, как описано, а из q3 автомат всегда возвращается в q0.',
  'feedback.chapter4-final-completeness-rule.correct':
      'Полный значит: переход для каждой пары "состояние - вход". Уже одна незаданная пара делает FSM неполным.',
  'feedback.chapter4-final-completeness-rule.answer.true':
      'Что произойдёт, если автомат находится в этом состоянии и получает именно этот вход? Полнота должна охватывать каждую пару "состояние - вход".',
  'feedback.chapter4-final-transition-count.correct':
      'Каждому из 3 состояний нужен ровно один переход для каждого из 2 входов: 3 × 2 = 6.',
  'feedback.chapter4-final-transition-count.chapter4.answer.fiveTransitions':
      'При пяти переходах одна пара "состояние - вход" остаётся незаданной. Сколько пар образуют 3 состояния и 2 входа?',
  'feedback.chapter4-final-transition-count.chapter4.answer.sevenTransitions':
      'При семи переходах у одной пары было бы две цели, и FSM перестал бы быть детерминированным. Посчитай пары "состояние - вход".',

  // Kapitel 4: Automaten erstellen
  'feedback.creation-build-bike-rental.correct':
      'Твой автомат ведёт себя так, как описано, для любой последовательности событий: код, взятие и возврат велосипеда образуют цикл, а остальные события сохраняют состояние.',
  'feedback.automata-creation-description-test-parcel-kiosk.correct':
      'Твой автомат посылок реагирует на каждое событие, как описано: закладка, открытие верным кодом и освобождение образуют цикл, а остальные события сохраняют состояние.',
  'feedback.creation-build-parking-barrier.correct':
      'Каждая строка таблицы стала ровно одним переходом, и каждое состояние несёт выход из таблицы выходов.',
  'feedback.creation-final-coffee.correct':
      'Только монета переводит WAITING в PAID, оба действия в PAID возвращают в WAITING, а остальные события сохраняют состояние.',
  'feedback.creation-final-locker.correct':
      'Твоя ячейка реагирует на каждое событие, как описано: неверный PIN сохраняет PARCEL STORED, а закрытие двери возвращает в LOCKER EMPTY.',
  'feedback.creation-final-washing-machine.correct':
      'Четыре события по порядку проводят через цикл стирки, а любое другое событие сохраняет текущее состояние.',

  // Kapitel 5: Prüfungsaufgaben
  'feedback.chapter5-theory-moore-output.correct':
      'Выход Мура назначен текущему состоянию. Поэтому он меняется только вместе с состоянием.',
  'feedback.chapter5-theory-moore-output.chapter5.answer.inputOnly':
      'Выход, который сразу следует за входом, типичен для Мили. Где записан выход в автомате Мура?',
  'feedback.chapter5-theory-moore-output.chapter5.answer.nextStateOnly':
      'Следующее состояние важно только тогда, когда оно стало текущим. Какому состоянию принадлежит выход Мура?',
  'feedback.chapter5-theory-mealy-output.correct':
      'Выход Мили записан на переходе, поэтому он зависит от текущего состояния вместе со входом.',
  'feedback.chapter5-theory-mealy-output.chapter5.answer.stateOnly':
      'Выход, зависящий только от состояния, описывает автомат Мура. Где записан выход Мили?',
  'feedback.chapter5-theory-mealy-output.chapter5.answer.clockOnly':
      'Тактовый сигнал решает только, когда сохраняется новое состояние. Какие два значения стоят на переходе Мили?',
  'feedback.chapter5-theory-timing.correct':
      'Поскольку выход Мили зависит и от входа, он может реагировать сразу; выход Мура ждёт следующего состояния.',
  'feedback.chapter5-theory-timing.chapter5.answer.sameTiming':
      'Сравни, от чего зависит каждый выход. Может ли выход Мура измениться, пока состояние остаётся прежним?',
  'feedback.chapter5-theory-timing.chapter5.answer.mooreImmediate':
      'Какой выход напрямую зависит от входа, а какой только от состояния?',
  'feedback.chapter5-tables-moore.correct':
      'Каждая строка таблицы переходов стала переходом, и каждое состояние несёт выход из таблицы выходов.',
  'feedback.chapter5-tables-mealy.correct':
      'Каждая запись таблицы стала переходом с входом и выходом на стрелке.',
  'feedback.chapter5-tables-practice-mealy.correct':
      'Каждое из трёх состояний реагирует на оба входа точно так, как в таблице, с входом и выходом на каждой стрелке.',
  'feedback.chapter5-complete-moore.correct':
      'Твой детектор соответствует условию для любой последовательности входов: вход 0 продвигает дальше, вход 1 возвращает, как описано, и только q1 выдаёт 1.',
  'feedback.chapter5-complete-moore-a.correct':
      'Вход 0 проходит по кругу через все три состояния, вход 1 следует своему порядку, а выходы соответствуют условию.',
  'feedback.chapter5-complete-moore-b.correct':
      'Вход 0 переключает между q0 и q1, вход 1 сохраняет каждое состояние, и оба выхода заданы.',
  'feedback.chapter5-create-mealy.correct':
      'Правильный билет в q0 открывает турникет с выходом 1; следующий билет в q1 сохраняет q1 с выходом 0, а вход 0 закрывает турникет.',
  'feedback.chapter5-create-coffee-machine.correct':
      'Только монета ведёт в PAID, выбор или отмена возвращают в WAITING, а любое другое событие сохраняет состояние.',
  'feedback.chapter5-create-washing-machine.correct':
      'Четыре события по порядку проводят через цикл, каждое состояние несёт свой выход, а остальные события сохраняют состояние.',
  'feedback.chapter5-analysis-trace.correct':
      'Каждый 0 продвигает автомат на одно состояние дальше: q0, q1, q2, q3.',
  'feedback.chapter5-analysis-trace.wrong':
      'Проходи ровно один переход на каждый вход и всегда начинай в состоянии, которого достиг на предыдущем шаге.',
  'feedback.chapter5-diagnostics-determinism.correct':
      'У q0 два перехода по входу 0: в q1 и в q2. Следующее состояние неоднозначно.',
  'feedback.chapter5-diagnostics-determinism.chapter5.answer.deterministic':
      'Сравни стрелки каждого состояния вход за входом. Есть ли состояние с двумя стрелками для одного входа?',
  'feedback.chapter5-diagnostics-missing-transition.correct':
      'У q2 есть переход только по входу 0. Для полного автомата ему нужен переход и по входу 1.',
  'feedback.chapter5-diagnostics-missing-transition.q1':
      'У q1 есть исходящая стрелка по входу 1. Проверь остальные состояния с обоими входами.',
  'feedback.chapter5-diagnostics-missing-transition.q3':
      'У q3 есть исходящая стрелка по входу 1. Проверь остальные состояния с обоими входами.',
};
