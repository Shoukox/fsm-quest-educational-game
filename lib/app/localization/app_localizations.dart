import 'package:bachelor/core/services/local_storage_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bachelor/app/localization/task_feedback_translations.dart';

enum AppLanguage {
  en('en', 'English'),
  de('de', 'Deutsch'),
  ru('ru', 'Русский');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.en,
    );
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );

/// Verwaltet die aktuelle Sprache und speichert ihre Auswahl lokal.
class AppLanguageController extends Notifier<AppLanguage> {
  static const _languageKey = 'app_language';

  @override
  AppLanguage build() {
    Future.microtask(_loadLanguage);
    return AppLanguage.en;
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      await LocalStorageService().setString(_languageKey, language.code);
    } catch (_) {
      // In Tests oder beim frühen App-Start kann die Datenbank noch fehlen.
    }
  }

  Future<void> _loadLanguage() async {
    try {
      final code = await LocalStorageService().getString(_languageKey);
      if (code == null) return;
      state = AppLanguage.fromCode(code);
    } catch (_) {
      state = AppLanguage.en;
    }
  }
}

class AppLocalizations extends InheritedWidget {
  const AppLocalizations({
    required this.language,
    required super.child,
    super.key,
  });

  final AppLanguage language;

  static AppLocalizations of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<AppLocalizations>();
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  String t(String key, {Map<String, Object> args = const {}}) {
    return translate(language, key, args: args);
  }

  /// Prüft, ob für [key] ein Text in der aktuellen Sprache oder auf Englisch vorliegt.
  bool has(String key) => hasTranslation(language, key);

  @override
  bool updateShouldNotify(AppLocalizations oldWidget) {
    return oldWidget.language != language;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Sucht zuerst in der gewählten Sprache, dann auf Englisch und zuletzt nach dem
/// Schlüssel selbst. Argumente ersetzen Platzhalter der Form `{name}` im Text.
String translate(
  AppLanguage language,
  String key, {
  Map<String, Object> args = const {},
}) {
  var value =
      _translations[language]?[key] ??
      _translations[AppLanguage.en]?[key] ??
      key;
  for (final entry in args.entries) {
    value = value.replaceAll('{${entry.key}}', entry.value.toString());
  }
  return value;
}

bool hasTranslation(AppLanguage language, String key) =>
    _translations[language]?.containsKey(key) == true ||
    _translations[AppLanguage.en]?.containsKey(key) == true;

Set<String> translationKeys(AppLanguage language) {
  return Set.unmodifiable(_translations[language]?.keys ?? const {});
}

const _translations = {
  AppLanguage.en: {
    ...taskFeedbackEn,
    'fsmFeedback.noStates': 'Add states before checking the automaton.',
    'fsmFeedback.missingInitialState':
        'Choose an initial state for the automaton.',
    'fsmFeedback.unknownInitialState':
        'The initial marker must point to an existing state.',
    'fsmFeedback.duplicateStateId':
        'State {state} occurs more than once. Use distinct state identifiers.',
    'fsmFeedback.missingStateOutput': 'Set the Moore output of state {state}.',
    'fsmFeedback.missingTransitionOutput':
        'The transition from {state} for input {input} needs a Mealy output.',
    'fsmFeedback.emptyTransitionSymbol':
        'Choose an input for a transition from state {state}.',
    'fsmFeedback.unknownTransitionEndpoint':
        'Check the endpoints of the transition from {state} for input {input}. Both must be existing states.',
    'fsmFeedback.nondeterministicTransition':
        'State {state} has more than one outgoing transition for input {input}. Keep exactly one for this input.',
    'fsmFeedback.missingTransition':
        'State {state} has no outgoing transition for input {input}. Add one for this state and input.',
    'fsmFeedback.unknownInputSymbol':
        'Input {input} at state {state} is not in the task alphabet. Use one of the actions shown.',
    'fsmFeedback.behaviorMismatch':
        'The automaton does not yet match the task specification. Check its transitions and outputs.',
    'fsmFeedback.incompleteTrace':
        'Check the output sequence: its values or length do not match the task.',
    'fsmTable.state': 'State',
    'fsmTable.input': 'Input',
    'fsmTable.nextState': 'Next state',
    'fsmTable.output': 'Output',
    'sandbox.action.tables': 'Tables',
    'sandbox.action.check': 'Check',
    'sandbox.action.simulate': 'Simulate',
    'sandbox.panel.close': 'Close panel',
    'sandbox.tables.title': 'Tables of your automaton',
    'sandbox.tables.empty':
        'Add states first. The tables are built from your drawing.',
    'sandbox.tables.noTransitions':
        'There are no transitions yet. Each input you use on a transition becomes a row of the table.',
    'sandbox.tables.alphabet': 'Inputs used: {symbols}',
    'sandbox.tables.transitionTitle': 'Transition table',
    'sandbox.tables.outputTitle': 'Output table',
    'sandbox.tables.legend':
        '→ marks the initial state, - means no transition, ⚠ means several transitions for the same state and input.',
    'sandbox.check.title': 'Structure check',
    'sandbox.check.ok':
        'No structural problems: every state has exactly one transition for each input used, and all outputs are set.',
    'sandbox.check.issues':
        '{count} problem(s) found. The affected states are marked in red.',
    'sandbox.check.scope':
        'The check uses the inputs you have drawn. It does not tell whether the automaton solves a particular task.',
    'sandbox.sim.title': 'Simulation',
    'sandbox.sim.inputLabel': 'Input sequence',
    'sandbox.sim.inputHint': 'e.g. 1 0 1 or coin, push',
    'sandbox.sim.alphabet': 'Possible inputs: {symbols}',
    'sandbox.sim.run': 'Run',
    'sandbox.sim.first': 'To the start',
    'sandbox.sim.previous': 'Previous step',
    'sandbox.sim.next': 'Next step',
    'sandbox.sim.last': 'To the end',
    'sandbox.sim.step': 'Step {step} of {total}',
    'sandbox.sim.outputs': 'Outputs: {outputs}',
    'sandbox.sim.noTransitions':
        'Draw transitions first, then you can simulate inputs.',
    'sandbox.sim.emptyInput': 'Enter at least one input.',
    'sandbox.sim.done': 'All inputs were processed.',
    'sandbox.sim.stop.missingInitialState':
        'The automaton has no initial state. Set one before simulating.',
    'sandbox.sim.stop.unknownSymbol':
        'Input {input} is not used on any transition.',
    'sandbox.sim.stop.missingTransition':
        'The simulation stops in state {state}: there is no transition for input {input}.',
    'sandbox.sim.stop.nondeterministicTransition':
        'The simulation stops in state {state}: there are several transitions for input {input}.',
    'lesson.submitTest': 'Submit test',
    'creation.test.washingMachine.prompt':
        'A Moore washing machine starts IDLE (output READY). start leads to WASHING (output WASH), wash done to RINSING (output RINSE), rinse done to DONE (output UNLOCK), and door opened returns it to IDLE. Build the automaton. For every event not otherwise specified in a state, add a self-loop: the state and its output remain unchanged.',
    'creation.test.locker.prompt':
        'A Moore parcel locker starts LOCKER EMPTY (output AVAILABLE). Inserting a parcel leads to PARCEL STORED (output LOCKED). A correct PIN opens it (DOOR OPEN, output OPEN); a wrong PIN keeps it locked. Closing the door returns it to LOCKER EMPTY. Build the automaton. For every event not otherwise specified in a state, add a self-loop: the state and its output remain unchanged.',
    'creation.test.coffee.prompt':
        'A Moore coffee machine starts WAITING (output INSERT COIN). A coin leads to PAID (output CHOOSE DRINK). Choosing a drink or cancelling returns to WAITING. Cancelling while waiting leaves it waiting. Build the automaton. For every event not otherwise specified in a state, add a self-loop: the state and its output remain unchanged.',
    'creation.description.test.prompt':
        'Practice: a parcel kiosk starts EMPTY (output READY), locks a parcel when it is inserted (PARCEL STORED, output LOCKED), opens for a valid pickup code (PICKUP OPEN, output OPEN), stays locked for a wrong code, and becomes empty after the door closes. Build its Moore automaton. For every event not otherwise specified in a state, add a self-loop: the state and its output remain unchanged.',
    'creation.tables.task.prompt':
        'Build the Moore automaton for a parking barrier from the displayed transition and output tables. Its initial state is q0.',
    'creation.tables.task.hint':
        'Read both tables. From q1, ticket leads to q2 and timeout returns to q0. The initial state is q0.',
    'creation.defaultRule':
        'For every event not otherwise specified in a state, add a self-loop: the state and its output remain unchanged.',
    'creation.check.incorrect':
        'Check the event again: taking the bike or validating the next ticket leads from q1 to q2.',
    'creation.check.correct': 'Correct: this event leads from q1 to q2.',
    'creation.check.tables':
        'Read the transition table: which state follows q1 on ticket?',
    'creation.check.description':
        'The code has been accepted (q1). Which state follows when the bike is taken?',
    'path.chapter4.locked': 'Pass the Chapter 2 test',
    'path.chapter4.test.title': 'Chapter 3 test',
    'path.chapter4.title': 'Chapter 3: Completing automata',
    'lesson.summary.automata-creation-test':
        'Build three new automata independently. Two correct solutions out of three are enough to pass.',
    'lesson.summary.automata-creation-tables':
        'Build a Moore automaton from the transition and output tables of a parking barrier.',
    'lesson.summary.automata-creation-description':
        'Derive states, outputs and transitions from descriptions of a bike rental and a parcel kiosk.',
    'creation.test.subtitle':
        '3 constructions · 15 minutes · 2 correct to pass',
    'creation.path.test.subtitle': '3 practical tasks · pass with 2 correct',
    'creation.path.test.title': 'Chapter 4 test',
    'creation.path.tables.subtitle': '1 construction task',
    'creation.path.description.subtitle': '2 construction tasks',
    'creation.path.locked': 'Pass the Chapter 3 test',
    'creation.path.unlocked': 'Construction chapter unlocked',
    'creation.path.title': 'Chapter 4: Creating automata',
    'creation.description.title': 'Create automata: descriptions',
    'creation.description.welcome.title': 'Welcome to Chapter 4',
    'automata-creation-description.welcome':
        'Welcome to Chapter 4. You will learn to create automata from real-world descriptions.',
    'creation.description.welcome.body':
        'First we derive the bike-rental automaton together. Then you build it yourself and apply the method to a parcel kiosk.',
    'creation.description.subtitle': 'From a real situation to an FSM',
    'creation.tables.title': 'Create automata: tables',
    'creation.tables.subtitle': 'From transition and output tables to an FSM',
    'automata-creation-description.story.0':
        'First read the whole situation. At a bike rental station, a bike stays locked until the station accepts a valid code. After the bike is taken, returning it makes the station ready again.',
    'automata-creation-description.story.1':
        'Turn the situations from the story into states: BIKE LOCKED, CODE ACCEPTED and BIKE TAKEN. Start with q0 = BIKE LOCKED.',
    'automata-creation-description.story.2':
        'Now add the events step by step: valid code leads to CODE ACCEPTED, wrong code loops at BIKE LOCKED, and take bike leads to BIKE TAKEN.',
    'automata-creation-description.story.3':
        'The graph follows from the description. Next, build the bike-rental automaton yourself, then transfer the method to a parcel kiosk.',
    'automata-creation-tables.story.0':
        'The same design method also starts from tables. This parking barrier has states, events and outputs already written down.',
    'automata-creation-tables.story.1':
        'The transition table says where each event leads. Read one row at a time: current state, event, next state.',
    'automata-creation-tables.story.2':
        'The output table says what the barrier does in each state. Keep state meaning, output and transitions together.',
    'automata-creation-tables.story.3':
        'Use both tables to build the parking-barrier automaton with tap-and-select.',
    'creation.description.visual.0.title': '1. Read the situation',
    'creation.description.visual.0.body':
        'A description is a specification. Extract the situations and events before drawing anything.',
    'creation.description.visual.1.title': '2. Create the states',
    'creation.description.visual.1.body':
        'Create q0, q1 and q2 for BIKE LOCKED, CODE ACCEPTED and BIKE TAKEN. Mark q0 as initial.',
    'creation.description.visual.2.title': '3. Add the transitions',
    'creation.description.visual.2.body':
        'Translate every sentence into an arrow: event on the arrow, resulting situation at its endpoint.',
    'creation.description.visual.3.title': '4. Check the complete automaton',
    'creation.description.visual.3.body':
        'All three situations and all five described events are now represented. Check that every event has a clear destination.',
    'creation.tables.visual.0.title': 'A parking barrier',
    'creation.tables.visual.0.body':
        'Tables can specify the same automaton without drawing it first.',
    'creation.tables.visual.1.title': 'Transition table',
    'creation.tables.visual.1.body':
        'Use the table to turn each state-event pair into one arrow.',
    'creation.tables.visual.2.title': 'Output table',
    'creation.tables.visual.2.body':
        'The output belongs to the current state: STOP, WAIT or GO.',
    'creation.tables.visual.3.title': 'Build it in the Sandbox',
    'creation.tables.visual.3.body':
        'Read the tables row by row, then use tap-and-select to build the graph.',
    'creation.description.task.prompt':
        'A Moore bike rental starts BIKE LOCKED (output WAIT). valid code leads to CODE ACCEPTED (output UNLOCK); wrong code leaves it locked. take bike leads from CODE ACCEPTED to BIKE TAKEN (output RIDE), timeout returns from CODE ACCEPTED to BIKE LOCKED, and return bike leads from BIKE TAKEN to BIKE LOCKED. Build the automaton. For every event not otherwise specified in a state, add a self-loop: the state and its output remain unchanged.',
    'creation.description.task.instruction':
        'Use tap-and-select: add the ready states, set q0 as initial, then choose every transition and tap its endpoints.',
    'creation.description.task.hint':
        'A wrong code leaves the bike locked; a valid code leads to CODE ACCEPTED.',
    'creation.description.test.instruction':
        'Use the description to identify the states and events, then build the complete FSM with tap-and-select.',
    'creation.description.test.hint':
        'The wrong-code transition loops on PARCEL STORED; the valid code leads to PICKUP OPEN.',
    'creation.tables.task.instruction':
        'Add the ready states, set q0 as initial, then reproduce every table row as a transition with tap-and-select.',
    'creation.test.coffee.instruction':
        'Create the two ready states and all ready transitions with tap-and-select.',
    'creation.test.coffee.hint':
        'Only coin changes WAITING to PAID. Both actions from PAID return to WAITING.',
    'creation.test.locker.instruction':
        'Create the three ready states and connect every described event using tap-and-select.',
    'creation.test.locker.hint': 'Wrong PIN is a self-loop on PARCEL STORED.',
    'creation.test.washingMachine.instruction':
        'Create the four ready states and connect the cycle with tap-and-select.',
    'creation.test.washingMachine.hint':
        'Follow the physical order: start, wash done, rinse done, door opened.',
    'fsmWorkspace.transitionOutput': 'Transition output',
    'fsmWorkspace.setTransitionOutput': 'Set the output of this transition',
    'fsmWorkspace.resetView': 'Reset view',
    'fsmWorkspace.setTransitionOutputHint':
        'You are now setting the output for the transition {from} → {to} with input {input}. The input stays unchanged.',
    'taskInteraction.actionAlphabet': 'Actions: {mapping}.',
    'taskInteraction.chapter2Legend':
        'Notation: S₁S₀ = current state code; A = input; CLK = clock pulse; S₁′S₀′ = next state after CLK; Y = output.',
    'lesson.start.skipOnce': 'Try tests directly (once)',
    'lesson.start.skipHint':
        'Already know this topic? Try the tests without the explanation. Earn all 3 stars by answering every task correctly on the first try to complete the lesson. One attempt per lesson; a mistake returns you to the explanation. Leaving also uses the attempt.',
    'lesson.start.skipUnavailable':
        'Cannot save the attempt. Start the lesson normally.',
    'lesson.start.skipFailed':
        'Study the explanation before trying the exercises again.',
    'lesson.summary.intro':
        'Discover states, the initial state and transitions using a traffic light.',
    'lesson.summary.states':
        'Identify states, reset and state outputs in diagrams.',
    'lesson.summary.transitions':
        'Read transitions and follow input sequences.',
    'lesson.summary.chapter_test':
        'Test your knowledge of states, transitions and outputs.',
    'lesson.summary.chapter2-gates-review':
        'Review AND, OR, NOT and XOR gates.',
    'lesson.summary.chapter_2':
        'Read a circuit and derive transition and output tables.',
    'lesson.summary.chapter_2_test':
        'Apply circuit logic, complete tables and reason about state bits.',
    'lesson.summary.chapter4-completion':
        'Complete missing states, transitions, reset and outputs from descriptions.',
    'lesson.summary.chapter_4_test':
        'Complete automata independently from the given requirements.',
    'lesson.summary.chapter5-theory':
        'Answer three theory questions about Moore, Mealy and timing.',
    'lesson.summary.chapter5-tables':
        'Build automata from transition and output tables.',
    'lesson.summary.chapter5-completion':
        'Complete missing elements using the description.',
    'lesson.summary.chapter5-creation':
        'Build a complete automaton from the described situation.',
    'lesson.summary.chapter5-diagnostics':
        'Find errors and trace the behaviour of automata.',
    'fsmWorkspace.chooseEndpointsHint':
        'Choose where the transition starts and where it ends.',
    'fsmGuide.addTransitionChooseEndpoints':
        'Tap {control}, then the source and target nodes. Choose an action and, for Mealy, an output from the lists.',
    'nav.learn': 'Learn',
    'nav.sandbox': 'Sandbox',
    'nav.progress': 'Progress',
    'nav.profile': 'Profile',
    'nav.settings': 'Settings',
    'common.back': 'Back',
    'common.yes': 'Yes',
    'common.next': 'Next',
    'common.finish': 'Finish',
    'lesson.storyIntro': 'Work through the example step by step.',
    'lesson.storyAcknowledge': 'I have worked through this step.',
    'lesson.storyWelcomeTitle': 'Your learning goal',
    'lesson.storyWelcomeInstruction':
        'Read the goal and identify the skill you will practise.',
    'lesson.storyRecallTitle': 'Recall',
    'lesson.storyRecallInstruction':
        'Use the diagram to recall the relevant states, inputs and outputs.',
    'lesson.storyObserveTitle': 'Observe the model',
    'lesson.storyObserveInstruction':
        'Follow one signal through the diagram before making a prediction.',
    'lesson.storyThinkTitle': 'Think before acting',
    'lesson.storyThinkInstruction':
        'Explain the next step to yourself, then confirm that you have checked it.',
    'lesson.storyPracticeTitle': 'Guided practice',
    'lesson.storyPracticeInstruction':
        'Solve this step independently and check every state/input pair.',
    'lesson.storySummaryTitle': 'What you can do now',
    'lesson.storySummaryInstruction':
        'Summarise the method and connect it to the practical chapter test.',
    'common.continue': 'Continue',
    'common.down': 'Down',
    'lesson.completeInteractionFirst':
        'Try the interactive controls on the scene first.',
    'common.reset': 'Reset',
    'common.cancel': 'Cancel',
    'common.add': 'Add',
    'common.save': 'Save',
    'answer.true': 'True',
    'answer.false': 'False',
    'lesson.taskWrong':
        'That is not correct yet. Check the automaton carefully and try again.',
    'taskDifficulty.ss1': 'Easy',
    'taskDifficulty.ss2': 'Medium',
    'taskDifficulty.ss3': 'Exam level',
    'taskDifficulty.ss4': 'Challenge',
    'taskKind.aa1': 'Outcome after a change',
    'taskKind.aa2': 'Find an error',
    'taskKind.aa3': 'Validate an automaton',
    'taskKind.aa4': 'Build an automaton',
    'taskKind.aa6': 'Build an FSM table',
    'taskKind.aa7': 'Trace a state',
    'taskKind.aa8': 'Complete an automaton',
    'taskKind.aa9': 'Theory',
    'fsmWorkspace.empty': 'No states in this automaton',
    'fsmWorkspace.tapToAdd':
        'Select "Add state", then tap anywhere on the canvas.',
    'fsmWorkspace.transitionSymbol': 'Transition symbol',
    'fsmWorkspace.symbolHint': 'For example: 0, coin, timer',
    'fsmWorkspace.stateLabel': 'State name',
    'fsmWorkspace.stateLabelHint': 'For example: Locked',
    'fsmWorkspace.customValue': 'Enter a custom value',
    'fsmWorkspace.customValueHint': 'Type any state name, action, or output.',
    'fsmWorkspace.transitionSymbolSlashError':
        'Avoid "/" in the input symbol; it separates input from output.',
    'fsmWorkspace.undo': 'Undo last action',
    'fsmWorkspace.autoArrange': 'Arrange states in a zigzag',
    'fsmWorkspace.clear': 'Clear automaton',
    'fsmWorkspace.help': 'HELP',
    'fsmWorkspace.chooseState': 'Choose a state name',
    'fsmWorkspace.chooseStateHint':
        'Pick a state with its name and output already filled in.',
    'fsmWorkspace.customState': 'Create a custom state',
    'fsmWorkspace.customStateHint': 'Then tap a free place on the canvas.',
    'fsmWorkspace.noOutput': 'No state output',
    'fsmWorkspace.chooseTransition': 'Choose a ready transition',
    'fsmWorkspace.chooseTransitionHint':
        'Pick a transition with its input and output already filled in.',
    'fsmWorkspace.customTransition': 'Create a custom transition',
    'fsmWorkspace.customTransitionHint':
        'Choose the source and target states yourself.',
    'fsmWorkspace.chooseEndpoints': 'Choose transition endpoints',
    'fsmWorkspace.fromState': 'From state',
    'fsmWorkspace.toState': 'To state',
    'fsmWorkspace.noStatesTitle': 'Add a state first',
    'fsmWorkspace.noStatesMessage':
        'Choose a ready state or create a custom state before adding a transition.',
    'fsmGuide.welcome':
        'Place nodes and arrows yourself. Choose names and outputs from lists; set the initial state with Reset.',
    'fsmGuide.customWelcome':
        'Build any Moore or Mealy automaton. Type your own state names, transition symbols and outputs, and switch modes at any time.',
    'fsmGuide.readyWelcome':
        'Place nodes and arrows yourself. Choose names and outputs from lists; set the initial state with Reset.',
    'fsmGuide.select':
        '{control} lets you choose a state and drag it to a better place.',
    'fsmGuide.addState':
        'Tap {control}, then an empty canvas position. Choose a state name from the list. Add its output and reset separately.',
    'fsmGuide.addStateCustom':
        'Tap {control}, then an empty canvas position. Choose a preset state or enter your own name; add its output and set the start state separately.',
    'fsmGuide.addStateReady':
        'Tap {control}, then an empty canvas position. Choose a state name from the list. Add its output and reset separately.',
    'fsmGuide.addTransition':
        'Tap {control}, then the source and target nodes. Choose an action and, for Mealy, an output from the lists.',
    'fsmGuide.addTransitionCustom':
        'Tap {control}, then the source and target nodes. Choose or type the input symbol and, for Mealy, the transition output.',
    'fsmGuide.addTransitionReady':
        'Tap {control}, then the source and target nodes. Choose an action and, for Mealy, an output from the lists.',
    'fsmGuide.setInitial':
        '{control} marks the state where the automaton starts after reset.',
    'fsmGuide.editOutput':
        'Tap {control}, then a Moore node or Mealy arrow, and choose its output from the list.',
    'fsmGuide.customize':
        'Long-press a node to rename it. Use {control}, then tap a Moore node to edit its output, a Moore transition to edit its label, or a Mealy transition to set its output. Choose a preset or type your own value.',
    'fsmGuide.delete': '{control} removes a state or a transition.',
    'fsmGuide.undo': '{control} brings back the last change.',
    'fsmGuide.clear':
        '{control} starts the canvas over with an empty automaton.',
    'fsmGuide.help':
        '{control} repeats this introduction whenever you need it.',
    'fsmGuide.done': 'Done',
    'fsmGuide.skip': 'Skip introduction',
    'fsmTool.select': 'Select and move',
    'fsmTool.addState': 'Add state',
    'fsmTool.addTransition': 'Add transition',
    'fsmTool.setInitial': 'Set initial state',
    'fsmTool.editOutput': 'Edit state output',
    'fsmTool.customize': 'Edit labels and outputs',
    'fsmWorkspace.stateOutput': 'State output',
    'fsmWorkspace.stateOutputHint': 'For example: 0, open, stop',
    'fsmTool.delete': 'Delete node or transition',
    'taskInteraction.input': 'Input: {input}',
    'taskInteraction.check': 'Check answer',
    'taskInteraction.checkAutomaton': 'Check automaton',
    'taskInteraction.checkTable': 'Check table',
    'taskInteraction.checkTrace': 'Check trace',
    'aa4Drag.title': 'AA4 · Build the automaton',
    'aa4Drag.hint':
        'Drag each part into a matching slot. You can also tap a part and then tap its slot.',
    'aa4Drag.parts': 'Available parts',
    'aa4Drag.slots': 'Automaton structure',
    'aa4Drag.stateSlot': 'Node {id}',
    'aa4Drag.transitionSlot': 'Transition {from} → {to}',
    'aa4Drag.initialSlot': 'Initial-state marker',
    'aa4Drag.emptySlot': 'Drop a part here',
    'aa4Drag.reset': 'Reset assembly',
    'aa4Drag.previewEmpty': 'The assembled automaton will appear here.',
    'aa4Drag.correct': 'Correct: the automaton is assembled.',
    'aa4Drag.incorrect':
        'Some parts are in the wrong slots. Rearrange them and check again.',
    'sandboxBuild.correct': 'Correct: the automaton matches the description.',
    'sandboxBuild.incorrect':
        'The automaton does not match the description yet. Check its nodes, outputs, transitions, and initial state.',
    'taskInteraction.state': 'State',
    'taskInteraction.output': 'Output',
    'taskInteraction.startState': 'Start state',
    'taskInteraction.afterInput': 'After input {input}',
    'taskInteraction.freeTextHint': 'Enter your answer',
    'taskInteraction.before': 'Before the change',
    'taskInteraction.after': 'After the change',
    'exitDialog.title': 'Exit app?',
    'exitDialog.message':
        'Fini will miss you. Are you sure you want to exit the app?',
    'exitDialog.confirm': 'Exit',
    'lessonExit.title': 'Leave lesson?',
    'lessonExit.message':
        'Progress from this attempt will not be saved. After leaving, you will see your current results.',
    'lessonExit.stay': 'Stay',
    'lessonExit.confirm': 'Leave',
    'common.fsm': 'FSM',
    'mascot.name': 'Fini',
    'onboarding.greeting.message':
        'Hi, I\'m Fini! Welcome to FSM Quest. Here you\'ll learn finite-state machines step by step: read them, complete them and build your own.',
    'onboarding.greeting.start': 'Let\'s go',
    'onboarding.username.title': 'Choose a username for the game.',
    'onboarding.username.label': 'Username',
    'onboarding.username.hint': 'Enter a username',
    'onboarding.username.helper':
        'A nickname is fine; a real name is not required.',
    'home.unit': 'Unit 1',
    'home.chapter2.unit': 'Unit 2',
    'home.title': 'Finite State Machines',
    'home.subtitle': 'States, transitions, and input strings',
    'settings.title': 'Settings',
    'settings.language': 'Language',
    'settings.theme': 'Theme',
    'settings.theme.light': 'Light',
    'settings.theme.dark': 'Dark',
    'settings.description': 'Choose the app language and theme.',
    'settings.developerAccess': 'Unlock all levels',
    'settings.developerAccess.description':
        'Developer mode: make every lesson available for testing.',
    'settings.credits': 'Credits',
    'settings.credits.lecture':
        '"Digitaltechnik" lecture, Fachgebiet ENCRYPTO, Prof. Dr.-Ing. Thomas Schneider, TU Darmstadt, WiSe 2025/26',
    'settings.credits.close': 'Close',
    'progress.title': 'Progress',
    'progress.xp': '{xp} / 100 XP',
    'progress.solvedTasks': 'Solved tasks: {count}',
    'progress.streak': 'Streak: {days} day',
    'progress.streakPlural': 'Streak: {days} days',
    'lesson.notFound': 'Lesson not found: {lessonId}',
    'lesson.practicalTest': 'Practical Test',
    'lesson.taskCount': 'Task {current} of {total}',
    'lesson.needHint': 'Need a hint?',
    'lesson.hideHint': 'Hide hint',
    'lesson.finish': 'Finish lesson',
    'lesson.next': 'Next task',
    'lesson.trace': 'Step-by-step trace',
    'lesson.showNext': 'Show next step',
    'lesson.correct': 'Correct. Continue with the next step.',
    'lesson.genericWrong':
        'Not quite: "{selected}" does not fit. Compare state, input symbol and target state step by step.',
    'lesson.start.button': 'Start',
    'lesson.start.rewardHint':
        'Your result determines the reward: 1 star = 50%, 2 stars = 75%, 3 stars = 100%.',
    'lesson.intro.title': 'Intro to FSM',
    'lesson.intro.subtitle':
        'Learn FSM basics through a real traffic-light cycle',
    'lesson.states.title': 'States',
    'lesson.states.subtitle': 'States and automaton types: Moore and Mealy',
    'lesson.transitions.title': 'Transitions',
    'lesson.transitions.subtitle': 'Input symbols and deterministic paths',
    'lesson.chapterTest.title': 'Chapter Test',
    'lesson.chapterTest.subtitle': '16 questions covering the whole chapter',
    'lesson.chapterTest.requirement':
        'Pass mark: at least {minimum} of {total} correct on the first try. A lower score resets this chapter.',
    'concept.states': 'States',
    'concept.transitions': 'States and transitions',
    'concept.mooreOutput': 'Moore output',
    'concept.startState': 'Start state',
    'concept.currentState': 'Current state',
    'concept.transitionLabels': 'Transition labels',
    'concept.errorDiagnosis': 'Error diagnosis',
    'concept.practicalSimulation': 'Practical simulation',
    'concept.digitalGates': 'Digital gates',
    'answer.0': '0',
    'answer.1': '1',
    'answer.2': '2',
    'answer.3': '3',
    'answer.4': '4',
    'answer.5': '5',
    'answer.initialRed': 'The initial state "RED"',
    'answer.randomState': 'A random state',
    'answer.greenState': 'The "GREEN" state',
    'answer.redYellowState': 'The "RED-YELLOW" state',
    'answer.yellowState': 'The "YELLOW" state',
    'answer.circlesStatesArrowsTransitions':
        'Circles are states; arrows are transitions',
    'answer.circlesTransitionsArrowsStates':
        'Circles are transitions; arrows are states',
    'answer.everythingState': 'Both circles and arrows are states',
    'answer.onlyDefinedArrows': 'Only along the defined arrows',
    'answer.anyStateDirectly': 'Directly to any state',
    'answer.alwaysResetFirst': 'Only after reset each time',
    'answer.s0': 'S0',
    'answer.s1': 'S1',
    'answer.onState': 'On the state',
    'answer.onInputArrow': 'On the input arrow',
    'answer.onlyAtEnd': 'Only at the end',
    'answer.startStateS0': 'Start state S0',
    'answer.lastState': 'The last state',
    'answer.anyOutputState': 'Any state with an output',
    'answer.noTransition': 'No transition',
    'answer.transitionS0Input1S1': 'S0 --"1"--> S1',
    'answer.transitionS0Input0S1': 'S0 --"0"--> S1',
    'answer.transitionS1Input1S0': 'S1 --"1"--> S0',
    'answer.wrongTargetState': 'Wrong target state',
    'answer.wrongInputSymbol': 'Wrong input symbol',
    'answer.noProblem': 'No problem',
    'answer.input1': 'Input 1',
    'task.intro.stateCount.prompt':
        'How many states does the traffic-light FSM shown below have?',
    'task.intro.stateCount.instruction':
        'Count the distinct traffic-light situations represented by circles.',
    'task.intro.stateCount.hint':
        'Remember red, red-yellow, green, and yellow.',
    'task.intro.stateCount.feedback.3':
        'Do not combine red and red-yellow: they are different states.',
    'task.intro.stateCount.feedback.5':
        'Only four distinct traffic-light situations are shown.',
    'task.intro.reset.prompt':
        'The RESET arrow points to the red traffic-light state. Is this a valid initial state?',
    'task.intro.reset.instruction':
        'Look at the traffic-light FSM and choose True or False.',
    'task.intro.reset.hint':
        'RESET must point to one known state that the machine can start in.',
    'task.intro.reset.feedback.random':
        'An initial state must be predictable, so RESET cannot choose randomly.',
    'task.intro.reset.feedback.green':
        'The RESET arrow points to the red traffic-light state, so the start is clearly defined.',
    'task.intro.components.prompt':
        'Which description of the FSM diagram is correct?',
    'task.intro.components.instruction':
        'Distinguish a current situation from a rule that changes it.',
    'task.intro.components.hint':
        'A state is shown as a node; movement between states follows arrows.',
    'task.intro.components.feedback.reversed':
        'The roles are reversed: circles show states and arrows show transitions.',
    'task.intro.components.feedback.everything':
        'Arrows are rules for changing state, not states themselves.',
    'task.intro.followTransition.prompt':
        'The FSM is in red. The 60-second timer expires. Which state comes next?',
    'task.intro.followTransition.instruction':
        'Follow the outgoing arrow from the current red state.',
    'task.intro.followTransition.hint':
        'The traffic light prepares drivers before switching to green.',
    'task.intro.followTransition.feedback.green':
        'Green comes later. The FSM first enters red-yellow.',
    'task.intro.followTransition.feedback.yellow':
        'Yellow follows green, not red, in this cycle.',
    'task.intro.definedPaths.prompt':
        'Can this FSM jump directly from red to green?',
    'task.intro.definedPaths.instruction':
        'Look at which directed transitions are actually defined.',
    'task.intro.definedPaths.hint':
        'An FSM changes state only when a matching transition exists.',
    'task.intro.definedPaths.feedback.anyState':
        'An FSM cannot invent a route: it follows only defined transitions.',
    'task.intro.definedPaths.feedback.reset':
        'Reset is used to initialize the FSM, not before every normal transition.',
    'task.intro.output.prompt':
        'In a Moore automaton, where is the output defined?',
    'task.intro.output.instruction':
        'Focus on the difference between state labels and transition labels.',
    'task.intro.output.hint': 'Moore outputs depend on the current state.',
    'task.intro.output.step.1': 'S0 / output 0',
    'task.intro.output.step.2': 'Input 1 moves to S1',
    'task.intro.output.step.3': 'S1 / output 1',
    'task.intro.output.feedback.onInputArrow':
        'That describes Mealy-style output. In Moore automata, output belongs to states.',
    'task.intro.output.feedback.onlyAtEnd':
        'The output is available in every current state, not only after the whole input.',
    'task.states.start.prompt':
        'Which state is active before the first input symbol is read?',
    'task.states.start.instruction':
        'Use the incoming start arrow to orient yourself.',
    'task.states.start.hint':
        'The start state is entered before reading input.',
    'task.states.start.feedback.lastState':
        'The last state is reached after processing input, not before it starts.',
    'task.states.start.feedback.anyOutputState':
        'Every Moore state may have an output, but the start arrow decides where execution begins.',
    'task.states.current.prompt':
        'Input sequence: "1", "0". Transitions: S0 --"1"--> S1, S1 --"0"--> S0. Where do we end?',
    'task.states.current.instruction': 'Follow one input symbol at a time.',
    'task.states.current.hint':
        'After input "1" you are in S1. Then apply input "0" from S1.',
    'task.states.current.step.1': 'Start in S0',
    'task.states.current.step.2': 'Input "1": S0 → S1',
    'task.states.current.step.3': 'Input "0": S1 → S0',
    'task.states.current.feedback.s1':
        'After input "1" the automaton is in S1, but input "0" then leads from S1 back to S0.',
    'task.states.current.feedback.noTransition':
        'There is a defined transition for input "0" from S1 to S0.',
    'task.transitions.symbol.prompt':
        'At S0, input "1" should move to S1. Which transition is correct?',
    'task.transitions.symbol.instruction':
        'Check source state, input symbol and target state.',
    'task.transitions.symbol.hint':
        'The source must be S0 and the input symbol must be "1".',
    'task.transitions.symbol.feedback.wrongInput':
        'The target is right, but the input label is wrong: the task asks for input "1".',
    'task.transitions.symbol.feedback.reversed':
        'This reverses source and target. The transition must start at S0.',
    'task.transitions.error.prompt':
        'Input "1" from S0 should lead to S1. A solution uses S0 --"1"--> S2. What is wrong?',
    'task.transitions.error.instruction':
        'Compare the expected transition with the proposed transition.',
    'task.transitions.error.hint':
        'The input symbol is "1" in both transitions.',
    'task.transitions.error.feedback.wrongInputSymbol':
        'The input is "1" in both cases. The error is the target state.',
    'task.transitions.error.feedback.noProblem':
        'There is a problem: on input "1", the transition from S0 leads to S1, not S2.',
    'task.test.simulate.prompt':
        'Simulate input 101. Transitions: S0 --"1"--> S1, S1 --"0"--> S1, S1 --"1"--> S0. Final state?',
    'task.test.simulate.instruction': 'Work step by step under the time limit.',
    'task.test.simulate.hint':
        'After "1" you are in S1; after "0" you stay in S1.',
    'task.test.simulate.step.1': 'Start S0',
    'task.test.simulate.step.2': '"1": S0 → S1',
    'task.test.simulate.step.3': '"0": S1 → S1',
    'task.test.simulate.step.4': '"1": S1 → S0',
    'task.test.simulate.feedback.s1':
        'The first two symbols leave you in S1, but the last input "1" moves from S1 to S0.',
    'task.test.simulate.feedback.noTransition':
        'All required transitions are defined for this input sequence.',
    'task.test.mooreOutput.prompt':
        'State S0 has output 0, S1 has output 1. After input 1 the automaton is in S1. What output is shown?',
    'task.test.mooreOutput.instruction':
        'Use the current state after the transition.',
    'task.test.mooreOutput.hint':
        'Moore output is attached to the reached state.',
    'task.test.mooreOutput.feedback.0':
        'Output 0 belongs to S0. After input 1 the current state is S1.',
    'task.test.mooreOutput.feedback.input1':
        'Input symbols are not outputs. The output is the value attached to S1.',
    'result.saved': 'Lesson complete',
    'result.abandoned': 'Lesson interrupted',
    'result.abandonedLesson': 'Not completed: {lessonId}',
    'result.chapterFailed': 'Chapter test not passed',
    'result.chapterFailedDetail':
        'You answered {score} of {total} correctly on the first try. At least {minimum} are required, so the chapter progress has been reset.',
    'result.chapterNoRewards':
        'No XP, coins, or stars were awarded for this attempt.',
    'result.noRewards':
        'Progress was not saved. No XP, coins, or stars were awarded.',
    'result.saving': 'Saving rewards…',
    'result.saveFailed': 'Progress could not be saved',
    'result.completed': 'Completed: {lessonId}',
    'result.xpEarned': 'XP earned: {score}',
    'result.firstTryScore': 'Correct on the first try: {score}',
    'result.rewards': '+{xp} XP  •  +{coins} coins',
    'result.repeatLesson': 'Repeat lesson',
    'result.restartChapter': 'Restart chapter',
    'result.backHome': 'Back home',
    'result.nextLesson': 'Next lesson',
    'sandbox.canvas': 'FSM canvas',
    'path.intro.title': 'Intro to FSM',
    'path.intro.subtitle': '3 tasks',
    'path.states.title': 'States',
    'path.states.subtitle': '3 tasks',
    'path.transitions.title': 'Transitions',
    'path.transitions.subtitle': '3 tasks',
    'path.test.title': 'Chapter Test',
    'path.test.subtitle': '5 questions',
    'path.chapter2.title': 'Chapter 2: Understanding DT-FSM diagrams',
    'path.chapter2.review.title': 'Digital gates review',
    'path.chapter2.review.subtitle': '3 tasks',
    'path.chapter2.locked': 'Pass the chapter test',
    'path.chapter2.unlocked': 'New chapter unlocked',
    'path.solved': 'Solved',
    'path.continue': 'Continue here',
    'path.finalCheck': 'Final check',
    'path.locked': 'Locked',
    'introFsm.auto': 'Auto',
    'introFsm.nextPhase': 'Next',
    'introFsm.step.1':
        'Welcome to the first lesson! Have you heard of finite state machines before?',
    'introFsm.step.2':
        'Imagine a German traffic light. It has four states:(1)red (2)red-yellow (3)green (4)yellow.',
    'introFsm.step.021':
        'Imagine a German traffic light. It has four states: red, red-yellow, green, and yellow.',
    'introFsm.step.022': 'Let\'s take a closer look at this traffic light.',
    'introFsm.step.023': 'Look: when the light is red, all cars must stop.',
    'introFsm.step.024':
        'After 60 seconds, red changes to red-yellow. Drivers can get ready.',
    'introFsm.step.025':
        'Now red and yellow are on together. The light is preparing to turn green.',
    'introFsm.step.026': 'After 10 seconds, the transition leads to green.',
    'introFsm.step.027': 'When the light is green, cars may go.',
    'introFsm.step.028': 'After 60 seconds, green changes to yellow.',
    'introFsm.step.029':
        'Yellow means stop soon. After 10 seconds, the transition returns to red.',
    'introFsm.step.3':
        'Step by step: red lasts 60 seconds, then red-yellow lasts 10 seconds, then green lasts 60 seconds and yellow lasts 10 seconds.',
    'introFsm.step.4':
        'Now we turn the traffic light into an FSM: states are circles, and timer rules are transitions between them.',
    'introFsm.step.041':
        'The reset arrow is the single start arrow for the whole automaton. It always returns the FSM to its initial state: red.',
    'introFsm.step.042':
        'This circle is a node, or state. It describes the complete situation right now: the red light is on, so cars must stop.',
    'introFsm.step.043':
        'This arrow is a transition. After 60 seconds, its input moves the machine from red to red-yellow.',
    'introFsm.step.044':
        'This node is another state: red-yellow. It is a short preparation phase before green, not a separate random event.',
    'introFsm.step.045':
        'This transition has a 10-second rule. When that time is reached, the machine leaves red-yellow and enters green.',
    'introFsm.step.046':
        'This node represents green: the current state tells the traffic light, and the drivers, that cars may go.',
    'introFsm.step.047':
        'After 60 seconds, this transition leads from green to yellow. The arrowhead always shows which node comes next.',
    'introFsm.step.048':
        'This node represents yellow. It gives drivers time to stop safely before the cycle starts again.',
    'introFsm.step.049':
        'The last transition waits 10 seconds and returns yellow to red. Together, all arrows form a controlled cycle.',
    'introFsm.step.5':
        'Great work! Let\'s try five questions about nodes, transitions, reset, and the traffic-light cycle. Shall we check whether we understood everything?',
    'introFsm.readyTitle': 'Ready for a quick check?',
    'introFsm.readyBody':
        'There are 5 questions ahead. Try to answer each one correctly on the first attempt to earn the maximum reward. If anything is unclear, I\'ll help you with a hint.',
    'introFsm.notYet': 'Not now',
    'introFsm.startTasks': 'Start tasks',
    'introFsm.stateExplanation':
        'The current traffic-light color is the state. Time passing is the input that triggers the next transition.',
    'introFsm.state.red': '1. Red: stop',
    'introFsm.state.redYellow': '2. red-yellow: get ready',
    'introFsm.state.green': '3. Green: go',
    'introFsm.state.yellow': '4. Yellow: stop soon',
    'introFsm.statesTitle': 'States',
    'introFsm.ruleTitle': 'Traffic-light rule',
    'introFsm.transition.redToRedYellow': '1. Red -> red-yellow (60 sec)',
    'introFsm.transition.redYellowToGreen': '2. red-yellow -> green (10 sec)',
    'introFsm.transition.greenToYellow': '3. Green -> yellow (60 sec)',
    'introFsm.transition.yellowToRed': '4. Yellow -> red (10 sec)',
    'introFsm.timerTitle': 'Timer ticks change the state step by step',
    'introFsm.node.red': 'RED',
    'introFsm.node.redYellow': 'RED-YELLOW',
    'introFsm.node.green': 'GREEN',
    'introFsm.node.yellow': 'YELLOW',
    'introFsm.duration.60': '60 s',
    'introFsm.duration.10': '10 sec',
    'introFsm.fsmExplanation':
        'In an FSM diagram, every circle is a node and every arrow is a transition to the next node.',
    'statesStory.intro.01':
        'Let\'s look at what these machines from the previous lesson are called.',
    'statesStory.intro.02':
        'In the Digitaltechnik module at TU Darmstadt, we study two types of finite-state machines (FSM): Mealy machines and Moore machines.',
    'statesStory.intro.03':
        'Now let\'s learn about Mealy and Moore machines and how to tell them apart! We\'ll use a practical example based on a turnstile - an automatically opening door, such as the entrance to a shop.',
    'statesStory.intro.mealy': 'Mealy machine',
    'statesStory.intro.moore': 'Moore machine',
    'statesStory.step.01':
        'On the previous screen we saw the general structure of a finite-state machine. Now let\'s use a turnstile to see what a state means: it can be locked or unlocked.',
    'statesStory.step.02':
        'By convention, the complete set of nodes is denoted by the capital letter Q, while individual nodes are called q0, q1, q2, and so on. Descriptions clarify their meaning: q0 = "turnstile locked", q1 = "turnstile unlocked".',
    'statesStory.step.04':
        'The index makes every state easy to reference, while a separate description explains its meaning. Here q0 means "turnstile locked" and q1 means "turnstile unlocked". The number is only an identifier: q0 is not automatically the initial or current state.',
    'statesStory.step.05':
        'The highlight shows what the machine remembers right now: q0 is active, so the turnstile is locked.',
    'statesStory.step.06':
        'Now it\'s your turn to control the turnstile! Watch the current node, insert a coin, and let a person pass through. The turnstile opens and locks again automatically.',
    'statesStory.step.07':
        'For a finite-state machine (FSM), the most important thing is knowing which node is current right now. Only the current node determines how the machine reacts to events and which values it outputs.',
    'statesStory.step.08':
        'Even before the first event, the machine needs a starting point. The "RESET" arrow identifies the initial node - for our turnstile, that is q0.',
    'statesStory.step.09':
        'The "RESET" arrow is present in every machine. It always returns the machine to its initial node, no matter what happened before. Without this arrow, the machine is not valid.',
    'statesStory.step.10':
        'Experiment again: move to q1, then press Reset. No matter what happened earlier, reset makes q0 - the locked turnstile - the current state.',
    'statesStory.step.11':
        'Our machines produce outputs. In a Moore FSM, every state owns its output: q0 outputs STOP, while q1 outputs GO. The legend below still tells you what each identifier means.',
    'statesStory.step.12':
        'Which state indicates that a person may pass through the turnstile? Check the legend and tap the node where the turnstile allows passage.',
    'statesStory.step.13':
        'When the machine enters node q1, it outputs "GO". The machine\'s output is denoted by the letter "y". In a Moore machine, the output depends only on the current state.',
    'statesStory.step.14':
        'Finite-state machines can produce outputs in two common ways. In a Moore machine, output belongs to the current state; in a Mealy machine, output belongs to a transition.',
    'statesStory.step.15':
        'Look at the notation: Moore writes output on states, such as q0 / STOP. Mealy writes input / output on arrows, such as coin / GO.',
    'statesStory.step.16':
        'Try the Mealy transition yourself. When coin occurs, the transition both changes the state and produces GO.',
    'statesStory.step.17':
        'Let\'s trace it step by step: reset gives q0/STOP, a coin gives q1/GO, and passage returns to q0/STOP.',
    'statesStory.step.18':
        'Here is the whole state toolkit. Initial says where execution starts, current says where the machine is now, and outputs may belong to states or transitions.',
    'statesStory.step.19':
        'Excellent - you can now trace states and distinguish Moore from Mealy machines! Let\'s finish with six short questions. First-try answers determine how many stars you earn.',
    'statesStory.teachMe': 'Teach me',
    'statesStory.next': 'Next',
    'statesStory.startTasks': 'Start 6 questions',
    'statesStory.state': 'State',
    'statesStory.meaning.q0': 'q0 = "turnstile locked"',
    'statesStory.meaning.q1': 'q1 = "turnstile unlocked"',
    'statesStory.event': 'Event',
    'statesStory.snapshotTitle': 'One machine, two possible states',
    'statesStory.locked': 'Locked',
    'statesStory.unlocked': 'Unlocked',
    'statesStory.coin': 'Insert coin',
    'statesStory.passage': 'Pass through',
    'statesStory.coinShort': 'coin',
    'statesStory.passageShort': 'passage',
    'statesStory.current': 'Current state',
    'statesStory.initial': 'Initial state',
    'statesStory.output': 'State output',
    'statesStory.output.locked': 'y = STOP',
    'statesStory.output.unlocked': 'y = GO',
    'statesStory.sim.ready':
        'The current state is Locked. Try a coin or simulate a passage.',
    'statesStory.sim.coinUnlocked':
        'Coin accepted: the turnstile opens automatically; the current state is now Unlocked.',
    'statesStory.sim.alreadyUnlocked':
        'The turnstile was already Unlocked, so another coin does not change its state.',
    'statesStory.sim.passageLocked':
        'A passage attempt cannot open a Locked turnstile. The state stays Locked.',
    'statesStory.sim.passageLockedAgain':
        'The person passed through; the turnstile closes and returns to Locked automatically.',
    'statesStory.sim.resetLocked':
        'Reset ignores the history and makes Locked current.',
    'statesStory.memoryTitle': 'Long history → small relevant memory',
    'statesStory.memory.coin': 'coin',
    'statesStory.memory.passage': 'passage',
    'statesStory.memoryRelevant': 'Relevant now: Unlocked',
    'statesStory.memoryExplanation':
        'Future behavior depends on the current state, not on remembering every past event.',
    'statesStory.initialTitle': 'What makes a state initial?',
    'statesStory.initialFact.1': 'It is active before the first normal input.',
    'statesStory.initialFact.2': 'The reset/start arrow points to it.',
    'statesStory.initialFact.3':
        'There is one designated initial state in this FSM.',
    'statesStory.outputPicker.title': 'Which state outputs GO?',
    'statesStory.outputPicker.prompt':
        'Tap the state in which passage is allowed.',
    'statesStory.outputPicker.locked':
        'Locked should output STOP. Try the other state.',
    'statesStory.outputPicker.unlocked': 'Correct! Unlocked outputs GO.',
    'statesStory.moore.title': 'Moore machine',
    'statesStory.moore.description':
        'The output is attached to the current state.',
    'statesStory.mealy.title': 'Mealy machine',
    'statesStory.mealy.description':
        'The output is attached to the transition that fires.',
    'statesStory.output.stop': 'y = STOP',
    'statesStory.output.go': 'y = GO',
    'statesStory.moore.transition': 'coin',
    'statesStory.mealy.transition': 'coin / GO',
    'statesStory.placement.title': 'Where is the output written?',
    'statesStory.placement.state': 'On a state',
    'statesStory.placement.transition': 'On a transition',
    'statesStory.placement.correct':
        'Exactly! Moore → state, Mealy → transition.',
    'statesStory.placement.wrong':
        'Almost. Moore keeps outputs on states; Mealy puts them on transitions.',
    'statesStory.mealy.simulationTitle': 'Run a Mealy transition',
    'statesStory.mealy.simulationRun': 'Insert coin',
    'statesStory.mealy.simulationReset': 'Reset example',
    'statesStory.mealy.simulationFeedback':
        'coin / GO fired: the machine produced GO and moved to Unlocked.',
    'statesStory.trace.reset': 'Reset',
    'statesStory.trace.coin': 'Coin',
    'statesStory.trace.passage': 'Passage',
    'statesStory.trace.next': 'Apply next input',
    'statesStory.trace.restart': 'Restart trace',
    'statesStory.rolesTitle': 'State essentials',
    'statesStory.roles.initial':
        'The designated starting point before normal input.',
    'statesStory.roles.current': 'The one active state right now.',
    'statesStory.roles.output':
        'The value produced while this state is current.',
    'statesStory.rolesOverlap':
        'In a Moore FSM, changing the current state also changes the output.',
    'statesStory.readyTitle': 'State lesson complete',
    'statesStory.readyBody':
        'Six questions will check states, tracing, outputs, and the difference between Moore and Mealy machines.',
    'concept.stateOutput': 'State output',
    'concept.mooreMealy': 'Moore and Mealy outputs',
    'answer.nodeQ0': 'q0',
    'answer.nodeQ1': 'q1',
    'answer.nodeQ2': 'q2',
    'answer.transitionA': 'Arrow "a"',
    'answer.resetArrow': '"RESET" arrow',
    'answer.transitionQ0AQ1': 'q0 -"a"→ q1',
    'answer.transitionQ0AQ2': 'q0 -"a"→ q2',
    'answer.lockedState': '"Locked"',
    'answer.unlockedState': '"Unlocked"',
    'answer.bothStates': 'Both states at the same time',
    'answer.outputBelongsToState': 'The output belongs to the current state',
    'answer.outputBelongsToTransition':
        'The output belongs only to the transition arrow',
    'answer.outputOnlyAtEnd': 'The output exists only after all input is read',
    'answer.mooreStateMealyTransition':
        'Moore: on states; Mealy: on transitions',
    'answer.mooreTransitionMealyState':
        'Moore: on transitions; Mealy: on states',
    'answer.bothOutputsOnStates': 'Both machines put outputs on states',
    'answer.goOutput': '"GO"',
    'answer.stopOutput': '"STOP"',
    'answer.noOutput': 'No output',
    'task.states.nodes.prompt': 'Select every node in the FSM diagram.',
    'task.states.nodes.instruction':
        'You may select more than one answer. Mark only the elements that are nodes.',
    'task.states.nodes.hint':
        'Nodes are drawn as circles. Arrows and the RESET marker are not nodes.',
    'task.states.initial.prompt':
        'Look at the diagram. Is q0 correctly designated as the initial node?',
    'task.states.initial.instruction':
        'Inspect the diagram and choose True or False.',
    'task.states.initial.hint':
        'The node targeted by "RESET" is the initial node.',
    'task.states.trace.prompt':
        'Start at "RESET", then apply "coin" and "passage". Which node is current after these two inputs?',
    'task.states.trace.instruction':
        'Keep exactly one current state after each step.',
    'task.states.trace.hint':
        'After "coin" the turnstile is "Unlocked"; "passage" returns it to "Locked".',
    'task.states.trace.step.1': '"RESET": current state = "Locked"',
    'task.states.trace.step.2': '"coin": current state = "Unlocked"',
    'task.states.trace.step.3': '"passage": current state = "Locked"',
    'task.states.trace.feedback.unlocked':
        '"Unlocked" is the intermediate state after "coin"; "passage" returns to "Locked".',
    'task.states.trace.feedback.both':
        'A deterministic FSM has one current state at a time in this example.',
    'task.states.output.prompt':
        'Where is the output defined in the Moore FSMs used here?',
    'task.states.output.instruction':
        'Connect the produced value to the current state.',
    'task.states.output.hint':
        'When the current state changes, the Moore output changes with it.',
    'task.states.output.feedback.transition':
        'That would describe a Mealy-style output. Here the output belongs to a state.',
    'task.states.output.feedback.end':
        'The current state always has an output, not only after the complete input.',
    'task.states.mooreMealy.prompt':
        'Where are outputs written in Moore and Mealy machines?',
    'task.states.mooreMealy.instruction':
        'Match each machine type to the diagram element that owns its output.',
    'task.states.mooreMealy.hint':
        'Moore reacts through a state; Mealy writes input / output on an arrow.',
    'task.states.mooreMealy.feedback.reversed':
        'The pair is reversed: Moore uses states, while Mealy uses transitions.',
    'task.states.mooreMealy.feedback.bothStates':
        'Only Moore attaches outputs to states. Mealy attaches them to transitions.',
    'task.states.mealyOutput.prompt':
        'Look at the Mealy diagram. A "coin" is inserted in q0. Which output is produced?',
    'task.states.mealyOutput.instruction':
        'Read the transition label as input / output.',
    'task.states.mealyOutput.hint':
        'In "coin / GO", the part after the slash is the output.',
    'task.states.mealyOutput.step.1': 'Current state: "Locked"',
    'task.states.mealyOutput.step.2': 'Input: "coin"',
    'task.states.mealyOutput.feedback.stop':
        '"STOP" belongs to the locked Moore-state example. This Mealy arrow explicitly produces "GO".',
    'task.states.mealyOutput.feedback.none':
        'A Mealy output is produced when its transition fires; here "coin / GO" fires.',
    'transitionsStory.step.01':
        'You already know that states describe the current situation. Transitions are the rules that move the FSM from one situation to another. Do you remember what an arrow tells us?',
    'transitionsStory.step.02':
        'Every transition answers three questions: Where are we starting? What trigger happened? Which state becomes current next?',
    'transitionsStory.step.03':
        'Let\'s read one rule: Locked -coin→ Unlocked. Tap each part and let me explain its job.',
    'transitionsStory.step.04':
        'A transition is directed. The arrow begins at its source state and its arrowhead points to the target state. Reading it backwards describes a different rule.',
    'transitionsStory.step.05':
        'Check the direction yourself. If the machine is Locked and a coin is inserted, which reading follows the arrow?',
    'transitionsStory.step.06':
        'The label above an arrow is its trigger or input. It may be a button press, an expired timer, or an input symbol such as 0 or 1.',
    'transitionsStory.step.07':
        'A trigger is checked from the current source state. The same event can produce another result - or no move at all - when a different state is current.',
    'transitionsStory.step.08':
        'An FSM may follow only transitions that are actually defined. If the diagram contains A → B but no A → C arrow, the machine cannot invent the shortcut.',
    'transitionsStory.step.09':
        'Remember our German traffic light? Its four timer rules form a transition cycle: red, red-yellow, green, yellow, and back to red.',
    'transitionsStory.step.10':
        'Run the traffic light yourself. The highlighted arrow is the only timer transition available from the current state.',
    'transitionsStory.step.11':
        'Focus on this rule: Red -60 seconds→ red-yellow. Source, trigger, direction, and target together make one complete transition.',
    'transitionsStory.step.12':
        'Now trace several transitions in order. After each trigger, first update the current state; only then search for the next outgoing transition.',
    'transitionsStory.step.13':
        'A transition may return to the same state. This is a self-loop. Pushing a locked door can leave it Locked while still handling the event.',
    'transitionsStory.step.14':
        'In a deterministic FSM, one source state and one trigger must identify at most one target. Two arrows with the same source and input but different targets create a conflict.',
    'transitionsStory.step.15':
        'To read any transition, check source, trigger, arrow direction, and target. Then verify that the rule is defined and does not conflict with another rule.',
    'transitionsStory.step.16':
        'Excellent - you can now read, simulate, and diagnose transitions! Five questions will check the whole lesson, including the traffic-light cycle.',
    'transitionsStory.teachMe': 'Teach me',
    'transitionsStory.startTasks': 'Start 5 questions',
    'transitionsStory.formulaTitle': 'A transition is a directed rule',
    'transitionsStory.source': 'Source state',
    'transitionsStory.trigger': 'Trigger / input',
    'transitionsStory.target': 'Target state',
    'transitionsStory.explorerTitle': 'Locked - coin → Unlocked',
    'transitionsStory.locked': 'Locked',
    'transitionsStory.coin': 'coin',
    'transitionsStory.unlocked': 'Unlocked',
    'transitionsStory.push': 'Push',
    'transitionsStory.explorerPrompt': 'Tap one of the three components.',
    'transitionsStory.explorer.source':
        'Locked is the source: the rule can be used only when Locked is current.',
    'transitionsStory.explorer.trigger':
        'Coin is the trigger: this event activates the rule.',
    'transitionsStory.explorer.target':
        'Unlocked is the target: it becomes current after the transition.',
    'transitionsStory.directionCaption':
        'Follow the arrowhead: Locked → Unlocked, not the reverse.',
    'transitionsStory.directionQuestion':
        'Which direction matches Locked -coin→ Unlocked?',
    'transitionsStory.direction.correct': 'From Locked to Unlocked',
    'transitionsStory.direction.reversed': 'From Unlocked to Locked',
    'transitionsStory.direction.correctFeedback':
        'Correct. The arrowhead points to Unlocked.',
    'transitionsStory.direction.wrongFeedback':
        'That reads the arrow backwards. Source and target would be swapped.',
    'transitionsStory.triggerTitle': 'A trigger activates a rule',
    'transitionsStory.trigger.button': 'button pressed',
    'transitionsStory.trigger.timer': 'timer expired',
    'transitionsStory.trigger.symbol': 'symbol 0 or 1',
    'transitionsStory.triggerCaption':
        'The arrow label says when that transition is allowed to fire.',
    'transitionsStory.sourceRule.locked':
        'From Locked, coin can lead to Unlocked.',
    'transitionsStory.sourceRule.unlocked':
        'From Unlocked, the same coin does not automatically use the Locked rule.',
    'transitionsStory.toggleCurrent': 'Change current state',
    'transitionsStory.definedCaption':
        'A can reach B because an arrow exists. Without an A → C arrow, C is not a legal next state.',
    'transitionsStory.traffic.red': 'RED',
    'transitionsStory.traffic.redYellow': 'RED-YELLOW',
    'transitionsStory.traffic.green': 'GREEN',
    'transitionsStory.traffic.yellow': 'YELLOW',
    'transitionsStory.traffic.advance': 'Expire {seconds}-second timer',
    'transitionsStory.trace.0':
        'Start in Red. Find the outgoing rule whose trigger is 60 seconds.',
    'transitionsStory.trace.1':
        'After 60 seconds: current = red-yellow. Next trigger: 10 seconds.',
    'transitionsStory.trace.2':
        'After 10 seconds: current = Green. Next trigger: 60 seconds.',
    'transitionsStory.trace.3':
        'After 60 seconds: current = Yellow. The trace followed one rule at a time.',
    'transitionsStory.trace.next': 'Apply next transition',
    'transitionsStory.trace.restart': 'Restart trace',
    'transitionsStory.selfLoopCount':
        'Push events handled: {count}. Current state remains Locked.',
    'transitionsStory.determinism.source': 'Source',
    'transitionsStory.determinism.targetA': 'Target A',
    'transitionsStory.determinism.targetB': 'Target B',
    'transitionsStory.determinism.sameInput': 'same\ninput',
    'transitionsStory.determinism.check': 'Check these rules',
    'transitionsStory.determinism.feedback':
        'Conflict: the machine cannot choose one predictable target for this source and input.',
    'transitionsStory.summaryTitle': 'Transition checklist',
    'transitionsStory.summary.source': 'Start at the current source state.',
    'transitionsStory.summary.trigger': 'Match the event with the arrow label.',
    'transitionsStory.summary.direction':
        'Follow the arrow in its drawn direction.',
    'transitionsStory.summary.target': 'Make the target the new current state.',
    'transitionsStory.summary.determinism':
        'Avoid two targets for the same source and trigger.',
    'transitionsStory.readyTitle': 'Transition lesson complete',
    'transitionsStory.readyBody':
        'Five questions cover reading arrows, direction, defined paths, the traffic-light trace, and determinism.',
    'answer.lockedCoinUnlocked': 'Locked -"coin"→ Unlocked',
    'answer.unlockedCoinLocked': 'Unlocked -"coin"→ Locked',
    'answer.lockedPushUnlocked': 'Locked -"passage"→ Unlocked',
    'answer.arrowSourceToTarget': 'From the source to the target',
    'answer.arrowTargetToSource': 'From the target back to the source',
    'answer.arrowHasNoDirection': 'An arrow has no direction',
    'answer.trafficGreen': '"GREEN"',
    'answer.trafficRedYellow': '"RED-YELLOW"',
    'answer.trafficYellow': '"YELLOW"',
    'answer.onlyExistingTransition':
        'Only follow an existing transition from the current state',
    'answer.anyDesiredState': 'Jump to any desired state',
    'answer.skipIntermediateState':
        'Skip an intermediate state even without an arrow',
    'answer.deterministicConflict':
        'The same source and input lead to two different targets',
    'answer.validSelfLoop': 'A transition returns to its source state',
    'answer.missingInitialState':
        'The shown transition does not mention the initial state',
    'task.transitions.reading.prompt':
        'Trace the diagram for the input "coin". Which node is current at the start and which node is current afterward?',
    'task.transitions.reading.instruction':
        'Choose the current node for both stages of the trace.',
    'task.transitions.reading.hint':
        'Start at q0 and follow the "coin" arrow to q1.',
    'task.transitions.reading.feedback.reversed':
        'This swaps source and target by reading the arrow backwards.',
    'task.transitions.reading.feedback.trigger':
        'The direction is right, but the arrow label is "coin", not "passage".',
    'task.transitions.direction.prompt':
        'What direction does a transition arrow describe?',
    'task.transitions.direction.instruction':
        'Use the tail and arrowhead to orient the rule.',
    'task.transitions.direction.hint':
        'The arrowhead touches the state that becomes current next.',
    'task.transitions.direction.feedback.reversed':
        'The arrow points away from the source and toward the target.',
    'task.transitions.direction.feedback.none':
        'Direction is essential: reversing an arrow creates a different rule.',
    'task.transitions.traffic.prompt':
        'Traffic-light FSM: start Red, then apply 60 seconds and 10 seconds. Which state is current?',
    'task.transitions.traffic.instruction':
        'Follow exactly one outgoing timer transition at each step.',
    'task.transitions.traffic.hint':
        '60 seconds leads to red-yellow; then apply the 10-second rule.',
    'task.transitions.traffic.step.1': 'Start: Red',
    'task.transitions.traffic.step.2': '60 seconds: Red → red-yellow',
    'task.transitions.traffic.step.3': '10 seconds: red-yellow → Green',
    'task.transitions.traffic.feedback.redYellow':
        'red-yellow is the intermediate state after only the first timer.',
    'task.transitions.traffic.feedback.yellow':
        'Yellow comes after Green later in the cycle.',
    'task.transitions.defined.prompt': 'How may an FSM choose its next state?',
    'task.transitions.defined.instruction':
        'Use only rules drawn or otherwise defined for the current state.',
    'task.transitions.defined.hint':
        'No arrow means there is no such transition.',
    'task.transitions.defined.feedback.any':
        'An FSM follows rules; it cannot choose an arbitrary destination.',
    'task.transitions.defined.feedback.skip':
        'Skipping requires its own direct transition. Without one, the path is illegal.',
    'task.transitions.determinism.prompt':
        'Select both transitions that create the determinism conflict.',
    'task.transitions.determinism.instruction':
        'Find the two arrows with the same source and input but different targets.',
    'task.transitions.determinism.hint':
        'Both conflicting arrows leave q0 with the input "a".',
    'task.transitions.determinism.feedback.selfLoop':
        'A self-loop is a valid transition back to the same state.',
    'task.transitions.determinism.feedback.initial':
        'A normal transition does not need to mention the initial state.',
    'mascot.intro.greeting': 'Glad to see you.',
    'mascot.intro.greeting.username': 'Glad to see you, {username}!',
    'mascot.intro.identity':
        'I\'ll be your guide in FSM Quest: I\'ll help you find your way around, make sense of new ideas, and keep track of your progress.',
    'mascot.intro.mission':
        'Together, we\'ll learn finite-state machines step by step - from their basic building blocks to reading, building, and checking automata. First, let me show you around.',
    'mascot.intro.lessonPath':
        'This is your lesson path. Start with the highlighted lesson; complete its tasks to unlock what comes next. I\'ll be here if you need a hand.',
    'mascot.intro.sandbox':
        'This is Sandbox, your workshop. Try building and changing automata to see what happens - no grades here, just experiments.',
    'mascot.intro.progress':
        'Here you can see your XP, stars, solved tasks, and learning streak. It\'s a nice way to see how far you\'ve come.',
    'mascot.intro.settings':
        'Here you can change the language or switch between light and dark appearance. You can change these whenever you like.',
    'mascot.intro.languages':
        'Choose the language that feels most comfortable: English, Deutsch, or Русский. You can change it later in Settings.',
    'mascot.intro.returnHome':
        'All set! Let\'s head back to the lesson path. Next, I\'ll show you the chapters ahead.',
    'mascot.chapterTour.intro':
        'Now let\'s look at the chapters ahead. I\'ll scroll through them so you can see how our journey builds. You can skip the tour at any time.',
    'mascot.chapterTour.summary':
        'That\'s the route ahead: we\'ll begin with the building blocks, then put them to work on more complex machines. Let\'s head back to the beginning and choose where to start.',
    'mascot.chapterTour.skip': 'Skip tour',
    'mascot.chapterTour.progress': 'Chapter {chapter} of {total}',
    'mascot.chapter1.intro':
        'In Kapitel 1, we\'ll explore the basics of finite-state machines - states and transitions - through clear examples. At the end, we\'ll check what you\'ve learned.',
    'mascot.chapter1.choice.title': 'Ready for Kapitel 1?',
    'mascot.chapter1.choice.body':
        'If you already know the basics of finite-state machines, you can skip Kapitel 1 and come back whenever you like.',
    'mascot.chapter1.choice.start': 'Start Kapitel 1',
    'mascot.chapter1.choice.skip': 'Skip',
    'mascot.chapter1.skip.confirmTitle': 'Skip Kapitel 1?',
    'mascot.chapter1.skip.confirmBody':
        'Are you sure you want to skip Kapitel 1? Skipping awards no stars or XP. The chapter will stay on the map, so you can complete it later. Kapitel 2 will unlock right away.',
    'mascot.chapter1.skip.return': 'Go back',
    'mascot.chapter1.skip.confirm': 'Yes, skip Kapitel 1',
    'mascot.chapter1.startHandoff':
        'Great! Tap the highlighted first lesson, and we\'ll get started.',
    'mascot.chapter2.skipHandoff':
        'Already know the basics? Then I won\'t keep you waiting at the red light - we\'re heading straight to more advanced topics! Tap the highlighted lesson in Kapitel 2.',
    'path.chapter1.skipped': 'Skipped',
    'mascot.fallback':
        'Hi! I\'m Fini, your guide. Start with the first lesson, and I\'ll help you through each step.',
    'transitionsDoorStory.step.01':
        'Welcome to the third lesson! Here we will take a closer look at Moore and Mealy machines and better understand how they differ.',
    'transitionsDoorStory.step.02':
        'A person approaches the automatic door. What should the controller command when the presence sensor becomes 1?',
    'transitionsDoorStory.step.03':
        'The sensor value person is the input. The motor command is the output. Classify both signals before we build an automaton.',
    'transitionsDoorStory.step.04':
        'Before writing formal labels, look at the two physical situations in this example: the door is closed or open. These pictures will become FSM nodes.',
    'transitionsDoorStory.step.05':
        'The controller must remember the door position. We begin with DOOR IS CLOSED and DOOR IS OPEN and let a separate actuator perform movement.',
    'transitionsDoorStory.step.06':
        'The door may already be open when the controller starts. First, create DOOR IS OPEN with the output OPEN DOOR and mark it with the reset arrow.',
    'transitionsDoorStory.step.07':
        'We must also represent a closed door. Add DOOR IS CLOSED with CLOSE DOOR. It is the safe starting position, so the reset arrow now points to it.',
    'transitionsDoorStory.step.08':
        'If the door is open and person becomes 0, nobody is in the doorway. Add the transition to DOOR IS CLOSED so the output changes to CLOSE DOOR.',
    'transitionsDoorStory.step.09':
        'If the door is closed and person becomes 1, someone has arrived. Add the transition to DOOR IS OPEN. The Moore machine is now complete.',
    'transitionsDoorStory.step.10':
        'Run the completed Moore machine. Notice the order: input, transition, new state, then the output stored in that state.',
    'transitionsDoorStory.step.11':
        'To convert Moore into Mealy, outputs cannot remain inside nodes: Mealy writes them on transitions. Remove both state outputs first.',
    'transitionsDoorStory.step.12':
        'Without state outputs, both nodes only wait for the same sensor and no separate position memory is needed in this simplified model. Merge them into one WAIT node.',
    'transitionsDoorStory.step.13':
        'When person = 1, Mealy must immediately command the door to open. Add the self-loop person = 1 / OPEN DOOR to WAIT.',
    'transitionsDoorStory.step.14':
        'When person = 0, the opposite reaction is needed. Add person = 0 / CLOSE DOOR. The Mealy transformation is complete.',
    'transitionsDoorStory.step.15':
        'Run the Mealy machine. The state stays WAIT, while each input immediately selects the output written on its transition.',
    'transitionsDoorStory.step.16':
        'Compare both solutions side by side: Moore puts the action in a state; Mealy puts it in the reaction to an input.',
    'transitionsDoorStory.step.17':
        'The two-state model was intentionally simplified. Real movement takes time, so a controller may need DOOR IS CLOSED, DOOR IS OPENING, DOOR IS OPEN, and DOOR IS CLOSING.',
    'transitionsDoorStory.step.18':
        'You now know the essential difference and its limit: Mealy often uses fewer states, but only when the process does not need extra memory.',
    'transitionsDoorStory.startTasks': 'Start practice',
    'transitionsDoorStory.readyTitle': 'The automatic door is ready!',
    'transitionsDoorStory.readyBody':
        'Two theory questions and six practical tasks check diagrams, errors, changes, traces, and FSM construction.',
    'transitionsStory.welcome.title': 'Third lesson',
    'transitionsStory.welcome.models': 'Moore • Mealy',
    'transitionsStory.automaticDoor': 'Automatic sliding door',
    'transitionsStory.sensorTitle': 'The sensor provides the input',
    'transitionsStory.sensorCaption':
        'The controller does not see a person directly - it receives a sensor input and follows the matching transition.',
    'transitionsStory.input.person': 'Person detected',
    'transitionsStory.input.clear': 'Doorway clear',
    'transitionsStory.input.opened': 'Fully open',
    'transitionsStory.input.closed': 'Fully closed',
    'transitionsStory.input.personShort': 'PERSON',
    'transitionsStory.input.clearShort': 'CLEAR',
    'transitionsStory.input.openedShort': 'OPENED',
    'transitionsStory.input.closedShort': 'CLOSED',
    'transitionsStory.output.open': 'OPEN',
    'transitionsStory.output.close': 'CLOSE',
    'transitionsStory.output.stop': 'STOP',
    'transitionsStory.predict.title': 'Your prediction',
    'transitionsStory.predict.question':
        'How many states does the detailed Moore door need?',
    'transitionsStory.predict.correct':
        'Exactly! The door has four distinct physical phases.',
    'transitionsStory.predict.wrong':
        'Not quite. Count closed, opening, open, and closing separately.',
    'transitionsStory.phases.title': 'Discover the Moore states',
    'transitionsStory.phases.instruction':
        'Tap every door phase to reveal the output produced in that state.',
    'transitionsStory.phase.closed': 'Closed',
    'transitionsStory.phase.opening': 'Opening',
    'transitionsStory.phase.open': 'Open',
    'transitionsStory.phase.closing': 'Closing',
    'transitionsStory.phases.complete':
        'Great! Four phase-and-output pairs are ready to become four Moore nodes.',
    'transitionsStory.reaction.question':
        'What should the door do when a person is detected?',
    'transitionsStory.reaction.answer.open': 'Open',
    'transitionsStory.reaction.answer.stay': 'Stay closed',
    'transitionsStory.reaction.answer.close': 'Close',
    'transitionsStory.reaction.correct':
        'Correct: person = 1 must produce the motor command OPEN DOOR.',
    'transitionsStory.reaction.wrong':
        'Try again: the person must be able to pass through the doorway.',
    'transitionsStory.signals.title': 'What is the input and the output?',
    'transitionsStory.signal.input': 'Input',
    'transitionsStory.signal.output': 'Output',
    'transitionsStory.signals.correct':
        'Exactly: the sensor informs the controller, and the controller commands the motor.',
    'transitionsStory.signals.wrong':
        'The sensor sends information in; the motor command comes out.',
    'transitionsStory.stateImages.title': 'First look: the door as pictures',
    'transitionsStory.stateImages.caption':
        'These concrete pictures are the situations that the controller will later represent with formal state identifiers.',
    'transitionsStory.states.title':
        'The automaton remembers the door position',
    'transitionsStory.states.actuatorNote':
        'Simplification: movement is instantaneous here, or a separate actuator performs it after receiving OPEN DOOR or CLOSE DOOR.',
    'transitionsStory.construction.progress': 'Step {current} of {total}',
    'transitionsStory.mooreSteps.title': 'Building the Moore machine',
    'transitionsStory.mooreSteps.action.openState':
        'Added the reset arrow and DOOR IS OPEN / OPEN DOOR.',
    'transitionsStory.mooreSteps.action.closedState':
        'Added DOOR IS CLOSED / CLOSE DOOR and moved reset to the safe start.',
    'transitionsStory.mooreSteps.action.closeTransition':
        'Added DOOR IS OPEN - person = 0 → DOOR IS CLOSED.',
    'transitionsStory.mooreSteps.action.openTransition':
        'Added DOOR IS CLOSED - person = 1 → DOOR IS OPEN. Moore is complete.',
    'transitionsStory.mealySteps.title': 'Converting Moore into Mealy',
    'transitionsStory.mealySteps.action.removeOutputs':
        'Removed outputs from the nodes because Mealy stores outputs on transitions.',
    'transitionsStory.mealySteps.action.mergeStates':
        'Merged equivalent nodes into WAIT because the sensor alone selects the command.',
    'transitionsStory.mealySteps.action.openTransition':
        'Added person = 1 / OPEN DOOR as the first WAIT self-loop.',
    'transitionsStory.mealySteps.action.closeTransition':
        'Added person = 0 / CLOSE DOOR. Mealy is complete.',
    'transitionsStory.mooreBuild.title': 'Build the Moore machine',
    'transitionsStory.mooreBuild.outputsInstruction':
        'First assign an output to each state.',
    'transitionsStory.mooreBuild.aa4Instruction':
        'Assemble the Moore machine from nodes, transitions, and the initial-state marker.',
    'transitionsStory.mooreBuild.sandboxInstruction':
        'Create the automaton in the Sandbox: q0 = DOOR IS CLOSED with CLOSE DOOR, q1 = DOOR IS OPEN with OPEN DOOR; q0 is initial. Add q0 - person = 1 → q1 and q1 - person = 0 → q0.',
    'transitionsStory.mooreBuild.question.closed':
        'Which output should we assign to the DOOR IS CLOSED node?',
    'transitionsStory.mooreBuild.question.open':
        'Which output should we assign to the DOOR IS OPEN node?',
    'transitionsStory.mooreBuild.answerCorrect':
        'Correct: the {state} node now shows the {output} output.',
    'transitionsStory.mooreBuild.answerWrong':
        'That output does not match the door position. Try another one.',
    'transitionsStory.mooreBuild.transitionsInstruction':
        'Now add the two sensor-triggered transitions.',
    'transitionsStory.mooreBuild.complete':
        'Ready: Moore outputs are inside states.',
    'transitionsStory.mooreSim.title': 'Run the Moore machine',
    'transitionsStory.mooreSim.personAppears': 'Set person = 1',
    'transitionsStory.mooreSim.personLeaves': 'Set person = 0',
    'transitionsStory.mooreSim.sequence':
        'input → transition → new state → state output',
    'transitionsStory.mealyTransform.title': 'Transform Moore into Mealy',
    'transitionsStory.mealyTransform.instruction':
        'Move both outputs from states onto the input reactions.',
    'transitionsStory.mealyTransform.aa4Instruction':
        'Use the same AA4 builder to assemble the transformed Mealy machine.',
    'transitionsStory.mealyTransform.sandboxInstruction':
        'WAIT and the first loop are already present. Complete the Sandbox automaton with the missing loop person = 0 / CLOSE DOOR.',
    'transitionsStory.mealyTransform.move': 'Move {output} onto its transition',
    'transitionsStory.mealyTransform.complete':
        'Now one WAIT state is enough for this simplified command controller.',
    'transitionsStory.mealySim.title': 'Run the Mealy machine',
    'transitionsStory.mealySim.stateStays':
        'WAIT does not change; state + input select the output immediately.',
    'transitionsStory.compare.title': 'Moore and Mealy side by side',
    'transitionsStory.compare.moore.states': '2 states in this example',
    'transitionsStory.compare.moore.output': 'Output inside the state',
    'transitionsStory.compare.moore.reaction':
        'Output changes after entering a new state',
    'transitionsStory.compare.mealy.states': '1 state in this example',
    'transitionsStory.compare.mealy.output': 'Output on the transition',
    'transitionsStory.compare.mealy.reaction':
        'State and input determine the output',
    'transitionsStory.compare.row.location': 'Where is the output?',
    'transitionsStory.compare.row.location.moore': 'in the state',
    'transitionsStory.compare.row.location.mealy': 'on the transition',
    'transitionsStory.compare.row.depends': 'What determines it?',
    'transitionsStory.compare.row.depends.moore': 'state',
    'transitionsStory.compare.row.depends.mealy': 'state + input',
    'transitionsStory.compare.row.count': 'States in the simplified example',
    'transitionsStory.errors.title': 'Repair the swapped outputs',
    'transitionsStory.errors.fix': 'Fix outputs',
    'transitionsStory.errors.fixed': 'Fixed',
    'transitionsStory.errors.complete':
        'Correct: person = 1 opens, person = 0 closes.',
    'transitionsStory.realistic.title': 'Return to the realistic model',
    'transitionsStory.realistic.conclusion':
        'Mealy does not always mean fewer states. If the controller must remember movement, DOOR IS OPENING and DOOR IS CLOSING may be necessary too.',
    'transitionsStory.ready.title': 'The key idea is clear',
    'transitionsStory.ready.moore':
        'Moore output depends on the current state.',
    'transitionsStory.ready.mealy':
        'Mealy output depends on the current state and input.',
    'transitionsStory.ready.count':
        'Mealy often uses fewer states, but not always.',
    'transitionsStory.ready.keyPhrase':
        'Moore puts the action in a state; Mealy puts it in the reaction to an input.',
    'transitionsStory.door.open': 'Door open',
    'transitionsStory.door.closed': 'Door closed',
    'transitionsStory.machine.moore': 'Moore machine',
    'transitionsStory.machine.mealy': 'Mealy machine',
    'transitionsStory.nodeLegend.q0': 'q0 = "door closed"',
    'transitionsStory.nodeLegend.q1': 'q1 = "door opening"',
    'transitionsStory.nodeLegend.mealy.q1': 'q1 = "door open"',
    'transitionsStory.nodeLegend.simple.q0': 'q0 = "door closed"',
    'transitionsStory.nodeLegend.simple.q1': 'q1 = "door open"',
    'transitionsStory.nodeLegend.mealy.q0': 'q0 = "WAIT"',
    'transitionsStory.nodeLegend.q2': 'q2 = "door open"',
    'transitionsStory.nodeLegend.q3': 'q3 = "door closing"',
    'transitionsStory.mooreCaption':
        'Moore: every movement phase is a node whose output controls the motor.',
    'transitionsStory.mealyCaption':
        'Mealy: the fired transition produces the output.',
    'transitionsStory.simulator.mooreOutput': 'Current-node output: {output}',
    'transitionsStory.simulator.mealyOutput':
        'Last-transition output: {output}',
    'transitionsStory.simulator.applyInput': 'Apply input {input}',
    'transitionsStory.comparisonTitle': 'Same door, different structure',
    'transitionsStory.comparison.moore':
        'OPEN is written inside q1: in a Moore machine, the current node determines the output.',
    'transitionsStory.comparison.mealy':
        'OPEN is written on PERSON / OPEN: in a Mealy machine, the fired transition produces the output.',
    'transitionsStory.comparison.sameTitle': 'What stays the same',
    'transitionsStory.comparison.same':
        'Both implement the same visible rule: open for a person, close when the doorway is clear.',
    'transitionsStory.placementTitle': 'Where does the output belong?',
    'transitionsStory.onNode': 'On the node',
    'transitionsStory.onTransition': 'On the transition',
    'transitionsStory.placement.correct':
        'Exactly: Moore → node, Mealy → transition.',
    'transitionsStory.placement.retry':
        'Almost! Compare the node labels with the input / output arrow labels.',
    'transitionsStory.placement.tryOther': 'Try the other diagram element.',
    'answer.outputsBothOnNodes': 'Both machines write outputs on nodes',
    'answer.mooreNodeMealyTransition': 'Moore: node; Mealy: transition',
    'answer.mooreTransitionMealyNode': 'Moore: transition; Mealy: node',
    'answer.doorOpens': 'The door opens',
    'answer.outputDisappears': 'The machine produces no output',
    'answer.doorStaysClosed': 'The door stays closed',
    'answer.nodeQ1WithOutput': 'q1 with y = OPEN',
    'answer.personTransitionWithoutOutput': 'Transition q0 -"PERSON"→ q1',
    'answer.clearCloseTransition': 'Transition q1 -"CLEAR / CLOSE"→ q0',
    'answer.currentStateOnly': 'Only the current state',
    'answer.inputOnly': 'Only the input signal',
    'answer.stateAndInput': 'The current state and the input signal',
    'answer.personOneCloseTransition': '"person = 1 / CLOSE DOOR"',
    'answer.personZeroOpenTransition': '"person = 0 / OPEN DOOR"',
    'answer.waitState': 'State WAIT',
    'answer.putCloseInsideWait': 'Write CLOSE DOOR inside the WAIT node',
    'answer.closeWhenPersonDetected':
        'Change the "person = 1" transition output to CLOSE DOOR',
    'answer.changePersonToZero': 'Replace "person = 1" with "person = 0"',
    'task.transitions.outputPlacement.prompt':
        'Where is the output written in a Moore machine?',
    'task.transitions.outputPlacement.instruction':
        'Choose the defining Moore rule.',
    'task.transitions.outputPlacement.hint':
        'Look for y = output inside a Moore state.',
    'task.transitions.changeTarget.prompt':
        'In the Mealy diagram, the transition "person = 1 / CLOSE DOOR" is shown while WAIT stays unchanged. What determines this output?',
    'task.transitions.changeTarget.instruction':
        'Compare the changed transition label with the unchanged current state.',
    'task.transitions.changeTarget.hint':
        'A Mealy output is selected by the pair: current state + current input.',
    'task.transitions.findErrors.prompt':
        'Both Mealy outputs are swapped. Select the two incorrect transitions.',
    'task.transitions.findErrors.instruction':
        'The transition "person = 1 / OPEN DOOR" must open the door; "person = 0 / CLOSE DOOR" must close it.',
    'task.transitions.findErrors.hint':
        'Select "person = 1 / CLOSE DOOR" and "person = 0 / OPEN DOOR".',
    'task.transitions.validateMoore.prompt':
        'The real controller must remember whether the door is moving. Is this one-state Mealy model always sufficient?',
    'task.transitions.validateMoore.instruction':
        'Decide whether Mealy always removes the need for movement states.',
    'task.transitions.validateMoore.hint':
        'Mealy can reduce output-only states, but it cannot remove memory the process actually needs.',
    'task.transitions.buildMoore.prompt':
        'Build the simplified two-state Moore door from the lesson.',
    'task.transitions.buildMoore.instruction':
        'Create q0 DOOR IS CLOSED/CLOSE DOOR and q1 DOOR IS OPEN/OPEN DOOR; make q0 initial and add "person = 1" and "person = 0".',
    'task.transitions.buildMoore.hint':
        'Moore outputs belong to states; sensor values label the two directed transitions.',
    'task.transitions.traceMoore.prompt':
        'Trace the simplified Moore door through "person = 1" and "person = 0".',
    'task.transitions.traceMoore.instruction':
        'Choose the current state before any input and after both sensor values.',
    'task.transitions.traceMoore.hint':
        'Follow DOOR IS CLOSED → DOOR IS OPEN → DOOR IS CLOSED.',
    'task.transitions.completeMealy.prompt':
        'Complete the one-state Mealy door with its missing second self-loop.',
    'task.transitions.completeMealy.instruction':
        'Add a self-loop on WAIT with the exact label "person = 0 / CLOSE DOOR".',
    'task.transitions.completeMealy.hint':
        'The state stays WAIT; input and output are written together on the loop.',
    'task.transitions.closeOnPerson.prompt':
        'What must be changed so the door closes as soon as the sensor detects a person?',
    'task.transitions.closeOnPerson.instruction':
        'Choose the change to the Mealy reaction for "person = 1".',
    'task.transitions.closeOnPerson.hint':
        'Keep the input "person = 1" and change the output written after the slash.',
    'lesson.scrollHint': 'Scroll down to continue',
    'home.chapter3.unit': 'Unit 3',
    'home.chapter4.unit': 'Unit 4',
    'home.chapter5.unit': 'Exam',
    'lesson.chapter2.diagram.title': 'Reading FSM diagrams',
    'lesson.chapter2.gates.title': 'Digital gates: signal flow',
    'lesson.chapter2.gates.subtitle': 'A quick interactive refresher',
    'lesson.chapter2.diagram.subtitle':
        'Understand states, transitions, reset and determinism',
    'lesson.chapter2.testSubtitle': 'Diagram reading and Moore/Mealy basics',
    'lesson.chapter4.title': 'Complete automata',
    'lesson.chapter4.subtitle': 'Find missing transitions and missing outputs',
    'lesson.chapter4.testSubtitle': 'Completeness check',
    'lesson.chapter5.title': 'Create automata',
    'lesson.chapter5.subtitle':
        'Build an FSM and describe it with a transition table',
    'lesson.chapter5.testSubtitle': 'Construction check',
    'lesson.bonus.title': 'FSM exam tasks',
    'lesson.bonus.subtitle': 'Six practice lessons with exam-style tasks',
    'concept.determinism': 'Determinism',
    'concept.transitionTable': 'Transition table',
    'answer.idleState': 'The IDLE state',
    'answer.activeState': 'The ACTIVE state',
    'answer.oneTransition': 'The transition labelled "1"',
    'answer.duplicateOneFirst': 'q0 --"1"--> q1',
    'answer.duplicateOneSecond': 'q0 --"1"--> q0',
    'answer.oneTransitionPerInput': 'Exactly one transition per input',
    'answer.anyNumberTransitions': 'Any number of transitions per input',
    'answer.noTransitionsNeeded': 'Transitions are not needed',
    'answer.defineStatesThenTransitions': 'Define states, then connect them',
    'answer.onlyDrawArrows': 'Only draw arrows; states are optional',
    'answer.randomLabels': 'Use random labels and adjust later',
    'answer.trafficFirstTimer': 'q0 --"timer"--> q1',
    'answer.trafficSecondTimer': 'q0 --"timer"--> q2',
    'answer.trafficGreenTimer': 'q1 --"timer"--> q2',
    'path.chapter2.lesson.title': 'Read FSM diagrams',
    'path.chapter2.lesson.subtitle': '3 tasks',
    'path.chapter2.test.title': 'Chapter 2 test',
    'path.chapter2.test.subtitle': '5 questions',
    'chapter2Story.intro':
        'You already know digital circuits. Now follow the signals to discover what this deterministic FSM does. Every coloured path is an illustration of the explanation.',
    'chapter2Story.purpose':
        'This circuit is an FSM. It stores its current state, calculates the next state from the input, and produces an output. We will read it from left to right, one block at a time.',
    'chapter2Story.stateBits':
        'The two flip-flops store the current state. Read their outputs as the bit pair S₁S₀ before looking at the next-state logic.',
    'chapter2Story.bitDecomposition':
        'Now split the state into its two wires: S₁S₀ = 00 means S₁ = 0 and S₀ = 0. Together, these two bits form S.',
    'chapter2Story.clockStep':
        'The logic calculates new values first. Only the CLK edge stores them in the flip-flops, so the FSM changes state at a defined moment.',
    'chapter2Story.outputStep':
        'Finally, the stored state goes through the output logic. This is a Moore output: Y is determined by S, not directly by A.',
    'chapter2Story.signalPath':
        'For a next state, start with A and the stored bits. Follow the highlighted arrows through the logic to the D inputs; the clock then stores those values.',
    'chapter2Story.simulator':
        'Try a state and an input. The diagram highlights the relevant path. Press CLK to transfer the calculated next state into memory.',
    'chapter2Story.transitionTable':
        'A state-transition table records the next state for every valid pair of current state S and input A. You can tap a row to check it against the animated circuit, then complete the table.',
    'chapter2Story.outputTable':
        'The output logic is separate. This is a Moore FSM: Y depends only on the stored state, not directly on A. Tap a row to check it against the animated circuit, then complete the output table.',
    'chapter2Story.transitionTableTitle': 'Transition table',
    'chapter2Story.outputTableTitle': 'Output table',
    'chapter2Story.completeOverview':
        'This is how we analysed the entire FSM: we discovered the rules that govern it and the values it produces. This will be very useful in the Klausur! The key is understanding how the automaton works inside - its gates.',
    'chapter2Story.ready':
        'You can now read the circuit as an FSM: decode S₁S₀, follow the next-state logic, apply CLK, and read Y from the output logic.',
    'chapter2Story.predictNextState': 'Predict the next state S′ before CLK.',
    'chapter2Story.predictionHint': 'Follow both highlighted paths again.',
    'chapter2Story.startTasks': 'Start tasks',
    'chapter2Gates.intro':
        'Welcome to Chapter 2! In this chapter, we will learn how to read digital FSM circuits: follow the input signals through the gates and understand how the circuit changes its state. I hope you remember the basic logic gates you studied at university.',
    'chapter2Gates.xor':
        'Toggle both inputs and watch the bit travel through XOR.',
    'chapter2Gates.andBubble':
        'A circle on an AND input inverts that input before the gate combines the signals.',
    'chapter2Gates.andNot':
        'Now follow the inverted input through NOT and AND.',
    'chapter2Gates.clock':
        'The gates calculate first. CLK stores the result as the new state.',
    'chapter2Gates.summary':
        'Great work! Now you should be able to recognise what each part of this FSM circuit does. In the next lesson, we will read the complete circuit step by step.',
    'chapter2Gates.introCard':
        'This chapter teaches you how to understand this FSM circuit: follow the input, read the gates, and see how the state changes. I hope the basic digital gates you studied at university are still familiar.',
    'chapter2Gates.summaryCard':
        'You can now look at this FSM and identify its input A, state memory S₁S₀, gates, CLK and output Y. The next lesson will show the complete signal path in detail.',
    'chapter2Gates.showSignal': 'Show the signal path',
    'chapter2Gates.xorTitle': 'XOR: different inputs produce 1',
    'chapter2Gates.xorBody':
        'XOR outputs 1 when exactly one input is 1. Change A or S₀ and watch the animated signal.',
    'chapter2Gates.notSymbolTitle': 'NOT: the circle means inversion',
    'chapter2Gates.notSymbolBody':
        'The small circle at the output is the inversion marker. It changes 0 to 1 and 1 to 0.',
    'chapter2Gates.notBubbleTitle': 'A NOT marker can stand alone',
    'chapter2Gates.notBubbleBody':
        'You do not always need a separate NOT gate. A circle on a wire already means NOT. Toggle A and watch Ä€ change.',
    'chapter2Gates.andBubbleTitle': 'NOT on one AND input',
    'chapter2Gates.andBubbleBody':
        'A small circle on an AND input means that input is inverted. The separate NOT gate is no longer needed: A becomes Ā before AND combines it with S₁.',
    'chapter2Gates.andNotTitle': 'NOT and AND: invert, then combine',
    'chapter2Gates.andNotBody':
        'The bubble means NOT: A becomes Ä€. AND outputs 1 only when all its inputs are 1.',
    'chapter2Gates.flipFlop':
        'A Flip-Flop is the smallest memory element: it stores one bit until the clock tells it to update.',
    'chapter2Gates.flipFlopTitle': 'Flip-Flop stores one bit',
    'chapter2Gates.flipFlopBody':
        'A Flip-Flop is a one-bit memory. It receives a bit at D and copies it to Q only on the CLK edge. Until then, Q keeps the old value.',
    'chapter2Gates.flipFlopPrompt': 'Choose the bit that arrives at D:',
    'chapter2Gates.flipFlopApply': 'Apply CLK',
    'chapter2Gates.flipFlopApplied': 'Bit stored',
    'chapter2Gates.clockTitle': 'CLK copies D-bits into memory',
    'chapter2Gates.clockBody':
        'In an FSM, the flip-flops are its state memory. The gates calculate D₁ and D₀ from the input and current state. At the rising CLK edge, the flip-flops copy them to S₁/S₀. This makes the state change in clear, separate steps.',
    'chapter2Gates.clockPrompt': 'What happens at the CLK edge?',
    'chapter2Gates.clockChoice0': 'The state changes immediately',
    'chapter2Gates.clockChoice1': 'CLK stores the calculated bits',
    'chapter2Gates.clockChoice2': 'A changes the state directly',
    'chapter2Gates.check': 'I understand the signal flow',
    'chapter2Gates.checked': 'Ready for FSM tables',
    'chapter2Gates.startLesson': 'Start FSM lesson',
    'chapter2Story.legend.input': 'input',
    'chapter2Story.legend.memory': 'state memory',
    'chapter2Story.legend.output': 'output',
    'chapter2Story.stateEncoding': 'State encoding',
    'chapter2Story.purposeTitle': 'What this FSM does',
    'chapter2Story.purposeInput':
        'A is the external input that can change from one clock cycle to the next.',
    'chapter2Story.purposeMemory':
        'S₁ and S₀ are the two stored state bits. Together they are the current state S.',
    'chapter2Story.purposeLogic':
        'The gates calculate the next state from A and the current bits.',
    'chapter2Story.purposeOutput':
        'The output logic turns the stored state into the output Y.',
    'chapter2Story.clockTitle': 'When does the state change?',
    'chapter2Story.clockBefore':
        'Before CLK, the gates calculate S₁′ and S₀′, but the old state remains stored.',
    'chapter2Story.clockEdge':
        'The CLK edge is the moment that transfers the calculated values into memory.',
    'chapter2Story.clockAfter':
        'After CLK, the new pair S₁S₀ becomes the current state S.',
    'chapter2Story.clockQuestion': 'What happens at the CLK edge?',
    'chapter2Story.clockChoice0': 'The state changes immediately',
    'chapter2Story.clockChoice1': 'CLK stores the calculated bits',
    'chapter2Story.clockChoice2': 'A changes the state directly',
    'chapter2Story.clockCorrect':
        'Correct: CLK copies the D values into the flip-flops.',
    'chapter2Story.clockTimeline':
        'Example: current state → calculated next state → stored state after CLK',
    'chapter2Story.flipFlops': 'Flip-Flops',
    'chapter2Story.unusedState':
        'The pair 11 is possible with two bits, but this FSM does not use it.',
    'chapter2Story.resetActive': 'Reset active: S₁S₀ = 00 → S = 0',
    'chapter2Story.resetInactive':
        'Reset is inactive: the stored state can change at CLK.',
    'chapter2Story.applyReset': 'Activate Reset',
    'chapter2Story.releaseReset': 'Release Reset',
    'chapter2Story.outputStepTitle': 'How does the FSM produce Y?',
    'chapter2Story.outputStepBody':
        'Read the current state from S₁S₀, then follow the output logic to Y. The input A is not needed for this Moore output.',
    'chapter2Story.bitDecompositionTitle': 'S₁S₀ is one two-bit state value',
    'chapter2Story.bitDecompositionBody':
        'The two wires S₁ and S₀ form the single state value S. The first bit is S₁, the second bit is S₀.',
    'chapter2Story.bitDecompositionFormula':
        'S₁S₀ = {bits}  →  S₁ = {s1}, S₀ = {s0}  →  S = {state}',
    'chapter2Story.workedExample':
        'Let us solve one complete row: S = 0 and A = 0.',
    'chapter2Story.resetStep':
        'Reset puts the flip-flops into the defined start state. It is not the normal input A.',
    'chapter2Story.workedExampleTitle':
        'Worked example: calculate both next bits',
    'chapter2Story.workedExampleBody':
        'For S = 0 and A = 0, follow every highlighted line: A and the stored bits S₁/S₀ enter the gates and produce S₀′ and S₁′.',
    'chapter2Story.workedExamplePrompt': 'Choose both calculated bits.',
    'chapter2Story.workedExampleCorrect':
        'Correct: the two bits form the next state.',
    'chapter2Story.predictNextBits': 'Predict S₀′ and S₁′ before applying CLK.',
    'chapter2Story.resetBody':
        'Reset forces the register into its defined initial state. Afterwards, CLK controls normal state changes.',
    'chapter2Story.unused': 'not used here',
    'chapter2Story.flow.input': 'Input A and the current state bits',
    'chapter2Story.flow.logic': 'Next-state logic calculates S0\' and S1\'',
    'chapter2Story.flow.clock':
        'CLK transfers the D inputs into the flip-flops',
    'chapter2Story.flow.state': 'The stored bits become the next current state',
    'chapter2Story.formulaS0': 'S₀′ = A ∧ (S₁ XOR S₀)',
    'chapter2Story.formulaS1': 'S₁′ = Ā ∧ ¬S₁ ∧ ¬S₀',
    'chapter2Story.formulaY': 'Y = S₁ ∧ ¬S₀',
    'chapter2Story.chooseState': 'Choose the current state',
    'chapter2Story.chooseInput': 'Choose the input',
    'chapter2Story.clock': 'Apply CLK',
    'chapter2Story.transitionInstruction':
        'Choose the next state for every row.',
    'chapter2Story.outputInstruction': 'Choose Y for every stored state.',
    'chapter2Story.fillEveryRow': 'Complete every row to continue.',
    'chapter2Story.summary':
        'A circuit becomes an FSM table when you evaluate each state/input combination one at a time.',
    'path.chapter4.unlocked': 'Completion chapter unlocked',
    'path.chapter4.lesson.title': 'Complete automata',
    'path.chapter4.lesson.subtitle': '3 tasks',
    'path.chapter4.test.subtitle': '5 questions',
    'path.chapter5.test.title': 'Exam tasks',
    'path.chapter5.test.subtitle': 'Six practice lessons',
    'path.chapter5.title': 'Chapter 5: Exam tasks',
    'path.chapter5.locked': 'Pass the Chapter 4 test',
    'path.chapter5.unlocked': 'Exam challenges unlocked',
    'path.chapter5.lesson.title': 'Six exam-practice lessons',
    'path.chapter5.lesson.subtitle': '6 lessons, 3 tasks each',
    'path.chapter5.theory.title': 'Theoretical tasks',
    'path.chapter5.theory.subtitle': '3 questions',
    'path.chapter5.completion.title': 'Complete an automaton',
    'path.chapter5.completion.subtitle': '3 construction tasks',
    'path.chapter5.creation.title': 'Create an automaton',
    'path.chapter5.creation.subtitle': '3 construction tasks',
    'path.chapter5.diagnostics.title': 'Analyse an automaton',
    'path.chapter5.diagnostics.subtitle': '3 tasks',
    'chapter5.lesson.theory.title': 'Theoretical tasks',
    'chapter5.lesson.theory.subtitle': 'Moore, Mealy and synchronous circuits',
    'chapter5.lesson.tables.title': 'Automata from tables',
    'chapter5.lesson.tables.subtitle': 'Read transition and output tables',
    'chapter5.lesson.completion.title': 'Completion challenge',
    'chapter5.lesson.completion.subtitle':
        'Find missing states and transitions',
    'chapter5.lesson.creation.title': 'Creation challenge',
    'chapter5.lesson.creation.subtitle': 'Build a complete automaton',
    'chapter5.lesson.diagnostics.title': 'Analysis challenge',
    'chapter5.lesson.diagnostics.subtitle': 'Trace and check determinism',
    'chapter5.theory.instruction': 'Choose the correct statement.',
    'chapter5.theory.mooreOutput.prompt':
        'State what the output of a Moore automaton depends on.',
    'chapter5.theory.mooreOutput.hint':
        'A Moore output is attached to the current state.',
    'chapter5.theory.mealyOutput.prompt':
        'State what the output of a Mealy automaton depends on.',
    'chapter5.theory.mealyOutput.hint':
        'A Mealy output is written on a transition together with its input.',
    'chapter5.theory.timing.prompt':
        'Name one essential timing difference between Mealy and Moore outputs.',
    'chapter5.theory.timing.hint':
        'Compare when the output can react to a changed input.',
    'chapter5.theory.realization.prompt':
        'How can automata be realised as a synchronous sequential circuit? Explain briefly using a sketch or description.',
    'chapter5.theory.realization.instruction':
        'Choose the description containing the state register, combinational logic and clock.',
    'chapter5.theory.realization.hint':
        'The register stores the state; logic calculates next state and output.',
    'chapter5.answer.stateOutput': 'It depends on the current state.',
    'chapter5.answer.inputOnly': 'It depends only on the input.',
    'chapter5.answer.nextStateOnly': 'It depends only on the next state.',
    'chapter5.answer.transitionInput':
        'It depends on the current state and input transition.',
    'chapter5.answer.stateOnly': 'It depends only on the state name.',
    'chapter5.answer.clockOnly': 'It depends only on the clock.',
    'chapter5.answer.mealyImmediate':
        'Mealy can react immediately to an input change; Moore changes with the state.',
    'chapter5.answer.sameTiming': 'They always react at exactly the same time.',
    'chapter5.answer.mooreImmediate': 'Moore always reacts before Mealy.',
    'chapter5.answer.registerLogic':
        'A clocked state register, combinational next-state/output logic and a common clock.',
    'chapter5.answer.onlyRegister':
        'Only a state register, without combinational logic.',
    'chapter5.answer.onlyCombinational':
        'Only combinational logic, without a clocked state register.',
    'chapter5.tables.instruction':
        'Build the automaton from the displayed tables. The initial state is q0. Define exactly one transition for every state and action.',
    'chapter5.tables.moore.prompt':
        'Create the Moore automaton from the transition and output tables.',
    'chapter5.tables.moore.hint':
        'Use the two table rows for each input and copy each state output into the state.',
    'chapter5.tables.mealy.prompt':
        'Create the Mealy automaton from the transition table and its input/output labels.',
    'chapter5.tables.mealy.hint':
        'Each arrow is labelled with its input and output.',
    'chapter5.completion.prompt':
        'A detector starts in q0. Input 0 advances q0 -> q1 -> q2 -> q3. For input 1: q0 -> q0, q1 -> q0, q2 -> q1 and q3 -> q1. Output 1 is assigned only to q1; q0, q2 and q3 output 0. Complete all missing outputs and transitions.',
    'chapter5.completion.instruction':
        'Add the missing state data and transitions shown by the specification.',
    'chapter5.completion.hint': 'Check every state/input pair exactly once.',
    'chapter5.creation.prompt':
        'A ticket gate starts locked in q0. Input 1 means that a valid ticket is scanned: the gate opens and the automaton moves to q1, emitting OPEN (1). Input 0 means reset or an invalid ticket; from q0 it stays locked with output 0, and from q1 it closes the gate and returns to q0 with output 0. A further valid ticket while the gate is open keeps q1 but does not emit OPEN again. Create the complete Mealy automaton from this description.',
    'chapter5.creation.instruction':
        'Place the prepared states, choose the initial state and connect every transition.',
    'chapter5.creation.hint':
        'A Mealy output belongs after the slash on a transition label.',
    'chapter5.analysis.prompt':
        'Trace the automaton for the given input sequence.',
    'chapter5.analysis.instruction':
        'Select the state before the first input and after every input.',
    'chapter5.analysis.hint': 'Follow one transition per input symbol.',
    'chapter5.diagnostics.prompt':
        'Which statement correctly diagnoses the shown automaton?',
    'chapter5.diagnostics.instruction':
        'Choose the statement that identifies the duplicate input transition.',
    'chapter5.diagnostics.hint':
        'A deterministic automaton has at most one target for each state/input pair.',
    'chapter5.answer.deterministic': 'The automaton is deterministic.',
    'chapter5.answer.conflict':
        'Two transitions use the same input from one state.',
    'task.chapter2.readDiagram.prompt':
        'Which states are stored by the circuit?',
    'task.chapter2.readDiagram.instruction':
        'Select all three stored states in the circuit representation.',
    'task.chapter2.readDiagram.hint':
        'The valid encodings are 00, 01 and 10. They represent S = 0, 1 and 2.',
    'task.chapter2.trace.prompt':
        'Trace the circuit state sequence for inputs 0, 1, 0, 1.',
    'task.chapter2.trace.instruction':
        'Start in S = 0 and enter the state after each CLK cycle.',
    'task.chapter2.trace.hint':
        'Start at S = 0 and use the circuit one CLK step at a time. Read both state bits after each step.',
    'task.chapter2.buildTable.prompt':
        'Which table describes the circuit correctly?',
    'task.chapter2.buildTable.instruction':
        'Read S₁S₀, follow the gates, apply CLK, and build the table.',
    'task.chapter2.buildTable.hint':
        'Evaluate each state and input value separately, then apply the clock to determine the next state.',
    'task.chapter2.stateCode.prompt': 'What state does S₁S₀ = 10 represent?',
    'task.chapter2.stateCode.instruction':
        'Read the two stored bits from left to right.',
    'task.chapter2.stateCode.hint':
        'S₁ is the 2-value bit and S₀ is the 1-value bit.',
    'answer.stateCodeTwo': 'S = 2',
    'answer.stateCodeOne': 'S = 1',
    'answer.stateCodeInvalid': 'This bit pair is not a state',
    'task.chapter2.mooreOutput.prompt':
        'What is the output when the current state is S = 2?',
    'task.chapter2.mooreOutput.instruction':
        'Read the output logic for the stored state. Do not use A directly.',
    'task.chapter2.mooreOutput.hint':
        'For a Moore machine, read Y from the stored state. The input A is not part of this lookup.',
    'task.chapter2.mooreMealy.prompt':
        'Where are outputs placed in Moore and Mealy machines?',
    'task.chapter2.mooreMealy.instruction':
        'Choose the statement that matches the Digitaltechnik notation.',
    'task.chapter2.mooreMealy.hint':
        'Moore writes output inside a state; Mealy writes input/output on a transition.',
    'task.chapter2.determinism.prompt':
        'Which elements make this automaton non-deterministic?',
    'task.chapter2.determinism.instruction':
        'Select both transitions that use the same input from q0.',
    'task.chapter2.determinism.hint':
        'For one state and one input, a deterministic FSM must have one target only.',
    'task.chapter2.gatesCheck.prompt':
        'What does XOR output for inputs 0 and 1?',
    'task.chapter2.gatesCheck.instruction':
        'Choose the value produced by the XOR gate before the signal continues.',
    'task.chapter2.gatesCheck.hint':
        'Look at the two inputs as a pair. XOR reacts to their relationship, not to one input alone.',
    'task.chapter2.gatesCheck.feedback.xorZero':
        'Take another look at the two input values. What does XOR compare before producing its output?',
    'task.chapter2.gatesCheck.feedback.andOne':
        'That rule belongs to a different gate. Focus on what XOR does when its two inputs do not match.',
    'answer.xorOne': '1 - the inputs are different',
    'answer.xorZero': '0 - the inputs are the same',
    'answer.andOne': '1 - AND always outputs 1',
    'answer.outputStateTwo': 'Y = 1 because S = 2',
    'answer.outputStateZero': 'Y = 0 because S = 0',
    'answer.outputInputA': 'Y equals A directly',
    'task.chapter4.completeMoore.prompt':
        'Complete the turnstile Moore automaton.',
    'task.chapter4.completeMoore.instruction':
        'Add the missing transition for input "coin" while the turnstile is UNLOCKED.',
    'task.chapter4.completeMoore.hint':
        'With "coin", an already unlocked turnstile remains UNLOCKED.',
    'task.chapter4.completeMealy.prompt':
        'Complete the Mealy door with its missing reaction.',
    'task.chapter4.completeMealy.instruction':
        'Add the "person = 0 / CLOSE DOOR" self-loop to WAIT.',
    'task.chapter4.completeMealy.hint':
        'The missing label contains both the input and the output after the slash.',
    'task.chapter4.missingOutput.prompt': 'Is this Mealy automaton complete?',
    'task.chapter4.missingOutput.instruction':
        'Check whether every transition has an input and an output.',
    'task.chapter4.missingOutput.hint':
        'A Mealy transition without text after / has no defined output.',
    'task.chapter4.determinismRule.prompt':
        'What must be true for a deterministic FSM?',
    'task.chapter4.determinismRule.instruction':
        'Choose the rule you can use to validate each state and input pair.',
    'task.chapter4.determinismRule.hint':
        'The same input from the same state cannot lead to two different transitions.',
    'task.chapter5.createMoore.prompt':
        'Build a Moore turnstile automaton from the specification.',
    'task.chapter5.createMoore.instruction':
        'Use the states LOCKED/STOP and UNLOCKED/GO, then add "coin" and "passage" transitions.',
    'task.chapter5.createMoore.hint':
        'In Moore, write STOP and GO inside the states, not on the arrows.',
    'task.chapter5.buildTable.prompt':
        'Build the transition table for the turnstile.',
    'task.chapter5.buildTable.instruction':
        'For every state, enter the target for "coin" and "passage" and copy its Moore output.',
    'task.chapter5.buildTable.hint':
        '"coin" opens the locked turnstile; "passage" makes an unlocked one lock again automatically.',
    'task.chapter5.createMealy.prompt':
        'Build a Mealy turnstile with outputs on transitions.',
    'task.chapter5.createMealy.instruction':
        'Create LOCKED and UNLOCKED, then add all four input / output reactions.',
    'task.chapter5.createMealy.hint':
        'Keep the state output fields empty and write each reaction after /.',
    'task.chapter5.chooseWorkflow.prompt':
        'Which workflow is the safest way to create an FSM?',
    'task.chapter5.chooseWorkflow.instruction':
        'Choose the sequence that keeps the diagram easy to validate.',
    'task.chapter5.chooseWorkflow.hint':
        'Name the situations first, then define how each input changes them.',
    'task.chapter5.outputPlacement.prompt':
        'Where should a Moore output be written in the diagram?',
    'task.chapter5.outputPlacement.instruction':
        'Choose the place used by the Moore representation.',
    'task.chapter5.outputPlacement.hint':
        'Moore outputs describe the current state.',
    'task.bonus.buildTraffic.prompt':
        'Build the three-state traffic-light Moore FSM.',
    'task.bonus.buildTraffic.instruction':
        'Use RED/STOP, GREEN/GO and YELLOW/SLOW with a "timer" cycle.',
    'task.bonus.buildTraffic.hint':
        'The "timer" cycle is RED → GREEN → YELLOW → RED.',
    'task.bonus.completeTurnstile.prompt':
        'Complete the turnstile with the one missing transition.',
    'task.bonus.completeTurnstile.instruction':
        'Find the state/input pair that still has no outgoing transition.',
    'task.bonus.completeTurnstile.hint':
        'From UNLOCKED, "coin" keeps the turnstile UNLOCKED.',
    'task.bonus.completeDoorMealy.prompt':
        'Complete the Mealy door under exam time pressure.',
    'task.bonus.completeDoorMealy.instruction':
        'Add the missing "person = 0 / CLOSE DOOR" loop without changing the state.',
    'task.bonus.completeDoorMealy.hint':
        'This is a one-state machine: both arrows are self-loops on WAIT.',
    'task.bonus.buildTable.prompt':
        'Build the transition table for the traffic-light cycle.',
    'task.bonus.buildTable.instruction':
        'Enter the next state and Moore output for every colour.',
    'task.bonus.buildTable.hint':
        'Every row has one "timer" target: the next colour in the cycle.',
    'task.bonus.findError.prompt':
        'Find the determinism error in this traffic-light FSM.',
    'task.bonus.findError.instruction':
        'Select both conflicting "timer" transitions from RED.',
    'task.bonus.findError.hint':
        'RED cannot go to GREEN and YELLOW for the same "timer" input.',
    'task.bonus.traceTurnstile.prompt':
        'Trace the turnstile after "coin", "passage", "coin".',
    'task.bonus.traceTurnstile.instruction':
        'Write the start state and the state after each input.',
    'task.bonus.traceTurnstile.hint':
        '"coin" opens it; "passage" triggers automatic relocking; the final "coin" opens it again.',
    'profile.title': 'Profile',
    'profile.subtitle': 'Your FSM journey and rewards',
    'profile.loadFailed': 'Profile could not be loaded.',
    'profile.saveFailed': 'Profile could not be saved.',
    'profile.username': 'Username',
    'profile.unknown': 'No username yet',
    'profile.edit': 'Edit profile',
    'profile.editTitle': 'Edit profile',
    'profile.usernameHint': 'Choose a username',
    'profile.usernameHelper':
        'A nickname is fine; a real name is not required.',
    'profile.stats.level': 'Level {level}',
    'profile.stats.xp': '{xp} XP',
    'profile.stats.stars': '{stars} stars',
    'profile.stats.coins': '{coins} coins',
    'profile.stats.streak': '{days} day streak',
    'profile.chapterProgress.title': 'Chapter progress',
    'profile.chapterProgress.item': '{chapter}: {completed}/{total} lessons',
    'profile.chapterProgress.chapter': 'Chapter {number}',
    'profile.shop.title': 'Mascot wardrobe',
    'profile.shop.subtitle': 'Spend coins to unlock a new look for Fini.',
    'profile.shop.buy': 'Buy',
    'profile.shop.equip': 'Use',
    'profile.shop.equipped': 'Equipped',
    'profile.shop.owned': 'Owned',
    'profile.shop.notEnoughCoins': 'You need more coins for this item.',
    'profile.shop.purchaseSuccess': 'New look unlocked!',
    'profile.shop.equipSuccess': 'Fini is wearing it now.',
    'profile.shop.cap.title': 'Study cap',
    'profile.shop.cap.description': 'A cap for focused FSM sessions.',
    'profile.shop.scarf.title': 'Signal scarf',
    'profile.shop.scarf.description': 'A colourful scarf for every transition.',
    'profile.shop.glasses.title': 'Logic glasses',
    'profile.shop.glasses.description': 'Spot deterministic paths faster.',
    'profile.shop.crown.title': 'FSM crown',
    'profile.shop.crown.description':
        'A reward for ambitious automaton builders.',
    'fsmWorkspace.mooreMode': 'Moore: output is written on states',
    'fsmWorkspace.mealyMode': 'Mealy: input / output is written on transitions',
    'fsmWorkspace.moore': 'Moore',
    'fsmWorkspace.mealy': 'Mealy',
    'chapter4.story.welcome':
        'Welcome to Chapter 3. You will read a machine description and complete the missing parts of its automaton.',
    'chapter4.story.intro':
        'Welcome to Chapter 3: Completing Automata. You will learn to recognize missing states and transitions and complete an automaton from a real situation.',
    'chapter4.story.coinMachine':
        'This vending machine accepts one coin at a time. Input 1 adds a coin; input 0 cancels. After two coins, it dispenses the drink.',
    'chapter4.story.stateMeaning':
        'First translate the story into states: q0 means no coin, q1 means one coin, and q2 means the drink is dispensed.',
    'chapter4.story.missingTransition':
        'Now complete the one missing reaction. From q1, inserting another coin must reach the dispensing state q2.',
    'chapter4.story.completenessCheck':
        'Finally, inspect every state: for each possible input there must be exactly one matching transition.',
    'chapter4.story.summary':
        'That is the method: read the situation, name the required states, add each missing transition, then check every state-input pair.',
    'chapter4.visual.welcome.title': 'Automaten vervollständigen',
    'chapter4.visual.intro.title': 'Welcome to Chapter 3',
    'chapter4.visual.intro.body':
        'We will read a real-world story, turn it into states and transitions, and complete the automaton step by step.',
    'chapter4.visual.partial.title': 'The incomplete coin machine',
    'chapter4.visual.partial.rule':
        'The arrow from q1 for input 1 is missing. The description tells us where it must go.',
    'chapter4.visual.states.title': 'What does q1 mean?',
    'chapter4.visual.transition.title': 'Add the missing transition',
    'chapter4.visual.transition.rule':
        'One coin is already stored in q1. A second coin reaches q2, where Y = 1 dispenses the drink.',
    'chapter4.visual.check.title': 'Check every state and input',
    'chapter4.visual.check.rule':
        'A complete deterministic automaton has one transition for input 0 and one for input 1 from every state.',
    'chapter4.visual.complete.title': 'The coin machine is complete',
    'chapter4.visual.complete.rule':
        'Use the same checklist for every new story: states, transitions, then completeness.',
    'chapter4.visual.step': 'Completion step {current} of {total}',
    'chapter4.check.state.question':
        'Which state represents one inserted coin?',
    'chapter4.check.state.correct':
        'Correct: q1 remembers that exactly one coin has been inserted.',
    'chapter4.check.state.incorrect':
        'Read the state meanings again: q0 has none, q1 has one, q2 dispenses.',
    'chapter4.check.transition.question':
        'Which missing transition fits the description?',
    'chapter4.check.transition.correct':
        'Correct: q1 --1--> q2 completes the second coin.',
    'chapter4.check.transition.incorrect':
        'From q1, input 1 is the second coin, so the drink must be dispensed in q2.',
    'chapter4.check.complete.question':
        'Is the completed automaton deterministic and complete for inputs 0 and 1?',
    'chapter4.check.complete.correct':
        'Yes. Each state has exactly one outgoing transition for each input.',
    'chapter4.check.complete.incorrect':
        'Check each row: every state needs exactly one transition for 0 and one for 1.',
    'chapter4.answer.q0': 'q0',
    'chapter4.answer.q1': 'q1',
    'chapter4.answer.q2': 'q2',
    'chapter4.answer.q1toQ2': 'q1 --1--> q2',
    'chapter4.answer.q1toQ0': 'q1 --1--> q0',
    'chapter4.answer.q0toQ2': 'q0 --1--> q2',
    'chapter4.answer.complete': 'Yes, it is complete',
    'chapter4.answer.missing': 'No, a transition is missing',
    'chapter4.answer.duplicate': 'No, an input has two transitions',
    'chapter4.task.coin.prompt':
        'A drink machine starts in q0 (no coin, output 0). Input 1 inserts a coin: q0 goes to q1 (one coin, output 0), then q1 goes to q2 (dispense, output 1). Input 0 cancels: from q0 or q1 go to q0. After dispensing in q2, either input returns to q0. Complete this Moore automaton.',
    'chapter4.task.coin.instruction':
        'Add the missing state q2, set its output, and complete all missing transitions according to the description.',
    'chapter4.task.coin.hint':
        'The second coin triggers the dispensing state q2.',
    'chapter4.test.switch.prompt':
        'Complete the two-state light switch. Input 0 toggles it; input 1 keeps its current setting.',
    'chapter4.test.switch.instruction':
        'Add the missing transition with tap-and-select.',
    'chapter4.test.switch.hint':
        'From q1, input 0 toggles the light back to q0.',
    'chapter4.test.ticket.prompt':
        'A ticket machine starts in q0 (waiting, output 0). Input 0 is payment, input 1 is confirmation. From q0, payment leads to q1 (paid, output 0); confirmation stays in q0. In q1, another payment keeps q1 and confirmation leads to q2 (ticket ready, output 1). In q2, payment starts a new cycle in q0 and confirmation keeps q2. Complete the missing state and transitions.',
    'chapter4.test.ticket.instruction':
        'Add the prepared missing state and connect its required transitions with tap-and-select.',
    'chapter4.test.ticket.hint':
        'The final state emits Y = 1; follow both inputs from it.',
    'chapter4.test.lock.prompt':
        'A code lock starts in q0. Input 0 advances q0 to q1, q1 to q2, and q2 to q3. Input 1 returns q0 and q1 to q0, but moves q2 to q1. From q3 either input returns to q0. The output is 1 only in q3 (unlocked), and 0 in q0, q1 and q2. Complete the Moore automaton.',
    'chapter4.test.lock.instruction':
        'Add every missing prepared transition with tap-and-select.',
    'chapter4.test.lock.hint':
        'Check input 0 and input 1 separately from q2 and q3.',
    'path.chapter5.description.title': 'From a description',
    'path.chapter5.description.subtitle': 'Build from a real situation',
    'path.chapter5.tables.title': 'From tables',
    'path.chapter5.tables.subtitle': 'Build from transition data',
    'chapter5.test.subtitle': 'Create three different automata.',
    'chapter5.test.coffee.prompt':
        'Build a Moore automaton for a coffee machine. It starts in WAITING with output WAIT. A coin leads to PAID with output CHOOSE. Choosing a drink or cancelling returns it to WAITING. Other events keep the current state.',
    'chapter5.test.coffee.instruction':
        'Create the two states, set their outputs and choose the initial state. For each state, define a transition for coin, choose drink and cancel. Events not described as a state change need a self-loop.',
    'chapter5.test.coffee.hint':
        'Only coin changes WAITING to PAID. Both actions from PAID return to WAITING.',
    'chapter5.test.locker.prompt':
        'A parcel locker is empty, then stores a parcel. A correct PIN opens it; a wrong PIN keeps it locked; closing the door makes it empty. Build its automaton.',
    'chapter5.test.locker.instruction':
        'Create the three ready states and connect every described event using tap-and-select.',
    'chapter5.test.locker.hint': 'Wrong PIN is a self-loop on PARCEL STORED.',
    'chapter5.test.washingMachine.prompt':
        'Build a Moore automaton that starts in IDLE with output READY. The events start, wash done, rinse done and door opened lead through WASHING (WASH), RINSING (RINSE), DONE (DONE) and back to IDLE. Other events keep the current state.',
    'chapter5.test.washingMachine.instruction':
        'Create the four states, set their outputs and the initial state. For every state and event, define exactly one transition. Use self-loops for events that do not change that state.',
    'chapter5.test.washingMachine.hint':
        'Follow the physical order: start, wash done, rinse done, door opened.',
    'task.chapter2.gatesAnd.prompt':
        'What is the output of AND when its inputs are 0 and 1?',
    'task.chapter2.gatesAnd.instruction': 'Choose the output value.',
    'task.chapter2.gatesAnd.hint': 'AND outputs 1 only when both inputs are 1.',
    'task.chapter2.gatesOr.prompt':
        'What is the output of OR when its inputs are 0 and 1?',
    'task.chapter2.gatesOr.instruction': 'Choose the output value.',
    'task.chapter2.gatesOr.hint': 'OR outputs 1 when at least one input is 1.',
    'chapter1.final.determinism.prompt':
        'For each state and input, how many outgoing transitions may a deterministic FSM have?',
    'chapter1.final.mooreOutput.prompt':
        'A Moore FSM starts in q0 with output 0. Input 1 moves it to q1, whose output is 1. What output is active after the move?',
    'chapter1.final.trace.prompt':
        'Start in q0 and follow input 1, then 0. Which state is reached?',
    'chapter1.final.complete.prompt':
        'Is the shown FSM complete for the input alphabet {start, stop}?',
    'chapter1.final.conflict.prompt':
        'Select every transition that creates a conflict: the same state and input lead to different targets.',
    'chapter1.final.edge.q0q1': 'q0 --0--> q1',
    'chapter1.final.edge.q0q2': 'q0 --0--> q2',
    'chapter1.final.edge.q1q2': 'q1 --1--> q2',
    'chapter2.final.andTable.prompt':
        'Use the displayed AND-gate circuit to derive every transition-table and output-table entry.',
    'chapter2.final.mixedTable.prompt':
        'Read the mixed-gate circuit and derive its complete transition and output tables.',
    'chapter2.final.xorTable.prompt':
        'Use the displayed XOR circuit to derive every transition-table and output-table entry.',
    'chapter2.final.stateBits.prompt':
        'How many different bit patterns can be represented by two state bits before any unused codes are excluded?',
    'chapter2.final.xor.prompt':
        'What does XOR output when both of its inputs are 1?',
    'chapter4.final.completeness.prompt':
        'If even one state/input pair has no defined transition, is the deterministic FSM complete?',
    'chapter4.final.transitionCount.prompt':
        'How many transitions are required for a complete deterministic FSM with three states and two input symbols?',
    'chapter4.answer.fiveTransitions': '5 transitions',
    'chapter4.answer.sixTransitions': '6 transitions',
    'chapter4.answer.sevenTransitions': '7 transitions',
    'chapter4.task.water.prompt':
        'Complete the Moore water-level controller. Input 0 drains the tank; input 1 fills it. The output is 1 while the tank is full.',
    'chapter4.task.water.instruction':
        'Add the missing transition from HIGH for input 1.',
    'chapter4.task.water.hint':
        'Filling an already full tank keeps the controller in HIGH.',
    'chapter4.task.pump.prompt':
        'Complete the one-state Mealy pump controller: sensor = 1 starts the pump and sensor = 0 stops it.',
    'chapter4.task.pump.instruction':
        'Add the missing sensor = 0 / STOP PUMP self-loop.',
    'chapter4.task.pump.hint':
        'A Mealy transition stores both the sensor input and the pump output.',
    'chapter5.tables.practice.prompt':
        'Build the Mealy automaton represented by the displayed three-state transition table.',
    'chapter5.tables.practice.hint':
        'Copy each defined table entry to one transition and preserve its input/output label.',
    'chapter5.completion.second.prompt':
        'Complete the three-state Moore controller. Input 0 cycles q0 -> q1 -> q2 -> q0. For input 1, q0 -> q2, q1 -> q0 and q2 -> q1. Outputs are 1 in q0 and q2, and 0 in q1.',
    'chapter5.completion.second.hint':
        'Check the missing transition from q2 for input 1.',
    'chapter5.completion.third.prompt':
        'Complete the two-state Moore controller. Input 0 toggles between q0 and q1; input 1 keeps the current state. q0 outputs 0 and q1 outputs 1.',
    'chapter5.completion.third.hint':
        'Set the missing output in q0 and add the missing self-loop from q1 for input 1.',
    'chapter5.diagnostics.missingTransition.prompt':
        'For input 1, which state has no outgoing transition in the displayed automaton?',
  },
  AppLanguage.de: {
    ...taskFeedbackDe,
    'fsmFeedback.noStates':
        'Füge Zustände hinzu, bevor du den Automaten prüfst.',
    'fsmFeedback.missingInitialState':
        'Wähle einen Anfangszustand für den Automaten.',
    'fsmFeedback.unknownInitialState':
        'Die Anfangsmarkierung muss auf einen vorhandenen Zustand zeigen.',
    'fsmFeedback.duplicateStateId':
        'Der Zustand {state} kommt mehrfach vor. Verwende eindeutige Zustandskennungen.',
    'fsmFeedback.missingStateOutput':
        'Lege die Moore-Ausgabe des Zustands {state} fest.',
    'fsmFeedback.missingTransitionOutput':
        'Der Übergang aus {state} für Eingabe {input} benötigt eine Mealy-Ausgabe.',
    'fsmFeedback.emptyTransitionSymbol':
        'Wähle eine Eingabe für einen Übergang aus Zustand {state}.',
    'fsmFeedback.unknownTransitionEndpoint':
        'Prüfe die Endpunkte des Übergangs aus {state} für Eingabe {input}. Beide müssen vorhandene Zustände sein.',
    'fsmFeedback.nondeterministicTransition':
        'Aus Zustand {state} gehen mehrere Übergänge für Eingabe {input} hervor. Lege für diese Eingabe genau einen Übergang fest.',
    'fsmFeedback.missingTransition':
        'Aus Zustand {state} gibt es für Eingabe {input} keinen Übergang. Ergänze einen Übergang für diesen Zustand und diese Eingabe.',
    'fsmFeedback.unknownInputSymbol':
        'Die Eingabe {input} bei Zustand {state} gehört nicht zum Aufgabenalphabet. Verwende eine der angezeigten Aktionen.',
    'fsmFeedback.behaviorMismatch':
        'Der Automat entspricht noch nicht der Aufgabenbeschreibung. Prüfe seine Übergänge und Ausgaben.',
    'fsmFeedback.incompleteTrace':
        'Prüfe die Ausgabefolge: Ihre Werte oder ihre Länge entsprechen noch nicht der Aufgabe.',
    'fsmTable.state': 'Zustand',
    'fsmTable.input': 'Eingang',
    'fsmTable.nextState': 'Nächster Zustand',
    'fsmTable.output': 'Ausgang',
    'sandbox.action.tables': 'Tabellen',
    'sandbox.action.check': 'Prüfen',
    'sandbox.action.simulate': 'Simulieren',
    'sandbox.panel.close': 'Bereich schließen',
    'sandbox.tables.title': 'Tabellen deines Automaten',
    'sandbox.tables.empty':
        'Füge zuerst Zustände hinzu. Die Tabellen entstehen aus deiner Zeichnung.',
    'sandbox.tables.noTransitions':
        'Es gibt noch keine Übergänge. Jede Eingabe, die du an einem Übergang verwendest, wird zu einer Zeile der Tabelle.',
    'sandbox.tables.alphabet': 'Verwendete Eingaben: {symbols}',
    'sandbox.tables.transitionTitle': 'Übergangstabelle',
    'sandbox.tables.outputTitle': 'Ausgabetabelle',
    'sandbox.tables.legend':
        '→ markiert den Startzustand, - bedeutet kein Übergang, ⚠ bedeutet mehrere Übergänge für denselben Zustand und dieselbe Eingabe.',
    'sandbox.check.title': 'Strukturprüfung',
    'sandbox.check.ok':
        'Keine Strukturfehler: Jeder Zustand hat für jede verwendete Eingabe genau einen Übergang, und alle Ausgaben sind gesetzt.',
    'sandbox.check.issues':
        '{count} Problem(e) gefunden. Die betroffenen Zustände sind rot markiert.',
    'sandbox.check.scope':
        'Geprüft wird über den gezeichneten Eingaben. Ob der Automat eine bestimmte Aufgabe löst, zeigt die Prüfung nicht.',
    'sandbox.sim.title': 'Simulation',
    'sandbox.sim.inputLabel': 'Eingabefolge',
    'sandbox.sim.inputHint': 'z. B. 1 0 1 oder Münze, Durchgang',
    'sandbox.sim.alphabet': 'Mögliche Eingaben: {symbols}',
    'sandbox.sim.run': 'Starten',
    'sandbox.sim.first': 'Zum Anfang',
    'sandbox.sim.previous': 'Vorheriger Schritt',
    'sandbox.sim.next': 'Nächster Schritt',
    'sandbox.sim.last': 'Zum Ende',
    'sandbox.sim.step': 'Schritt {step} von {total}',
    'sandbox.sim.outputs': 'Ausgaben: {outputs}',
    'sandbox.sim.noTransitions':
        'Zeichne zuerst Übergänge, dann kannst du Eingaben simulieren.',
    'sandbox.sim.emptyInput': 'Gib mindestens eine Eingabe ein.',
    'sandbox.sim.done': 'Alle Eingaben wurden verarbeitet.',
    'sandbox.sim.stop.missingInitialState':
        'Der Automat hat keinen Startzustand. Lege ihn vor der Simulation fest.',
    'sandbox.sim.stop.unknownSymbol':
        'Die Eingabe {input} kommt an keinem Übergang vor.',
    'sandbox.sim.stop.missingTransition':
        'Die Simulation stoppt in Zustand {state}: Für die Eingabe {input} gibt es keinen Übergang.',
    'sandbox.sim.stop.nondeterministicTransition':
        'Die Simulation stoppt in Zustand {state}: Für die Eingabe {input} gibt es mehrere Übergänge.',
    'lesson.submitTest': 'Test abgeben',
    'creation.test.washingMachine.prompt':
        'Eine Moore-Waschmaschine beginnt IDLE (Ausgabe READY). start führt zu WASHING (Ausgabe WASH), wash done zu RINSING (Ausgabe RINSE), rinse done zu DONE (Ausgabe UNLOCK) und door opened zurück zu IDLE. Erstelle den Automaten. Ergänze für jedes Ereignis, das in einem Zustand nicht anders beschrieben ist, eine Selbstschleife: Zustand und Ausgabe bleiben unverändert.',
    'creation.test.locker.prompt':
        'Ein Moore-Schließfach beginnt LOCKER EMPTY (Ausgabe AVAILABLE). Ein eingelegtes Paket führt zu PARCEL STORED (Ausgabe LOCKED). Eine richtige PIN öffnet die Tür: DOOR OPEN (Ausgabe OPEN). Eine falsche PIN lässt sie gesperrt. Das Schließen der Tür führt zurück zu LOCKER EMPTY. Erstelle den Automaten. Ergänze für jedes Ereignis, das in einem Zustand nicht anders beschrieben ist, eine Selbstschleife: Zustand und Ausgabe bleiben unverändert.',
    'creation.test.coffee.prompt':
        'Ein Moore-Kaffeeautomat beginnt WAITING (Ausgabe INSERT COIN). Eine Münze führt zu PAID (Ausgabe CHOOSE DRINK). Getränkeauswahl oder Abbruch führen zurück zu WAITING. Ein Abbruch beim Warten ändert nichts. Erstelle den Automaten. Ergänze für jedes Ereignis, das in einem Zustand nicht anders beschrieben ist, eine Selbstschleife: Zustand und Ausgabe bleiben unverändert.',
    'creation.description.test.prompt':
        'Übung: Ein Paketautomat beginnt EMPTY (Ausgabe READY). Ein eingelegtes Paket führt zu PARCEL STORED (Ausgabe LOCKED). Ein gültiger Abholcode öffnet das Fach: PICKUP OPEN (Ausgabe OPEN). Ein falscher Code lässt es gesperrt. Nach dem Schließen der Tür ist es wieder leer. Erstelle den Moore-Automaten. Ergänze für jedes Ereignis, das in einem Zustand nicht anders beschrieben ist, eine Selbstschleife: Zustand und Ausgabe bleiben unverändert.',
    'creation.tables.task.prompt':
        'Erstelle den Moore-Automaten einer Parkschranke aus den angezeigten Übergangs- und Ausgabetabellen. Der Anfangszustand ist q0.',
    'creation.tables.task.hint':
        'Lies beide Tabellen. Von q1 führt ticket nach q2 und timeout zurück nach q0. Der Anfangszustand ist q0.',
    'creation.defaultRule':
        'Ergänze für jedes Ereignis, das in einem Zustand nicht anders beschrieben ist, eine Selbstschleife: Zustand und Ausgabe bleiben unverändert.',
    'creation.check.incorrect':
        'Prüfe das Ereignis erneut: Fahrrad entnehmen beziehungsweise das nächste Ticket prüfen führt von q1 nach q2.',
    'creation.check.correct': 'Richtig: Dieses Ereignis führt von q1 nach q2.',
    'creation.check.tables':
        'Lies die Übergangstabelle: Welcher Zustand folgt auf q1 bei ticket?',
    'creation.check.description':
        'Der Code wurde akzeptiert (q1). Welcher Zustand folgt, wenn das Fahrrad entnommen wird?',
    'path.chapter4.locked': 'Test für Kapitel 2 bestehen',
    'path.chapter4.test.title': 'Test Kapitel 3',
    'path.chapter4.title': 'Kapitel 3: Automaten vervollständigen',
    'lesson.summary.automata-creation-test':
        'Erstelle drei neue Automaten selbstständig. Zwei von drei richtigen Lösungen reichen zum Bestehen.',
    'lesson.summary.automata-creation-tables':
        'Erstelle einen Moore-Automaten aus den Übergangs- und Ausgabetabellen einer Parkschranke.',
    'lesson.summary.automata-creation-description':
        'Leite Zustände, Ausgaben und Übergänge aus den Beschreibungen eines Fahrradverleihs und eines Paketautomaten ab.',
    'creation.test.subtitle':
        '3 Konstruktionen · 15 Minuten · 2 richtige zum Bestehen',
    'creation.path.test.subtitle':
        '3 praktische Aufgaben · 2 richtige zum Bestehen',
    'creation.path.test.title': 'Test Kapitel 4',
    'creation.path.tables.subtitle': '1 Konstruktionsaufgabe',
    'creation.path.description.subtitle': '2 Konstruktionsaufgaben',
    'creation.path.locked': 'Test für Kapitel 3 bestehen',
    'creation.path.unlocked': 'Erstellungskapitel freigeschaltet',
    'creation.path.title': 'Kapitel 4: Automaten erstellen',
    'creation.description.title': 'Automaten erstellen: Beschreibungen',
    'creation.description.welcome.title': 'Willkommen in Kapitel 4',
    'automata-creation-description.welcome':
        'Willkommen in Kapitel 4. Du lernst, Automaten aus realen Beschreibungen zu erstellen.',
    'creation.description.welcome.body':
        'Zuerst leiten wir den Automaten eines Fahrradverleihs gemeinsam her. Danach baust du ihn selbst und überträgst das Vorgehen auf einen Paketautomaten.',
    'creation.description.subtitle': 'Von einer Alltagssituation zum FSM',
    'creation.tables.title': 'Automaten erstellen: Tabellen',
    'creation.tables.subtitle': 'Von Übergangs- und Ausgangstabellen zum FSM',
    'automata-creation-description.story.0':
        'Lies zuerst die ganze Situation. An einer Fahrradstation bleibt das Fahrrad gesperrt, bis ein gültiger Code akzeptiert wird. Nach der Rückgabe ist die Station wieder bereit.',
    'automata-creation-description.story.1':
        'Übertrage die Situationen aus der Geschichte in Zustände: BIKE LOCKED, CODE ACCEPTED und BIKE TAKEN. Beginne mit q0 = BIKE LOCKED.',
    'automata-creation-description.story.2':
        'Füge nun die Ereignisse Schritt für Schritt hinzu: valid code führt zu CODE ACCEPTED, wrong code bleibt bei BIKE LOCKED und take bike führt zu BIKE TAKEN.',
    'automata-creation-description.story.3':
        'Der Graph folgt aus der Beschreibung. Baue als Nächstes den Fahrradverleih selbst und übertrage das Vorgehen anschließend auf einen Paketautomaten.',
    'automata-creation-tables.story.0':
        'Dieselbe Methode funktioniert auch mit Tabellen. Für diese Parkplatzschranke sind Zustände, Ereignisse und Ausgaben bereits notiert.',
    'automata-creation-tables.story.1':
        'Die Übergangstabelle zeigt, wohin jedes Ereignis führt: Zustand, Ereignis, Folgezustand.',
    'automata-creation-tables.story.2':
        'Die Ausgangstabelle zeigt, was die Schranke in jedem Zustand tut. Halte Zustand, Ausgabe und Übergänge zusammen.',
    'automata-creation-tables.story.3':
        'Nutze beide Tabellen, um den Schrankenautomaten mit Tap-and-Select zu bauen.',
    'creation.description.visual.0.title': '1. Situation lesen',
    'creation.description.visual.0.body':
        'Eine Beschreibung ist eine Spezifikation. Sammle zuerst Situationen und Ereignisse.',
    'creation.description.visual.1.title': '2. Zustände erstellen',
    'creation.description.visual.1.body':
        'Erstelle q0, q1 und q2 für BIKE LOCKED, CODE ACCEPTED und BIKE TAKEN. Markiere q0 als Start.',
    'creation.description.visual.2.title': '3. Übergänge hinzufügen',
    'creation.description.visual.2.body':
        'Übersetze jeden Satz in einen Pfeil: Ereignis auf dem Pfeil, Zielsituation am Ende.',
    'creation.description.visual.3.title': '4. Automaten prüfen',
    'creation.description.visual.3.body':
        'Alle drei Situationen und fünf Ereignisse sind nun enthalten. Prüfe, ob jedes Ereignis ein klares Ziel hat.',
    'creation.tables.visual.0.title': 'Eine Parkplatzschranke',
    'creation.tables.visual.0.body':
        'Tabellen können denselben Automaten beschreiben, ohne ihn zuerst zu zeichnen.',
    'creation.tables.visual.1.title': 'Übergangstabelle',
    'creation.tables.visual.1.body':
        'Wandle jedes Zustand-Ereignis-Paar aus der Tabelle in einen Pfeil um.',
    'creation.tables.visual.2.title': 'Ausgangstabelle',
    'creation.tables.visual.2.body':
        'Die Ausgabe gehört zum aktuellen Zustand: STOP, WAIT oder GO.',
    'creation.tables.visual.3.title': 'Im Sandbox bauen',
    'creation.tables.visual.3.body':
        'Lies die Tabellen zeilenweise und baue den Graphen mit Tap-and-Select.',
    'creation.description.task.prompt':
        'Ein Moore-Fahrradverleih beginnt BIKE LOCKED (Ausgabe WAIT). valid code führt zu CODE ACCEPTED (Ausgabe UNLOCK); wrong code lässt das Fahrrad gesperrt. take bike führt von CODE ACCEPTED zu BIKE TAKEN (Ausgabe RIDE), timeout von CODE ACCEPTED zurück zu BIKE LOCKED und return bike von BIKE TAKEN zu BIKE LOCKED. Erstelle den Automaten. Ergänze für jedes Ereignis, das in einem Zustand nicht anders beschrieben ist, eine Selbstschleife: Zustand und Ausgabe bleiben unverändert.',
    'creation.description.task.instruction':
        'Nutze Tap-and-Select: Zustände hinzufügen, q0 als Start setzen, dann jeden Übergang wählen und seine Endpunkte antippen.',
    'creation.description.task.hint':
        'Ein falscher Code lässt das Fahrrad gesperrt; ein gültiger Code führt zu CODE ACCEPTED.',
    'creation.description.test.instruction':
        'Leite Zustände und Ereignisse aus der Beschreibung ab und baue den vollständigen FSM mit Tap-and-Select.',
    'creation.description.test.hint':
        'Der Übergang für wrong code ist eine Schleife auf PARCEL STORED; valid code führt zu PICKUP OPEN.',
    'creation.tables.task.instruction':
        'Füge die Zustände hinzu, setze q0 als Start und übernimm jede Tabellenzeile mit Tap-and-Select als Übergang.',
    'creation.test.coffee.instruction':
        'Erstelle die zwei fertigen Zustände und alle Übergänge mit Tap-and-Select.',
    'creation.test.coffee.hint':
        'Nur coin führt von WAITING zu PAID. Beide Aktionen aus PAID führen zu WAITING.',
    'creation.test.locker.instruction':
        'Erstelle die drei fertigen Zustände und verbinde jedes beschriebene Ereignis mit Tap-and-Select.',
    'creation.test.locker.hint':
        'wrong PIN ist eine Schleife auf PARCEL STORED.',
    'creation.test.washingMachine.instruction':
        'Erstelle die vier fertigen Zustände und verbinde den Zyklus mit Tap-and-Select.',
    'creation.test.washingMachine.hint':
        'Folge der realen Reihenfolge: start, wash done, rinse done, door opened.',
    'fsmWorkspace.transitionOutput': 'Übergangsausgabe',
    'fsmWorkspace.setTransitionOutput': 'Ausgabe des Übergangs festlegen',
    'fsmWorkspace.resetView': 'Ansicht zurücksetzen',
    'fsmWorkspace.setTransitionOutputHint':
        'Du legst jetzt die Ausgabe für den Übergang {from} → {to} bei Eingabe {input} fest. Die Eingabe bleibt unverändert.',
    'taskInteraction.actionAlphabet': 'Aktionen: {mapping}.',
    'taskInteraction.chapter2Legend':
        'Notation: S₁S₀ = aktueller Zustandskode; A = Eingang; CLK = Taktimpuls; S₁′S₀′ = Folgezustand nach CLK; Y = Ausgang.',
    'lesson.start.skipOnce': 'Einmal direkt die Aufgaben versuchen',
    'lesson.start.skipHint':
        'Kennst du das Thema schon? Starte direkt mit den Aufgaben. Zum Überspringen brauchst du alle 3 Sterne: Löse jede Aufgabe beim ersten Versuch richtig. Ein Versuch pro Lektion; bei einem Fehler geht es zur Erklärung. Auch Verlassen verbraucht den Versuch.',
    'lesson.start.skipUnavailable':
        'Versuch nicht speicherbar. Bitte starte die Lektion regulär.',
    'lesson.start.skipFailed':
        'Bearbeite die Erklärung, bevor du die Aufgaben erneut versuchst.',
    'lesson.summary.intro':
        'Lerne Zustände, den Anfangszustand und Übergänge am Beispiel einer Ampel kennen.',
    'lesson.summary.states':
        'Erkenne Zustände, Reset und Zustandsausgaben in Diagrammen.',
    'lesson.summary.transitions': 'Lies Übergänge und verfolge Eingabefolgen.',
    'lesson.summary.chapter_test':
        'Prüfe dein Wissen über Zustände, Übergänge und Ausgaben.',
    'lesson.summary.chapter2-gates-review':
        'Wiederhole AND-, OR-, NOT- und XOR-Gatter.',
    'lesson.summary.chapter_2':
        'Lies ein Schaltwerk und leite Übergangs- und Ausgabetabellen ab.',
    'lesson.summary.chapter_2_test':
        'Wende Gatterlogik an, erstelle Tabellen und interpretiere Zustandsbits.',
    'lesson.summary.chapter4-completion':
        'Ergänze Zustände, Übergänge, Reset und Ausgaben anhand von Beschreibungen.',
    'lesson.summary.chapter_4_test':
        'Vervollständige Automaten selbstständig anhand der Anforderungen.',
    'lesson.summary.chapter5-theory':
        'Beantworte drei Theoriefragen zu Moore, Mealy und Zeitverhalten.',
    'lesson.summary.chapter5-tables':
        'Erstelle Automaten aus Übergangs- und Ausgabetabellen.',
    'lesson.summary.chapter5-completion':
        'Ergänze fehlende Elemente anhand der Beschreibung.',
    'lesson.summary.chapter5-creation':
        'Erstelle einen vollständigen Automaten aus der beschriebenen Situation.',
    'lesson.summary.chapter5-diagnostics':
        'Finde Fehler und verfolge das Verhalten von Automaten.',
    'fsmWorkspace.chooseEndpointsHint':
        'Wähle, bei welchem Zustand der Übergang beginnt und bei welchem er endet.',
    'fsmGuide.addTransitionChooseEndpoints':
        'Tippe auf {control}, dann auf Start- und Zielknoten. Wähle Aktion und bei Mealy die Ausgabe aus Listen.',
    'nav.learn': 'Lernen',
    'nav.sandbox': 'Sandbox',
    'nav.progress': 'Fortschritt',
    'nav.profile': 'Profil',
    'nav.settings': 'Einstellungen',
    'common.back': 'Zurück',
    'common.yes': 'Ja',
    'common.next': 'Weiter',
    'common.finish': 'Fertig',
    'lesson.storyIntro': 'Bearbeite das Beispiel Schritt für Schritt.',
    'lesson.storyAcknowledge': 'Ich habe diesen Schritt bearbeitet.',
    'lesson.storyWelcomeTitle': 'Dein Lernziel',
    'lesson.storyWelcomeInstruction':
        'Lies das Ziel und erkenne die Fähigkeit, die du üben wirst.',
    'lesson.storyRecallTitle': 'Rückblick',
    'lesson.storyRecallInstruction':
        'Nutze die Abbildung, um Zustände, Eingaben und Ausgaben zu wiederholen.',
    'lesson.storyObserveTitle': 'Modell beobachten',
    'lesson.storyObserveInstruction':
        'Verfolge ein Signal durch die Abbildung, bevor du eine Vorhersage machst.',
    'lesson.storyThinkTitle': 'Erst denken',
    'lesson.storyThinkInstruction':
        'Erkläre dir den nächsten Schritt und bestätige danach deine Prüfung.',
    'lesson.storyPracticeTitle': 'Begleitete Übung',
    'lesson.storyPracticeInstruction':
        'Löse diesen Schritt selbstständig und prüfe jedes Zustands-Eingabe-Paar.',
    'lesson.storySummaryTitle': 'Das kannst du jetzt',
    'lesson.storySummaryInstruction':
        'Fasse die Methode zusammen und verbinde sie mit dem Praxistest.',
    'common.continue': 'Weiter',
    'common.down': 'Nach unten',
    'lesson.completeInteractionFirst':
        'Probiere zuerst die interaktiven Elemente in der Szene aus.',
    'common.reset': 'Reset',
    'common.cancel': 'Abbrechen',
    'common.add': 'Hinzufügen',
    'common.save': 'Speichern',
    'answer.true': 'Wahr',
    'answer.false': 'Falsch',
    'lesson.taskWrong':
        'Das ist noch nicht richtig. Prüfe den Automaten genau und versuche es erneut.',
    'taskDifficulty.ss1': 'Einfach',
    'taskDifficulty.ss2': 'Mittel',
    'taskDifficulty.ss3': 'Klausurniveau',
    'taskDifficulty.ss4': 'Sternchenaufgabe',
    'taskKind.aa1': 'Folge einer Änderung',
    'taskKind.aa2': 'Fehler finden',
    'taskKind.aa3': 'Automaten prüfen',
    'taskKind.aa4': 'Automaten erstellen',
    'taskKind.aa6': 'FSM-Tabelle erstellen',
    'taskKind.aa7': 'Zustand verfolgen',
    'taskKind.aa8': 'Automaten vervollständigen',
    'taskKind.aa9': 'Theorie',
    'fsmWorkspace.empty': 'Dieser Automat enthält keine Zustände',
    'fsmWorkspace.tapToAdd':
        'Wähle "Zustand hinzufügen" und tippe dann auf die Arbeitsfläche.',
    'fsmWorkspace.transitionSymbol': 'Übergangssymbol',
    'fsmWorkspace.symbolHint': 'Zum Beispiel: 0, Münze, Timer',
    'fsmWorkspace.stateLabel': 'Zustandsname',
    'fsmWorkspace.stateLabelHint': 'Zum Beispiel: Gesperrt',
    'fsmWorkspace.customValue': 'Eigenen Wert eingeben',
    'fsmWorkspace.customValueHint':
        'Gib einen Zustandsnamen, eine Aktion oder Ausgabe ein.',
    'fsmWorkspace.transitionSymbolSlashError':
        'Verwende kein "/" im Eingangssymbol; es trennt Eingang und Ausgabe.',
    'fsmWorkspace.undo': 'Letzte Aktion rückgängig machen',
    'fsmWorkspace.autoArrange': 'Zustände im Zickzack anordnen',
    'fsmWorkspace.clear': 'Automaten leeren',
    'fsmWorkspace.help': 'HELP',
    'fsmWorkspace.chooseState': 'Zustandsnamen auswählen',
    'fsmWorkspace.chooseStateHint':
        'Wähle einen Zustand mit bereits ausgefülltem Namen und Ausgang.',
    'fsmWorkspace.customState': 'Eigenen Zustand erstellen',
    'fsmWorkspace.customStateHint': 'Tippe danach auf einen freien Platz.',
    'fsmWorkspace.noOutput': 'Kein Zustandsausgang',
    'fsmWorkspace.chooseTransition': 'Fertigen Übergang auswählen',
    'fsmWorkspace.chooseTransitionHint':
        'Wähle einen Übergang mit bereits ausgefülltem Eingang und Ausgang.',
    'fsmWorkspace.customTransition': 'Eigenen Übergang erstellen',
    'fsmWorkspace.customTransitionHint':
        'Wähle den Ausgangs- und Zielzustand selbst.',
    'fsmWorkspace.chooseEndpoints': 'Endpunkte des Übergangs auswählen',
    'fsmWorkspace.fromState': 'Von Zustand',
    'fsmWorkspace.toState': 'Zu Zustand',
    'fsmWorkspace.noStatesTitle': 'Zuerst einen Zustand hinzufügen',
    'fsmWorkspace.noStatesMessage':
        'Wähle einen fertigen Zustand oder erstelle einen eigenen, bevor du einen Übergang hinzufügst.',
    'fsmGuide.welcome':
        'Platziere Knoten und Pfeile selbst. Wähle Namen und Ausgaben aus Listen; setze den Startzustand mit Reset.',
    'fsmGuide.customWelcome':
        'Erstelle Moore- und Mealy-Automaten nach deinen Vorstellungen. Gib eigene Zustandsnamen, Übergangssymbole und Ausgaben ein und wechsle jederzeit den Modus.',
    'fsmGuide.readyWelcome':
        'Platziere Knoten und Pfeile selbst. Wähle Namen und Ausgaben aus Listen; setze den Startzustand mit Reset.',
    'fsmGuide.select':
        'Mit {control} kannst du einen Zustand auswählen und an eine bessere Stelle ziehen.',
    'fsmGuide.addState':
        'Tippe auf {control}, dann auf eine freie Stelle. Wähle den Zustandsnamen aus der Liste. Ausgabe und Reset setzt du separat.',
    'fsmGuide.addStateCustom':
        'Tippe auf {control}, dann auf eine freie Stelle. Wähle einen Vorschlag oder gib einen eigenen Zustandsnamen ein; Ausgabe und Startzustand legst du separat fest.',
    'fsmGuide.addStateReady':
        'Tippe auf {control}, dann auf eine freie Stelle. Wähle den Zustandsnamen aus der Liste. Ausgabe und Reset setzt du separat.',
    'fsmGuide.addTransition':
        'Tippe auf {control}, dann auf Start- und Zielknoten. Wähle Aktion und bei Mealy die Ausgabe aus Listen.',
    'fsmGuide.addTransitionCustom':
        'Tippe auf {control}, dann auf Start- und Zielknoten. Wähle oder tippe das Eingangssymbol und bei Mealy die Übergangsausgabe ein.',
    'fsmGuide.addTransitionReady':
        'Tippe auf {control}, dann auf Start- und Zielknoten. Wähle Aktion und bei Mealy die Ausgabe aus Listen.',
    'fsmGuide.setInitial':
        '{control} markiert den Zustand, in dem der Automat nach dem Zurücksetzen beginnt.',
    'fsmGuide.editOutput':
        'Tippe auf {control}, dann auf einen Moore-Knoten oder Mealy-Pfeil und wähle die Ausgabe aus der Liste.',
    'fsmGuide.customize':
        'Halte einen Knoten gedrückt, um ihn umzubenennen. Mit {control} bearbeitest du die Ausgabe eines Moore-Knotens oder die Beschriftung eines Moore-Übergangs; bei Mealy legst du damit die Ausgabe eines Übergangs fest. Wähle einen Vorschlag oder gib einen eigenen Wert ein.',
    'fsmGuide.delete': '{control} entfernt einen Zustand oder einen Übergang.',
    'fsmGuide.undo': '{control} macht die letzte Änderung rückgängig.',
    'fsmGuide.clear':
        '{control} setzt die Arbeitsfläche auf einen leeren Automaten zurück.',
    'fsmGuide.help':
        '{control} wiederholt diese Einführung, wann immer du sie brauchst.',
    'fsmGuide.done': 'Fertig',
    'fsmGuide.skip': 'Einführung überspringen',
    'fsmTool.select': 'Auswählen und verschieben',
    'fsmTool.addState': 'Zustand hinzufügen',
    'fsmTool.addTransition': 'Übergang hinzufügen',
    'fsmTool.setInitial': 'Startzustand festlegen',
    'fsmTool.editOutput': 'Zustandsausgabe bearbeiten',
    'fsmTool.customize': 'Namen und Ausgaben bearbeiten',
    'fsmWorkspace.stateOutput': 'Zustandsausgabe',
    'fsmWorkspace.stateOutputHint': 'Zum Beispiel: 0, offen, stopp',
    'fsmTool.delete': 'Knoten oder Transition löschen',
    'taskInteraction.input': 'Eingabe: {input}',
    'taskInteraction.check': 'Antwort prüfen',
    'taskInteraction.checkAutomaton': 'Automaten prüfen',
    'taskInteraction.checkTable': 'Tabelle prüfen',
    'taskInteraction.checkTrace': 'Zustandsfolge prüfen',
    'aa4Drag.title': 'AA4 · Automaten erstellen',
    'aa4Drag.hint':
        'Ziehe jedes Teil in den passenden Platz. Du kannst auch ein Teil und danach seinen Platz antippen.',
    'aa4Drag.parts': 'Verfügbare Teile',
    'aa4Drag.slots': 'Struktur des Automaten',
    'aa4Drag.stateSlot': 'Knoten {id}',
    'aa4Drag.transitionSlot': 'Transition {from} → {to}',
    'aa4Drag.initialSlot': 'Startzustandsmarkierung',
    'aa4Drag.emptySlot': 'Teil hier ablegen',
    'aa4Drag.reset': 'Aufbau zurücksetzen',
    'aa4Drag.previewEmpty': 'Der zusammengesetzte Automat erscheint hier.',
    'aa4Drag.correct': 'Richtig: Der Automat ist vollständig aufgebaut.',
    'aa4Drag.incorrect':
        'Einige Teile liegen am falschen Platz. Ordne sie neu und prüfe erneut.',
    'sandboxBuild.correct': 'Richtig: Der Automat entspricht der Beschreibung.',
    'sandboxBuild.incorrect':
        'Der Automat entspricht der Beschreibung noch nicht. Prüfe Knoten, Ausgaben, Transitionen und Startzustand.',
    'taskInteraction.state': 'Zustand',
    'taskInteraction.output': 'Ausgabe',
    'taskInteraction.startState': 'Startzustand',
    'taskInteraction.afterInput': 'Nach Eingabe {input}',
    'taskInteraction.freeTextHint': 'Antwort eingeben',
    'taskInteraction.before': 'Vor der Änderung',
    'taskInteraction.after': 'Nach der Änderung',
    'exitDialog.title': 'App beenden?',
    'exitDialog.message':
        'Fini wird dich vermissen. Möchtest du die App wirklich beenden?',
    'exitDialog.confirm': 'Beenden',
    'lessonExit.title': 'Lektion verlassen?',
    'lessonExit.message':
        'Der Fortschritt dieses Versuchs wird nicht gespeichert. Danach siehst du dein aktuelles Ergebnis.',
    'lessonExit.stay': 'Bleiben',
    'lessonExit.confirm': 'Verlassen',
    'common.fsm': 'FSM',
    'mascot.name': 'Fini',
    'onboarding.greeting.message':
        'Hallo, ich bin Fini! Willkommen bei FSM Quest. Hier lernst du endliche Automaten Schritt für Schritt: lesen, ergänzen und selbst bauen.',
    'onboarding.greeting.start': 'Los geht\'s',
    'onboarding.username.title': 'Wähle einen Nutzernamen für das Spiel.',
    'onboarding.username.label': 'Nutzername',
    'onboarding.username.hint': 'Nutzernamen eingeben',
    'onboarding.username.helper':
        'Ein Spitzname genügt; dein echter Name ist nicht erforderlich.',
    'home.unit': 'Einheit 1',
    'home.chapter2.unit': 'Einheit 2',
    'home.title': 'Endliche Automaten',
    'home.subtitle': 'Zustände, Übergänge und Eingabewörter',
    'settings.title': 'Einstellungen',
    'settings.language': 'Sprache',
    'settings.theme': 'Darstellung',
    'settings.theme.light': 'Hell',
    'settings.theme.dark': 'Dunkel',
    'settings.description': 'Wähle Sprache und Darstellung der App.',
    'settings.developerAccess': 'Alle Level freischalten',
    'settings.developerAccess.description':
        'Entwicklermodus: Alle Lektionen zum Testen verfügbar machen.',
    'settings.credits': 'Credits',
    'settings.credits.lecture':
        'Vorlesung „Digitaltechnik“, Fachgebiet ENCRYPTO, Prof. Dr.-Ing. Thomas Schneider, TU Darmstadt, WiSe 2025/26',
    'settings.credits.close': 'Schließen',
    'progress.title': 'Fortschritt',
    'progress.xp': '{xp} / 100 XP',
    'progress.solvedTasks': 'Gelöste Aufgaben: {count}',
    'progress.streak': 'Serie: {days} Tag',
    'progress.streakPlural': 'Serie: {days} Tage',
    'lesson.notFound': 'Lektion nicht gefunden: {lessonId}',
    'lesson.practicalTest': 'Praktischer Test',
    'lesson.taskCount': 'Aufgabe {current} von {total}',
    'lesson.needHint': 'Brauchst du einen Hinweis?',
    'lesson.hideHint': 'Hinweis ausblenden',
    'lesson.finish': 'Lektion abschließen',
    'lesson.next': 'Nächste Aufgabe',
    'lesson.trace': 'Schrittweise Simulation',
    'lesson.showNext': 'Nächsten Schritt anzeigen',
    'lesson.correct': 'Richtig. Weiter zum nächsten Schritt.',
    'lesson.genericWrong':
        'Nicht ganz: "{selected}" passt nicht. Vergleiche Zustand, Eingabesymbol und Zielzustand Schritt für Schritt.',
    'lesson.start.button': 'Starten',
    'lesson.start.rewardHint':
        'Dein Ergebnis bestimmt die Belohnung: 1 Stern = 50 %, 2 Sterne = 75 %, 3 Sterne = 100 %.',
    'lesson.intro.title': 'Einführung in FSM',
    'lesson.intro.subtitle':
        'FSM-Grundlagen am Beispiel eines echten Ampelzyklus',
    'lesson.states.title': 'Zustände',
    'lesson.states.subtitle': 'Zustände und Automatenarten: Moore und Mealy',
    'lesson.transitions.title': 'Übergänge',
    'lesson.transitions.subtitle': 'Eingabesymbole und deterministische Pfade',
    'lesson.chapterTest.title': 'Kapiteltest',
    'lesson.chapterTest.subtitle': '16 Fragen zum gesamten Kapitel',
    'lesson.chapterTest.requirement':
        'Bestehensgrenze: mindestens {minimum} von {total} beim ersten Versuch richtig. Ein niedrigeres Ergebnis setzt dieses Kapitel zurück.',
    'concept.states': 'Zustände',
    'concept.transitions': 'Zustände und Übergänge',
    'concept.mooreOutput': 'Moore-Ausgabe',
    'concept.startState': 'Startzustand',
    'concept.currentState': 'Aktueller Zustand',
    'concept.transitionLabels': 'Übergangsbeschriftungen',
    'concept.errorDiagnosis': 'Fehlerdiagnose',
    'concept.practicalSimulation': 'Praktische Simulation',
    'concept.digitalGates': 'Digitale Gatter',
    'answer.0': '0',
    'answer.1': '1',
    'answer.2': '2',
    'answer.3': '3',
    'answer.4': '4',
    'answer.5': '5',
    'answer.initialRed': 'Der Anfangszustand "RED"',
    'answer.randomState': 'Ein zufälliger Zustand',
    'answer.greenState': 'Der Zustand "GREEN"',
    'answer.redYellowState': 'Der Zustand "RED-YELLOW"',
    'answer.yellowState': 'Der Zustand "YELLOW"',
    'answer.circlesStatesArrowsTransitions':
        'Kreise sind Zustände; Pfeile sind Übergänge',
    'answer.circlesTransitionsArrowsStates':
        'Kreise sind Übergänge; Pfeile sind Zustände',
    'answer.everythingState': 'Kreise und Pfeile sind Zustände',
    'answer.onlyDefinedArrows': 'Nur entlang der definierten Pfeile',
    'answer.anyStateDirectly': 'Direkt zu jedem beliebigen Zustand',
    'answer.alwaysResetFirst': 'Jedes Mal nur nach einem Reset',
    'answer.s0': 'S0',
    'answer.s1': 'S1',
    'answer.onState': 'Am Zustand',
    'answer.onInputArrow': 'Am Eingabepfeil',
    'answer.onlyAtEnd': 'Nur am Ende',
    'answer.startStateS0': 'Startzustand S0',
    'answer.lastState': 'Der letzte Zustand',
    'answer.anyOutputState': 'Ein beliebiger Zustand mit einer Ausgabe',
    'answer.noTransition': 'Kein Übergang',
    'answer.transitionS0Input1S1': 'S0 --"1"--> S1',
    'answer.transitionS0Input0S1': 'S0 --"0"--> S1',
    'answer.transitionS1Input1S0': 'S1 --"1"--> S0',
    'answer.wrongTargetState': 'Falscher Zielzustand',
    'answer.wrongInputSymbol': 'Falsches Eingabesymbol',
    'answer.noProblem': 'Kein Problem',
    'answer.input1': 'Eingabe 1',
    'task.intro.stateCount.prompt':
        'Wie viele Zustände hat der unten gezeigte Ampelautomat?',
    'task.intro.stateCount.instruction':
        'Zähle die verschiedenen Ampelsituationen, die als Kreise dargestellt sind.',
    'task.intro.stateCount.hint': 'Denke an Rot, Rot-gelb, Grün und Gelb.',
    'task.intro.stateCount.feedback.3':
        'Rot und Rot-gelb sind zwei verschiedene Zustände.',
    'task.intro.stateCount.feedback.5':
        'Es werden nur vier verschiedene Ampelsituationen gezeigt.',
    'task.intro.reset.prompt':
        'Der RESET-Pfeil zeigt auf den roten Ampelzustand. Ist das ein gültiger Anfangszustand?',
    'task.intro.reset.instruction':
        'Betrachte die Ampel-FSM und wähle Wahr oder Falsch.',
    'task.intro.reset.hint':
        'RESET muss auf einen bekannten Zustand zeigen, in dem der Automat starten kann.',
    'task.intro.reset.feedback.random':
        'Ein Anfangszustand muss vorhersehbar sein; RESET darf daher nicht zufällig wählen.',
    'task.intro.reset.feedback.green':
        'Der RESET-Pfeil zeigt auf den roten Ampelzustand, daher ist der Start eindeutig.',
    'task.intro.components.prompt':
        'Welche Beschreibung des FSM-Diagramms ist richtig?',
    'task.intro.components.instruction':
        'Unterscheide eine aktuelle Situation von einer Regel, die sie verändert.',
    'task.intro.components.hint':
        'Ein Zustand ist ein Knoten; der Wechsel folgt den Pfeilen.',
    'task.intro.components.feedback.reversed':
        'Die Rollen sind vertauscht: Kreise zeigen Zustände, Pfeile Übergänge.',
    'task.intro.components.feedback.everything':
        'Pfeile sind Regeln für Zustandswechsel und keine Zustände.',
    'task.intro.followTransition.prompt':
        'Die FSM ist in Rot. Der 60-Sekunden-Timer läuft ab. Welcher Zustand folgt?',
    'task.intro.followTransition.instruction':
        'Folge dem ausgehenden Pfeil des roten Zustands.',
    'task.intro.followTransition.hint':
        'Die Ampel bereitet die Fahrer vor, bevor sie auf Grün schaltet.',
    'task.intro.followTransition.feedback.green':
        'Grün kommt später. Zuerst folgt Rot und Gelb.',
    'task.intro.followTransition.feedback.yellow':
        'Gelb folgt in diesem Zyklus auf Grün, nicht auf Rot.',
    'task.intro.definedPaths.prompt':
        'Kann diese FSM direkt von Rot zu Grün springen?',
    'task.intro.definedPaths.instruction':
        'Prüfe, welche gerichteten Übergänge tatsächlich definiert sind.',
    'task.intro.definedPaths.hint':
        'Eine FSM wechselt nur bei einem passenden definierten Übergang.',
    'task.intro.definedPaths.feedback.anyState':
        'Eine FSM erfindet keinen Weg, sondern folgt nur definierten Übergängen.',
    'task.intro.definedPaths.feedback.reset':
        'Reset initialisiert die FSM, ist aber nicht vor jedem Übergang nötig.',
    'task.intro.output.prompt':
        'Wo ist bei einem Moore-Automaten die Ausgabe definiert?',
    'task.intro.output.instruction':
        'Achte auf den Unterschied zwischen Zustandsbeschriftungen und Übergangsbeschriftungen.',
    'task.intro.output.hint': 'Moore-Ausgaben hängen vom aktuellen Zustand ab.',
    'task.intro.output.step.1': 'S0 / Ausgabe 0',
    'task.intro.output.step.2': 'Eingabe 1 führt nach S1',
    'task.intro.output.step.3': 'S1 / Ausgabe 1',
    'task.intro.output.feedback.onInputArrow':
        'Das beschreibt eine Mealy-Ausgabe. Bei Moore-Automaten gehört die Ausgabe zu Zuständen.',
    'task.intro.output.feedback.onlyAtEnd':
        'Die Ausgabe ist in jedem aktuellen Zustand verfügbar, nicht nur nach der gesamten Eingabe.',
    'task.states.start.prompt':
        'Welcher Zustand ist aktiv, bevor das erste Eingabesymbol gelesen wird?',
    'task.states.start.instruction':
        'Orientiere dich am eingehenden Startpfeil.',
    'task.states.start.hint':
        'Der Startzustand wird vor dem Lesen der Eingabe betreten.',
    'task.states.start.feedback.lastState':
        'Der letzte Zustand wird nach der Verarbeitung der Eingabe erreicht, nicht davor.',
    'task.states.start.feedback.anyOutputState':
        'Jeder Moore-Zustand kann eine Ausgabe haben, aber der Startpfeil legt den Beginn fest.',
    'task.states.current.prompt':
        'Eingabefolge: "1", "0". Übergänge: S0 --"1"--> S1, S1 --"0"--> S0. Wo endet der Automat?',
    'task.states.current.instruction': 'Folge jeweils einem Eingabesymbol.',
    'task.states.current.hint':
        'Nach Eingabe "1" bist du in S1. Danach wendest du Eingabe "0" von S1 aus an.',
    'task.states.current.step.1': 'Start in S0',
    'task.states.current.step.2': 'Eingabe "1": S0 → S1',
    'task.states.current.step.3': 'Eingabe "0": S1 → S0',
    'task.states.current.feedback.s1':
        'Nach Eingabe "1" ist der Automat in S1, aber Eingabe "0" führt dann von S1 zurück nach S0.',
    'task.states.current.feedback.noTransition':
        'Für Eingabe "0" gibt es einen definierten Übergang von S1 nach S0.',
    'task.transitions.symbol.prompt':
        'Bei S0 soll Eingabe "1" nach S1 führen. Welcher Übergang ist korrekt?',
    'task.transitions.symbol.instruction':
        'Prüfe Ausgangszustand, Eingabesymbol und Zielzustand.',
    'task.transitions.symbol.hint':
        'Der Ausgangszustand muss S0 sein und das Eingabesymbol muss "1" sein.',
    'task.transitions.symbol.feedback.wrongInput':
        'Der Zielzustand ist richtig, aber das Eingabesymbol ist falsch: Gesucht ist Eingabe "1".',
    'task.transitions.symbol.feedback.reversed':
        'Hier sind Ausgangs- und Zielzustand vertauscht. Der Übergang muss bei S0 starten.',
    'task.transitions.error.prompt':
        'Eingabe "1" von S0 soll nach S1 führen. Eine Lösung nutzt S0 --"1"--> S2. Was ist falsch?',
    'task.transitions.error.instruction':
        'Vergleiche den erwarteten Übergang mit dem vorgeschlagenen Übergang.',
    'task.transitions.error.hint':
        'Das Eingabesymbol ist in beiden Übergängen "1".',
    'task.transitions.error.feedback.wrongInputSymbol':
        'Die Eingabe ist in beiden Fällen "1". Der Fehler liegt im Zielzustand.',
    'task.transitions.error.feedback.noProblem':
        'Es gibt ein Problem: Bei Eingabe "1" führt der Übergang von S0 nach S1, nicht nach S2.',
    'task.test.simulate.prompt':
        'Simuliere Eingabe 101. Übergänge: S0 --"1"--> S1, S1 --"0"--> S1, S1 --"1"--> S0. Endzustand?',
    'task.test.simulate.instruction':
        'Arbeite Schritt für Schritt innerhalb des Zeitlimits.',
    'task.test.simulate.hint':
        'Nach "1" bist du in S1; nach "0" bleibst du in S1.',
    'task.test.simulate.step.1': 'Start S0',
    'task.test.simulate.step.2': '"1": S0 → S1',
    'task.test.simulate.step.3': '"0": S1 → S1',
    'task.test.simulate.step.4': '"1": S1 → S0',
    'task.test.simulate.feedback.s1':
        'Die ersten zwei Symbole lassen dich in S1, aber die letzte Eingabe "1" führt von S1 nach S0.',
    'task.test.simulate.feedback.noTransition':
        'Alle benötigten Übergänge sind für diese Eingabefolge definiert.',
    'task.test.mooreOutput.prompt':
        'Zustand S0 hat Ausgabe 0, S1 hat Ausgabe 1. Nach Eingabe 1 ist der Automat in S1. Welche Ausgabe wird angezeigt?',
    'task.test.mooreOutput.instruction':
        'Nutze den aktuellen Zustand nach dem Übergang.',
    'task.test.mooreOutput.hint':
        'Die Moore-Ausgabe gehört zum erreichten Zustand.',
    'task.test.mooreOutput.feedback.0':
        'Ausgabe 0 gehört zu S0. Nach Eingabe 1 ist der aktuelle Zustand S1.',
    'task.test.mooreOutput.feedback.input1':
        'Eingabesymbole sind keine Ausgaben. Die Ausgabe ist der Wert, der zu S1 gehört.',
    'result.saved': 'Lektion abgeschlossen',
    'result.abandoned': 'Lektion unterbrochen',
    'result.abandonedLesson': 'Nicht abgeschlossen: {lessonId}',
    'result.chapterFailed': 'Kapiteltest nicht bestanden',
    'result.chapterFailedDetail':
        'Du hast {score} von {total} beim ersten Versuch richtig beantwortet. Mindestens {minimum} sind nötig, daher wurde der Kapitelfortschritt zurückgesetzt.',
    'result.chapterNoRewards':
        'Für diesen Versuch gibt es keine XP, Münzen oder Sterne.',
    'result.noRewards':
        'Der Fortschritt wurde nicht gespeichert. Es gibt keine XP, Münzen oder Sterne.',
    'result.saving': 'Belohnungen werden gespeichert…',
    'result.saveFailed': 'Fortschritt konnte nicht gespeichert werden',
    'result.completed': 'Abgeschlossen: {lessonId}',
    'result.xpEarned': 'Erhaltene XP: {score}',
    'result.firstTryScore': 'Beim ersten Versuch richtig: {score}',
    'result.rewards': '+{xp} XP  •  +{coins} Münzen',
    'result.repeatLesson': 'Lektion wiederholen',
    'result.restartChapter': 'Kapitel neu starten',
    'result.backHome': 'Zur Startseite',
    'result.nextLesson': 'Nächste Lektion',
    'sandbox.canvas': 'FSM-Arbeitsfläche',
    'path.intro.title': 'Einführung in FSM',
    'path.intro.subtitle': '3 Aufgaben',
    'path.states.title': 'Zustände',
    'path.states.subtitle': '3 Aufgaben',
    'path.transitions.title': 'Übergänge',
    'path.transitions.subtitle': '3 Aufgaben',
    'path.test.title': 'Kapiteltest',
    'path.test.subtitle': '5 Fragen',
    'path.chapter2.title': 'Kapitel 2: DT-FSM-Abbildungen verstehen',
    'path.chapter2.review.title': 'Wiederholung: Digitale Gatter',
    'path.chapter2.review.subtitle': '3 Aufgaben',
    'path.chapter2.locked': 'Kapiteltest bestehen',
    'path.chapter2.unlocked': 'Neues Kapitel freigeschaltet',
    'path.solved': 'Gelöst',
    'path.continue': 'Hier weiter',
    'path.finalCheck': 'Abschlusstest',
    'path.locked': 'Gesperrt',
    'introFsm.auto': 'Auto',
    'introFsm.nextPhase': 'Weiter',
    'introFsm.step.1':
        'Willkommen zur ersten Lektion! Hast du schon einmal von endlichen Automaten gehört?',
    'introFsm.step.2':
        'Stell dir eine deutsche Ampel vor. Sie hat vier Zustände: Rot, Rot-gelb, Grün und Gelb.',
    'introFsm.step.021':
        'Stell dir eine deutsche Ampel vor. Sie hat vier Zustände: Rot, Rot-gelb, Grün und Gelb.',
    'introFsm.step.022': 'Schauen wir uns diese Ampel einmal genauer an.',
    'introFsm.step.023': 'Schau: Bei Rot müssen alle Autos stehen bleiben.',
    'introFsm.step.024':
        'Nach 60 Sekunden wechselt Rot zu Rot-gelb. Die Fahrer können sich vorbereiten.',
    'introFsm.step.025':
        'Jetzt leuchten Rot und Gelb gemeinsam. Die Ampel bereitet den Wechsel zu Grün vor.',
    'introFsm.step.026': 'Nach 10 Sekunden führt der Übergang zu Grün.',
    'introFsm.step.027': 'Bei Grün dürfen die Autos fahren.',
    'introFsm.step.028': 'Nach 60 Sekunden wechselt Grün zu Gelb.',
    'introFsm.step.029':
        'Gelb bedeutet: gleich anhalten. Nach 10 Sekunden führt der Übergang zurück zu Rot.',
    'introFsm.step.3':
        'Wir gehen Schritt für Schritt: Rot bleibt 60 Sekunden, dann kommt Rot-gelb für 10 Sekunden, danach Grün für 60 Sekunden und Gelb für 10 Sekunden.',
    'introFsm.step.4':
        'Jetzt übersetzen wir die Ampel in einen FSM: Zustände sind Kreise, und die Timer-Regeln sind Transitionen.',
    'introFsm.step.041':
        'Der Reset-Pfeil ist der einzige Startpfeil für den gesamten Automaten. Er führt den FSM immer in seinen Anfangszustand Rot zurück.',
    'introFsm.step.042':
        'Dieser Kreis ist ein Knoten oder Zustand. Er beschreibt die aktuelle Situation vollständig: Rot leuchtet, also müssen die Autos stehen bleiben.',
    'introFsm.step.043':
        'Dieser Pfeil ist eine Transition. Nach 60 Sekunden bewegt ihre Eingabe den Automaten von Rot zu Rot-gelb.',
    'introFsm.step.044':
        'Dieser Knoten ist ein weiterer Zustand: Rot-gelb. Er ist eine kurze Vorbereitungsphase vor Grün und kein zufälliges Ereignis.',
    'introFsm.step.045':
        'Diese Transition enthält eine 10-Sekunden-Regel. Danach verlässt der Automat Rot-gelb und geht zu Grün.',
    'introFsm.step.046':
        'Dieser Knoten steht für Grün: Der aktuelle Zustand sagt der Ampel und den Fahrern, dass sie fahren dürfen.',
    'introFsm.step.047':
        'Nach 60 Sekunden führt diese Transition von Grün zu Gelb. An der Pfeilspitze erkennst du immer, welcher Knoten als Nächstes folgt.',
    'introFsm.step.048':
        'Dieser Knoten steht für Gelb. Er gibt den Fahrern Zeit, sicher anzuhalten, bevor der Zyklus neu beginnt.',
    'introFsm.step.049':
        'Die letzte Transition wartet 10 Sekunden und führt von Gelb zurück zu Rot. Zusammen bilden alle Pfeile einen kontrollierten Zyklus.',
    'introFsm.step.5':
        'Starke Arbeit! Probieren wir fünf Fragen zu Knoten, Transitionen, Reset und dem Ampelzyklus. Prüfen wir, ob wir alles verstanden haben?',
    'introFsm.readyTitle': 'Bereit für den kurzen Check?',
    'introFsm.readyBody':
        'Vor dir liegen 5 Fragen. Versuche, jede gleich beim ersten Mal richtig zu beantworten, um die maximale Belohnung zu erhalten. Falls etwas unklar ist, helfe ich dir mit einem Hinweis.',
    'introFsm.notYet': 'Jetzt nicht',
    'introFsm.startTasks': 'Zu den Aufgaben',
    'introFsm.stateExplanation':
        'Die aktuelle Ampelfarbe ist der Zustand. Die Zeit ist die Eingabe, die den nächsten Übergang auslöst.',
    'introFsm.state.red': '1. Rot: Stopp',
    'introFsm.state.redYellow': '2. Rot-gelb: vorbereiten',
    'introFsm.state.green': '3. Grün: fahren',
    'introFsm.state.yellow': '4. Gelb: gleich stoppen',
    'introFsm.statesTitle': 'Zustände',
    'introFsm.ruleTitle': 'Ampelregel',
    'introFsm.transition.redToRedYellow': '1. Rot -> Rot-gelb (60 Sek.)',
    'introFsm.transition.redYellowToGreen': '2. Rot-gelb -> Grün (10 Sek.)',
    'introFsm.transition.greenToYellow': '3. Grün -> Gelb (60 Sek.)',
    'introFsm.transition.yellowToRed': '4. Gelb -> Rot (10 Sek.)',
    'introFsm.timerTitle':
        'Timer-Ticks wechseln den Zustand Schritt für Schritt',
    'introFsm.node.red': 'RED',
    'introFsm.node.redYellow': 'RED-YELLOW',
    'introFsm.node.green': 'GREEN',
    'introFsm.node.yellow': 'YELLOW',
    'introFsm.duration.60': '60 s',
    'introFsm.duration.10': '10 sec',
    'introFsm.fsmExplanation':
        'In einem FSM-Diagramm ist jeder Kreis ein Knoten und jeder Pfeil eine Transition zum nächsten Knoten.',
    'statesStory.intro.01':
        'Schauen wir uns an, wie diese Automaten aus der vorherigen Lektion heißen.',
    'statesStory.intro.02':
        'Im Modul Digitaltechnik an der TU Darmstadt lernen wir zwei Typen endlicher Automaten (FSM) kennen: Mealy- und Moore-Automaten.',
    'statesStory.intro.03':
        'Jetzt lernen wir Mealy- und Moore-Automaten kennen und wie man sie unterscheidet! Wir betrachten ein praktisches Beispiel mit einem Drehkreuz - einer automatisch öffnenden Tür, etwa am Eingang eines Geschäfts.',
    'statesStory.intro.mealy': 'Mealy-Automat',
    'statesStory.intro.moore': 'Moore-Automat',
    'statesStory.step.01':
        'Auf dem vorherigen Bildschirm haben wir den allgemeinen Aufbau eines endlichen Automaten gesehen. Jetzt schauen wir uns am Beispiel eines Drehkreuzes an, was ein Zustand bedeutet: Es kann verriegelt oder entriegelt sein.',
    'statesStory.step.02':
        'Üblicherweise wird die Menge aller Knoten mit dem Großbuchstaben Q bezeichnet; einzelne Knoten heißen q0, q1, q2 und so weiter. Beschreibungen erklären ihre Bedeutung: q0 = "Drehkreuz verriegelt", q1 = "Drehkreuz entriegelt".',
    'statesStory.step.04':
        'Der Index macht jeden Zustand eindeutig ansprechbar, die Beschreibung erklärt seine Bedeutung. Hier bedeutet q0 "Drehkreuz verriegelt" und q1 "Drehkreuz entriegelt". Die Zahl ist nur eine Kennung: q0 ist nicht automatisch der Anfangs- oder aktuelle Zustand.',
    'statesStory.step.05':
        'Die Hervorhebung zeigt, was der Automat gerade weiß: q0 ist aktiv, also ist das Drehkreuz verriegelt.',
    'statesStory.step.06':
        'Jetzt steuerst du das Drehkreuz! Achte auf den aktuellen Knoten, wirf eine Münze ein und lass eine Person hindurch. Das Drehkreuz öffnet und verriegelt danach automatisch.',
    'statesStory.step.07':
        'Für einen endlichen Automaten (FSM) ist vor allem wichtig, in welchem Knoten er sich gerade befindet. Nur der aktuelle Knoten bestimmt, wie der Automat auf Ereignisse reagiert und welche Werte er ausgibt.',
    'statesStory.step.08':
        'Noch vor dem ersten Ereignis braucht der Automat einen Startpunkt. Der Pfeil "RESET" markiert den Anfangsknoten - bei unserem Drehkreuz ist das q0.',
    'statesStory.step.09':
        'Der Pfeil "RESET" ist in jedem Automaten vorhanden. Er bringt den Automaten immer zum Anfangsknoten zurück, unabhängig davon, was vorher passiert ist. Ohne diesen Pfeil ist der Automat nicht gültig.',
    'statesStory.step.10':
        'Experimentiere erneut: Wechsle zu q1 und drücke dann Reset. Unabhängig von der Vorgeschichte wird q0 - das verriegelte Drehkreuz - wieder aktuell.',
    'statesStory.step.11':
        'Unsere Automaten erzeugen Ausgaben. In einer Moore-FSM gehört die Ausgabe zum Zustand: q0 gibt STOPP aus, q1 dagegen GEHEN. Die Legende darunter erklärt weiterhin beide Kennungen.',
    'statesStory.step.12':
        'Welcher Zustand zeigt an, dass eine Person durch das Drehkreuz gehen darf? Nutze die Legende und tippe den Knoten an, in dem das Drehkreuz den Durchgang erlaubt.',
    'statesStory.step.13':
        'Wenn der Automat den Knoten q1 erreicht, gibt er "GEHEN" aus. Die Ausgabe des Automaten wird mit dem Buchstaben "y" bezeichnet. Bei einem Moore-Automaten hängt die Ausgabe nur vom aktuellen Zustand ab.',
    'statesStory.step.14':
        'Endliche Automaten können Ausgaben auf zwei verbreitete Arten erzeugen. Beim Moore-Automaten gehört die Ausgabe zum aktuellen Zustand, beim Mealy-Automaten zu einer Transition.',
    'statesStory.step.15':
        'Achte auf die Schreibweise: Bei Moore steht die Ausgabe am Zustand, etwa q0 / STOPP. Bei Mealy steht Eingabe / Ausgabe am Pfeil, etwa Münze / GEHEN.',
    'statesStory.step.16':
        'Probiere die Mealy-Transition selbst aus. Beim Einwurf einer Münze wechselt der Automat den Zustand und gibt gleichzeitig GEHEN aus.',
    'statesStory.step.17':
        'Verfolgen wir den Ablauf: Reset ergibt q0/STOPP, eine Münze q1/GEHEN und der Durchgang führt wieder zu q0/STOPP.',
    'statesStory.step.18':
        'Das ist dein Zustands-Werkzeugkasten: Anfang zeigt den Start, aktuell zeigt die momentane Position, und Ausgaben können zu Zuständen oder Transitionen gehören.',
    'statesStory.step.19':
        'Sehr gut - du kannst Zustände verfolgen und Moore von Mealy unterscheiden! Zum Abschluss folgen sechs kurze Fragen. Antworten beim ersten Versuch bestimmen deine Sterne.',
    'statesStory.teachMe': 'Zeig es mir',
    'statesStory.next': 'Weiter',
    'statesStory.startTasks': '6 Fragen starten',
    'statesStory.state': 'Zustand',
    'statesStory.meaning.q0': 'q0 = "Drehkreuz verriegelt"',
    'statesStory.meaning.q1': 'q1 = "Drehkreuz entriegelt"',
    'statesStory.event': 'Ereignis',
    'statesStory.snapshotTitle': 'Ein Automat, zwei mögliche Zustände',
    'statesStory.locked': 'Locked',
    'statesStory.unlocked': 'Unlocked',
    'statesStory.coin': 'Münze einwerfen',
    'statesStory.passage': 'Durchgehen',
    'statesStory.coinShort': 'coin',
    'statesStory.passageShort': 'passage',
    'statesStory.current': 'Aktueller Zustand',
    'statesStory.initial': 'Anfangszustand',
    'statesStory.output': 'Zustandsausgabe',
    'statesStory.output.locked': 'y = STOP',
    'statesStory.output.unlocked': 'y = GO',
    'statesStory.sim.ready':
        'Der aktuelle Zustand ist Verriegelt. Probiere Münze oder Durchgang.',
    'statesStory.sim.coinUnlocked':
        'Münze akzeptiert: Das Drehkreuz öffnet automatisch; der aktuelle Zustand ist jetzt Entriegelt.',
    'statesStory.sim.alreadyUnlocked':
        'Das Drehkreuz war bereits entriegelt; eine weitere Münze ändert den Zustand nicht.',
    'statesStory.sim.passageLocked':
        'Ein Durchgang kann ein verriegeltes Drehkreuz nicht öffnen. Der Zustand bleibt Verriegelt.',
    'statesStory.sim.passageLockedAgain':
        'Die Person ist durchgegangen; das Drehkreuz schließt und verriegelt sich automatisch wieder.',
    'statesStory.sim.resetLocked':
        'Reset ignoriert die Vorgeschichte und macht Verriegelt aktuell.',
    'statesStory.memoryTitle': 'Lange Geschichte → kleines Gedächtnis',
    'statesStory.memory.coin': 'Münze',
    'statesStory.memory.passage': 'Durchgang',
    'statesStory.memoryRelevant': 'Jetzt relevant: Entriegelt',
    'statesStory.memoryExplanation':
        'Zukünftiges Verhalten hängt vom aktuellen Zustand ab, nicht von jedem vergangenen Ereignis.',
    'statesStory.initialTitle': 'Was macht einen Zustand zum Anfang?',
    'statesStory.initialFact.1':
        'Er ist vor der ersten normalen Eingabe aktiv.',
    'statesStory.initialFact.2':
        'Der Reset-/Startpfeil zeigt auf diesen Zustand.',
    'statesStory.initialFact.3':
        'In dieser FSM gibt es einen festgelegten Anfangszustand.',
    'statesStory.outputPicker.title': 'Welcher Zustand gibt GEHEN aus?',
    'statesStory.outputPicker.prompt':
        'Tippe den Zustand an, in dem der Durchgang erlaubt ist.',
    'statesStory.outputPicker.locked':
        'Verriegelt sollte STOPP ausgeben. Probiere den anderen Zustand.',
    'statesStory.outputPicker.unlocked': 'Richtig! Entriegelt gibt GEHEN aus.',
    'statesStory.moore.title': 'Moore-Automat',
    'statesStory.moore.description':
        'Die Ausgabe gehört zum aktuellen Zustand.',
    'statesStory.mealy.title': 'Mealy-Automat',
    'statesStory.mealy.description':
        'Die Ausgabe gehört zur ausgelösten Transition.',
    'statesStory.output.stop': 'y = STOP',
    'statesStory.output.go': 'y = GO',
    'statesStory.moore.transition': 'coin',
    'statesStory.mealy.transition': 'coin / GO',
    'statesStory.placement.title': 'Wo wird die Ausgabe notiert?',
    'statesStory.placement.state': 'Am Zustand',
    'statesStory.placement.transition': 'An der Transition',
    'statesStory.placement.correct':
        'Genau! Moore → Zustand, Mealy → Transition.',
    'statesStory.placement.wrong':
        'Fast. Bei Moore stehen Ausgaben an Zuständen, bei Mealy an Transitionen.',
    'statesStory.mealy.simulationTitle': 'Eine Mealy-Transition ausführen',
    'statesStory.mealy.simulationRun': 'Münze einwerfen',
    'statesStory.mealy.simulationReset': 'Beispiel zurücksetzen',
    'statesStory.mealy.simulationFeedback':
        'Münze / GEHEN wurde ausgeführt: Der Automat gibt GEHEN aus und wechselt zu Entriegelt.',
    'statesStory.trace.reset': 'Reset',
    'statesStory.trace.coin': 'Münze',
    'statesStory.trace.passage': 'Durchgang',
    'statesStory.trace.next': 'Nächste Eingabe anwenden',
    'statesStory.trace.restart': 'Ablauf neu starten',
    'statesStory.rolesTitle': 'Das Wichtigste über Zustände',
    'statesStory.roles.initial':
        'Der festgelegte Startpunkt vor der normalen Eingabe.',
    'statesStory.roles.current': 'Der eine Zustand, der gerade aktiv ist.',
    'statesStory.roles.output':
        'Der Wert, den der Automat ausgibt, solange dieser Zustand aktuell ist.',
    'statesStory.rolesOverlap':
        'In einer Moore-FSM ändert sich mit dem aktuellen Zustand auch die Ausgabe.',
    'statesStory.readyTitle': 'Zustandslektion abgeschlossen',
    'statesStory.readyBody':
        'Sechs Fragen prüfen Zustände, Abläufe, Ausgaben und den Unterschied zwischen Moore und Mealy.',
    'concept.stateOutput': 'Zustandsausgabe',
    'concept.mooreMealy': 'Moore- und Mealy-Ausgaben',
    'answer.nodeQ0': 'q0',
    'answer.nodeQ1': 'q1',
    'answer.nodeQ2': 'q2',
    'answer.transitionA': 'Pfeil "a"',
    'answer.resetArrow': 'Pfeil "RESET"',
    'answer.transitionQ0AQ1': 'q0 -"a"→ q1',
    'answer.transitionQ0AQ2': 'q0 -"a"→ q2',
    'answer.lockedState': '"Locked"',
    'answer.unlockedState': '"Unlocked"',
    'answer.bothStates': 'Beide Zustände gleichzeitig',
    'answer.outputBelongsToState': 'Die Ausgabe gehört zum aktuellen Zustand',
    'answer.outputBelongsToTransition':
        'Die Ausgabe gehört nur zum Übergangspfeil',
    'answer.outputOnlyAtEnd':
        'Die Ausgabe existiert erst nach der gesamten Eingabe',
    'answer.mooreStateMealyTransition':
        'Moore: an Zuständen; Mealy: an Transitionen',
    'answer.mooreTransitionMealyState':
        'Moore: an Transitionen; Mealy: an Zuständen',
    'answer.bothOutputsOnStates':
        'Beide Automaten notieren Ausgaben an Zuständen',
    'answer.goOutput': '"GO"',
    'answer.stopOutput': '"STOP"',
    'answer.noOutput': 'Keine Ausgabe',
    'task.states.nodes.prompt': 'Wähle alle Knoten im FSM-Diagramm aus.',
    'task.states.nodes.instruction':
        'Du darfst mehrere Antworten auswählen. Markiere nur Elemente, die Knoten sind.',
    'task.states.nodes.hint':
        'Knoten werden als Kreise gezeichnet. Pfeile und die RESET-Markierung sind keine Knoten.',
    'task.states.initial.prompt':
        'Sieh dir das Diagramm an. Ist q0 korrekt als Anfangsknoten festgelegt?',
    'task.states.initial.instruction':
        'Untersuche das Diagramm und wähle Wahr oder Falsch.',
    'task.states.initial.hint':
        'Der Knoten, auf den "RESET" zeigt, ist der Anfangsknoten.',
    'task.states.trace.prompt':
        'Starte bei "RESET" und wende dann "coin" und "passage" an. Welcher Knoten ist nach diesen beiden Eingaben aktuell?',
    'task.states.trace.instruction':
        'Behalte nach jedem Schritt genau einen aktuellen Zustand.',
    'task.states.trace.hint':
        'Nach "coin" ist das Drehkreuz "Unlocked"; "passage" verriegelt es wieder automatisch.',
    'task.states.trace.step.1': '"RESET": aktuell = "Locked"',
    'task.states.trace.step.2': '"coin": aktuell = "Unlocked"',
    'task.states.trace.step.3': '"passage": aktuell = "Locked"',
    'task.states.trace.feedback.unlocked':
        '"Unlocked" ist nur der Zwischenzustand nach "coin"; "passage" führt zurück zu "Locked".',
    'task.states.trace.feedback.both':
        'In diesem deterministischen Beispiel gibt es immer genau einen aktuellen Zustand.',
    'task.states.output.prompt':
        'Wo wird die Ausgabe in den hier verwendeten Moore-FSMs definiert?',
    'task.states.output.instruction':
        'Verbinde den ausgegebenen Wert mit dem aktuellen Zustand.',
    'task.states.output.hint':
        'Wenn sich der aktuelle Zustand ändert, ändert sich auch die Moore-Ausgabe.',
    'task.states.output.feedback.transition':
        'Das wäre eine Mealy-Ausgabe. Hier gehört die Ausgabe zu einem Zustand.',
    'task.states.output.feedback.end':
        'Der aktuelle Zustand hat immer eine Ausgabe, nicht erst nach der gesamten Eingabe.',
    'task.states.mooreMealy.prompt':
        'Wo werden Ausgaben bei Moore- und Mealy-Automaten notiert?',
    'task.states.mooreMealy.instruction':
        'Ordne jedem Automatentyp das Diagrammelement zu, das seine Ausgabe trägt.',
    'task.states.mooreMealy.hint':
        'Moore reagiert über Zustände; bei Mealy steht Eingabe / Ausgabe am Pfeil.',
    'task.states.mooreMealy.feedback.reversed':
        'Die Zuordnung ist vertauscht: Moore nutzt Zustände, Mealy Transitionen.',
    'task.states.mooreMealy.feedback.bothStates':
        'Nur Moore bindet Ausgaben an Zustände. Bei Mealy gehören sie zu Transitionen.',
    'task.states.mealyOutput.prompt':
        'Sieh dir das Mealy-Diagramm an. In q0 wird "coin" eingeworfen. Welche Ausgabe entsteht?',
    'task.states.mealyOutput.instruction':
        'Lies die Beschriftung der Transition als Eingabe / Ausgabe.',
    'task.states.mealyOutput.hint':
        'Bei "coin / GO" ist der Teil hinter dem Schrägstrich die Ausgabe.',
    'task.states.mealyOutput.step.1': 'Aktueller Zustand: "Locked"',
    'task.states.mealyOutput.step.2': 'Eingabe: "coin"',
    'task.states.mealyOutput.feedback.stop':
        '"STOP" gehört zum verriegelten Moore-Zustand aus dem Beispiel. Dieser Mealy-Pfeil gibt ausdrücklich "GO" aus.',
    'task.states.mealyOutput.feedback.none':
        'Eine Mealy-Ausgabe entsteht beim Ausführen der Transition; hier wird "coin / GO" ausgeführt.',
    'transitionsStory.step.01':
        'Zustände beschreiben die aktuelle Situation. Transitionen sind Regeln, die die FSM von einer Situation zur nächsten bewegen. Erinnerst du dich, was ein Pfeil aussagt?',
    'transitionsStory.step.02':
        'Jede Transition beantwortet drei Fragen: Wo starten wir? Welcher Auslöser ist eingetreten? Welcher Zustand wird als Nächstes aktuell?',
    'transitionsStory.step.03':
        'Lesen wir eine Regel: Verriegelt -Münze→ Entriegelt. Tippe jeden Teil an, damit ich seine Aufgabe erkläre.',
    'transitionsStory.step.04':
        'Eine Transition ist gerichtet. Der Pfeil beginnt am Ausgangszustand und zeigt auf den Zielzustand. Rückwärts gelesen entsteht eine andere Regel.',
    'transitionsStory.step.05':
        'Prüfe die Richtung selbst. Der Automat ist Verriegelt und eine Münze wird eingeworfen. Welche Lesart folgt dem Pfeil?',
    'transitionsStory.step.06':
        'Die Beschriftung über einem Pfeil ist Auslöser oder Eingabe. Das kann ein Tastendruck, ein abgelaufener Timer oder ein Symbol wie 0 oder 1 sein.',
    'transitionsStory.step.07':
        'Ein Auslöser wird vom aktuellen Ausgangszustand aus geprüft. In einem anderen aktuellen Zustand kann dasselbe Ereignis anders oder gar nicht wirken.',
    'transitionsStory.step.08':
        'Eine FSM darf nur tatsächlich definierte Transitionen nutzen. Gibt es A → B, aber keinen Pfeil A → C, darf der Automat diese Abkürzung nicht erfinden.',
    'transitionsStory.step.09':
        'Erinnerst du dich an unsere deutsche Ampel? Vier Timerregeln bilden einen Zyklus: Rot, Rot-gelb, Grün, Gelb und zurück zu Rot.',
    'transitionsStory.step.10':
        'Steuere die Ampel selbst. Der hervorgehobene Pfeil ist die einzige verfügbare Timer-Transition des aktuellen Zustands.',
    'transitionsStory.step.11':
        'Betrachte diese Regel: Rot -60 Sekunden→ Rot-gelb. Ausgang, Auslöser, Richtung und Ziel bilden gemeinsam eine vollständige Transition.',
    'transitionsStory.step.12':
        'Verfolge mehrere Transitionen. Aktualisiere nach jedem Auslöser zuerst den aktuellen Zustand und suche erst dann dessen nächsten Pfeil.',
    'transitionsStory.step.13':
        'Eine Transition darf zum selben Zustand zurückführen. Das ist eine Selbstschleife. Drücken kann eine verriegelte Tür in Verriegelt lassen.',
    'transitionsStory.step.14':
        'In einer deterministischen FSM dürfen ein Ausgangszustand und ein Auslöser höchstens ein Ziel bestimmen. Zwei verschiedene Ziele erzeugen einen Konflikt.',
    'transitionsStory.step.15':
        'Prüfe bei jeder Transition Ausgang, Auslöser, Pfeilrichtung und Ziel. Stelle danach sicher, dass die Regel definiert und konfliktfrei ist.',
    'transitionsStory.step.16':
        'Sehr gut - du kannst Transitionen lesen, simulieren und Fehler finden! Fünf Fragen prüfen die gesamte Lektion samt Ampelzyklus.',
    'transitionsStory.teachMe': 'Zeig es mir',
    'transitionsStory.startTasks': '5 Fragen starten',
    'transitionsStory.formulaTitle':
        'Eine Transition ist eine gerichtete Regel',
    'transitionsStory.source': 'Ausgangszustand',
    'transitionsStory.trigger': 'Auslöser / Eingabe',
    'transitionsStory.target': 'Zielzustand',
    'transitionsStory.explorerTitle': 'Verriegelt - Münze → Entriegelt',
    'transitionsStory.locked': 'Verriegelt',
    'transitionsStory.coin': 'Münze',
    'transitionsStory.unlocked': 'Entriegelt',
    'transitionsStory.push': 'Drücken',
    'transitionsStory.explorerPrompt': 'Tippe eine der drei Komponenten an.',
    'transitionsStory.explorer.source':
        'Verriegelt ist der Ausgang: Die Regel gilt nur, wenn Verriegelt aktuell ist.',
    'transitionsStory.explorer.trigger':
        'Münze ist der Auslöser: Dieses Ereignis aktiviert die Regel.',
    'transitionsStory.explorer.target':
        'Entriegelt ist das Ziel und wird nach der Transition aktuell.',
    'transitionsStory.directionCaption':
        'Folge der Pfeilspitze: Verriegelt → Entriegelt, nicht umgekehrt.',
    'transitionsStory.directionQuestion':
        'Welche Richtung passt zu Verriegelt -Münze→ Entriegelt?',
    'transitionsStory.direction.correct': 'Von Verriegelt zu Entriegelt',
    'transitionsStory.direction.reversed': 'Von Entriegelt zu Verriegelt',
    'transitionsStory.direction.correctFeedback':
        'Richtig. Die Pfeilspitze zeigt auf Entriegelt.',
    'transitionsStory.direction.wrongFeedback':
        'So liest du den Pfeil rückwärts und vertauschst Ausgang und Ziel.',
    'transitionsStory.triggerTitle': 'Ein Auslöser aktiviert eine Regel',
    'transitionsStory.trigger.button': 'Taste gedrückt',
    'transitionsStory.trigger.timer': 'Timer abgelaufen',
    'transitionsStory.trigger.symbol': 'Symbol 0 oder 1',
    'transitionsStory.triggerCaption':
        'Die Pfeilbeschriftung sagt, wann die Transition ausgelöst werden darf.',
    'transitionsStory.sourceRule.locked':
        'Von Verriegelt kann eine Münze zu Entriegelt führen.',
    'transitionsStory.sourceRule.unlocked':
        'Von Entriegelt nutzt dieselbe Münze nicht automatisch die Verriegelt-Regel.',
    'transitionsStory.toggleCurrent': 'Aktuellen Zustand wechseln',
    'transitionsStory.definedCaption':
        'A erreicht B, weil ein Pfeil existiert. Ohne A → C ist C kein erlaubter nächster Zustand.',
    'transitionsStory.traffic.red': 'ROT',
    'transitionsStory.traffic.redYellow': 'ROT-GELB',
    'transitionsStory.traffic.green': 'GRÜN',
    'transitionsStory.traffic.yellow': 'GELB',
    'transitionsStory.traffic.advance': '{seconds}-Sekunden-Timer auslösen',
    'transitionsStory.trace.0':
        'Start in Rot. Suche die ausgehende Regel für 60 Sekunden.',
    'transitionsStory.trace.1':
        'Nach 60 Sekunden: aktuell = Rot-gelb. Nächster Auslöser: 10 Sekunden.',
    'transitionsStory.trace.2':
        'Nach 10 Sekunden: aktuell = Grün. Nächster Auslöser: 60 Sekunden.',
    'transitionsStory.trace.3':
        'Nach 60 Sekunden: aktuell = Gelb. Die Spur folgte immer genau einer Regel.',
    'transitionsStory.trace.next': 'Nächste Transition anwenden',
    'transitionsStory.trace.restart': 'Ablauf neu starten',
    'transitionsStory.selfLoopCount':
        'Verarbeitete Drück-Ereignisse: {count}. Aktuell bleibt Verriegelt.',
    'transitionsStory.determinism.source': 'Ausgang',
    'transitionsStory.determinism.targetA': 'Ziel A',
    'transitionsStory.determinism.targetB': 'Ziel B',
    'transitionsStory.determinism.sameInput': 'gleiche\nEingabe',
    'transitionsStory.determinism.check': 'Regeln prüfen',
    'transitionsStory.determinism.feedback':
        'Konflikt: Für diesen Ausgang und diese Eingabe gibt es kein eindeutig vorhersagbares Ziel.',
    'transitionsStory.summaryTitle': 'Transitions-Checkliste',
    'transitionsStory.summary.source':
        'Beginne beim aktuellen Ausgangszustand.',
    'transitionsStory.summary.trigger':
        'Vergleiche das Ereignis mit der Pfeilbeschriftung.',
    'transitionsStory.summary.direction':
        'Folge dem Pfeil in der gezeichneten Richtung.',
    'transitionsStory.summary.target':
        'Mache den Zielzustand zum aktuellen Zustand.',
    'transitionsStory.summary.determinism':
        'Vermeide zwei Ziele für denselben Ausgang und Auslöser.',
    'transitionsStory.readyTitle': 'Transitionslektion abgeschlossen',
    'transitionsStory.readyBody':
        'Fünf Fragen prüfen Pfeile, Richtung, definierte Wege, Ampelspur und Determinismus.',
    'answer.lockedCoinUnlocked': 'Locked -"coin"→ Unlocked',
    'answer.unlockedCoinLocked': 'Unlocked -"coin"→ Locked',
    'answer.lockedPushUnlocked': 'Locked -"passage"→ Unlocked',
    'answer.arrowSourceToTarget': 'Vom Ausgang zum Ziel',
    'answer.arrowTargetToSource': 'Vom Ziel zurück zum Ausgang',
    'answer.arrowHasNoDirection': 'Ein Pfeil hat keine Richtung',
    'answer.trafficGreen': '"GREEN"',
    'answer.trafficRedYellow': '"RED-YELLOW"',
    'answer.trafficYellow': '"YELLOW"',
    'answer.onlyExistingTransition':
        'Nur einer vorhandenen Transition des aktuellen Zustands folgen',
    'answer.anyDesiredState': 'Zu jedem gewünschten Zustand springen',
    'answer.skipIntermediateState':
        'Einen Zwischenzustand auch ohne Pfeil überspringen',
    'answer.deterministicConflict':
        'Gleicher Ausgang und gleiche Eingabe führen zu zwei Zielen',
    'answer.validSelfLoop': 'Eine Transition führt zu ihrem Ausgang zurück',
    'answer.missingInitialState':
        'Die Transition erwähnt den Anfangszustand nicht',
    'task.transitions.reading.prompt':
        'Verfolge das Diagramm für die Eingabe "coin". Welcher Knoten ist am Anfang und welcher danach aktuell?',
    'task.transitions.reading.instruction':
        'Wähle für beide Schritte des Ablaufs den aktuellen Knoten.',
    'task.transitions.reading.hint':
        'Beginne bei q0 und folge dem Pfeil "coin" zu q1.',
    'task.transitions.reading.feedback.reversed':
        'Das vertauscht Ausgang und Ziel, weil der Pfeil rückwärts gelesen wird.',
    'task.transitions.reading.feedback.trigger':
        'Die Richtung stimmt, aber die Beschriftung ist "coin", nicht "passage".',
    'task.transitions.direction.prompt':
        'Welche Richtung beschreibt ein Transitionspfeil?',
    'task.transitions.direction.instruction':
        'Orientiere dich an Pfeilanfang und Pfeilspitze.',
    'task.transitions.direction.hint':
        'Die Pfeilspitze berührt den Zustand, der als Nächstes aktuell wird.',
    'task.transitions.direction.feedback.reversed':
        'Der Pfeil zeigt vom Ausgang weg und zum Ziel hin.',
    'task.transitions.direction.feedback.none':
        'Die Richtung ist wesentlich: Ein umgekehrter Pfeil ist eine andere Regel.',
    'task.transitions.traffic.prompt':
        'Ampel-FSM: Start Rot, dann 60 Sekunden und 10 Sekunden. Welcher Zustand ist aktuell?',
    'task.transitions.traffic.instruction':
        'Folge pro Schritt genau einer ausgehenden Timer-Transition.',
    'task.transitions.traffic.hint':
        '60 Sekunden führen zu Rot-gelb; wende dann die 10-Sekunden-Regel an.',
    'task.transitions.traffic.step.1': 'Start: Rot',
    'task.transitions.traffic.step.2': '60 Sekunden: Rot → Rot-gelb',
    'task.transitions.traffic.step.3': '10 Sekunden: Rot-gelb → Grün',
    'task.transitions.traffic.feedback.redYellow':
        'Rot-gelb ist nur der Zwischenzustand nach dem ersten Timer.',
    'task.transitions.traffic.feedback.yellow':
        'Gelb folgt später im Zyklus erst nach Grün.',
    'task.transitions.defined.prompt':
        'Wie darf eine FSM ihren nächsten Zustand wählen?',
    'task.transitions.defined.instruction':
        'Nutze nur Regeln, die für den aktuellen Zustand definiert sind.',
    'task.transitions.defined.hint':
        'Kein Pfeil bedeutet: Diese Transition existiert nicht.',
    'task.transitions.defined.feedback.any':
        'Eine FSM folgt Regeln und darf kein beliebiges Ziel wählen.',
    'task.transitions.defined.feedback.skip':
        'Überspringen braucht eine eigene direkte Transition. Ohne sie ist der Weg ungültig.',
    'task.transitions.determinism.prompt':
        'Wähle beide Transitionen aus, die den Determinismuskonflikt erzeugen.',
    'task.transitions.determinism.instruction':
        'Finde die zwei Pfeile mit demselben Ausgang und derselben Eingabe, aber unterschiedlichen Zielen.',
    'task.transitions.determinism.hint':
        'Beide Konfliktpfeile verlassen q0 mit der Eingabe "a".',
    'task.transitions.determinism.feedback.selfLoop':
        'Eine Selbstschleife ist eine gültige Transition zurück zum selben Zustand.',
    'task.transitions.determinism.feedback.initial':
        'Eine normale Transition muss den Anfangszustand nicht erwähnen.',
    'mascot.intro.greeting': 'Schön, dich zu sehen.',
    'mascot.intro.greeting.username': 'Schön, dich zu sehen, {username}!',
    'mascot.intro.identity':
        'Ich begleite dich durch FSM Quest, helfe dir bei neuen Ideen und zeige dir, wo du deinen Lernfortschritt findest.',
    'mascot.intro.mission':
        'Gemeinsam lernen wir endliche Automaten Schritt für Schritt: von ihren Grundbausteinen bis zum Lesen, Erstellen und Prüfen von Automaten. Zuerst zeige ich dir, wie die App aufgebaut ist.',
    'mascot.intro.lessonPath':
        'Hier ist dein Lernpfad. Beginne mit der hervorgehobenen Lektion. Löse ihre Aufgaben, damit die nächsten Schritte freigeschaltet werden. Wenn du Hilfe brauchst, bin ich da.',
    'mascot.intro.sandbox':
        'Das ist die Sandbox, unsere kleine Werkstatt. Baue Automaten, ändere sie und schau, was passiert - hier geht es ums Ausprobieren, nicht um Noten.',
    'mascot.intro.progress':
        'Hier siehst du deine XP, Sterne, gelöste Aufgaben und deine Lernserie. So erkennst du, wie weit du schon gekommen bist.',
    'mascot.intro.settings':
        'Hier kannst du die Sprache ändern und zwischen hellem und dunklem Design wechseln. Das lässt sich jederzeit anpassen.',
    'mascot.intro.languages':
        'Wähle die Sprache, in der du dich am wohlsten fühlst: English, Deutsch oder Русский. Du kannst sie später in den Einstellungen ändern.',
    'mascot.intro.returnHome':
        'Alles bereit! Wir gehen zurück zum Lernpfad. Als Nächstes zeige ich dir kurz die Kapitel.',
    'mascot.chapterTour.intro':
        'Schauen wir uns nun die Kapitel an. Ich scrolle sie durch, damit du siehst, wie sich unser Lernweg aufbaut. Du kannst die Tour jederzeit überspringen.',
    'mascot.chapterTour.summary':
        'So sieht unser Weg aus: Wir beginnen mit den Grundlagen und wenden sie später auf anspruchsvollere Automaten an. Jetzt gehen wir zum Anfang zurück und wählen unseren Startpunkt.',
    'mascot.chapterTour.skip': 'Tour überspringen',
    'mascot.chapterTour.progress': 'Kapitel {chapter} von {total}',
    'mascot.chapter1.intro':
        'In Kapitel 1 lernen wir die Grundlagen endlicher Automaten kennen: Zustände und Übergänge anhand anschaulicher Beispiele. Am Ende schauen wir gemeinsam, was du schon kannst.',
    'mascot.chapter1.choice.title': 'Bereit für Kapitel 1?',
    'mascot.chapter1.choice.body':
        'Wenn du die Grundlagen endlicher Automaten schon kennst, kannst du Kapitel 1 überspringen und jederzeit später nachholen.',
    'mascot.chapter1.choice.start': 'Kapitel 1 beginnen',
    'mascot.chapter1.choice.skip': 'Überspringen',
    'mascot.chapter1.skip.confirmTitle': 'Kapitel 1 überspringen?',
    'mascot.chapter1.skip.confirmBody':
        'Möchtest du Kapitel 1 wirklich überspringen? Dafür erhältst du weder Sterne noch XP. Das Kapitel bleibt auf der Karte und kann später absolviert werden. Kapitel 2 wird sofort freigeschaltet.',
    'mascot.chapter1.skip.return': 'Zurück',
    'mascot.chapter1.skip.confirm': 'Ja, Kapitel 1 überspringen',
    'mascot.chapter1.startHandoff':
        'Super! Tippe auf die hervorgehobene erste Lektion, dann legen wir los.',
    'mascot.chapter2.skipHandoff':
        'Du kennst die Grundlagen schon? Dann halte ich dich nicht länger an der roten Ampel auf - wir gehen direkt zu anspruchsvolleren Themen! Tippe auf die hervorgehobene Lektion in Kapitel 2.',
    'path.chapter1.skipped': 'Übersprungen',
    'mascot.fallback':
        'Hallo, ich bin Fini und begleite dich beim Lernen. Beginne mit der ersten Lektion - ich helfe dir Schritt für Schritt weiter.',
    'transitionsDoorStory.step.01':
        'Willkommen zur dritten Lektion! Hier lernen wir Moore- und Mealy-Automaten genauer kennen und verstehen besser, worin sie sich unterscheiden.',
    'transitionsDoorStory.step.02':
        'Eine Person nähert sich der automatischen Tür. Welchen Befehl soll die Steuerung geben, wenn der Anwesenheitssensor 1 wird?',
    'transitionsDoorStory.step.03':
        'Der Sensorwert person ist die Eingabe. Der Motorbefehl ist die Ausgabe. Ordne beide Signale ein, bevor wir einen Automaten bauen.',
    'transitionsDoorStory.step.04':
        'Bevor wir formale Bezeichnungen schreiben, sehen wir uns die zwei physischen Situationen an: Die Tür ist geschlossen oder geöffnet. Diese Bilder werden später zu FSM-Knoten.',
    'transitionsDoorStory.step.05':
        'Die Steuerung muss die Türposition speichern. Wir beginnen mit DOOR IS CLOSED und DOOR IS OPEN; ein separater Antrieb führt die Bewegung aus.',
    'transitionsDoorStory.step.06':
        'Die Tür kann beim Start der Steuerung bereits offen sein. Erstelle zuerst DOOR IS OPEN mit der Ausgabe OPEN DOOR und markiere den Knoten mit dem Reset-Pfeil.',
    'transitionsDoorStory.step.07':
        'Auch eine geschlossene Tür muss dargestellt werden. Ergänze DOOR IS CLOSED mit CLOSE DOOR. Das ist die sichere Startposition, deshalb zeigt der Reset-Pfeil nun dorthin.',
    'transitionsDoorStory.step.08':
        'Ist die Tür offen und person wird 0, steht niemand im Durchgang. Ergänze die Transition zu DOOR IS CLOSED, damit die Ausgabe zu CLOSE DOOR wird.',
    'transitionsDoorStory.step.09':
        'Ist die Tür geschlossen und person wird 1, ist jemand angekommen. Ergänze die Transition zu DOOR IS OPEN. Der Moore-Automat ist jetzt vollständig.',
    'transitionsDoorStory.step.10':
        'Starte den vollständigen Moore-Automaten. Achte auf die Reihenfolge: Eingabe, Transition, neuer Zustand, dann die dort gespeicherte Ausgabe.',
    'transitionsDoorStory.step.11':
        'Für die Umwandlung in Mealy dürfen Ausgaben nicht in den Knoten bleiben: Mealy schreibt sie auf Transitionen. Entferne zuerst beide Zustandsausgaben.',
    'transitionsDoorStory.step.12':
        'Ohne Zustandsausgaben warten beide Knoten nur auf denselben Sensor; in diesem vereinfachten Modell ist kein getrennter Positionsspeicher nötig. Fasse sie zu WAIT zusammen.',
    'transitionsDoorStory.step.13':
        'Bei person = 1 muss Mealy sofort das Öffnen befehlen. Ergänze an WAIT die Schleife person = 1 / OPEN DOOR.',
    'transitionsDoorStory.step.14':
        'Bei person = 0 wird die Gegenreaktion benötigt. Ergänze person = 0 / CLOSE DOOR. Die Umwandlung in Mealy ist abgeschlossen.',
    'transitionsDoorStory.step.15':
        'Starte den Mealy-Automaten. Der Zustand bleibt WAIT, während jede Eingabe sofort die Ausgabe ihrer Transition auswählt.',
    'transitionsDoorStory.step.16':
        'Vergleiche beide Lösungen: Moore setzt die Aktion in einen Zustand, Mealy in die Reaktion auf eine Eingabe.',
    'transitionsDoorStory.step.17':
        'Das Modell mit zwei Zuständen war absichtlich vereinfacht. Echte Bewegung braucht Zeit; deshalb können DOOR IS CLOSED, DOOR IS OPENING, DOOR IS OPEN und DOOR IS CLOSING nötig sein.',
    'transitionsDoorStory.step.18':
        'Du kennst jetzt den Unterschied und seine Grenze: Mealy braucht oft weniger Zustände, aber nur ohne zusätzlichen Speicherbedarf.',
    'transitionsDoorStory.startTasks': 'Übungen starten',
    'transitionsDoorStory.readyTitle': 'Die automatische Tür ist bereit!',
    'transitionsDoorStory.readyBody':
        'Zwei Theoriefragen und sechs praktische Aufgaben prüfen Diagramme, Fehler, Änderungen, Abläufe und den FSM-Aufbau.',
    'transitionsStory.welcome.title': 'Dritte Lektion',
    'transitionsStory.welcome.models': 'Moore • Mealy',
    'transitionsStory.automaticDoor': 'Automatische Schiebetür',
    'transitionsStory.sensorTitle': 'Der Sensor liefert die Eingabe',
    'transitionsStory.sensorCaption':
        'Die Steuerung sieht keine Person direkt - sie erhält eine Sensoreingabe und folgt der passenden Transition.',
    'transitionsStory.input.person': 'Person erkannt',
    'transitionsStory.input.clear': 'Türbereich frei',
    'transitionsStory.input.opened': 'Vollständig geöffnet',
    'transitionsStory.input.closed': 'Vollständig geschlossen',
    'transitionsStory.input.personShort': 'PERSON',
    'transitionsStory.input.clearShort': 'CLEAR',
    'transitionsStory.input.openedShort': 'OPENED',
    'transitionsStory.input.closedShort': 'CLOSED',
    'transitionsStory.output.open': 'OPEN',
    'transitionsStory.output.close': 'CLOSE',
    'transitionsStory.output.stop': 'STOP',
    'transitionsStory.predict.title': 'Deine Prognose',
    'transitionsStory.predict.question':
        'Wie viele Zustände braucht die detaillierte Moore-Tür?',
    'transitionsStory.predict.correct':
        'Genau! Die Tür hat vier verschiedene physische Phasen.',
    'transitionsStory.predict.wrong':
        'Noch nicht. Zähle geschlossen, öffnend, offen und schließend einzeln.',
    'transitionsStory.phases.title': 'Entdecke die Moore-Zustände',
    'transitionsStory.phases.instruction':
        'Tippe auf jede Türphase, um die Ausgabe dieses Zustands aufzudecken.',
    'transitionsStory.phase.closed': 'Geschlossen',
    'transitionsStory.phase.opening': 'Öffnend',
    'transitionsStory.phase.open': 'Offen',
    'transitionsStory.phase.closing': 'Schließend',
    'transitionsStory.phases.complete':
        'Super! Vier Paare aus Phase und Ausgabe können jetzt zu vier Moore-Knoten werden.',
    'transitionsStory.reaction.question':
        'Was soll die Tür tun, wenn eine Person erkannt wird?',
    'transitionsStory.reaction.answer.open': 'Öffnen',
    'transitionsStory.reaction.answer.stay': 'Geschlossen bleiben',
    'transitionsStory.reaction.answer.close': 'Schließen',
    'transitionsStory.reaction.correct':
        'Richtig: person = 1 muss den Motorbefehl OPEN DOOR erzeugen.',
    'transitionsStory.reaction.wrong':
        'Versuche es erneut: Die Person muss durch die Tür gehen können.',
    'transitionsStory.signals.title': 'Was ist Eingabe und was Ausgabe?',
    'transitionsStory.signal.input': 'Eingabe',
    'transitionsStory.signal.output': 'Ausgabe',
    'transitionsStory.signals.correct':
        'Genau: Der Sensor informiert die Steuerung, die Steuerung befiehlt dem Motor.',
    'transitionsStory.signals.wrong':
        'Der Sensor liefert Informationen hinein; der Motorbefehl kommt heraus.',
    'transitionsStory.stateImages.title': 'Erster Blick: die Tür als Bilder',
    'transitionsStory.stateImages.caption':
        'Diese konkreten Bilder zeigen die Situationen, die die Steuerung später mit formalen Zustandsbezeichnungen darstellt.',
    'transitionsStory.states.title': 'Der Automat merkt sich die Türposition',
    'transitionsStory.states.actuatorNote':
        'Vereinfachung: Die Bewegung gilt hier als sofort, oder ein separater Antrieb führt OPEN DOOR bzw. CLOSE DOOR aus.',
    'transitionsStory.construction.progress': 'Schritt {current} von {total}',
    'transitionsStory.mooreSteps.title': 'Aufbau des Moore-Automaten',
    'transitionsStory.mooreSteps.action.openState':
        'Reset-Pfeil und DOOR IS OPEN / OPEN DOOR wurden ergänzt.',
    'transitionsStory.mooreSteps.action.closedState':
        'DOOR IS CLOSED / CLOSE DOOR wurde ergänzt und Reset auf den sicheren Start verschoben.',
    'transitionsStory.mooreSteps.action.closeTransition':
        'DOOR IS OPEN - person = 0 → DOOR IS CLOSED wurde ergänzt.',
    'transitionsStory.mooreSteps.action.openTransition':
        'DOOR IS CLOSED - person = 1 → DOOR IS OPEN wurde ergänzt. Moore ist vollständig.',
    'transitionsStory.mealySteps.title': 'Moore in Mealy umwandeln',
    'transitionsStory.mealySteps.action.removeOutputs':
        'Die Ausgaben wurden aus den Knoten entfernt, weil Mealy sie auf Transitionen speichert.',
    'transitionsStory.mealySteps.action.mergeStates':
        'Gleichwertige Knoten wurden zu WAIT zusammengefasst, weil allein der Sensor den Befehl auswählt.',
    'transitionsStory.mealySteps.action.openTransition':
        'person = 1 / OPEN DOOR wurde als erste WAIT-Schleife ergänzt.',
    'transitionsStory.mealySteps.action.closeTransition':
        'person = 0 / CLOSE DOOR wurde ergänzt. Mealy ist vollständig.',
    'transitionsStory.mooreBuild.title': 'Baue den Moore-Automaten',
    'transitionsStory.mooreBuild.outputsInstruction':
        'Ordne zuerst jedem Zustand eine Ausgabe zu.',
    'transitionsStory.mooreBuild.aa4Instruction':
        'Setze den Moore-Automaten aus Knoten, Transitionen und Startmarkierung zusammen.',
    'transitionsStory.mooreBuild.sandboxInstruction':
        'Erstelle den Automaten im Sandbox: q0 = DOOR IS CLOSED mit CLOSE DOOR, q1 = DOOR IS OPEN mit OPEN DOOR; q0 ist der Startzustand. Ergänze q0 - person = 1 → q1 und q1 - person = 0 → q0.',
    'transitionsStory.mooreBuild.question.closed':
        'Welche Ausgabe weisen wir dem Knoten DOOR IS CLOSED zu?',
    'transitionsStory.mooreBuild.question.open':
        'Welche Ausgabe weisen wir dem Knoten DOOR IS OPEN zu?',
    'transitionsStory.mooreBuild.answerCorrect':
        'Richtig: Der Knoten {state} zeigt jetzt die Ausgabe {output}.',
    'transitionsStory.mooreBuild.answerWrong':
        'Diese Ausgabe passt nicht zur Türposition. Versuche eine andere.',
    'transitionsStory.mooreBuild.transitionsInstruction':
        'Ergänze nun die beiden sensorabhängigen Transitionen.',
    'transitionsStory.mooreBuild.complete':
        'Fertig: Bei Moore stehen die Ausgaben in den Zuständen.',
    'transitionsStory.mooreSim.title': 'Starte den Moore-Automaten',
    'transitionsStory.mooreSim.personAppears': 'person = 1 setzen',
    'transitionsStory.mooreSim.personLeaves': 'person = 0 setzen',
    'transitionsStory.mooreSim.sequence':
        'Eingabe → Transition → neuer Zustand → Zustandsausgabe',
    'transitionsStory.mealyTransform.title': 'Moore in Mealy umwandeln',
    'transitionsStory.mealyTransform.instruction':
        'Verschiebe beide Ausgaben von den Zuständen auf die Eingabereaktionen.',
    'transitionsStory.mealyTransform.aa4Instruction':
        'Baue den umgewandelten Mealy-Automaten mit demselben AA4-Baukasten zusammen.',
    'transitionsStory.mealyTransform.sandboxInstruction':
        'WAIT und die erste Schleife sind bereits vorhanden. Ergänze im Sandbox die fehlende Schleife person = 0 / CLOSE DOOR.',
    'transitionsStory.mealyTransform.move':
        '{output} auf die Transition verschieben',
    'transitionsStory.mealyTransform.complete':
        'Für diese vereinfachte Befehlssteuerung genügt nun ein WAIT-Zustand.',
    'transitionsStory.mealySim.title': 'Starte den Mealy-Automaten',
    'transitionsStory.mealySim.stateStays':
        'WAIT bleibt gleich; Zustand + Eingabe bestimmen sofort die Ausgabe.',
    'transitionsStory.compare.title': 'Moore und Mealy im Vergleich',
    'transitionsStory.compare.moore.states': '2 Zustände in diesem Beispiel',
    'transitionsStory.compare.moore.output': 'Ausgabe im Zustand',
    'transitionsStory.compare.moore.reaction':
        'Ausgabe ändert sich nach Eintritt in einen neuen Zustand',
    'transitionsStory.compare.mealy.states': '1 Zustand in diesem Beispiel',
    'transitionsStory.compare.mealy.output': 'Ausgabe auf der Transition',
    'transitionsStory.compare.mealy.reaction':
        'Zustand und Eingabe bestimmen die Ausgabe',
    'transitionsStory.compare.row.location': 'Wo steht die Ausgabe?',
    'transitionsStory.compare.row.location.moore': 'im Zustand',
    'transitionsStory.compare.row.location.mealy': 'auf der Transition',
    'transitionsStory.compare.row.depends': 'Wovon hängt sie ab?',
    'transitionsStory.compare.row.depends.moore': 'Zustand',
    'transitionsStory.compare.row.depends.mealy': 'Zustand + Eingabe',
    'transitionsStory.compare.row.count': 'Zustände im vereinfachten Beispiel',
    'transitionsStory.errors.title': 'Repariere die vertauschten Ausgaben',
    'transitionsStory.errors.fix': 'Ausgaben korrigieren',
    'transitionsStory.errors.fixed': 'Korrigiert',
    'transitionsStory.errors.complete':
        'Richtig: person = 1 öffnet, person = 0 schließt.',
    'transitionsStory.realistic.title': 'Zurück zum realistischen Modell',
    'transitionsStory.realistic.conclusion':
        'Mealy bedeutet nicht immer weniger Zustände. Muss die Steuerung Bewegung speichern, können DOOR IS OPENING und DOOR IS CLOSING ebenfalls nötig sein.',
    'transitionsStory.ready.title': 'Die Kernidee sitzt',
    'transitionsStory.ready.moore':
        'Die Moore-Ausgabe hängt vom aktuellen Zustand ab.',
    'transitionsStory.ready.mealy':
        'Die Mealy-Ausgabe hängt vom aktuellen Zustand und der Eingabe ab.',
    'transitionsStory.ready.count':
        'Mealy braucht oft weniger Zustände, aber nicht immer.',
    'transitionsStory.ready.keyPhrase':
        'Moore setzt die Aktion in einen Zustand; Mealy in die Reaktion auf eine Eingabe.',
    'transitionsStory.door.open': 'Tür geöffnet',
    'transitionsStory.door.closed': 'Tür geschlossen',
    'transitionsStory.machine.moore': 'Moore-Automat',
    'transitionsStory.machine.mealy': 'Mealy-Automat',
    'transitionsStory.nodeLegend.q0': 'q0 = "Tür geschlossen"',
    'transitionsStory.nodeLegend.q1': 'q1 = "Tür öffnet"',
    'transitionsStory.nodeLegend.mealy.q1': 'q1 = "Tür geöffnet"',
    'transitionsStory.nodeLegend.simple.q0': 'q0 = "Tür geschlossen"',
    'transitionsStory.nodeLegend.simple.q1': 'q1 = "Tür geöffnet"',
    'transitionsStory.nodeLegend.mealy.q0': 'q0 = "WAIT"',
    'transitionsStory.nodeLegend.q2': 'q2 = "Tür geöffnet"',
    'transitionsStory.nodeLegend.q3': 'q3 = "Tür schließt"',
    'transitionsStory.mooreCaption':
        'Moore: Jede Bewegungsphase ist ein Knoten, dessen Ausgabe den Motor steuert.',
    'transitionsStory.mealyCaption':
        'Mealy: Die ausgelöste Transition erzeugt die Ausgabe.',
    'transitionsStory.simulator.mooreOutput':
        'Ausgabe des aktuellen Knotens: {output}',
    'transitionsStory.simulator.mealyOutput':
        'Ausgabe der letzten Transition: {output}',
    'transitionsStory.simulator.applyInput': 'Eingabe {input} anwenden',
    'transitionsStory.comparisonTitle': 'Dieselbe Tür, eine andere Struktur',
    'transitionsStory.comparison.moore':
        'OPEN steht in q1: Beim Moore-Automaten bestimmt der aktuelle Knoten die Ausgabe.',
    'transitionsStory.comparison.mealy':
        'OPEN steht an PERSON / OPEN: Beim Mealy-Automaten erzeugt die ausgelöste Transition die Ausgabe.',
    'transitionsStory.comparison.sameTitle': 'Was gleich bleibt',
    'transitionsStory.comparison.same':
        'Beide setzen dieselbe sichtbare Regel um: für eine Person öffnen, bei freiem Bereich schließen.',
    'transitionsStory.placementTitle': 'Wohin gehört die Ausgabe?',
    'transitionsStory.onNode': 'An den Knoten',
    'transitionsStory.onTransition': 'An die Transition',
    'transitionsStory.placement.correct':
        'Genau: Moore → Knoten, Mealy → Transition.',
    'transitionsStory.placement.retry':
        'Fast! Vergleiche die Knotenbeschriftungen mit Eingabe / Ausgabe an den Pfeilen.',
    'transitionsStory.placement.tryOther':
        'Probiere das andere Diagrammelement.',
    'answer.outputsBothOnNodes': 'Beide Automaten schreiben Ausgaben an Knoten',
    'answer.mooreNodeMealyTransition': 'Moore: Knoten; Mealy: Transition',
    'answer.mooreTransitionMealyNode': 'Moore: Transition; Mealy: Knoten',
    'answer.doorOpens': 'Die Tür öffnet sich',
    'answer.outputDisappears': 'Der Automat erzeugt keine Ausgabe',
    'answer.doorStaysClosed': 'Die Tür bleibt geschlossen',
    'answer.nodeQ1WithOutput': 'q1 mit y = OPEN',
    'answer.personTransitionWithoutOutput': 'Übergang q0 -"PERSON"→ q1',
    'answer.clearCloseTransition': 'Übergang q1 -"CLEAR / CLOSE"→ q0',
    'answer.currentStateOnly': 'Nur der aktuelle Zustand',
    'answer.inputOnly': 'Nur das Eingabesignal',
    'answer.stateAndInput': 'Der aktuelle Zustand und das Eingabesignal',
    'answer.personOneCloseTransition': '"person = 1 / CLOSE DOOR"',
    'answer.personZeroOpenTransition': '"person = 0 / OPEN DOOR"',
    'answer.waitState': 'Zustand WAIT',
    'answer.putCloseInsideWait': 'CLOSE DOOR in den WAIT-Knoten schreiben',
    'answer.closeWhenPersonDetected':
        'Die Ausgabe der Transition "person = 1" in CLOSE DOOR ändern',
    'answer.changePersonToZero': '"person = 1" durch "person = 0" ersetzen',
    'task.transitions.outputPlacement.prompt':
        'Wo wird die Ausgabe bei einem Moore-Automaten eingetragen?',
    'task.transitions.outputPlacement.instruction':
        'Wähle die grundlegende Moore-Regel.',
    'task.transitions.outputPlacement.hint':
        'Suche y = Ausgabe innerhalb eines Moore-Zustands.',
    'task.transitions.changeTarget.prompt':
        'Im Mealy-Diagramm ist die Transition "person = 1 / CLOSE DOOR" eingezeichnet, während WAIT unverändert bleibt. Wovon hängt diese Ausgabe ab?',
    'task.transitions.changeTarget.instruction':
        'Vergleiche die geänderte Transitionsbeschriftung mit dem unveränderten aktuellen Zustand.',
    'task.transitions.changeTarget.hint':
        'Eine Mealy-Ausgabe wird durch das Paar aktueller Zustand + aktuelle Eingabe bestimmt.',
    'task.transitions.findErrors.prompt':
        'Beide Mealy-Ausgaben wurden vertauscht. Wähle die zwei falschen Transitionen.',
    'task.transitions.findErrors.instruction':
        'Die Transition "person = 1 / OPEN DOOR" muss die Tür öffnen; "person = 0 / CLOSE DOOR" muss sie schließen.',
    'task.transitions.findErrors.hint':
        'Wähle "person = 1 / CLOSE DOOR" und "person = 0 / OPEN DOOR".',
    'task.transitions.validateMoore.prompt':
        'Der echte Controller muss sich merken, ob sich die Tür bewegt. Reicht dieses Mealy-Modell mit einem Zustand immer aus?',
    'task.transitions.validateMoore.instruction':
        'Entscheide, ob Mealy Bewegungszustände immer überflüssig macht.',
    'task.transitions.validateMoore.hint':
        'Mealy kann reine Ausgabezustände reduzieren, aber keine tatsächlich benötigte Prozessinformation entfernen.',
    'task.transitions.buildMoore.prompt':
        'Baue die vereinfachte Moore-Tür mit zwei Zuständen aus dem Unterricht.',
    'task.transitions.buildMoore.instruction':
        'Erstelle q0 DOOR IS CLOSED/CLOSE DOOR und q1 DOOR IS OPEN/OPEN DOOR; setze q0 als Startzustand und ergänze "person = 1" und "person = 0".',
    'task.transitions.buildMoore.hint':
        'Moore-Ausgaben gehören in Zustände; Sensorwerte beschriften die zwei gerichteten Transitionen.',
    'task.transitions.traceMoore.prompt':
        'Verfolge die vereinfachte Moore-Tür durch "person = 1" und "person = 0".',
    'task.transitions.traceMoore.instruction':
        'Wähle den aktuellen Zustand vor jeder Eingabe und nach beiden Sensorwerten.',
    'task.transitions.traceMoore.hint':
        'Folge DOOR IS CLOSED → DOOR IS OPEN → DOOR IS CLOSED.',
    'task.transitions.completeMealy.prompt':
        'Ergänze bei der Mealy-Tür mit einem Zustand die fehlende zweite Selbstschleife.',
    'task.transitions.completeMealy.instruction':
        'Füge an WAIT eine Selbstschleife mit der exakten Beschriftung "person = 0 / CLOSE DOOR" hinzu.',
    'task.transitions.completeMealy.hint':
        'Der Zustand bleibt WAIT; Eingabe und Ausgabe stehen gemeinsam an der Schleife.',
    'task.transitions.closeOnPerson.prompt':
        'Was muss geändert werden, damit sich die Tür schließt, sobald der Sensor eine Person erkennt?',
    'task.transitions.closeOnPerson.instruction':
        'Wähle die Änderung an der Mealy-Reaktion für "person = 1".',
    'task.transitions.closeOnPerson.hint':
        'Behalte die Eingabe "person = 1" und ändere die Ausgabe hinter dem Schrägstrich.',
    'lesson.scrollHint': 'Nach unten scrollen, um fortzufahren',
    'home.chapter3.unit': 'Einheit 3',
    'home.chapter4.unit': 'Einheit 4',
    'home.chapter5.unit': 'Prüfung',
    'lesson.chapter2.diagram.title': 'FSM-Abbildungen verstehen',
    'lesson.chapter2.gates.title': 'Digitale Gatter: Signalfluss',
    'lesson.chapter2.gates.subtitle': 'Kurze interaktive Wiederholung',
    'lesson.chapter2.diagram.subtitle':
        'Zustände, Übergänge, Reset und Determinismus erkennen',
    'lesson.chapter2.testSubtitle': 'Abbildungen und Moore/Mealy-Grundlagen',
    'lesson.chapter4.title': 'Automaten vervollständigen',
    'lesson.chapter4.subtitle': 'Fehlende Übergänge und Ausgaben finden',
    'lesson.chapter4.testSubtitle': 'Vollständigkeits-Check',
    'lesson.chapter5.title': 'Automaten erstellen',
    'lesson.chapter5.subtitle':
        'Einen FSM bauen und als Übergangstabelle beschreiben',
    'lesson.chapter5.testSubtitle': 'Erstellungs-Check',
    'lesson.bonus.title': 'FSM-Prüfungsaufgaben',
    'lesson.bonus.subtitle':
        'Sechs Übungslektionen mit Aufgaben nach Klausurvorbild',
    'concept.determinism': 'Determinismus',
    'concept.transitionTable': 'Übergangstabelle',
    'answer.idleState': 'Der Zustand IDLE',
    'answer.activeState': 'Der Zustand ACTIVE',
    'answer.oneTransition': 'Der Übergang mit der Beschriftung "1"',
    'answer.duplicateOneFirst': 'q0 --"1"--> q1',
    'answer.duplicateOneSecond': 'q0 --"1"--> q0',
    'answer.oneTransitionPerInput': 'Genau ein Übergang pro Eingabe',
    'answer.anyNumberTransitions': 'Beliebig viele Übergänge pro Eingabe',
    'answer.noTransitionsNeeded': 'Übergänge sind nicht nötig',
    'answer.defineStatesThenTransitions':
        'Zustände festlegen und anschließend verbinden',
    'answer.onlyDrawArrows': 'Nur Pfeile zeichnen; Zustände sind optional',
    'answer.randomLabels': 'Zufällige Beschriftungen verwenden',
    'answer.trafficFirstTimer': 'q0 --"timer"--> q1',
    'answer.trafficSecondTimer': 'q0 --"timer"--> q2',
    'answer.trafficGreenTimer': 'q1 --"timer"--> q2',
    'path.chapter2.lesson.title': 'FSM-Abbildungen lesen',
    'path.chapter2.lesson.subtitle': '3 Aufgaben',
    'path.chapter2.test.title': 'Test Kapitel 2',
    'path.chapter2.test.subtitle': '5 Fragen',
    'chapter2Story.intro':
        'Du kannst digitale Schaltungen bereits lesen. Folge nun den Signalen, um zu erkennen, was dieser deterministische FSM macht. Jeder farbige Pfad illustriert die Erklärung.',
    'chapter2Story.purpose':
        'Diese Schaltung ist ein FSM. Sie speichert den aktuellen Zustand, berechnet aus dem Eingang den Folgezustand und erzeugt einen Ausgang. Wir lesen sie von links nach rechts, Block für Block.',
    'chapter2Story.stateBits':
        'Die beiden Flip-Flops speichern den aktuellen Zustand. Lies ihre Ausgänge zuerst als Bitpaar S₁S₀, bevor du die Folgezustandslogik ansiehst.',
    'chapter2Story.bitDecomposition':
        'Teile den Zustand jetzt in seine beiden Leitungen auf: S₁S₀ = 00 bedeutet S₁ = 0 und S₀ = 0. Zusammen bilden die beiden Bits S.',
    'chapter2Story.clockStep':
        'Die Logik berechnet zuerst neue Werte. Erst die CLK-Flanke speichert sie in den Flip-Flops; dadurch wechselt der FSM zu einem definierten Zeitpunkt den Zustand.',
    'chapter2Story.outputStep':
        'Zum Schluss läuft der gespeicherte Zustand durch die Ausgangslogik. Das ist ein Moore-Ausgang: Y wird durch S bestimmt, nicht direkt durch A.',
    'chapter2Story.signalPath':
        'Für einen Folgezustand beginnst du bei A und den gespeicherten Bits. Folge den hervorgehobenen Pfeilen durch die Logik zu den D-Eingängen; der Takt speichert diese Werte.',
    'chapter2Story.simulator':
        'Wähle einen Zustand und einen Eingang. Die Schaltung hebt den relevanten Pfad hervor. Drücke CLK, um den berechneten Folgezustand zu speichern.',
    'chapter2Story.transitionTable':
        'Eine Zustandsübergangstabelle enthält für jedes gültige Paar aus aktuellem Zustand S und Eingang A den Folgezustand. Tippe auf eine Zeile, um sie mit der animierten Schaltung zu prüfen, und vervollständige dann die Tabelle.',
    'chapter2Story.outputTable':
        'Die Ausgangslogik ist getrennt. Dies ist ein Moore-Automat: Y hängt nur vom gespeicherten Zustand ab, nicht direkt von A. Tippe auf eine Zeile, um sie mit der animierten Schaltung zu prüfen, und vervollständige dann die Ausgangstabelle.',
    'chapter2Story.transitionTableTitle': 'Zustandsübergangstabelle',
    'chapter2Story.outputTableTitle': 'Ausgangstabelle',
    'chapter2Story.completeOverview':
        'So konnten wir den gesamten Automaten analysieren: Wir haben herausgefunden, welchen Regeln er folgt und welche Werte er ausgibt. Das wird dir in der Klausur sehr helfen! Wichtig ist, dass du verstehst, wie der Automat innen arbeitet - mit seinen Gattern.',
    'chapter2Story.ready':
        'Du kannst die Schaltung jetzt als FSM lesen: S₁S₀ dekodieren, der Folgezustandslogik folgen, CLK anwenden und Y aus der Ausgangslogik ablesen.',
    'chapter2Story.predictNextState': 'Предскажи S′ до применения CLK.',
    'chapter2Story.predictionHint':
        'Verfolge beide hervorgehobenen Wege noch einmal.',
    'chapter2Story.startTasks': 'Aufgaben starten',
    'chapter2Gates.intro':
        'Willkommen in Kapitel 2! In diesem Kapitel lernen wir, digitale FSM-Schaltungen zu lesen: Wir verfolgen die Eingangssignale durch die Gatter und verstehen, wie die Schaltung ihren Zustand verändert. Ich hoffe, du erinnerst dich noch gut an die Grundgatter, die du während deines Studiums an der Universität gelernt hast.',
    'chapter2Gates.xor':
        'Verändere beide Eingänge und beobachte das Bit auf seinem Weg durch XOR.',
    'chapter2Gates.andBubble':
        'Ein Kreis an einem AND-Eingang invertiert diesen Eingang, bevor das Gatter die Signale verbindet.',
    'chapter2Gates.andNot':
        'Verfolge nun den invertierten Eingang durch NOT und AND.',
    'chapter2Gates.clock':
        'Die Gatter berechnen zuerst. CLK speichert das Ergebnis als neuen Zustand.',
    'chapter2Gates.summary':
        'Sehr gut! Jetzt solltest du erkennen können, was die einzelnen Teile dieser FSM-Schaltung machen. In der nächsten Lektion lesen wir die vollständige Schaltung Schritt für Schritt.',
    'chapter2Gates.introCard':
        'In diesem Kapitel lernst du, diese FSM-Schaltung zu verstehen: Verfolge den Eingang, lies die Gatter und beobachte, wie sich der Zustand ändert. Ich hoffe, die Grundgatter aus deinem Universitätsstudium sind dir noch vertraut.',
    'chapter2Gates.summaryCard':
        'Jetzt kannst du in diesem FSM den Eingang A, den Zustandsspeicher S₁S₀, die Gatter, CLK und den Ausgang Y erkennen. In der nächsten Lektion verfolgen wir den vollständigen Signalweg.',
    'chapter2Gates.showSignal': 'Signalweg anzeigen',
    'chapter2Gates.xorTitle': 'XOR: verschiedene Eingänge ergeben 1',
    'chapter2Gates.xorBody':
        'XOR liefert 1, wenn genau ein Eingang 1 ist. Ändere A oder S₀ und beobachte das animierte Signal.',
    'chapter2Gates.notSymbolTitle': 'NOT: Der Kreis bedeutet Invertierung',
    'chapter2Gates.notSymbolBody':
        'Der kleine Kreis am Ausgang ist das Inversionszeichen. Er macht aus 0 eine 1 und aus 1 eine 0.',
    'chapter2Gates.notBubbleTitle': 'Ein NOT-Zeichen kann allein stehen',
    'chapter2Gates.notBubbleBody':
        'Du brauchst nicht immer ein eigenes NOT-Gatter. Ein Kreis auf einer Leitung bedeutet bereits NOT. Ändere A und beobachte Ā.',
    'chapter2Gates.andBubbleTitle': 'NOT an einem AND-Eingang',
    'chapter2Gates.andBubbleBody':
        'Ein kleiner Kreis an einem AND-Eingang bedeutet, dass dieser Eingang invertiert wird. Ein eigenes NOT-Gatter ist nicht nötig: A wird vor dem AND zu Ā und mit S₁ verbunden.',
    'chapter2Gates.andNotTitle': 'NOT und AND: invertieren und verbinden',
    'chapter2Gates.andNotBody':
        'Der Kreis bedeutet NOT: Aus A wird Ā. AND liefert nur dann 1, wenn alle Eingänge 1 sind.',
    'chapter2Gates.flipFlop':
        'Ein Flip-Flop ist das kleinste Speicherelement: Es speichert ein Bit, bis der Takt es aktualisiert.',
    'chapter2Gates.flipFlopTitle': 'Flip-Flop speichert ein Bit',
    'chapter2Gates.flipFlopBody':
        'Ein Flip-Flop ist ein Speicher für ein Bit. Es empfängt ein Bit an D und kopiert es erst an der CLK-Flanke nach Q. Bis dahin bleibt der alte Wert in Q.',
    'chapter2Gates.flipFlopPrompt': 'Wähle das Bit an D:',
    'chapter2Gates.flipFlopApply': 'CLK anwenden',
    'chapter2Gates.flipFlopApplied': 'Bit gespeichert',
    'chapter2Gates.clockTitle': 'CLK kopiert D-Bits in den Speicher',
    'chapter2Gates.clockBody':
        'In einem FSM sind die Flip-Flops der Zustandsspeicher. Die Gatter berechnen D₁ und D₀ aus Eingang und aktuellem Zustand. An der steigenden CLK-Flanke kopieren die Flip-Flops sie nach S₁/S₀. So ändert sich der Zustand in klaren, getrennten Schritten.',
    'chapter2Gates.clockPrompt': 'Was passiert an der CLK-Flanke?',
    'chapter2Gates.clockChoice0': 'Der Zustand ändert sich sofort',
    'chapter2Gates.clockChoice1': 'CLK speichert die berechneten Bits',
    'chapter2Gates.clockChoice2': 'A ändert den Zustand direkt',
    'chapter2Gates.check': 'Ich verstehe den Signalfluss',
    'chapter2Gates.checked': 'Bereit für FSM-Tabellen',
    'chapter2Gates.startLesson': 'FSM-Lektion starten',
    'chapter2Story.legend.input': 'Eingang',
    'chapter2Story.legend.memory': 'Zustandsspeicher',
    'chapter2Story.legend.output': 'Ausgang',
    'chapter2Story.stateEncoding': 'Zustandskodierung',
    'chapter2Story.purposeTitle': 'Was macht dieser FSM?',
    'chapter2Story.purposeInput':
        'A ist der Eingang von außen und kann sich zwischen zwei Taktzyklen ändern.',
    'chapter2Story.purposeMemory':
        'S₁ und S₀ sind die beiden gespeicherten Zustandsbits. Zusammen bilden sie den aktuellen Zustand S.',
    'chapter2Story.purposeLogic':
        'Die Gatter berechnen aus A und den aktuellen Bits den Folgezustand.',
    'chapter2Story.purposeOutput':
        'Die Ausgangslogik macht aus dem gespeicherten Zustand den Ausgang Y.',
    'chapter2Story.clockTitle': 'Wann ändert sich der Zustand?',
    'chapter2Story.clockBefore':
        'Vor CLK berechnen die Gatter S₁′ und S₀′, aber der alte Zustand bleibt gespeichert.',
    'chapter2Story.clockEdge':
        'Die CLK-Flanke überträgt die berechneten Werte in den Speicher.',
    'chapter2Story.clockAfter':
        'Nach CLK wird das neue Bitpaar S₁S₀ zum aktuellen Zustand S.',
    'chapter2Story.clockQuestion': 'Was passiert an der CLK-Flanke?',
    'chapter2Story.clockChoice0': 'Der Zustand ändert sich sofort',
    'chapter2Story.clockChoice1': 'CLK speichert die berechneten Bits',
    'chapter2Story.clockChoice2': 'A ändert den Zustand direkt',
    'chapter2Story.clockCorrect':
        'Richtig: CLK übernimmt die D-Werte in die Flip-Flops.',
    'chapter2Story.clockTimeline':
        'Beispiel: aktueller Zustand → berechneter Folgezustand → gespeicherter Zustand nach CLK',
    'chapter2Story.flipFlops': 'Flip-Flops',
    'chapter2Story.unusedState':
        'Das Bitpaar 11 ist mit zwei Bits möglich, wird von diesem FSM aber nicht verwendet.',
    'chapter2Story.resetActive': 'Reset aktiv: S₁S₀ = 00 → S = 0',
    'chapter2Story.resetInactive':
        'Reset inaktiv: Der gespeicherte Zustand kann sich mit CLK ändern.',
    'chapter2Story.applyReset': 'Reset aktivieren',
    'chapter2Story.releaseReset': 'Reset lösen',
    'chapter2Story.outputStepTitle': 'Wie erzeugt der FSM Y?',
    'chapter2Story.outputStepBody':
        'Lies den aktuellen Zustand aus S₁S₀ und folge dann der Ausgangslogik zu Y. Für diesen Moore-Ausgang wird A nicht benötigt.',
    'chapter2Story.bitDecompositionTitle':
        'S₁S₀ ist ein zweistelliger Zustandswert',
    'chapter2Story.bitDecompositionBody':
        'Die beiden Leitungen S₁ und S₀ bilden gemeinsam den Zustandswert S. Das erste Bit ist S₁, das zweite Bit ist S₀.',
    'chapter2Story.bitDecompositionFormula':
        'S₁S₀ = {bits}  →  S₁ = {s1}, S₀ = {s0}  →  S = {state}',
    'chapter2Story.workedExample':
        'Wir lösen eine vollständige Zeile: S = 0 und A = 0.',
    'chapter2Story.resetStep':
        'Reset setzt die Flip-Flops in den festgelegten Startzustand. Es ist nicht der normale Eingang A.',
    'chapter2Story.workedExampleTitle': 'Beispiel: beide Folgebits berechnen',
    'chapter2Story.workedExampleBody':
        'Für S = 0 und A = 0 verfolgst du jede markierte Linie: A und die gespeicherten Bits S₁/S₀ laufen in die Gatter und ergeben S₀′ und S₁′.',
    'chapter2Story.workedExamplePrompt': 'Wähle beide berechneten Bits.',
    'chapter2Story.workedExampleCorrect':
        'Richtig: Die beiden Bits bilden den Folgezustand.',
    'chapter2Story.predictNextBits': 'S₀′ und S₁′ vor CLK vorhersagen.',
    'chapter2Story.resetBody':
        'Reset zwingt das Register in den festgelegten Anfangszustand. Danach steuert CLK die normalen Zustandsänderungen.',
    'chapter2Story.unused': 'hier nicht verwendet',
    'chapter2Story.flow.input': 'Eingang A und die Bits des aktuellen Zustands',
    'chapter2Story.flow.logic': 'Folgezustandslogik berechnet S0\' und S1\'',
    'chapter2Story.flow.clock':
        'CLK übernimmt die D-Eingänge in die Flip-Flops',
    'chapter2Story.flow.state':
        'Die gespeicherten Bits bilden den neuen aktuellen Zustand',
    'chapter2Story.formulaS0': 'S₀′ = A ∧ (S₁ XOR S₀)',
    'chapter2Story.formulaS1': 'S₁′ = Ā ∧ ¬S₁ ∧ ¬S₀',
    'chapter2Story.formulaY': 'Y = S₁ ∧ ¬S₀',
    'chapter2Story.chooseState': 'Aktuellen Zustand wählen',
    'chapter2Story.chooseInput': 'Eingang wählen',
    'chapter2Story.clock': 'CLK anwenden',
    'chapter2Story.transitionInstruction':
        'Wähle für jede Zeile den Folgezustand.',
    'chapter2Story.outputInstruction':
        'Wähle Y für jeden gespeicherten Zustand.',
    'chapter2Story.fillEveryRow':
        'Vervollständige alle Zeilen, um fortzufahren.',
    'chapter2Story.summary':
        'Eine Schaltung wird zur FSM-Tabelle, indem du jede Zustands-Eingabe-Kombination einzeln auswertest.',
    'path.chapter4.unlocked': 'Vervollständigungskapitel freigeschaltet',
    'path.chapter4.lesson.title': 'Automaten vervollständigen',
    'path.chapter4.lesson.subtitle': '3 Aufgaben',
    'path.chapter4.test.subtitle': '5 Fragen',
    'path.chapter5.test.title': 'Prüfungsaufgaben',
    'path.chapter5.test.subtitle': 'Sechs Übungslektionen',
    'path.chapter5.title': 'Kapitel 5: Prüfungsaufgaben',
    'path.chapter5.locked': 'Test für Kapitel 4 bestehen',
    'path.chapter5.unlocked': 'Klausuraufgaben freigeschaltet',
    'path.chapter5.lesson.title': 'Sechs Lektionen mit Prüfungsaufgaben',
    'path.chapter5.lesson.subtitle': '6 Lektionen, je 3 Aufgaben',
    'path.chapter5.theory.title': 'Theoretische Aufgaben',
    'path.chapter5.theory.subtitle': '3 Fragen',
    'path.chapter5.completion.title': 'Automat vervollständigen',
    'path.chapter5.completion.subtitle': '3 Konstruktionsaufgaben',
    'path.chapter5.creation.title': 'Automat erstellen',
    'path.chapter5.creation.subtitle': '3 Konstruktionsaufgaben',
    'path.chapter5.diagnostics.title': 'Automat analysieren',
    'path.chapter5.diagnostics.subtitle': '3 Aufgaben',
    'chapter5.lesson.theory.title': 'Theoretische Aufgaben',
    'chapter5.lesson.theory.subtitle': 'Moore, Mealy und synchrone Schaltungen',
    'chapter5.lesson.tables.title': 'Automaten aus Tabellen',
    'chapter5.lesson.tables.subtitle':
        'Zustandsübergangs- und Ausgabetabellen lesen',
    'chapter5.lesson.completion.title': 'Vervollständigungsaufgabe',
    'chapter5.lesson.completion.subtitle':
        'Fehlende Zustände und Übergänge finden',
    'chapter5.lesson.creation.title': 'Erstellungsaufgabe',
    'chapter5.lesson.creation.subtitle': 'Einen vollständigen Automaten bauen',
    'chapter5.lesson.diagnostics.title': 'Analyseaufgabe',
    'chapter5.lesson.diagnostics.subtitle':
        'Zustände verfolgen und Determinismus prüfen',
    'chapter5.theory.instruction': 'Wähle die richtige Aussage.',
    'chapter5.theory.mooreOutput.prompt':
        'Geben Sie an, wovon der Ausgang eines Moore-Automaten abhängt.',
    'chapter5.theory.mooreOutput.hint':
        'Beim Moore-Automaten gehört der Ausgang zum aktuellen Zustand.',
    'chapter5.theory.mealyOutput.prompt':
        'Geben Sie an, wovon der Ausgang eines Mealy-Automaten abhängt.',
    'chapter5.theory.mealyOutput.hint':
        'Beim Mealy-Automaten steht der Ausgang am Übergang zusammen mit dem Eingang.',
    'chapter5.theory.timing.prompt':
        'Nennen Sie einen wesentlichen Unterschied zwischen dem zeitlichen Verhalten der Ausgänge eines Mealy- und eines Moore-Automaten.',
    'chapter5.theory.timing.hint':
        'Vergleiche, wann der Ausgang auf einen geänderten Eingang reagieren kann.',
    'chapter5.theory.realization.prompt':
        'Wie kann man Automaten als synchron sequentielle Schaltung realisieren? Erklären Sie kurz anhand einer Skizze oder einer Beschreibung.',
    'chapter5.theory.realization.instruction':
        'Wähle die Beschreibung mit Zustandsregister, kombinatorischer Logik und Takt.',
    'chapter5.theory.realization.hint':
        'Das Register speichert den Zustand; die Logik berechnet Folge-Zustand und Ausgang.',
    'chapter5.answer.stateOutput': 'Er hängt vom aktuellen Zustand ab.',
    'chapter5.answer.inputOnly': 'Er hängt nur vom Eingang ab.',
    'chapter5.answer.nextStateOnly': 'Er hängt nur vom Folgezustand ab.',
    'chapter5.answer.transitionInput':
        'Er hängt vom aktuellen Zustand und vom Eingangsübergang ab.',
    'chapter5.answer.stateOnly': 'Er hängt nur vom Namen des Zustands ab.',
    'chapter5.answer.clockOnly': 'Er hängt nur vom Takt ab.',
    'chapter5.answer.mealyImmediate':
        'Mealy kann sofort auf eine Eingangsänderung reagieren; Moore ändert sich mit dem Zustand.',
    'chapter5.answer.sameTiming': 'Beide reagieren immer exakt gleichzeitig.',
    'chapter5.answer.mooreImmediate': 'Moore reagiert immer vor Mealy.',
    'chapter5.answer.registerLogic':
        'Getaktetes Zustandsregister, kombinatorische Folge-Zustands-/Ausgangslogik und gemeinsamer Takt.',
    'chapter5.answer.onlyRegister':
        'Nur ein Zustandsregister ohne kombinatorische Logik.',
    'chapter5.answer.onlyCombinational':
        'Nur kombinatorische Logik ohne getaktetes Zustandsregister.',
    'chapter5.tables.instruction':
        'Baue den Automaten aus den gezeigten Tabellen. Der Anfangszustand ist q0. Lege für jeden Zustand und jede Aktion genau einen Übergang fest.',
    'chapter5.tables.moore.prompt':
        'Erstelle den Moore-Automaten aus der Übergangs- und Ausgabetabelle.',
    'chapter5.tables.moore.hint':
        'Nutze die beiden Eingangszeilen jedes Zustands und übertrage den Ausgang in den Zustand.',
    'chapter5.tables.mealy.prompt':
        'Erstelle den Mealy-Automaten aus der Übergangstabelle mit Eingangs-/Ausgangsbezeichnungen.',
    'chapter5.tables.mealy.hint':
        'Jeder Pfeil erhält Eingang und Ausgang als Beschriftung.',
    'chapter5.completion.prompt':
        'Ein Detektor startet in q0. Eingabe 0 führt q0 -> q1 -> q2 -> q3. Bei Eingabe 1 gilt: q0 -> q0, q1 -> q0, q2 -> q1 und q3 -> q1. Nur q1 hat die Ausgabe 1; q0, q2 und q3 geben 0 aus. Ergänze alle fehlenden Ausgaben und Übergänge.',
    'chapter5.completion.instruction':
        'Füge die laut Beschreibung fehlenden Zustandsdaten und Übergänge hinzu.',
    'chapter5.completion.hint':
        'Prüfe jedes Zustand-Eingang-Paar genau einmal.',
    'chapter5.creation.prompt':
        'Ein Zugangstor startet verriegelt in q0. Eingang 1 bedeutet: Ein gültiges Ticket wird gelesen; das Tor öffnet sich, der Automat wechselt nach q1 und gibt OPEN (1) aus. Eingang 0 bedeutet Reset oder ein ungültiges Ticket; aus q0 bleibt das Tor mit Ausgang 0 verriegelt, aus q1 schließt es und kehrt mit Ausgang 0 nach q0 zurück. Ein weiteres gültiges Ticket bei offenem Tor hält q1, gibt OPEN aber nicht erneut aus. Erstelle den vollständigen Mealy-Automaten aus dieser Beschreibung.',
    'chapter5.creation.instruction':
        'Platziere die vorbereiteten Zustände, wähle den Startzustand und verbinde alle Übergänge.',
    'chapter5.creation.hint':
        'Beim Mealy-Automaten steht der Ausgang hinter dem Schrägstrich am Übergang.',
    'chapter5.analysis.prompt':
        'Verfolge den Automaten für die angegebene Eingabefolge.',
    'chapter5.analysis.instruction':
        'Wähle den Zustand vor dem ersten Eingang und nach jedem Eingang.',
    'chapter5.analysis.hint':
        'Folge für jedes Eingabesymbol genau einem Übergang.',
    'chapter5.diagnostics.prompt':
        'Welche Aussage diagnostiziert den gezeigten Automaten richtig?',
    'chapter5.diagnostics.instruction':
        'Wähle die Aussage mit dem doppelten Eingangsübergang.',
    'chapter5.diagnostics.hint':
        'Ein deterministischer Automat hat für jedes Zustand-Eingang-Paar höchstens ein Ziel.',
    'chapter5.answer.deterministic': 'Der Automat ist deterministisch.',
    'chapter5.answer.conflict':
        'Zwei Übergänge verwenden denselben Eingang aus einem Zustand.',
    'task.chapter2.readDiagram.prompt':
        'Welche Zustände speichert diese Schaltung?',
    'task.chapter2.readDiagram.instruction':
        'Wähle alle drei gespeicherten Zustände in der Schaltungsdarstellung.',
    'task.chapter2.readDiagram.hint':
        'Die gültigen Kodierungen sind 00, 01 und 10. Sie bedeuten S = 0, 1 und 2.',
    'task.chapter2.trace.prompt':
        'Verfolge die Zustandsfolge der Schaltung für die Eingaben 0, 1, 0, 1.',
    'task.chapter2.trace.instruction':
        'Starte mit S = 0 und trage den Zustand nach jedem CLK-Zyklus ein.',
    'task.chapter2.trace.hint':
        'Starte bei S = 0 und nutze die Schaltung Schritt für Schritt mit CLK. Lies nach jedem Schritt beide Zustandsbits ab.',
    'task.chapter2.mooreMealy.prompt':
        'Wo stehen die Ausgaben bei Moore- und Mealy-Automaten?',
    'task.chapter2.mooreMealy.instruction':
        'Wähle die Aussage, die zur Schreibweise in Digitaltechnik passt.',
    'task.chapter2.mooreMealy.hint':
        'Bei Moore steht die Ausgabe im Zustand, bei Mealy am Übergang als Eingabe/Ausgabe.',
    'task.chapter2.determinism.prompt':
        'Welche Elemente machen diesen Automaten nichtdeterministisch?',
    'task.chapter2.determinism.instruction':
        'Wähle die beiden Übergänge mit derselben Eingabe aus q0.',
    'task.chapter2.determinism.hint':
        'Für einen Zustand und eine Eingabe darf ein deterministischer FSM nur ein Ziel haben.',
    'task.chapter2.gatesCheck.prompt':
        'Welchen Ausgang liefert XOR bei den Eingängen 0 und 1?',
    'task.chapter2.gatesCheck.instruction':
        'Wähle den Wert, den das XOR-Gatter ausgibt.',
    'task.chapter2.gatesCheck.hint':
        'Betrachte die beiden Eingänge als Paar. XOR reagiert auf ihr Verhältnis, nicht auf einen Eingang allein.',
    'task.chapter2.gatesCheck.feedback.xorZero':
        'Schau dir die beiden Eingangswerte noch einmal an. Was vergleicht XOR, bevor der Ausgang entsteht?',
    'task.chapter2.gatesCheck.feedback.andOne':
        'Diese Regel gehört zu einem anderen Gatter. Überlege, was XOR macht, wenn seine Eingänge nicht übereinstimmen.',
    'answer.xorOne': '1 - die Eingänge sind verschieden',
    'answer.xorZero': '0 - die Eingänge sind gleich',
    'answer.andOne': '1 - AND liefert immer 1',
    'task.chapter4.completeMoore.prompt':
        'Vervollständige den Moore-Automaten des Drehkreuzes.',
    'task.chapter4.completeMoore.instruction':
        'Füge den fehlenden Übergang für die Eingabe "coin" im Zustand UNLOCKED hinzu.',
    'task.chapter4.completeMoore.hint':
        'Mit "coin" bleibt ein bereits entsperrtes Drehkreuz UNLOCKED.',
    'task.chapter4.completeMealy.prompt':
        'Vervollständige den Mealy-Automaten der Tür.',
    'task.chapter4.completeMealy.instruction':
        'Füge die Selbstschleife "person = 0 / CLOSE DOOR" an WAIT hinzu.',
    'task.chapter4.completeMealy.hint':
        'Die fehlende Beschriftung enthält Eingabe und Ausgabe hinter dem Schrägstrich.',
    'task.chapter4.missingOutput.prompt':
        'Ist dieser Mealy-Automat vollständig?',
    'task.chapter4.missingOutput.instruction':
        'Prüfe, ob jeder Übergang eine Eingabe und eine Ausgabe besitzt.',
    'task.chapter4.missingOutput.hint':
        'Ein Mealy-Übergang ohne Text nach / hat keine definierte Ausgabe.',
    'task.chapter4.determinismRule.prompt':
        'Was muss für einen deterministischen FSM gelten?',
    'task.chapter4.determinismRule.instruction':
        'Wähle die Regel, mit der du jedes Zustands-Eingabe-Paar prüfen kannst.',
    'task.chapter4.determinismRule.hint':
        'Dieselbe Eingabe aus demselben Zustand darf nicht auf zwei Übergänge führen.',
    'task.chapter5.createMoore.prompt':
        'Baue einen Moore-Automaten für das Drehkreuz aus der Beschreibung.',
    'task.chapter5.createMoore.instruction':
        'Nutze LOCKED/STOP und UNLOCKED/GO und ergänze "coin"- und "passage"-Übergänge.',
    'task.chapter5.createMoore.hint':
        'Bei Moore stehen STOP und GO in den Zuständen, nicht auf den Pfeilen.',
    'task.chapter5.buildTable.prompt':
        'Erstelle die Übergangstabelle für das Drehkreuz.',
    'task.chapter5.buildTable.instruction':
        'Trage für jeden Zustand die Ziele von "coin" und "passage" sowie die Moore-Ausgabe ein.',
    'task.chapter5.buildTable.hint':
        '"coin" öffnet das gesperrte Drehkreuz; "passage" verriegelt es danach automatisch wieder.',
    'task.chapter5.createMealy.prompt':
        'Baue einen Mealy-Automaten für das Drehkreuz mit Ausgaben an Übergängen.',
    'task.chapter5.createMealy.instruction':
        'Erstelle LOCKED und UNLOCKED und ergänze alle vier Eingabe/Ausgabe-Reaktionen.',
    'task.chapter5.createMealy.hint':
        'Lasse die Zustandsausgaben leer und schreibe jede Reaktion hinter /.',
    'task.chapter5.chooseWorkflow.prompt':
        'Welche Reihenfolge ist beim Erstellen eines FSM am sichersten?',
    'task.chapter5.chooseWorkflow.instruction':
        'Wähle die Reihenfolge, mit der sich die Abbildung leicht prüfen lässt.',
    'task.chapter5.chooseWorkflow.hint':
        'Lege zuerst die Situationen fest und beschreibe dann die Änderungen durch Eingaben.',
    'task.chapter5.outputPlacement.prompt':
        'Wo wird eine Moore-Ausgabe in der Abbildung eingetragen?',
    'task.chapter5.outputPlacement.instruction':
        'Wähle den Platz, den die Moore-Darstellung verwendet.',
    'task.chapter5.outputPlacement.hint':
        'Moore-Ausgaben beschreiben den aktuellen Zustand.',
    'task.bonus.buildTraffic.prompt':
        'Baue den dreistufigen Moore-FSM für eine Ampel.',
    'task.bonus.buildTraffic.instruction':
        'Nutze RED/STOP, GREEN/GO und YELLOW/SLOW mit einem "timer"-Zyklus.',
    'task.bonus.buildTraffic.hint':
        'Der "timer"-Zyklus lautet RED → GREEN → YELLOW → RED.',
    'task.bonus.completeTurnstile.prompt':
        'Vervollständige das Drehkreuz mit dem einen fehlenden Übergang.',
    'task.bonus.completeTurnstile.instruction':
        'Finde das Zustands-Eingabe-Paar ohne ausgehenden Übergang.',
    'task.bonus.completeTurnstile.hint':
        'Aus UNLOCKED hält "coin" das Drehkreuz in UNLOCKED.',
    'task.bonus.completeDoorMealy.prompt':
        'Vervollständige den Mealy-Automaten der Tür unter Klausurzeitdruck.',
    'task.bonus.completeDoorMealy.instruction':
        'Füge die fehlende "person = 0 / CLOSE DOOR"-Schleife hinzu.',
    'task.bonus.completeDoorMealy.hint':
        'Es ist ein Automat mit einem Zustand: Beide Pfeile sind Schleifen an WAIT.',
    'task.bonus.buildTable.prompt':
        'Erstelle die Übergangstabelle für den Ampelzyklus.',
    'task.bonus.buildTable.instruction':
        'Trage für jede Farbe den nächsten Zustand und die Moore-Ausgabe ein.',
    'task.bonus.buildTable.hint':
        'Jede Zeile hat ein "timer"-Ziel: die nächste Farbe im Zyklus.',
    'task.bonus.findError.prompt':
        'Finde den Determinismusfehler in diesem Ampel-FSM.',
    'task.bonus.findError.instruction':
        'Wähle die beiden widersprüchlichen "timer"-Übergänge aus RED.',
    'task.bonus.findError.hint':
        'RED darf bei derselben "timer"-Eingabe nicht nach GREEN und YELLOW führen.',
    'task.bonus.traceTurnstile.prompt':
        'Verfolge das Drehkreuz nach "coin", "passage", "coin".',
    'task.bonus.traceTurnstile.instruction':
        'Trage den Startzustand und den Zustand nach jeder Eingabe ein.',
    'task.bonus.traceTurnstile.hint':
        '"coin" öffnet, "passage" verriegelt automatisch wieder, und die letzte "coin"-Eingabe öffnet erneut.',
    'profile.title': 'Profil',
    'profile.subtitle': 'Deine FSM-Reise und Belohnungen',
    'profile.loadFailed': 'Das Profil konnte nicht geladen werden.',
    'profile.saveFailed': 'Das Profil konnte nicht gespeichert werden.',
    'profile.username': 'Nutzername',
    'profile.unknown': 'Noch kein Nutzername',
    'profile.edit': 'Profil bearbeiten',
    'profile.editTitle': 'Profil bearbeiten',
    'profile.usernameHint': 'Nutzernamen eingeben',
    'profile.usernameHelper':
        'Ein Spitzname genügt; dein echter Name ist nicht erforderlich.',
    'profile.stats.level': 'Level {level}',
    'profile.stats.xp': '{xp} XP',
    'profile.stats.stars': '{stars} Sterne',
    'profile.stats.coins': '{coins} Münzen',
    'profile.stats.streak': '{days} Tage Serie',
    'profile.chapterProgress.title': 'Kapitelfortschritt',
    'profile.chapterProgress.item': '{chapter}: {completed}/{total} Lektionen',
    'profile.chapterProgress.chapter': 'Kapitel {number}',
    'profile.shop.title': 'Fini-Kleiderschrank',
    'profile.shop.subtitle':
        'Gib Münzen aus und schalte einen neuen Look frei.',
    'profile.shop.buy': 'Kaufen',
    'profile.shop.equip': 'Anziehen',
    'profile.shop.equipped': 'Angezogen',
    'profile.shop.owned': 'Besitzt du',
    'profile.shop.notEnoughCoins':
        'Für diesen Gegenstand brauchst du mehr Münzen.',
    'profile.shop.purchaseSuccess': 'Neuer Look freigeschaltet!',
    'profile.shop.equipSuccess': 'Fini trägt ihn jetzt.',
    'profile.shop.cap.title': 'Lernmütze',
    'profile.shop.cap.description':
        'Eine Mütze für konzentrierte FSM-Sessions.',
    'profile.shop.scarf.title': 'Signalschal',
    'profile.shop.scarf.description': 'Ein bunter Schal für jeden Übergang.',
    'profile.shop.glasses.title': 'Logikbrille',
    'profile.shop.glasses.description':
        'Deterministische Wege schneller erkennen.',
    'profile.shop.crown.title': 'FSM-Krone',
    'profile.shop.crown.description':
        'Eine Belohnung für ambitionierte Automatenbauer.',
    'fsmWorkspace.mooreMode': 'Moore: Die Ausgabe steht in den Zuständen',
    'fsmWorkspace.mealyMode':
        'Mealy: Eingabe und Ausgabe stehen an den Übergängen',
    'fsmWorkspace.moore': 'Moore',
    'fsmWorkspace.mealy': 'Mealy',
    'chapter4.story.welcome':
        'Willkommen in Kapitel 3. Du liest eine Automatenbeschreibung und ergänzt die fehlenden Teile im Diagramm.',
    'chapter4.story.intro':
        'Willkommen in Kapitel 3: Automaten vervollständigen. Du lernst, fehlende Zustände und Übergänge in einer realen Situation zu erkennen und zu ergänzen.',
    'chapter4.story.coinMachine':
        'Dieser Verkaufsautomat nimmt jeweils eine Münze an. Eingabe 1 fügt eine Münze hinzu; Eingabe 0 bricht ab. Nach zwei Münzen gibt er das Getränk aus.',
    'chapter4.story.stateMeaning':
        'Übersetze die Geschichte zuerst in Zustände: q0 bedeutet keine Münze, q1 eine Münze und q2 gibt das Getränk aus.',
    'chapter4.story.missingTransition':
        'Jetzt ergänzen wir die fehlende Reaktion. Von q1 muss eine weitere Münze zum Ausgabezustand q2 führen.',
    'chapter4.story.completenessCheck':
        'Prüfe zum Schluss jeden Zustand: Für jede mögliche Eingabe muss es genau einen passenden Übergang geben.',
    'chapter4.story.summary':
        'Das ist die Methode: Situation lesen, Zustände benennen, fehlende Übergänge ergänzen und jedes Zustand-Eingabe-Paar prüfen.',
    'chapter4.visual.welcome.title': 'Automaten vervollständigen',
    'chapter4.visual.intro.title': 'Willkommen in Kapitel 3',
    'chapter4.visual.intro.body':
        'Wir lesen eine Alltagssituation, übertragen sie in Zustände und Übergänge und vervollständigen den Automaten Schritt für Schritt.',
    'chapter4.visual.partial.title': 'Der unvollständige Münzautomat',
    'chapter4.visual.partial.rule':
        'Der Pfeil von q1 für Eingabe 1 fehlt. Die Beschreibung verrät, wohin er führen muss.',
    'chapter4.visual.states.title': 'Was bedeutet q1?',
    'chapter4.visual.transition.title': 'Fehlenden Übergang ergänzen',
    'chapter4.visual.transition.rule':
        'In q1 ist schon eine Münze gespeichert. Die zweite Münze führt zu q2, wo Y = 1 das Getränk ausgibt.',
    'chapter4.visual.check.title': 'Jeden Zustand und jede Eingabe prüfen',
    'chapter4.visual.check.rule':
        'Ein vollständiger deterministischer Automat hat von jedem Zustand je einen Übergang für Eingabe 0 und Eingabe 1.',
    'chapter4.visual.complete.title': 'Der Münzautomat ist vollständig',
    'chapter4.visual.complete.rule':
        'Nutze dieselbe Checkliste: Zustände, Übergänge, dann Vollständigkeit.',
    'chapter4.visual.step': 'Ergänzungsschritt {current} von {total}',
    'chapter4.check.state.question':
        'Welcher Zustand steht für genau eine eingeworfene Münze?',
    'chapter4.check.state.correct': 'Richtig: q1 merkt sich genau eine Münze.',
    'chapter4.check.state.incorrect':
        'q0 hat keine Münze, q1 eine und q2 gibt aus.',
    'chapter4.check.transition.question':
        'Welcher fehlende Übergang passt zur Beschreibung?',
    'chapter4.check.transition.correct':
        'Richtig: q1 --1--> q2 verarbeitet die zweite Münze.',
    'chapter4.check.transition.incorrect':
        'Von q1 ist Eingabe 1 die zweite Münze, also geht es nach q2.',
    'chapter4.check.complete.question':
        'Ist der vervollständigte Automat für 0 und 1 deterministisch und vollständig?',
    'chapter4.check.complete.correct':
        'Ja. Jeder Zustand hat für jede Eingabe genau einen Übergang.',
    'chapter4.check.complete.incorrect':
        'Jeder Zustand braucht genau einen Übergang für 0 und einen für 1.',
    'chapter4.answer.q0': 'q0',
    'chapter4.answer.q1': 'q1',
    'chapter4.answer.q2': 'q2',
    'chapter4.answer.q1toQ2': 'q1 --1--> q2',
    'chapter4.answer.q1toQ0': 'q1 --1--> q0',
    'chapter4.answer.q0toQ2': 'q0 --1--> q2',
    'chapter4.answer.complete': 'Ja, er ist vollständig',
    'chapter4.answer.missing': 'Nein, ein Übergang fehlt',
    'chapter4.answer.duplicate': 'Nein, eine Eingabe hat zwei Übergänge',
    'chapter4.task.coin.prompt':
        'Ein Getränkeautomat startet in q0 (keine Münze, Ausgabe 0). Eingabe 1 wirft eine Münze ein: q0 geht nach q1 (eine Münze, Ausgabe 0), q1 nach q2 (Ausgabe des Getränks, Ausgabe 1). Eingabe 0 bricht ab: Von q0 oder q1 geht es nach q0. Nach der Ausgabe in q2 führen beide Eingaben nach q0. Vervollständige diesen Moore-Automaten.',
    'chapter4.task.coin.instruction':
        'Ergänze den fehlenden Zustand q2, seine Ausgabe und alle fehlenden Übergänge gemäß der Beschreibung.',
    'chapter4.task.coin.hint': 'Die zweite Münze löst q2 aus.',
    'chapter4.test.switch.prompt':
        'Vervollständige den Zwei-Zustands-Lichtschalter. 0 schaltet um; 1 behält die Einstellung.',
    'chapter4.test.switch.instruction':
        'Ergänze den fehlenden Übergang mit Tap-and-Select.',
    'chapter4.test.switch.hint': 'Von q1 schaltet 0 zurück nach q0.',
    'chapter4.test.ticket.prompt':
        'Ein Ticketautomat startet in q0 (wartend, Ausgabe 0). Eingabe 0 ist Zahlung, Eingabe 1 Bestätigung. In q0 führt Zahlung nach q1 (bezahlt, Ausgabe 0), Bestätigung bleibt in q0. In q1 bleibt eine weitere Zahlung in q1, Bestätigung führt nach q2 (Ticket bereit, Ausgabe 1). In q2 startet Zahlung einen neuen Zyklus in q0, Bestätigung bleibt in q2. Ergänze Zustand und Übergänge.',
    'chapter4.test.ticket.instruction':
        'Füge den vorbereiteten Zustand und seine Übergänge mit Tap-and-Select hinzu.',
    'chapter4.test.ticket.hint': 'Der letzte Zustand gibt Y = 1 aus.',
    'chapter4.test.lock.prompt':
        'Ein Codeschloss startet in q0. Eingabe 0 führt von q0 nach q1, von q1 nach q2 und von q2 nach q3. Eingabe 1 führt q0 und q1 nach q0, aber q2 nach q1. Von q3 führen beide Eingaben nach q0. Die Ausgabe ist nur in q3 gleich 1 (entriegelt), in q0, q1 und q2 gleich 0. Vervollständige den Moore-Automaten.',
    'chapter4.test.lock.instruction':
        'Ergänze alle fehlenden vorbereiteten Übergänge mit Tap-and-Select.',
    'chapter4.test.lock.hint': 'Prüfe 0 und 1 getrennt von q2 und q3.',
    'path.chapter5.description.title': 'Aus einer Beschreibung',
    'path.chapter5.description.subtitle': 'Aus einer echten Situation bauen',
    'path.chapter5.tables.title': 'Aus Tabellen',
    'path.chapter5.tables.subtitle': 'Aus Übergangsdaten bauen',
    'chapter5.test.subtitle': 'Erstelle drei verschiedene Automaten.',
    'chapter5.test.coffee.prompt':
        'Erstelle einen Moore-Automaten für einen Kaffeeautomaten. Er startet in WAITING mit Ausgabe WAIT. Eine Münze führt nach PAID mit Ausgabe CHOOSE. Getränkewahl oder Abbruch führen zurück nach WAITING. Andere Ereignisse erhalten den aktuellen Zustand.',
    'chapter5.test.coffee.instruction':
        'Erstelle die zwei Zustände, lege ihre Ausgaben und den Anfangszustand fest. Definiere für jeden Zustand die Übergänge für coin, choose drink und cancel. Ereignisse ohne beschriebenen Zustandswechsel erhalten eine Selbstschleife.',
    'chapter5.test.coffee.hint':
        'Nur coin führt von WAITING zu PAID. Beide Aktionen aus PAID führen zu WAITING.',
    'chapter5.test.locker.prompt':
        'Ein Paketfach ist leer und speichert dann ein Paket. Die richtige PIN öffnet es; eine falsche PIN lässt es gesperrt; das Schließen macht es wieder leer. Erstelle den Automaten.',
    'chapter5.test.locker.instruction':
        'Erstelle die drei fertigen Zustände und verbinde jedes beschriebene Ereignis mit Tap-and-Select.',
    'chapter5.test.locker.hint':
        'wrong PIN ist eine Schleife auf PARCEL STORED.',
    'chapter5.test.washingMachine.prompt':
        'Erstelle einen Moore-Automaten, der in IDLE mit Ausgabe READY startet. Die Ereignisse start, wash done, rinse done und door opened führen über WASHING (WASH), RINSING (RINSE), DONE (DONE) zurück nach IDLE. Andere Ereignisse erhalten den aktuellen Zustand.',
    'chapter5.test.washingMachine.instruction':
        'Erstelle die vier Zustände, lege ihre Ausgaben und den Anfangszustand fest. Definiere für jeden Zustand und jedes Ereignis genau einen Übergang. Nutze Selbstschleifen für Ereignisse ohne Zustandswechsel.',
    'chapter5.test.washingMachine.hint':
        'Folge der realen Reihenfolge: start, wash done, rinse done, door opened.',
    'task.chapter2.buildTable.prompt':
        'Welche Tabelle beschreibt die Schaltung korrekt?',
    'task.chapter2.buildTable.instruction':
        'Lies S₁S₀, verfolge die Gatter, wende CLK an und erstelle die Tabelle.',
    'task.chapter2.buildTable.hint':
        'Werte für jeden Zustand und jeden Eingangswert die Logik aus und übernimm das Ergebnis mit dem Takt als Folgezustand.',
    'task.chapter2.stateCode.prompt': 'Welchen Zustand stellt S₁S₀ = 10 dar?',
    'task.chapter2.stateCode.instruction':
        'Lies die beiden gespeicherten Bits von links nach rechts.',
    'task.chapter2.stateCode.hint': 'S₁ hat den Wert 2 und S₀ den Wert 1.',
    'answer.stateCodeTwo': 'S = 2',
    'answer.stateCodeOne': 'S = 1',
    'answer.stateCodeInvalid': 'Dieses Bitpaar ist kein Zustand',
    'task.chapter2.mooreOutput.prompt':
        'Wie lautet der Ausgang beim aktuellen Zustand S = 2?',
    'task.chapter2.mooreOutput.instruction':
        'Lies die Ausgangslogik des gespeicherten Zustands. Verwende A nicht direkt.',
    'task.chapter2.mooreOutput.hint':
        'Bei einem Moore-Automaten liest du Y aus dem gespeicherten Zustand ab. Der Eingang A gehört nicht zu dieser Abfrage.',
    'answer.outputStateTwo': 'Y = 1, weil S = 2',
    'answer.outputStateZero': 'Y = 0, weil S = 0',
    'answer.outputInputA': 'Y entspricht direkt A',
    'task.chapter2.gatesAnd.prompt':
        'Welchen Ausgang liefert AND bei den Eingängen 0 und 1?',
    'task.chapter2.gatesAnd.instruction': 'Wähle den Ausgangswert.',
    'task.chapter2.gatesAnd.hint':
        'AND liefert nur dann 1, wenn beide Eingänge 1 sind.',
    'task.chapter2.gatesOr.prompt':
        'Welchen Ausgang liefert OR bei den Eingängen 0 und 1?',
    'task.chapter2.gatesOr.instruction': 'Wähle den Ausgangswert.',
    'task.chapter2.gatesOr.hint':
        'OR liefert 1, wenn mindestens ein Eingang 1 ist.',
    'chapter1.final.determinism.prompt':
        'Wie viele ausgehende Übergänge darf es bei einem deterministischen FSM je Zustand und Eingabe geben?',
    'chapter1.final.mooreOutput.prompt':
        'Ein Moore-FSM startet in q0 mit Ausgabe 0. Eingabe 1 führt nach q1, dessen Ausgabe 1 ist. Welche Ausgabe ist nach dem Übergang aktiv?',
    'chapter1.final.trace.prompt':
        'Beginne in q0 und verfolge zuerst die Eingabe 1, dann 0. Welcher Zustand wird erreicht?',
    'chapter1.final.complete.prompt':
        'Ist der gezeigte FSM für das Eingabealphabet {start, stop} vollständig?',
    'chapter1.final.conflict.prompt':
        'Wähle alle Übergänge aus, die einen Konflikt verursachen: gleicher Zustand und gleiche Eingabe, aber verschiedene Ziele.',
    'chapter1.final.edge.q0q1': 'q0 --0--> q1',
    'chapter1.final.edge.q0q2': 'q0 --0--> q2',
    'chapter1.final.edge.q1q2': 'q1 --1--> q2',
    'chapter2.final.andTable.prompt':
        'Leite mit der gezeigten AND-Schaltung alle Einträge der Übergangs- und Ausgabetabelle her.',
    'chapter2.final.mixedTable.prompt':
        'Lies die Schaltung mit mehreren Gattern und erstelle ihre Übergangs- und Ausgabetabellen.',
    'chapter2.final.xorTable.prompt':
        'Leite mit der gezeigten XOR-Schaltung alle Einträge der Übergangs- und Ausgabetabelle her.',
    'chapter2.final.stateBits.prompt':
        'Wie viele verschiedene Bitmuster lassen sich mit zwei Zustandsbits darstellen, bevor ungenutzte Codes ausgeschlossen werden?',
    'chapter2.final.xor.prompt':
        'Welchen Wert gibt XOR aus, wenn beide Eingänge 1 sind?',
    'chapter4.final.completeness.prompt':
        'Ist ein deterministischer FSM vollständig, wenn für ein Zustand-Eingabe-Paar kein Übergang definiert ist?',
    'chapter4.final.transitionCount.prompt':
        'Wie viele Übergänge braucht ein vollständiger deterministischer FSM mit drei Zuständen und zwei Eingabesymbolen?',
    'chapter4.answer.fiveTransitions': '5 Übergänge',
    'chapter4.answer.sixTransitions': '6 Übergänge',
    'chapter4.answer.sevenTransitions': '7 Übergänge',
    'chapter4.task.water.prompt':
        'Vervollständige den Moore-Wasserstandsregler. Eingabe 0 leert den Tank, Eingabe 1 füllt ihn. Bei vollem Tank ist der Ausgang 1.',
    'chapter4.task.water.instruction':
        'Ergänze den fehlenden Übergang aus HIGH für Eingabe 1.',
    'chapter4.task.water.hint':
        'Ein bereits voller Tank bleibt bei Eingabe 1 im Zustand HIGH.',
    'chapter4.task.pump.prompt':
        'Vervollständige den Mealy-Pumpenregler mit einem Zustand: Sensor = 1 startet die Pumpe, Sensor = 0 stoppt sie.',
    'chapter4.task.pump.instruction':
        'Ergänze die fehlende Selbstschleife sensor = 0 / STOP PUMP.',
    'chapter4.task.pump.hint':
        'Ein Mealy-Übergang enthält sowohl Sensoreingabe als auch Pumpenausgabe.',
    'chapter5.tables.practice.prompt':
        'Erstelle den Mealy-Automaten aus der gezeigten Übergangstabelle mit drei Zuständen.',
    'chapter5.tables.practice.hint':
        'Übertrage jeden vorgegebenen Tabelleneintrag in einen Übergang und behalte Eingabe/Ausgabe bei.',
    'chapter5.completion.second.prompt':
        'Vervollständige den dreizuständigen Moore-Automaten. Eingabe 0 führt im Kreis q0 -> q1 -> q2 -> q0. Bei Eingabe 1 gilt: q0 -> q2, q1 -> q0 und q2 -> q1. q0 und q2 geben 1 aus, q1 gibt 0 aus.',
    'chapter5.completion.second.hint':
        'Prüfe den fehlenden Übergang von q2 für Eingabe 1.',
    'chapter5.completion.third.prompt':
        'Vervollständige den Moore-Automaten mit zwei Zuständen. Eingabe 0 wechselt zwischen q0 und q1; Eingabe 1 lässt den Zustand unverändert. q0 gibt 0, q1 gibt 1 aus.',
    'chapter5.completion.third.hint':
        'Ergänze die fehlende Ausgabe in q0 und die fehlende Schleife von q1 für Eingabe 1.',
    'chapter5.diagnostics.missingTransition.prompt':
        'In welchem Zustand fehlt im gezeigten Automaten ein ausgehender Übergang für Eingabe 1?',
  },
  AppLanguage.ru: {
    ...taskFeedbackRu,
    'fsmFeedback.noStates': 'Добавь состояния перед проверкой автомата.',
    'fsmFeedback.missingInitialState': 'Выбери начальное состояние автомата.',
    'fsmFeedback.unknownInitialState':
        'Начальная стрелка должна указывать на существующее состояние.',
    'fsmFeedback.duplicateStateId':
        'Состояние {state} встречается несколько раз. Используй уникальные обозначения состояний.',
    'fsmFeedback.missingStateOutput': 'Задай выход Мура для состояния {state}.',
    'fsmFeedback.missingTransitionOutput':
        'Для перехода из {state} по входу {input} нужен выход Мили.',
    'fsmFeedback.emptyTransitionSymbol':
        'Выбери вход для перехода из состояния {state}.',
    'fsmFeedback.unknownTransitionEndpoint':
        'Проверь концы перехода из {state} по входу {input}. Оба должны быть существующими состояниями.',
    'fsmFeedback.nondeterministicTransition':
        'Из состояния {state} выходит несколько переходов по входу {input}. Оставь ровно один переход для этого входа.',
    'fsmFeedback.missingTransition':
        'Из состояния {state} нет перехода по входу {input}. Добавь переход для этого состояния и входа.',
    'fsmFeedback.unknownInputSymbol':
        'Вход {input} в состоянии {state} не входит в алфавит задания. Используй одно из показанных действий.',
    'fsmFeedback.behaviorMismatch':
        'Автомат пока не соответствует условию задания. Проверь его переходы и выходы.',
    'fsmFeedback.incompleteTrace':
        'Проверь последовательность выходов: её значения или длина пока не соответствуют заданию.',
    'fsmTable.state': 'Состояние',
    'fsmTable.input': 'Вход',
    'fsmTable.nextState': 'Следующее состояние',
    'fsmTable.output': 'Выход',
    'sandbox.action.tables': 'Таблицы',
    'sandbox.action.check': 'Проверить',
    'sandbox.action.simulate': 'Симуляция',
    'sandbox.panel.close': 'Закрыть панель',
    'sandbox.tables.title': 'Таблицы твоего автомата',
    'sandbox.tables.empty':
        'Сначала добавь состояния. Таблицы строятся по твоему рисунку.',
    'sandbox.tables.noTransitions':
        'Переходов пока нет. Каждый вход, который ты используешь на переходе, станет строкой таблицы.',
    'sandbox.tables.alphabet': 'Использованные входы: {symbols}',
    'sandbox.tables.transitionTitle': 'Таблица переходов',
    'sandbox.tables.outputTitle': 'Таблица выходов',
    'sandbox.tables.legend':
        '→ отмечает начальное состояние, - значит, перехода нет, ⚠ значит, что для одного состояния и входа есть несколько переходов.',
    'sandbox.check.title': 'Проверка структуры',
    'sandbox.check.ok':
        'Ошибок в структуре нет: у каждого состояния ровно один переход для каждого использованного входа, и все выходы заданы.',
    'sandbox.check.issues':
        'Найдено проблем: {count}. Затронутые состояния отмечены красным.',
    'sandbox.check.scope':
        'Проверка учитывает только нарисованные входы. Решает ли автомат конкретную задачу, она не показывает.',
    'sandbox.sim.title': 'Симуляция',
    'sandbox.sim.inputLabel': 'Последовательность входов',
    'sandbox.sim.inputHint': 'например, 1 0 1 или монета, проход',
    'sandbox.sim.alphabet': 'Возможные входы: {symbols}',
    'sandbox.sim.run': 'Запустить',
    'sandbox.sim.first': 'В начало',
    'sandbox.sim.previous': 'Предыдущий шаг',
    'sandbox.sim.next': 'Следующий шаг',
    'sandbox.sim.last': 'В конец',
    'sandbox.sim.step': 'Шаг {step} из {total}',
    'sandbox.sim.outputs': 'Выходы: {outputs}',
    'sandbox.sim.noTransitions':
        'Сначала нарисуй переходы, потом можно будет симулировать входы.',
    'sandbox.sim.emptyInput': 'Укажи хотя бы один вход.',
    'sandbox.sim.done': 'Все входы обработаны.',
    'sandbox.sim.stop.missingInitialState':
        'У автомата нет начального состояния. Задай его перед симуляцией.',
    'sandbox.sim.stop.unknownSymbol':
        'Вход {input} не встречается ни на одном переходе.',
    'sandbox.sim.stop.missingTransition':
        'Симуляция остановилась в состоянии {state}: для входа {input} нет перехода.',
    'sandbox.sim.stop.nondeterministicTransition':
        'Симуляция остановилась в состоянии {state}: для входа {input} есть несколько переходов.',
    'lesson.submitTest': 'Завершить тест',
    'creation.test.washingMachine.prompt':
        'Стиральная машина Мура начинает в IDLE (выход READY). start ведёт в WASHING (выход WASH), wash done - в RINSING (выход RINSE), rinse done - в DONE (выход UNLOCK), door opened - обратно в IDLE. Построй автомат. Для каждого события, не описанного иначе в данном состоянии, добавь петлю: состояние и его выход остаются прежними.',
    'creation.test.locker.prompt':
        'Ячейка Мура начинает в LOCKER EMPTY (выход AVAILABLE). Посылка переводит её в PARCEL STORED (выход LOCKED). Верный PIN открывает дверь: DOOR OPEN (выход OPEN). Неверный PIN оставляет дверь запертой. Закрытие двери возвращает в LOCKER EMPTY. Построй автомат. Для каждого события, не описанного иначе в данном состоянии, добавь петлю: состояние и его выход остаются прежними.',
    'creation.test.coffee.prompt':
        'Кофейный автомат Мура начинает в WAITING (выход INSERT COIN). Монета переводит его в PAID (выход CHOOSE DRINK). Выбор напитка или отмена возвращают в WAITING. Отмена во время ожидания ничего не меняет. Построй автомат. Для каждого события, не описанного иначе в данном состоянии, добавь петлю: состояние и его выход остаются прежними.',
    'creation.description.test.prompt':
        'Практика: автомат посылок начинает в EMPTY (выход READY). Посылка переводит его в PARCEL STORED (выход LOCKED), верный код - в PICKUP OPEN (выход OPEN). Неверный код оставляет ячейку запертой. Закрытие дверцы возвращает в EMPTY. Построй автомат Мура. Для каждого события, не описанного иначе в данном состоянии, добавь петлю: состояние и его выход остаются прежними.',
    'creation.tables.task.prompt':
        'Построй автомат Мура для шлагбаума по показанным таблицам переходов и выходов. Начальное состояние - q0.',
    'creation.tables.task.hint':
        'Используй обе таблицы. Из q1 событие ticket ведёт в q2, а timeout возвращает в q0. Начальное состояние - q0.',
    'creation.defaultRule':
        'Для каждого события, не описанного иначе в данном состоянии, добавь петлю: состояние и его выход остаются прежними.',
    'creation.check.incorrect':
        'Проверь событие: получение велосипеда или проверка следующего билета ведёт из q1 в q2.',
    'creation.check.correct': 'Верно: это событие ведёт из q1 в q2.',
    'creation.check.tables':
        'Прочитай таблицу переходов: куда ведёт ticket из q1?',
    'creation.check.description':
        'Код принят (q1). В какое состояние перейдёт автомат, когда велосипед заберут?',
    'path.chapter4.locked': 'Пройди тест главы 2',
    'path.chapter4.test.title': 'Тест главы 3',
    'path.chapter4.title': 'Глава 3: Дополнение автоматов',
    'lesson.summary.automata-creation-test':
        'Самостоятельно построй три новых автомата. Для прохождения достаточно двух верных решений.',
    'lesson.summary.automata-creation-tables':
        'Построй автомат Мура по таблицам переходов и выходов парковочного шлагбаума.',
    'lesson.summary.automata-creation-description':
        'Выделяй состояния, выходы и переходы из описаний проката велосипедов и автомата для посылок.',
    'creation.test.subtitle': '3 автомата · 15 минут · достаточно 2 верных',
    'creation.path.test.subtitle':
        '3 практических задания · достаточно 2 верных',
    'creation.path.test.title': 'Тест главы 4',
    'creation.path.tables.subtitle': '1 задание на построение',
    'creation.path.description.subtitle': '2 задания на построение',
    'creation.path.locked': 'Пройди тест главы 3',
    'creation.path.unlocked': 'Раздел создания автоматов открыт',
    'creation.path.title': 'Глава 4: Создание автоматов',
    'creation.description.title': 'Создание автоматов: описание',
    'creation.description.welcome.title': 'Добро пожаловать в главу 4',
    'automata-creation-description.welcome':
        'Добро пожаловать в главу 4. Ты научишься создавать автоматы по описаниям реальных ситуаций.',
    'creation.description.welcome.body':
        'Сначала вместе выведем автомат проката велосипедов. Затем ты построишь его самостоятельно и применишь метод к автомату для посылок.',
    'creation.description.subtitle': 'От жизненной ситуации к FSM',
    'creation.tables.title': 'Создание автоматов: таблицы',
    'creation.tables.subtitle': 'От таблиц переходов и выходов к FSM',
    'automata-creation-description.story.0':
        'Сначала прочитай всю ситуацию. На станции проката велосипед остаётся заблокированным, пока не принят верный код. После возврата станция снова готова.',
    'automata-creation-description.story.1':
        'Преврати ситуации из рассказа в состояния: BIKE LOCKED, CODE ACCEPTED и BIKE TAKEN. Начни с q0 = BIKE LOCKED.',
    'automata-creation-description.story.2':
        'Теперь добавляй события по шагам: valid code ведёт в CODE ACCEPTED, wrong code оставляет BIKE LOCKED, а take bike ведёт в BIKE TAKEN.',
    'automata-creation-description.story.3':
        'Граф следует из описания. Теперь самостоятельно построй автомат проката велосипедов, а затем примени метод к автомату для посылок.',
    'automata-creation-tables.story.0':
        'Тот же метод работает с таблицами. Для парковочного шлагбаума уже записаны состояния, события и выходы.',
    'automata-creation-tables.story.1':
        'Таблица переходов показывает, куда ведёт каждое событие: состояние, событие, следующее состояние.',
    'automata-creation-tables.story.2':
        'Таблица выходов показывает действие шлагбаума в каждом состоянии. Держи вместе состояние, выход и переходы.',
    'automata-creation-tables.story.3':
        'Используй обе таблицы, чтобы создать автомат шлагбаума через tap-and-select.',
    'creation.description.visual.0.title': '1. Прочитай ситуацию',
    'creation.description.visual.0.body':
        'Описание - это спецификация. Сначала выдели ситуации и события, не рисуя граф.',
    'creation.description.visual.1.title': '2. Создай состояния',
    'creation.description.visual.1.body':
        'Создай q0, q1 и q2 для BIKE LOCKED, CODE ACCEPTED и BIKE TAKEN. Назначь q0 начальным.',
    'creation.description.visual.2.title': '3. Добавь переходы',
    'creation.description.visual.2.body':
        'Переводи каждое предложение в стрелку: событие на стрелке, ситуация назначения в её конце.',
    'creation.description.visual.3.title': '4. Проверь автомат',
    'creation.description.visual.3.body':
        'Теперь представлены все три ситуации и пять событий. Проверь, что у каждого события есть понятное назначение.',
    'creation.tables.visual.0.title': 'Парковочный шлагбаум',
    'creation.tables.visual.0.body':
        'Таблицы могут описать тот же автомат без начального рисунка.',
    'creation.tables.visual.1.title': 'Таблица переходов',
    'creation.tables.visual.1.body':
        'Преврати каждую пару "состояние - событие" из таблицы в стрелку.',
    'creation.tables.visual.2.title': 'Таблица выходов',
    'creation.tables.visual.2.body':
        'Выход принадлежит текущему состоянию: STOP, WAIT или GO.',
    'creation.tables.visual.3.title': 'Создай в Sandbox',
    'creation.tables.visual.3.body':
        'Читай таблицы построчно и построй граф через tap-and-select.',
    'creation.description.task.prompt':
        'Прокат велосипедов Мура начинает в BIKE LOCKED (выход WAIT). valid code ведёт в CODE ACCEPTED (выход UNLOCK), wrong code оставляет велосипед запертым. take bike ведёт из CODE ACCEPTED в BIKE TAKEN (выход RIDE), timeout возвращает из CODE ACCEPTED в BIKE LOCKED, return bike - из BIKE TAKEN в BIKE LOCKED. Построй автомат. Для каждого события, не описанного иначе в данном состоянии, добавь петлю: состояние и его выход остаются прежними.',
    'creation.description.task.instruction':
        'Используй tap-and-select: добавь состояния, назначь q0 начальным, затем выбирай каждый переход и нажимай его начало и конец.',
    'creation.description.task.hint':
        'Неверный код оставляет велосипед заблокированным; верный ведёт к CODE ACCEPTED.',
    'creation.description.test.instruction':
        'Выдели состояния и события из описания и построй полный FSM через tap-and-select.',
    'creation.description.test.hint':
        'Переход wrong code образует петлю на PARCEL STORED, а valid code ведёт в PICKUP OPEN.',
    'creation.tables.task.instruction':
        'Добавь состояния, назначь q0 начальным и перенеси каждую строку таблицы в переход через tap-and-select.',
    'creation.test.coffee.instruction':
        'Создай два готовых состояния и все переходы через tap-and-select.',
    'creation.test.coffee.hint':
        'Только coin переводит WAITING в PAID. Оба действия из PAID ведут в WAITING.',
    'creation.test.locker.instruction':
        'Создай три готовых состояния и соедини каждое событие через tap-and-select.',
    'creation.test.locker.hint': 'wrong PIN - петля на PARCEL STORED.',
    'creation.test.washingMachine.instruction':
        'Создай четыре готовых состояния и соедини цикл через tap-and-select.',
    'creation.test.washingMachine.hint':
        'Следуй реальному порядку: start, wash done, rinse done, door opened.',
    'fsmWorkspace.transitionOutput': 'Выход перехода',
    'fsmWorkspace.setTransitionOutput': 'Задать выход перехода',
    'fsmWorkspace.resetView': 'Сбросить вид',
    'fsmWorkspace.setTransitionOutputHint':
        'Сейчас ты задаёшь выход для перехода {from} → {to} при входе {input}. Вход при этом не меняется.',
    'taskInteraction.actionAlphabet': 'Действия: {mapping}.',
    'taskInteraction.chapter2Legend':
        '\u041e\u0431\u043e\u0437\u043d\u0430\u0447\u0435\u043d\u0438\u044f: S₁S₀ - \u043a\u043e\u0434 \u0442\u0435\u043a\u0443\u0449\u0435\u0433\u043e \u0441\u043e\u0441\u0442\u043e\u044f\u043d\u0438\u044f; A - \u0432\u0445\u043e\u0434; CLK - \u0442\u0430\u043a\u0442\u043e\u0432\u044b\u0439 \u0438\u043c\u043f\u0443\u043b\u044c\u0441; S₁′S₀′ - \u0441\u043b\u0435\u0434\u0443\u044e\u0449\u0435\u0435 \u0441\u043e\u0441\u0442\u043e\u044f\u043d\u0438\u0435; Y - \u0432\u044b\u0445\u043e\u0434.',
    'lesson.start.skipOnce': 'Один раз попробовать сразу тесты',
    'lesson.start.skipHint':
        'Уже знаком с темой? Перейди сразу к тестам. Чтобы пройти урок без объяснения, получи все 3 звезды: реши каждое задание правильно с первой попытки. Одна попытка на урок; при ошибке откроется объяснение. Выход тоже расходует попытку.',
    'lesson.start.skipUnavailable':
        'Не удалось сохранить попытку. Начни урок обычным способом.',
    'lesson.start.skipFailed': 'Пройди объяснение перед повторной попыткой.',
    'lesson.summary.intro':
        'Познакомься с состояниями, начальным состоянием и переходами на примере светофора.',
    'lesson.summary.states':
        'Научись находить состояния, сброс и выходы на диаграммах.',
    'lesson.summary.transitions':
        'Научись читать переходы и прослеживать последовательности входов.',
    'lesson.summary.chapter_test':
        'Проверь знания о состояниях, переходах и выходах.',
    'lesson.summary.chapter2-gates-review':
        'Повтори логические элементы AND, OR, NOT и XOR.',
    'lesson.summary.chapter_2':
        'Разбери схему и составь таблицы переходов и выходов.',
    'lesson.summary.chapter_2_test':
        'Разбери логику схем, составь таблицы и проанализируй биты состояния.',
    'lesson.summary.chapter4-completion':
        'По описанию дополни состояния, переходы, сброс и выходы.',
    'lesson.summary.chapter_4_test':
        'Самостоятельно дополни автоматы по заданным требованиям.',
    'lesson.summary.chapter5-theory':
        'Ответь на три вопроса о Moore, Mealy и временном поведении.',
    'lesson.summary.chapter5-tables':
        'Построй автоматы по таблицам переходов и выходов.',
    'lesson.summary.chapter5-completion':
        'Дополни недостающие элементы согласно описанию.',
    'lesson.summary.chapter5-creation':
        'Построй полный автомат по ситуации из условия.',
    'lesson.summary.chapter5-diagnostics':
        'Найди ошибки и проследи поведение автоматов.',
    'fsmWorkspace.chooseEndpointsHint':
        'Укажи, из какой ноды начинается переход и в какую ноду он ведёт.',
    'fsmGuide.addTransitionChooseEndpoints':
        'Нажми {control}, затем исходную и целевую ноды. Выбери действие и, для Mealy, выход из списков.',
    'nav.learn': 'Уроки',
    'nav.sandbox': 'Песочница',
    'nav.progress': 'Прогресс',
    'nav.profile': 'Профиль',
    'nav.settings': 'Настройки',
    'common.back': 'Назад',
    'common.yes': 'Да',
    'common.next': 'Дальше',
    'common.finish': 'Завершить',
    'lesson.storyIntro': 'Разбери пример пошагово.',
    'lesson.storyAcknowledge': 'Я разобрал этот шаг.',
    'lesson.storyWelcomeTitle': 'Цель урока',
    'lesson.storyWelcomeInstruction':
        'Прочитай цель и пойми, какой навык ты будешь тренировать.',
    'lesson.storyRecallTitle': 'Повторение',
    'lesson.storyRecallInstruction':
        'Используй схему, чтобы вспомнить состояния, входы и выходы.',
    'lesson.storyObserveTitle': 'Наблюдай схему',
    'lesson.storyObserveInstruction':
        'Проследи сигнал по схеме, прежде чем делать предсказание.',
    'lesson.storyThinkTitle': 'Сначала подумай',
    'lesson.storyThinkInstruction':
        'Опиши себе следующий шаг и после этого подтверди проверку.',
    'lesson.storyPracticeTitle': 'Упражнение с поддержкой',
    'lesson.storyPracticeInstruction':
        'Реши этот шаг самостоятельно и проверь каждую пару "состояние - вход".',
    'lesson.storySummaryTitle': 'Теперь ты умеешь',
    'lesson.storySummaryInstruction':
        'Сформулируй метод и свяжи его с практическим тестом главы.',
    'common.continue': 'Продолжить',
    'common.down': '\u0412\u043d\u0438\u0437',
    'lesson.completeInteractionFirst': 'Сначала попробуй кнопки на сцене.',
    'common.reset': 'Сброс',
    'common.cancel': 'Отмена',
    'common.add': 'Добавить',
    'common.save': 'Сохранить',
    'answer.true': 'Верно',
    'answer.false': 'Неверно',
    'lesson.taskWrong':
        'Почти получилось! Ещё раз внимательно посмотри на автомат - я уверен, ты найдёшь верный ответ.',
    'taskDifficulty.ss1': 'Лёгкое',
    'taskDifficulty.ss2': 'Среднее',
    'taskDifficulty.ss3': 'Экзаменационный уровень',
    'taskDifficulty.ss4': 'Задание со звёздочкой',
    'taskKind.aa1': 'Что изменится?',
    'taskKind.aa2': 'Поиск ошибки',
    'taskKind.aa3': 'Верно ли построен автомат?',
    'taskKind.aa4': 'Построение автомата',
    'taskKind.aa6': 'Таблица переходов',
    'taskKind.aa7': 'Путь по состояниям',
    'taskKind.aa8': 'Дополнение автомата',
    'taskKind.aa9': 'Вопрос по теории',
    'fsmWorkspace.empty': 'Здесь пока нет ни одного состояния',
    'fsmWorkspace.tapToAdd':
        'Выбери "Добавить состояние", а затем нажми в нужном месте на поле.',
    'fsmWorkspace.transitionSymbol': 'Символ перехода',
    'fsmWorkspace.symbolHint': 'Например: 0, монета, таймер',
    'fsmWorkspace.stateLabel': 'Название состояния',
    'fsmWorkspace.stateLabelHint': 'Например: Заблокирован',
    'fsmWorkspace.customValue': 'Ввести своё значение',
    'fsmWorkspace.customValueHint':
        'Введи название состояния, действие или выход.',
    'fsmWorkspace.transitionSymbolSlashError':
        'Не используй "/" во входном символе: он разделяет вход и выход.',
    'fsmWorkspace.undo': 'Отменить последнее действие',
    'fsmWorkspace.autoArrange': 'Расположить состояния зигзагом',
    'fsmWorkspace.clear': 'Очистить автомат',
    'fsmWorkspace.help': 'HELP',
    'fsmWorkspace.chooseState': 'Выбери название состояния',
    'fsmWorkspace.chooseStateHint':
        'Название и выход уже заполнены - осталось выбрать подходящий вариант.',
    'fsmWorkspace.customState': 'Создать своё состояние',
    'fsmWorkspace.customStateHint':
        'После этого нажми на свободное место на поле.',
    'fsmWorkspace.noOutput': 'У состояния нет выхода',
    'fsmWorkspace.chooseTransition': 'Выбери готовый переход',
    'fsmWorkspace.chooseTransitionHint':
        'Выбери переход с уже заполненными входом и выходом.',
    'fsmWorkspace.customTransition': 'Создать свой переход',
    'fsmWorkspace.customTransitionHint':
        'Исходное и целевое состояния можно выбрать самостоятельно.',
    'fsmWorkspace.chooseEndpoints': 'Выбери начало и конец перехода',
    'fsmWorkspace.fromState': 'Из состояния',
    'fsmWorkspace.toState': 'В состояние',
    'fsmWorkspace.noStatesTitle': 'Сначала добавь состояние',
    'fsmWorkspace.noStatesMessage':
        'Выбери готовое состояние или создай своё, а затем добавляй переход.',
    'fsmGuide.welcome':
        'Сам размещай ноды и стрелки. Имена и выходы выбирай из списков, начальное состояние укажи через сброс.',
    'fsmGuide.customWelcome':
        'Создавай автоматы Мура и Мили по своему усмотрению. Вводи свои названия состояний, символы переходов и выходы, а режим можно менять в любой момент.',
    'fsmGuide.readyWelcome':
        'Сам размещай ноды и стрелки. Имена и выходы выбирай из списков, начальное состояние укажи через сброс.',
    'fsmGuide.select':
        '{control} позволяет выбрать состояние и перетащить его в удобное место.',
    'fsmGuide.addState':
        'Нажми {control}, затем на свободное место. Выбери имя из списка. Выход и сброс добавь отдельно.',
    'fsmGuide.addStateCustom':
        'Нажми {control}, затем на свободное место. Выбери вариант или введи своё название состояния; выход и начальное состояние задай отдельно.',
    'fsmGuide.addStateReady':
        'Нажми {control}, затем на свободное место. Выбери имя из списка. Выход и сброс добавь отдельно.',
    'fsmGuide.addTransition':
        'Нажми {control}, затем исходную и целевую ноды. Выбери действие и, для Mealy, выход из списков.',
    'fsmGuide.addTransitionCustom':
        'Нажми {control}, затем исходную и целевую ноды. Выбери или введи входной символ и, для Mealy, выход перехода.',
    'fsmGuide.addTransitionReady':
        'Нажми {control}, затем исходную и целевую ноды. Выбери действие и, для Mealy, выход из списков.',
    'fsmGuide.setInitial':
        '{control} отмечает состояние, с которого автомат стартует после сброса.',
    'fsmGuide.editOutput':
        'Нажми {control}, затем ноду Moore или стрелку Mealy и выбери выход из списка.',
    'fsmGuide.customize':
        'Удерживай ноду, чтобы переименовать её. Нажми {control}, затем выбери ноду Moore, чтобы изменить выход, переход Moore, чтобы изменить его подпись, или переход Mealy, чтобы задать его выход. Можно выбрать вариант или ввести своё значение.',
    'fsmGuide.delete': '{control} убирает состояние или переход.',
    'fsmGuide.undo': '{control} возвращает последнее изменение.',
    'fsmGuide.clear': '{control} начинает работу с пустым автоматом.',
    'fsmGuide.help': '{control} в любой момент повторит это введение.',
    'fsmGuide.done': 'Готово',
    'fsmGuide.skip': 'Пропустить введение',
    'fsmTool.select': 'Выбрать и переместить',
    'fsmTool.addState': 'Добавить состояние',
    'fsmTool.addTransition': 'Добавить переход',
    'fsmTool.setInitial': 'Назначить начальное состояние',
    'fsmTool.editOutput': 'Задать выход состояния',
    'fsmTool.customize': 'Изменить названия и выходы',
    'fsmWorkspace.stateOutput': 'Выход состояния',
    'fsmWorkspace.stateOutputHint': 'Например: 0, открыт, стоп',
    'fsmTool.delete': 'Удалить ноду или переход',
    'taskInteraction.input': 'Вход: {input}',
    'taskInteraction.check': 'Проверить ответ',
    'taskInteraction.checkAutomaton': 'Проверить автомат',
    'taskInteraction.checkTable': 'Проверить таблицу',
    'taskInteraction.checkTrace': 'Проверить последовательность',
    'aa4Drag.title': 'AA4 · Собери автомат',
    'aa4Drag.hint':
        'Перетащи каждую часть в подходящее место. Также можно нажать на часть, а затем на нужный слот.',
    'aa4Drag.parts': 'Доступные части',
    'aa4Drag.slots': 'Структура автомата',
    'aa4Drag.stateSlot': 'Нода {id}',
    'aa4Drag.transitionSlot': 'Переход {from} → {to}',
    'aa4Drag.initialSlot': 'Маркер начальной ноды',
    'aa4Drag.emptySlot': 'Перетащи часть сюда',
    'aa4Drag.reset': 'Сбросить сборку',
    'aa4Drag.previewEmpty': 'Собранный автомат появится здесь.',
    'aa4Drag.correct': 'Верно: автомат собран правильно.',
    'aa4Drag.incorrect':
        'Некоторые части находятся не на своих местах. Переставь их и проверь ещё раз.',
    'sandboxBuild.correct': 'Верно: автомат соответствует описанию.',
    'sandboxBuild.incorrect':
        'Автомат пока не соответствует описанию. Проверь ноды, выходы, переходы и начальную ноду.',
    'taskInteraction.state': 'q0',
    'taskInteraction.output': 'Выход',
    'taskInteraction.startState': 'Начальное состояние',
    'taskInteraction.afterInput': 'После входного символа {input}',
    'taskInteraction.freeTextHint': 'Напиши свой ответ',
    'taskInteraction.before': 'До изменения',
    'taskInteraction.after': 'После изменения',
    'exitDialog.title': 'Выйти из приложения?',
    'exitDialog.message': 'Мне будет тебя не хватать! Точно хочешь выйти?',
    'exitDialog.confirm': 'Выйти',
    'lessonExit.title': 'Выйти из урока?',
    'lessonExit.message':
        'Если выйти сейчас, прогресс этой попытки не сохранится. Я покажу твой текущий результат, но награды за урок не будет.',
    'lessonExit.stay': 'Остаться',
    'lessonExit.confirm': 'Выйти',
    'common.fsm': 'FSM',
    'mascot.name': 'Фини',
    'onboarding.greeting.message':
        'Привет, я Фини! Добро пожаловать в FSM Quest. Здесь ты шаг за шагом изучишь конечные автоматы: научишься их читать, дополнять и строить сам.',
    'onboarding.greeting.start': 'Поехали',
    'onboarding.username.title': 'Придумай имя пользователя для игры.',
    'onboarding.username.label': 'Имя пользователя',
    'onboarding.username.hint': 'Введи имя пользователя',
    'onboarding.username.helper':
        'Можно выбрать псевдоним - настоящее имя не нужно.',
    'home.unit': 'Раздел 1',
    'home.chapter2.unit': 'Раздел 2',
    'home.title': 'Конечные автоматы',
    'home.subtitle': 'Состояния, переходы и входные строки',
    'settings.title': 'Настройки',
    'settings.language': 'Язык',
    'settings.theme': 'Тема',
    'settings.theme.light': 'Светлая',
    'settings.theme.dark': 'Тёмная',
    'settings.description': 'Выбери удобный язык и оформление приложения.',
    'settings.developerAccess': 'Разблокировать все уровни',
    'settings.developerAccess.description':
        'Режим разработчика: открыть все уроки для тестирования.',
    'settings.credits': 'Credits',
    'settings.credits.lecture':
        'Лекции «Digitaltechnik», Fachgebiet ENCRYPTO, Prof. Dr.-Ing. Thomas Schneider, TU Darmstadt, WiSe 2025/26',
    'settings.credits.close': 'Закрыть',
    'progress.title': 'Прогресс',
    'progress.xp': '{xp} / 100 XP',
    'progress.solvedTasks': 'Решённые задания: {count}',
    'progress.streak': 'Дней подряд: {days}',
    'progress.streakPlural': 'Дней подряд: {days}',
    'lesson.notFound': 'Не получилось найти урок "{lessonId}".',
    'lesson.practicalTest': 'Итоговый тест',
    'lesson.taskCount': 'Задание {current} из {total}',
    'lesson.needHint': 'Подсказать?',
    'lesson.hideHint': 'Скрыть подсказку',
    'lesson.finish': 'Завершить урок',
    'lesson.next': 'Следующее задание',
    'lesson.trace': 'Разберём по шагам',
    'lesson.showNext': 'Показать следующий шаг',
    'lesson.correct': 'Точно! Отличная работа - можно двигаться дальше.',
    'lesson.genericWrong':
        'Почти! Вариант "{selected}" не подходит. Давай ещё раз сверим текущее состояние, входной символ и направление стрелки.',
    'lesson.start.button': 'Начать',
    'lesson.start.rewardHint':
        'Чем точнее ответы, тем больше награда: 1 звезда - 50%, 2 звезды - 75%, 3 звезды - 100%.',
    'lesson.intro.title': 'Знакомство с FSM',
    'lesson.intro.subtitle':
        'Разберём конечный автомат на знакомом примере светофора',
    'lesson.states.title': 'Состояния',
    'lesson.states.subtitle': 'Состояния и типы автоматов: Мур и Мили',
    'lesson.transitions.title': 'Переходы',
    'lesson.transitions.subtitle': 'Входные символы и детерминированные пути',
    'lesson.chapterTest.title': 'Тест главы',
    'lesson.chapterTest.subtitle': '16 вопросов по всей главе',
    'lesson.chapterTest.requirement':
        'Чтобы пройти главу, ответь верно хотя бы на {minimum} из {total} вопросов с первой попытки. Если результат будет ниже, главу придётся пройти заново.',
    'concept.states': 'Состояния',
    'concept.transitions': 'Состояния и переходы',
    'concept.mooreOutput': 'Выход Мура',
    'concept.startState': 'Начальное состояние',
    'concept.currentState': 'Текущее состояние',
    'concept.transitionLabels': 'Метки переходов',
    'concept.errorDiagnosis': 'Диагностика ошибки',
    'concept.practicalSimulation': 'Практическая симуляция',
    'concept.digitalGates': 'Цифровые логические элементы',
    'answer.0': '0',
    'answer.1': '1',
    'answer.2': '2',
    'answer.3': '3',
    'answer.4': '4',
    'answer.5': '5',
    'answer.initialRed': 'Начальное состояние "RED"',
    'answer.randomState': 'Случайное состояние',
    'answer.greenState': 'Состояние "GREEN"',
    'answer.redYellowState': 'Состояние "RED-YELLOW"',
    'answer.yellowState': 'Состояние "YELLOW"',
    'answer.circlesStatesArrowsTransitions':
        'Круги - состояния, стрелки - переходы',
    'answer.circlesTransitionsArrowsStates':
        'Круги - переходы, стрелки - состояния',
    'answer.everythingState': 'И круги, и стрелки - состояния',
    'answer.onlyDefinedArrows': 'Только по заданным стрелкам',
    'answer.anyStateDirectly': 'Напрямую в любое состояние',
    'answer.alwaysResetFirst': 'Только после сброса перед каждым переходом',
    'answer.s0': 'S0',
    'answer.s1': 'S1',
    'answer.onState': 'На состоянии',
    'answer.onInputArrow': 'На стрелке входа',
    'answer.onlyAtEnd': 'Только в конце',
    'answer.startStateS0': 'Начальное состояние S0',
    'answer.lastState': 'Последнее состояние',
    'answer.anyOutputState': 'Любое состояние с выходом',
    'answer.noTransition': 'Нет перехода',
    'answer.transitionS0Input1S1': 'S0 -"1"→ S1',
    'answer.transitionS0Input0S1': 'S0 -"0"→ S1',
    'answer.transitionS1Input1S0': 'S1 -"1"→ S0',
    'answer.wrongTargetState': 'Неверное целевое состояние',
    'answer.wrongInputSymbol': 'Неверный входной символ',
    'answer.noProblem': 'Ошибки нет',
    'answer.input1': 'Вход 1',
    'task.intro.stateCount.prompt':
        'Сколько состояний у показанного ниже FSM светофора?',
    'task.intro.stateCount.instruction':
        'Посчитай отдельные ситуации светофора, изображённые кругами.',
    'task.intro.stateCount.hint':
        'Вспомни "красный", "красный-жёлтый", "зелёный" и "жёлтый".',
    'task.intro.stateCount.feedback.3':
        'Почти! "Красный" и "красный-жёлтый" - два разных состояния.',
    'task.intro.stateCount.feedback.5':
        'Кажется, одно состояние оказалось лишним. На схеме их четыре.',
    'task.intro.reset.prompt':
        'Стрелка "СБРОС" указывает на состояние "красный" светофора. Может ли это быть начальным состоянием?',
    'task.intro.reset.instruction':
        'Рассмотри FSM светофора и выбери "Верно" или "Неверно".',
    'task.intro.reset.hint':
        'Стрелка "СБРОС" должна указывать на известное состояние, с которого автомат может начать работу.',
    'task.intro.reset.feedback.random':
        'Начальное состояние должно быть предсказуемым, поэтому случайный выбор не подходит.',
    'task.intro.reset.feedback.green':
        'Стрелка "СБРОС" указывает на состояние "красный" светофора, поэтому начало задано однозначно.',
    'task.intro.components.prompt':
        'Как правильно прочитать эту схему автомата?',
    'task.intro.components.instruction':
        'Отличи текущую ситуацию от правила, которое её изменяет.',
    'task.intro.components.hint':
        'Состояния показаны кругами, а переходы между ними - стрелками.',
    'task.intro.components.feedback.reversed':
        'Наоборот: круги показывают состояния, а стрелки - переходы.',
    'task.intro.components.feedback.everything':
        'Не совсем: стрелки задают правила смены состояния, но сами состояниями не являются.',
    'task.intro.followTransition.prompt':
        'Сейчас горит "красный". Прошло 60 секунд. Какое состояние будет следующим?',
    'task.intro.followTransition.instruction':
        'Проследи исходящую стрелку из текущего состояния "красный".',
    'task.intro.followTransition.hint':
        'Светофор сначала предупреждает водителей и лишь затем включает зелёный.',
    'task.intro.followTransition.feedback.green':
        '"Зелёный" загорится чуть позже: сначала автомат перейдёт в "красный-жёлтый".',
    'task.intro.followTransition.feedback.yellow':
        'В этом цикле "жёлтый" идёт после "зелёного", а не после "красного".',
    'task.intro.definedPaths.prompt':
        'Может ли автомат перейти напрямую из состояния "красный" в состояние "зелёный"?',
    'task.intro.definedPaths.instruction':
        'Проверь, какие направленные переходы действительно заданы.',
    'task.intro.definedPaths.hint':
        'Автомат меняет состояние, только если на схеме есть подходящий переход.',
    'task.intro.definedPaths.feedback.anyState':
        'Автомат не может придумать короткий путь - он следует только заданным стрелкам.',
    'task.intro.definedPaths.feedback.reset':
        'Сброс задаёт начальную точку, но перед каждым обычным переходом он не нужен.',
    'task.intro.output.prompt': 'Где в автомате Мура задаётся выход?',
    'task.intro.output.instruction':
        'Обрати внимание на разницу между подписями состояний и переходов.',
    'task.intro.output.hint':
        'Выход автомата Мура зависит от текущего состояния.',
    'task.intro.output.step.1': 'S0 / выход 0',
    'task.intro.output.step.2': 'Вход 1 переводит в S1',
    'task.intro.output.step.3': 'S1 / выход 1',
    'task.intro.output.feedback.onInputArrow':
        'Похоже на автомат Мили. Но мы разбираем автомат Мура, а в нём выход относится к состоянию.',
    'task.intro.output.feedback.onlyAtEnd':
        'Выход доступен в каждом текущем состоянии, а не только после всей входной строки.',
    'task.states.start.prompt':
        'Какое состояние активно до чтения первого входного символа?',
    'task.states.start.instruction':
        'Найди особую стартовую стрелку, входящую в схему.',
    'task.states.start.hint':
        'Начальное состояние активно ещё до чтения первого символа.',
    'task.states.start.feedback.lastState':
        'Последнее состояние достигается после обработки входа, а не до неё.',
    'task.states.start.feedback.anyOutputState':
        'У каждого состояния Мура может быть выход, но начало всё равно задаёт стартовая стрелка.',
    'task.states.current.prompt':
        'Входная последовательность: "1", "0". Переходы: S0 -"1"→ S1, S1 -"0"→ S0. В каком состоянии окажется автомат?',
    'task.states.current.instruction':
        'Обрабатывай по одному входному символу.',
    'task.states.current.hint':
        'После входа "1" ты в S1. Затем применяй вход "0" из S1.',
    'task.states.current.step.1': 'Старт в S0',
    'task.states.current.step.2': 'Вход "1": S0 → S1',
    'task.states.current.step.3': 'Вход "0": S1 → S0',
    'task.states.current.feedback.s1':
        'После входа "1" автомат в S1, но вход "0" ведёт из S1 обратно в S0.',
    'task.states.current.feedback.noTransition':
        'Для входа "0" есть определённый переход из S1 в S0.',
    'task.transitions.symbol.prompt':
        'В S0 вход "1" должен вести в S1. Какой переход верный?',
    'task.transitions.symbol.instruction':
        'Проверь исходное состояние, входной символ и целевое состояние.',
    'task.transitions.symbol.hint':
        'Исходное состояние должно быть S0, а входной символ - "1".',
    'task.transitions.symbol.feedback.wrongInput':
        'Целевое состояние верное, но метка входа неверна: нужен вход "1".',
    'task.transitions.symbol.feedback.reversed':
        'Стрелка прочитана наоборот. Переход должен начинаться в S0.',
    'task.transitions.error.prompt':
        'Вход "1" из S0 должен вести в S1, но в решении указано S0 -"1"→ S2. Где ошибка?',
    'task.transitions.error.instruction':
        'Сравни ожидаемый переход с предложенным.',
    'task.transitions.error.hint': 'В обоих переходах входной символ - "1".',
    'task.transitions.error.feedback.wrongInputSymbol':
        'В обоих случаях вход равен "1". Ошибка в целевом состоянии.',
    'task.transitions.error.feedback.noProblem':
        'Ошибка всё-таки есть: при входе "1" стрелка из S0 должна вести в S1, а не в S2.',
    'task.test.simulate.prompt':
        'Проследи вход 101. Переходы: S0 -"1"→ S1, S1 -"0"→ S1, S1 -"1"→ S0. Где окажется автомат?',
    'task.test.simulate.instruction': 'Не спеши: обработай символы по одному.',
    'task.test.simulate.hint': 'После "1" ты в S1; после "0" остаёшься в S1.',
    'task.test.simulate.step.1': 'Старт S0',
    'task.test.simulate.step.2': '"1": S0 → S1',
    'task.test.simulate.step.3': '"0": S1 → S1',
    'task.test.simulate.step.4': '"1": S1 → S0',
    'task.test.simulate.feedback.s1':
        'Первые два символа оставляют тебя в S1, но последний вход "1" переводит из S1 в S0.',
    'task.test.simulate.feedback.noTransition':
        'Все необходимые переходы для этой входной последовательности определены.',
    'task.test.mooreOutput.prompt':
        'Состояние S0 имеет выход 0, S1 - выход 1. После входа 1 автомат в S1. Какой выход показан?',
    'task.test.mooreOutput.instruction':
        'Используй текущее состояние после перехода.',
    'task.test.mooreOutput.hint':
        'Выход Мура привязан к достигнутому состоянию.',
    'task.test.mooreOutput.feedback.0':
        'Выход 0 принадлежит S0. После входа 1 текущее состояние - S1.',
    'task.test.mooreOutput.feedback.input1':
        'Входные символы не являются выходами. Выход - это значение, привязанное к S1.',
    'result.saved': 'Урок пройден!',
    'result.abandoned': 'Ты вышел из урока',
    'result.abandonedLesson': 'Попытка "{lessonId}" не завершена',
    'result.chapterFailed': 'Давай попробуем ещё раз',
    'result.chapterFailedDetail':
        'С первой попытки получилось {score} из {total}. Для прохождения нужно минимум {minimum}, поэтому начнём главу заново - теперь ты уже знаешь, на что обратить внимание!',
    'result.chapterNoRewards':
        'За эту попытку награды нет, но полученный опыт точно пригодится в следующий раз.',
    'result.noRewards':
        'Эта попытка не сохранена, поэтому XP, монеты и звёзды не начислены.',
    'result.saving': 'Секундочку, сохраняю награды…',
    'result.saveFailed': 'Ой, не получилось сохранить прогресс',
    'result.completed': 'Готово: {lessonId}',
    'result.xpEarned': 'Получено XP: {score}',
    'result.firstTryScore': 'Верных ответов с первой попытки: {score}',
    'result.rewards': '+{xp} XP  •  +{coins} монет',
    'result.repeatLesson': 'Пройти урок ещё раз',
    'result.restartChapter': 'Начать главу заново',
    'result.backHome': 'На главную',
    'result.nextLesson': 'Следующий урок',
    'sandbox.canvas': 'Поле конечного автомата',
    'path.intro.title': 'Знакомство с FSM',
    'path.intro.subtitle': '3 задания',
    'path.states.title': 'Состояния',
    'path.states.subtitle': '3 задания',
    'path.transitions.title': 'Переходы',
    'path.transitions.subtitle': '3 задания',
    'path.test.title': 'Тест главы',
    'path.test.subtitle': '5 вопросов',
    'path.chapter2.title': 'Глава 2: Понимание схем DT-FSM',
    'path.chapter2.review.title': 'Повторение: цифровые Gatter',
    'path.chapter2.review.subtitle': '3 задания',
    'path.chapter2.locked': 'Сначала пройди тест главы',
    'path.chapter2.unlocked': 'Ура, новая глава открыта!',
    'path.solved': 'Пройдено',
    'path.continue': 'Продолжим отсюда',
    'path.finalCheck': 'Итоговая проверка',
    'path.locked': 'Закрыто',
    'introFsm.auto': 'Авто',
    'introFsm.nextPhase': 'Далее',
    'introFsm.step.1':
        'Привет! Я Фини, и сегодня мы вместе разберёмся, что такое конечный автомат. Начнём со знакомого примера - светофора!',
    'introFsm.step.2':
        'У немецкого светофора четыре состояния: "красный", "красный-жёлтый", "зелёный" и "жёлтый". Их порядок всегда один и тот же.',
    'introFsm.step.021':
        'У немецкого светофора четыре состояния: "красный", "красный-жёлтый", "зелёный" и "жёлтый". Их порядок всегда один и тот же.',
    'introFsm.step.022':
        'Давай посмотрим на этот светофор поближе - я покажу весь цикл по шагам.',
    'introFsm.step.023':
        'Сейчас горит "красный". Машины стоят, и это одна конкретная ситуация - запомним её.',
    'introFsm.step.024':
        'Через 60 секунд автомат переходит из состояния "красный" в состояние "красный-жёлтый". Водители понимают: скоро можно будет ехать.',
    'introFsm.step.025':
        'Теперь активно состояние "красный-жёлтый". Это отдельная короткая фаза подготовки к "зелёному".',
    'introFsm.step.026':
        'Проходит ещё 10 секунд - и светофор переключается на "зелёный".',
    'introFsm.step.027':
        'Состояние "зелёный" означает, что машины могут ехать.',
    'introFsm.step.028':
        'Через 60 секунд состояние "зелёный" сменяется на "жёлтый".',
    'introFsm.step.029':
        'Состояние "жёлтый" предупреждает: скоро нужно остановиться. Ещё 10 секунд - и цикл вернётся к состоянию "красный".',
    'introFsm.step.3':
        'Смотри, какой аккуратный цикл: "красный" - 60 секунд, "красный-жёлтый" - 10, "зелёный" - 60 и "жёлтый" - 10.',
    'introFsm.step.4':
        'А теперь превратим светофор в конечный автомат, или FSM. Круги будут состояниями, а стрелки между ними - переходами.',
    'introFsm.step.041':
        'Это единственная стартовая стрелка для всего автомата. При запуске или сбросе FSM всегда возвращается в начальное состояние "красный".',
    'introFsm.step.042':
        'Этот круг показывает состояние автомата. Он описывает ситуацию прямо сейчас: горит "красный", значит, машины стоят.',
    'introFsm.step.043':
        'Стрелка - это переход. Когда проходят 60 секунд, автомат меняет состояние - в этом случае из состояния "красный" в состояние "красный-жёлтый".',
    'introFsm.step.044':
        '"красный-жёлтый" - ещё одно состояние. Оно хранит важную информацию: светофор уже готовится включить "зелёный".',
    'introFsm.step.045':
        'У этого перехода условие "10 секунд". Как только время проходит, автомат покидает состояние "красный-жёлтый" и переходит в состояние "зелёный".',
    'introFsm.step.046':
        '"зелёный" - текущее состояние, в котором светофор разрешает машинам ехать.',
    'introFsm.step.047':
        'Через 60 секунд этот переход ведёт от состояния "зелёный" к состоянию "жёлтый". По наконечнику стрелки всегда видно, какая нода будет следующей.',
    'introFsm.step.048':
        'Состояние "жёлтый" предупреждает водителей и даёт им время безопасно остановиться.',
    'introFsm.step.049':
        'Последний переход через 10 секунд возвращает автомат из состояния "жёлтый" в состояние "красный". Готово - все стрелки сложились в понятный цикл!',
    'introFsm.step.5':
        'Отличная работа! Давай попробуем решить пять вопросов про ноды, переходы, сброс и цикл светофора. Проверим, всё ли мы смогли понять?',
    'introFsm.readyTitle': 'Готов к небольшой проверке?',
    'introFsm.readyBody':
        'Впереди 5 вопросов. Постарайся отвечать на все с первой попытки, чтобы получить максимальную награду. Если что-то будет непонятно, я помогу подсказкой.',
    'introFsm.notYet': 'Не сейчас',
    'introFsm.startTasks': 'К заданиям',
    'introFsm.stateExplanation':
        'Текущий сигнал светофора - это состояние. Сигнал таймера - событие, которое запускает следующий переход.',
    'introFsm.state.red': '1. "Красный": стоп',
    'introFsm.state.redYellow': '2. "Красный-жёлтый": приготовиться',
    'introFsm.state.green': '3. "Зелёный": можно ехать',
    'introFsm.state.yellow': '4. "Жёлтый": скоро останавливаемся',
    'introFsm.statesTitle': 'Состояния',
    'introFsm.ruleTitle': 'Правило светофора',
    'introFsm.transition.redToRedYellow':
        '1. "Красный" → "красный-жёлтый" (60 сек.)',
    'introFsm.transition.redYellowToGreen':
        '2. "Красный-жёлтый" → "зелёный" (10 сек.)',
    'introFsm.transition.greenToYellow': '3. "Зелёный" → "жёлтый" (60 сек.)',
    'introFsm.transition.yellowToRed': '4. "Жёлтый" → "красный" (10 сек.)',
    'introFsm.timerTitle': 'Таймер шаг за шагом меняет состояние',
    'introFsm.node.red': 'RED',
    'introFsm.node.redYellow': 'RED-YELLOW',
    'introFsm.node.green': 'GREEN',
    'introFsm.node.yellow': 'YELLOW',
    'introFsm.duration.60': '60 s',
    'introFsm.duration.10': '10 sec',
    'introFsm.fsmExplanation':
        'На схеме FSM каждый круг - это нода, а каждая стрелка - переход к следующей ноде.',
    'statesStory.intro.01':
        'Давай разберем, как называются такие автоматы, показанные в уроке ранее',
    'statesStory.intro.02':
        'В рамках модуля Digitaltechnik в TU Darmstadt проходят 2 типа автоматов (FSM): автомат Mealy и автомат Moore.',
    'statesStory.intro.03':
        'А теперь давай узнаем об автоматах Мили и Мура, и как же их различать! Мы рассмотрим один практический пример на основе турникета - автоматически открывающейся двери, например, при входе в магазин.',
    'statesStory.intro.mealy': 'Автомат мили',
    'statesStory.intro.moore': 'Автомат мура',
    'statesStory.step.01':
        'На предыдущем экране мы увидели общую схему конечного автомата. Теперь на примере турникета разберём, что означает состояние: турникет может быть заблокирован или разблокирован.',
    'statesStory.step.02':
        'По традиции всё множество нод обозначают большой буквой Q, а отдельные ноды называют q0, q1, q2 и так далее. Подписи уточняют их смысл: q0 = "турникет заблокирован", q1 = "турникет разблокирован".',
    'statesStory.step.04':
        'Индекс помогает однозначно ссылаться на состояние, а отдельная подпись раскрывает его смысл. Здесь q0 означает "турникет заблокирован", а q1 - "турникет разблокирован". Номер - лишь идентификатор: q0 не обязано быть начальным или текущим.',
    'statesStory.step.05':
        'Подсветка показывает, что автомат помнит прямо сейчас: активно q0, значит турникет заблокирован.',
    'statesStory.step.06':
        'Твоя очередь управлять турникетом! Следи за текущей нодой, вставь монету и пропусти человека. Турникет откроется и затем автоматически заблокируется.',
    'statesStory.step.07':
        'Конечному автомату (FSM) важнее всего знать, в какой ноде он находится прямо сейчас. Только текущая нода определяет, как автомат реагирует на события и какие значения выдаёт.',
    'statesStory.step.08':
        'Ещё до первого события автомату нужна точка старта. Стрелка "СБРОС" указывает начальную ноду - у нашего турникета это q0.',
    'statesStory.step.09':
        'Стрелка "СБРОС" присутствует в каждом автомате. Она всегда возвращает автомат в начальную ноду, независимо от того, что происходило раньше. Без этой стрелки автомат не является валидным.',
    'statesStory.step.10':
        'Проведём опыт: перейди в q1, а затем нажми "Сброс". Что бы ни происходило раньше, текущим снова станет q0 - "турникет заблокирован".',
    'statesStory.step.11':
        'Наши автоматы не распознают слова, а выдают значения. В автомате Мура выход принадлежит состоянию: q0 выдаёт СТОП, а q1 - ИДИ. Расшифровка под схемой всегда подскажет смысл этих обозначений.',
    'statesStory.step.12':
        'Какое состояние говорит о том, что человеку можно идти через турникет? Сверься с расшифровкой и нажми на ноду, в котором турникет разрешает проход.',
    'statesStory.step.13':
        'Когда автомат попадает в ноду q1, автомат выводит "ИДИ". Выход автомата указан как буква \'y\'. В автомате Мура выход зависит только от текущего состояния.',
    'statesStory.step.14':
        'Автоматы могут выдавать значения двумя способами. В автомате Мура выход принадлежит текущему состоянию, а в автомате Мили - переходу.',
    'statesStory.step.15':
        'Смотри на запись: у Мура выход указан рядом с состоянием - например, "q0 / СТОП". У Мили на стрелке пишут "вход / выход" - например, "монета / ИДИ.',
    'statesStory.step.16':
        'Запусти переход Мили сам. Когда появляется монета, одна стрелка одновременно меняет состояние и выдаёт ИДИ.',
    'statesStory.step.17':
        'Проследим путь вместе: сброс даёт q0/СТОП, монета - q1/ИДИ, а проход возвращает q0/СТОП.',
    'statesStory.step.18':
        'Соберём всё вместе: начальное состояние показывает старт, текущее - положение автомата сейчас, а выход может принадлежать состоянию или переходу.',
    'statesStory.step.19':
        'Отлично! Теперь ты умеешь отслеживать состояния и отличать автомат Мура от автомата Мили. Осталось шесть коротких вопросов - покажи, что всё понял!',
    'statesStory.teachMe': 'Научи меня',
    'statesStory.next': 'Далее',
    'statesStory.startTasks': 'К 6 вопросам',
    'statesStory.state': 'Состояние',
    'statesStory.meaning.q0': 'q0 = "турникет заблокирован"',
    'statesStory.meaning.q1': 'q1 = "турникет разблокирован"',
    'statesStory.event': 'Событие',
    'statesStory.snapshotTitle': 'Один автомат, два возможных состояния',
    'statesStory.locked': 'Locked',
    'statesStory.unlocked': 'Unlocked',
    'statesStory.coin': 'Вставить монету',
    'statesStory.passage': 'Пройти',
    'statesStory.coinShort': 'coin',
    'statesStory.passageShort': 'passage',
    'statesStory.current': 'Текущее состояние подсвечено',
    'statesStory.initial': 'Начальное состояние',
    'statesStory.output': 'Выход состояния',
    'statesStory.output.locked': 'y = STOP',
    'statesStory.output.unlocked': 'y = GO',
    'statesStory.sim.ready':
        'Сейчас турникет заблокирован. Выбери монету или смоделируй проход.',
    'statesStory.sim.coinUnlocked':
        'Монета принята: турникет автоматически открывается; текущее состояние - "Разблокирован".',
    'statesStory.sim.alreadyUnlocked':
        'Турникет уже разблокирован, поэтому новая монета состояние не меняет.',
    'statesStory.sim.passageLocked':
        'Попытка прохода не открывает заблокированный турникет. Состояние остаётся "Заблокирован".',
    'statesStory.sim.passageLockedAgain':
        'Человек прошёл; турникет автоматически закрывается и снова блокируется.',
    'statesStory.sim.resetLocked':
        'Сброс не зависит от прошлых событий и возвращает турникет в "Заблокирован".',
    'statesStory.memoryTitle': 'Длинная история → маленькая память',
    'statesStory.memory.coin': 'монета',
    'statesStory.memory.passage': 'проход',
    'statesStory.memoryRelevant': 'Текущее состояние: "Разблокирован"',
    'statesStory.memoryExplanation':
        'Для следующего решения автомату достаточно текущего состояния - всю прошлую историю хранить не нужно.',
    'statesStory.initialTitle': 'Что делает состояние начальным?',
    'statesStory.initialFact.1': 'Оно активно до первого события или входа.',
    'statesStory.initialFact.2': 'На него указывает особая стартовая стрелка.',
    'statesStory.initialFact.3':
        'В этом автомате назначено одно начальное состояние.',
    'statesStory.outputPicker.title': 'Какое состояние выдаёт ИДИ?',
    'statesStory.outputPicker.prompt':
        'Нажми на состояние, в котором проход разрешён.',
    'statesStory.outputPicker.locked':
        '"Заблокирован" должен выдавать СТОП. Попробуй другой вариант.',
    'statesStory.outputPicker.unlocked':
        'Точно! Состояние "Разблокирован" выдаёт ИДИ.',
    'statesStory.moore.title': 'Автомат Мура',
    'statesStory.moore.description': 'Выход закреплён за текущим состоянием.',
    'statesStory.mealy.title': 'Автомат Мили',
    'statesStory.mealy.description':
        'Выход закреплён за сработавшим переходом.',
    'statesStory.output.stop': 'y = STOP',
    'statesStory.output.go': 'y = GO',
    'statesStory.moore.transition': 'coin',
    'statesStory.mealy.transition': 'coin / GO',
    'statesStory.placement.title': 'Где записывается выход?',
    'statesStory.placement.state': 'У состояния',
    'statesStory.placement.transition': 'У перехода',
    'statesStory.placement.correct': 'Точно! Мур → состояние, Мили → переход.',
    'statesStory.placement.wrong':
        'Почти! У Мура выходы стоят на состояниях, а у Мили - на переходах.',
    'statesStory.mealy.simulationTitle': 'Запусти переход Мили',
    'statesStory.mealy.simulationRun': 'Вставить монету',
    'statesStory.mealy.simulationReset': 'Начать пример заново',
    'statesStory.mealy.simulationFeedback':
        'Сработал переход "монета / ИДИ: автомат выдал ИДИ и перешёл в "Разблокирован".',
    'statesStory.trace.reset': 'Сброс',
    'statesStory.trace.coin': 'Монета',
    'statesStory.trace.passage': 'Проход',
    'statesStory.trace.next': 'Применить следующий вход',
    'statesStory.trace.restart': 'Начать путь заново',
    'statesStory.rolesTitle': 'Главное о состояниях',
    'statesStory.roles.initial': 'Назначенная точка старта до первого входа.',
    'statesStory.roles.current':
        'Единственное активное состояние прямо сейчас.',
    'statesStory.roles.output':
        'Значение, которое автомат выдаёт, пока это состояние текущее.',
    'statesStory.rolesOverlap':
        'В автомате Мура вместе с текущим состоянием меняется и выход.',
    'statesStory.readyTitle': 'С состояниями разобрались!',
    'statesStory.readyBody':
        'Шесть вопросов помогут закрепить состояния, отслеживание пути, выходы и разницу между автоматами Мура и Мили.',
    'concept.stateOutput': 'Выход состояния',
    'concept.mooreMealy': 'Выходы Мура и Мили',
    'answer.nodeQ0': 'q0',
    'answer.nodeQ1': 'q1',
    'answer.nodeQ2': 'q2',
    'answer.transitionA': 'Стрелка "a"',
    'answer.resetArrow': 'Стрелка "RESET"',
    'answer.transitionQ0AQ1': 'q0 -"a"→ q1',
    'answer.transitionQ0AQ2': 'q0 -"a"→ q2',
    'answer.lockedState': '"Locked"',
    'answer.unlockedState': '"Unlocked"',
    'answer.bothStates': 'Оба состояния одновременно',
    'answer.outputBelongsToState': 'Выход принадлежит текущему состоянию',
    'answer.outputBelongsToTransition':
        'Выход принадлежит только стрелке перехода',
    'answer.outputOnlyAtEnd':
        'Выход появляется только после всей входной строки',
    'answer.mooreStateMealyTransition': 'Мур: у состояний; Мили: у переходов',
    'answer.mooreTransitionMealyState': 'Мур: у переходов; Мили: у состояний',
    'answer.bothOutputsOnStates': 'Оба автомата записывают выходы у состояний',
    'answer.goOutput': '"GO"',
    'answer.stopOutput': '"STOP"',
    'answer.noOutput': 'Выхода нет',
    'task.states.nodes.prompt': 'Выбери все ноды на схеме FSM.',
    'task.states.nodes.instruction':
        'Можно выбрать несколько ответов. Отметь только те элементы, которые являются нодами.',
    'task.states.nodes.hint':
        'Ноды изображены кругами. Стрелки и отметка "СБРОС" нодами не являются.',
    'task.states.initial.prompt':
        'Посмотри на схему. Верно ли q0 обозначена как начальная нода?',
    'task.states.initial.instruction':
        'Рассмотри схему и выбери "Верно" или "Неверно".',
    'task.states.initial.hint':
        'Нода, на которую указывает "RESET", является начальной.',
    'task.states.trace.prompt':
        'Начни с "RESET", затем примени входы "coin" и "passage". Какая нода станет текущей после этих двух входов?',
    'task.states.trace.instruction':
        'После каждого шага оставляй ровно одно текущее состояние.',
    'task.states.trace.hint':
        'После "coin" турникет в состоянии "Unlocked"; "passage" запускает автоматическую блокировку.',
    'task.states.trace.step.1': '"RESET": текущее = "Locked"',
    'task.states.trace.step.2': '"coin": текущее = "Unlocked"',
    'task.states.trace.step.3': '"passage": текущее = "Locked"',
    'task.states.trace.feedback.unlocked':
        '"Unlocked" - промежуточное состояние после "coin"; "passage" возвращает турникет в "Locked".',
    'task.states.trace.feedback.both':
        'В этом примере текущим может быть только одно состояние.',
    'task.states.output.prompt':
        'Где задаётся выход в автоматах Мура, которые мы изучаем?',
    'task.states.output.instruction':
        'Свяжи выдаваемое значение с текущим состоянием.',
    'task.states.output.hint':
        'Когда меняется текущее состояние, вместе с ним меняется и выход Мура.',
    'task.states.output.feedback.transition':
        'Так был бы устроен выход автомата Мили. У нас выход принадлежит состоянию.',
    'task.states.output.feedback.end':
        'У текущего состояния всегда есть выход - ждать конца входной строки не нужно.',
    'task.states.mooreMealy.prompt':
        'Где записываются выходы в автоматах Мура и Мили?',
    'task.states.mooreMealy.instruction':
        'Сопоставь каждый вид автомата с элементом схемы, которому принадлежит выход.',
    'task.states.mooreMealy.hint':
        'У Мура выход связан с состоянием, а у Мили на стрелке записано "вход / выход".',
    'task.states.mooreMealy.feedback.reversed':
        'Ты поменял их местами: Мур использует состояния, а Мили - переходы.',
    'task.states.mooreMealy.feedback.bothStates':
        'Только Мур закрепляет выходы за состояниями. У Мили они принадлежат переходам.',
    'task.states.mealyOutput.prompt':
        'Посмотри на схему автомата Мили. В q0 вставили "coin". Какой выход появится?',
    'task.states.mealyOutput.instruction':
        'Прочитай надпись перехода как "вход / выход".',
    'task.states.mealyOutput.hint':
        'В записи "coin / GO" после косой черты указан выход.',
    'task.states.mealyOutput.step.1': 'Текущее состояние: "Locked"',
    'task.states.mealyOutput.step.2': 'Вход: "coin"',
    'task.states.mealyOutput.feedback.stop':
        '"STOP" относится к заблокированному состоянию из примера Мура. Эта стрелка Мили явно выдаёт "GO".',
    'task.states.mealyOutput.feedback.none':
        'Выход Мили появляется, когда срабатывает переход. Здесь срабатывает "coin / GO".',
    'transitionsStory.step.01':
        'Состояния уже знакомы. Теперь разберём стрелки! Переход - это правило, по которому автомат меняет одно состояние на другое.',
    'transitionsStory.step.02':
        'Каждый переход отвечает на три вопроса: откуда выходим, какое событие произошло и куда попадём?',
    'transitionsStory.step.03':
        'Прочитаем правило вместе: Заблокирован -монета→ Разблокирован. Нажми на каждую часть - я объясню, за что она отвечает.',
    'transitionsStory.step.04':
        'У перехода есть направление: начало стрелки стоит у исходного состояния, а наконечник указывает на целевое. Читать наоборот нельзя - получится другое правило.',
    'transitionsStory.step.05':
        'Теперь попробуй сам: турникет заблокирован, в него вставили монету. Куда ведёт стрелка?',
    'transitionsStory.step.06':
        'Надпись над стрелкой - это событие, или вход. Им может быть кнопка, сигнал таймера или символ 0 либо 1.',
    'transitionsStory.step.07':
        'Важно учитывать текущее состояние. Одно и то же событие в другом состоянии может привести к другому результату или вовсе ничего не изменить.',
    'transitionsStory.step.08':
        'Автомат ходит только по нарисованным стрелкам. Есть A → B, но нет A → C? Значит, напрямую из A в C попасть нельзя.',
    'transitionsStory.step.09':
        'Вернёмся к нашему светофору. Четыре перехода образуют цикл: красный, красный-жёлтый, зелёный, жёлтый - и снова красный.',
    'transitionsStory.step.10':
        'Теперь запусти светофор сам! Подсветка покажет переход, доступный из текущего состояния.',
    'transitionsStory.step.11':
        'Разберём стрелку: Красный -60 секунд→ красный-жёлтый. Здесь есть источник, событие, направление и цель - все части одного перехода.',
    'transitionsStory.step.12':
        'Проследим несколько шагов. После каждого события сначала обновляй текущее состояние и только потом ищи следующую стрелку.',
    'transitionsStory.step.13':
        'Иногда переход возвращает в то же состояние - это петля, или self-loop. Например, толчок не откроет заблокированный турникет.',
    'transitionsStory.step.14':
        'В детерминированном автомате одно состояние и одно событие должны вести не более чем к одной цели. Две разные цели - это конфликт.',
    'transitionsStory.step.15':
        'Моя памятка: проверь источник, событие, направление и цель. Потом убедись, что переход существует и не спорит с другим правилом.',
    'transitionsStory.step.16':
        'Отлично! Теперь ты умеешь читать и проверять переходы. Закрепим навык пятью вопросами, включая знакомый светофор.',
    'transitionsStory.teachMe': 'Научи меня',
    'transitionsStory.startTasks': 'К 5 вопросам',
    'transitionsStory.formulaTitle': 'Переход - направленное правило',
    'transitionsStory.source': 'Исходное состояние',
    'transitionsStory.trigger': 'Событие / вход',
    'transitionsStory.target': 'Целевое состояние',
    'transitionsStory.explorerTitle': 'Заблокирован - монета → Разблокирован',
    'transitionsStory.locked': 'Заблокирован',
    'transitionsStory.coin': 'монета',
    'transitionsStory.unlocked': 'Разблокирован',
    'transitionsStory.push': 'Толкнуть',
    'transitionsStory.explorerPrompt': 'Нажми на один из трёх компонентов.',
    'transitionsStory.explorer.source':
        '"Заблокирован" - источник. Это правило доступно, только когда турникет находится в этом состоянии.',
    'transitionsStory.explorer.trigger':
        'Монета - событие: именно оно запускает этот переход.',
    'transitionsStory.explorer.target':
        '"Разблокирован" - цель: она становится текущей после перехода.',
    'transitionsStory.directionCaption':
        'Следуй наконечнику: Заблокирован → Разблокирован, не наоборот.',
    'transitionsStory.directionQuestion':
        'Какое направление соответствует Заблокирован -монета→ Разблокирован?',
    'transitionsStory.direction.correct': 'Из "Заблокирован" в "Разблокирован"',
    'transitionsStory.direction.reversed':
        'Из "Разблокирован" в "Заблокирован"',
    'transitionsStory.direction.correctFeedback':
        'Именно! Наконечник стрелки указывает на "Разблокирован".',
    'transitionsStory.direction.wrongFeedback':
        'Так стрелка читается задом наперёд, а источник и цель меняются местами.',
    'transitionsStory.triggerTitle': 'Событие запускает переход',
    'transitionsStory.trigger.button': 'нажата кнопка',
    'transitionsStory.trigger.timer': 'истёк таймер',
    'transitionsStory.trigger.symbol': 'символ 0 или 1',
    'transitionsStory.triggerCaption':
        'Надпись на стрелке подсказывает, какое событие запускает переход.',
    'transitionsStory.sourceRule.locked':
        'Из "Заблокирован" монета может привести в "Разблокирован".',
    'transitionsStory.sourceRule.unlocked':
        'В состоянии "Разблокирован" монета не может использовать правило, которое начинается у "Заблокирован".',
    'transitionsStory.toggleCurrent': 'Сменить текущее состояние',
    'transitionsStory.definedCaption':
        'Из A можно попасть в B, потому что есть стрелка. Без A → C состояние C не может быть следующим.',
    'transitionsStory.traffic.red': 'КРАСНЫЙ',
    'transitionsStory.traffic.redYellow': 'КРАСН.-ЖЁЛТ.',
    'transitionsStory.traffic.green': 'ЗЕЛЁНЫЙ',
    'transitionsStory.traffic.yellow': 'ЖЁЛТЫЙ',
    'transitionsStory.traffic.advance': 'Пусть пройдёт {seconds} секунд',
    'transitionsStory.trace.0':
        'Начинаем с красного. Найди исходящую стрелку с условием "60 секунд".',
    'transitionsStory.trace.1':
        'Через 60 секунд: текущее = красный-жёлтый. Следующее событие наступит через 10 секунд.',
    'transitionsStory.trace.2':
        'Через 10 секунд: текущее = зелёный. Следующее событие наступит через 60 секунд.',
    'transitionsStory.trace.3':
        'Ещё 60 секунд: текущее = жёлтый. Мы применяли ровно по одному переходу за шаг.',
    'transitionsStory.trace.next': 'Применить следующий переход',
    'transitionsStory.trace.restart': 'Начать путь заново',
    'transitionsStory.selfLoopCount':
        'Турникет толкнули {count} раз, но текущее состояние осталось "Заблокирован".',
    'transitionsStory.determinism.source': 'Источник',
    'transitionsStory.determinism.targetA': 'Цель A',
    'transitionsStory.determinism.targetB': 'Цель B',
    'transitionsStory.determinism.sameInput': 'одинаковый\nвход',
    'transitionsStory.determinism.check': 'Проверить правила',
    'transitionsStory.determinism.feedback':
        'Вот и конфликт: один источник и один вход предлагают сразу две цели. Автомат не сможет выбрать однозначно.',
    'transitionsStory.summaryTitle': 'Проверка перехода',
    'transitionsStory.summary.source':
        'Начинай с текущего состояния - это источник перехода.',
    'transitionsStory.summary.trigger': 'Сопоставь событие с надписью стрелки.',
    'transitionsStory.summary.direction':
        'Следуй по нарисованному направлению стрелки.',
    'transitionsStory.summary.target':
        'Сделай целевое состояние новым текущим.',
    'transitionsStory.summary.determinism':
        'Не допускай две цели для одного источника и события.',
    'transitionsStory.readyTitle': 'С переходами разобрались!',
    'transitionsStory.readyBody':
        'Впереди пять вопросов про направление стрелок, заданные пути, светофор и детерминизм.',
    'answer.lockedCoinUnlocked': 'Locked -"coin"→ Unlocked',
    'answer.unlockedCoinLocked': 'Unlocked -"coin"→ Locked',
    'answer.lockedPushUnlocked': 'Locked -"passage"→ Unlocked',
    'answer.arrowSourceToTarget': 'От источника к цели',
    'answer.arrowTargetToSource': 'От цели обратно к источнику',
    'answer.arrowHasNoDirection': 'У стрелки нет направления',
    'answer.trafficGreen': '"GREEN"',
    'answer.trafficRedYellow': '"RED-YELLOW"',
    'answer.trafficYellow': '"YELLOW"',
    'answer.onlyExistingTransition':
        'Следовать только существующему переходу из текущего состояния',
    'answer.anyDesiredState': 'Перейти в любое желаемое состояние',
    'answer.skipIntermediateState':
        'Пропустить промежуточное состояние даже без стрелки',
    'answer.deterministicConflict':
        'Один источник и вход ведут в две разные цели',
    'answer.validSelfLoop': 'Переход возвращается в исходное состояние',
    'answer.missingInitialState': 'В переходе не упомянуто начальное состояние',
    'task.transitions.reading.prompt':
        'Проследи схему для входа "coin". Какая нода является текущей в начале и какая - после входа?',
    'task.transitions.reading.instruction':
        'Выбери текущую ноду для обоих этапов пути.',
    'task.transitions.reading.hint':
        'Начни с q0 и пройди по стрелке "coin" в q1.',
    'task.transitions.reading.feedback.reversed':
        'Почти! Стрелка прочитана наоборот, поэтому источник и цель поменялись местами.',
    'task.transitions.reading.feedback.trigger':
        'Направление верное, но метка стрелки - "coin", а не "passage".',
    'task.transitions.direction.prompt':
        'Какое направление описывает стрелка перехода?',
    'task.transitions.direction.instruction':
        'Ориентируйся по началу и наконечнику стрелки.',
    'task.transitions.direction.hint':
        'Наконечник указывает на состояние, которое станет текущим после перехода.',
    'task.transitions.direction.feedback.reversed':
        'Стрелка выходит из источника и направляется к цели.',
    'task.transitions.direction.feedback.none':
        'У стрелки обязательно есть направление. Если развернуть её, получится уже другое правило.',
    'task.transitions.traffic.prompt':
        'Светофор начинает с красного, затем проходят 60 и ещё 10 секунд. Какое состояние станет текущим?',
    'task.transitions.traffic.instruction':
        'На каждом шаге применяй ровно один исходящий переход таймера.',
    'task.transitions.traffic.hint':
        'Через 60 секунд будет красный-жёлтый; затем проследи ещё один переход через 10 секунд.',
    'task.transitions.traffic.step.1': 'Старт: красный',
    'task.transitions.traffic.step.2': '60 секунд: красный → красный-жёлтый',
    'task.transitions.traffic.step.3': '10 секунд: красный-жёлтый → зелёный',
    'task.transitions.traffic.feedback.redYellow':
        'красный-жёлтый - верный результат первого шага, но затем проходит ещё 10 секунд.',
    'task.transitions.traffic.feedback.yellow':
        'Жёлтый появляется позже в цикле после зелёного.',
    'task.transitions.defined.prompt':
        'Как автомат выбирает следующее состояние?',
    'task.transitions.defined.instruction':
        'Используй только правила, заданные для текущего состояния.',
    'task.transitions.defined.hint': 'Нет стрелки - нет такого перехода.',
    'task.transitions.defined.feedback.any':
        'Автомат не выбирает произвольно - он следует подходящей стрелке из текущего состояния.',
    'task.transitions.defined.feedback.skip':
        'Для пропуска нужен отдельный прямой переход. Без него путь недопустим.',
    'task.transitions.determinism.prompt':
        'Выбери оба перехода, которые создают конфликт детерминизма.',
    'task.transitions.determinism.instruction':
        'Найди две стрелки с одинаковыми источником и входом, но разными целями.',
    'task.transitions.determinism.hint':
        'Обе конфликтующие стрелки выходят из q0 по входу "a".',
    'task.transitions.determinism.feedback.selfLoop':
        'Петля - обычный допустимый переход обратно в то же состояние.',
    'task.transitions.determinism.feedback.initial':
        'Обычный переход не обязан упоминать начальное состояние.',
    'mascot.intro.greeting': 'Рад тебя видеть.',
    'mascot.intro.greeting.username': 'Рад тебя видеть, {username}!',
    'mascot.intro.identity':
        'Я буду твоим проводником в FSM Quest: помогу освоиться, разобраться в новых идеях и замечать, как растёт твой прогресс.',
    'mascot.intro.mission':
        'Вместе мы шаг за шагом разберём конечные автоматы - от их основ до чтения, построения и проверки. Сначала покажу, как здесь всё устроено.',
    'mascot.intro.lessonPath':
        'Это твой учебный путь. Начни с выделенного урока: выполняй задания, и постепенно откроются следующие. Если понадобится помощь, я рядом.',
    'mascot.intro.sandbox':
        'А здесь Песочница - наша мастерская. Собирай и меняй автоматы, смотри, что получится. Здесь можно спокойно экспериментировать.',
    'mascot.intro.progress':
        'Здесь видны твои XP, звёзды, решённые задания и серия занятий. Так ты увидишь, как далеко уже продвинулся.',
    'mascot.intro.settings':
        'В настройках можно сменить язык и выбрать светлую или тёмную тему. Это можно сделать в любой момент.',
    'mascot.intro.languages':
        'Выбирай язык, на котором тебе удобнее заниматься: English, Deutsch или Русский. Потом его можно поменять в настройках.',
    'mascot.intro.returnHome':
        'Ну вот, теперь ты знаешь, где что находится. Возвращаемся к учебному пути - дальше покажу, какие главы нас ждут.',
    'mascot.chapterTour.intro':
        'Теперь посмотрим на главы. Я плавно пролистаю их, чтобы ты увидел весь маршрут. Экскурсию можно пропустить в любой момент.',
    'mascot.chapterTour.summary':
        'Вот какой путь нас ждёт: начнём с основ, а потом научимся применять их к более сложным автоматам. Теперь вернёмся к началу и выберем, с чего стартовать.',
    'mascot.chapterTour.skip': 'Пропустить экскурсию',
    'mascot.chapterTour.progress': 'Глава {chapter} из {total}',
    'mascot.chapter1.intro':
        'В Kapitel 1 мы разберём основы конечных автоматов - состояния и переходы - на понятных примерах. А в конце посмотрим, что ты уже умеешь.',
    'mascot.chapter1.choice.title': 'Начинаем Kapitel 1?',
    'mascot.chapter1.choice.body':
        'Если ты уже знаком с основами конечных автоматов, Kapitel 1 можно пропустить и пройти позже.',
    'mascot.chapter1.choice.start': 'Начать Kapitel 1',
    'mascot.chapter1.choice.skip': 'Пропустить',
    'mascot.chapter1.skip.confirmTitle': 'Пропустить Kapitel 1?',
    'mascot.chapter1.skip.confirmBody':
        'Ты точно хочешь пропустить Kapitel 1? За пропуск не начисляются звёзды и XP. Глава останется на карте - ты сможешь пройти её позже. Kapitel 2 откроется сразу.',
    'mascot.chapter1.skip.return': 'Вернуться',
    'mascot.chapter1.skip.confirm': 'Да, пропустить Kapitel 1',
    'mascot.chapter1.startHandoff':
        'Супер! Нажми на выделенный первый урок - и начнём.',
    'mascot.chapter2.skipHandoff':
        'Уже знаком с основами? Тогда не буду долго держать тебя на красном - сразу перейдём к более продвинутым темам! Нажми на выделенный урок Kapitel 2.',
    'path.chapter1.skipped': 'Пропущена',
    'mascot.fallback':
        'Привет, я Фини и буду сопровождать тебя в обучении. Начни с первого урока, а я помогу пройти его шаг за шагом.',
    'transitionsDoorStory.step.01':
        'Добро пожаловать на третий урок! Здесь мы познакомимся поближе с автоматами Мура и Мили, а также узнаем лучше, чем же они различаются',
    'transitionsDoorStory.step.02':
        'Человек подходит к автоматической двери. Какую команду должен дать контроллер, когда датчик присутствия станет равен 1?',
    'transitionsDoorStory.step.03':
        'Значение датчика person - это вход. Команда мотору - выход. Определи оба сигнала до построения автомата.',
    'transitionsDoorStory.step.04':
        'Сначала посмотрим на две реальные ситуации из этого примера: дверь закрыта или открыта. Эти картинки позже станут нодами FSM.',
    'transitionsDoorStory.step.05':
        'Контроллер должен помнить положение двери. Начнём с DOOR IS CLOSED и DOOR IS OPEN, а движение поручим отдельному приводу.',
    'transitionsDoorStory.step.06':
        'Дверь может быть открыта уже в момент запуска контроллера. Поэтому сначала создадим ноду DOOR IS OPEN с выходом OPEN DOOR и отметим её стрелкой сброса.',
    'transitionsDoorStory.step.07':
        'Нужно представить и закрытую дверь. Добавим ноду DOOR IS CLOSED с выходом CLOSE DOOR. Это безопасная стартовая позиция, поэтому теперь стрелка сброса указывает на неё.',
    'transitionsDoorStory.step.08':
        'Если дверь открыта и person становится равен 0, в проходе никого нет. Добавим переход в DOOR IS CLOSED, чтобы выход сменился на CLOSE DOOR.',
    'transitionsDoorStory.step.09':
        'Если дверь закрыта и person становится равен 1, человек подошёл. Добавим переход в DOOR IS OPEN. Теперь автомат Мура собран полностью.',
    'transitionsDoorStory.step.10':
        'Запусти готовый автомат Мура. Обрати внимание на порядок: вход, переход, новая нода, затем выход, записанный в этой ноде.',
    'transitionsDoorStory.step.11':
        'Чтобы превратить Мура в Мили, выходы нельзя оставлять внутри нод: у Мили они записываются на переходах. Сначала уберём оба выхода из нод.',
    'transitionsDoorStory.step.12':
        'Без выходов обе ноды только ждут один и тот же датчик, а отдельная память о положении в этой упрощённой модели не нужна. Объединим их в одну ноду WAIT.',
    'transitionsDoorStory.step.13':
        'При person = 1 автомат Мили должен сразу дать команду открыть дверь. Добавим к WAIT петлю person = 1 / OPEN DOOR.',
    'transitionsDoorStory.step.14':
        'При person = 0 нужна обратная реакция. Добавим person = 0 / CLOSE DOOR. Пошаговый перевод в автомат Мили завершён.',
    'transitionsDoorStory.step.15':
        'Запусти автомат Мили. Нода остаётся WAIT, а каждый вход сразу выбирает выход, записанный на переходе.',
    'transitionsDoorStory.step.16':
        'Сравни решения рядом: Мур помещает действие в ноду, а Мили - в реакцию на вход.',
    'transitionsDoorStory.step.17':
        'Модель с двумя состояниями была специально упрощена. Реальное движение занимает время, поэтому могут понадобиться DOOR IS CLOSED, DOOR IS OPENING, DOOR IS OPEN и DOOR IS CLOSING.',
    'transitionsDoorStory.step.18':
        'Теперь ты знаешь главное различие и его ограничение: Мили часто требует меньше состояний, но только когда процессу не нужна дополнительная память.',
    'transitionsDoorStory.startTasks': 'К практике',
    'transitionsDoorStory.readyTitle': 'Автоматическая дверь готова!',
    'transitionsDoorStory.readyBody':
        'Два вопроса по теории и шесть практических заданий проверят схемы, ошибки, изменения, трассировку и сборку автоматов.',
    'transitionsStory.welcome.title': 'Третий урок',
    'transitionsStory.welcome.models': 'Мур • Мили',
    'transitionsStory.automaticDoor': 'Автоматическая раздвижная дверь',
    'transitionsStory.sensorTitle': 'Датчик передаёт вход',
    'transitionsStory.sensorCaption':
        'Контроллер не видит человека напрямую - он получает сигнал датчика и выполняет подходящий переход.',
    'transitionsStory.input.person': 'Человек обнаружен',
    'transitionsStory.input.clear': 'Проход свободен',
    'transitionsStory.input.opened': 'Полностью открыта',
    'transitionsStory.input.closed': 'Полностью закрыта',
    'transitionsStory.input.personShort': 'PERSON',
    'transitionsStory.input.clearShort': 'CLEAR',
    'transitionsStory.input.openedShort': 'OPENED',
    'transitionsStory.input.closedShort': 'CLOSED',
    'transitionsStory.output.open': 'OPEN',
    'transitionsStory.output.close': 'CLOSE',
    'transitionsStory.output.stop': 'STOP',
    'transitionsStory.predict.title': 'Твоё предположение',
    'transitionsStory.predict.question':
        'Сколько состояний нужно подробной модели двери Мура?',
    'transitionsStory.predict.correct':
        'Точно! У двери четыре разные физические фазы.',
    'transitionsStory.predict.wrong':
        'Это не совсем так. Вспомни, как работает такая дверь: она сначала закрыта, затем датчик видит человека, она начинает открываться, после чего она становится открытой. Если людей нет, она начинает закрываться и в итоге становится закрытой.',
    'transitionsStory.phases.title': 'Открой состояния Мура',
    'transitionsStory.phases.instruction':
        'Нажми на каждую фазу двери и узнай, какой выход создаётся в этом состоянии.',
    'transitionsStory.phase.closed': 'Дверь закрыта',
    'transitionsStory.phase.opening': 'Дверь открывается',
    'transitionsStory.phase.open': 'Дверь открыта',
    'transitionsStory.phase.closing': 'Дверь закрывается',
    'transitionsStory.phases.complete':
        'Отлично! Четыре пары "фаза + выход" готовы стать четырьмя нодами Мура.',
    'transitionsStory.reaction.question':
        'Что должна сделать дверь, когда датчик обнаружит человека?',
    'transitionsStory.reaction.answer.open': 'Открыться',
    'transitionsStory.reaction.answer.stay': 'Остаться закрытой',
    'transitionsStory.reaction.answer.close': 'Закрыться',
    'transitionsStory.reaction.correct':
        'Верно: person = 1 должен создать команду мотору OPEN DOOR.',
    'transitionsStory.reaction.wrong':
        'Попробуй ещё раз: человек должен пройти через дверь.',
    'transitionsStory.signals.title': 'Что является входом и выходом?',
    'transitionsStory.signal.input': 'Вход',
    'transitionsStory.signal.output': 'Выход',
    'transitionsStory.signals.correct':
        'Точно: датчик сообщает данные контроллеру, а контроллер командует мотором.',
    'transitionsStory.signals.wrong':
        'Данные датчика поступают внутрь, а команда мотору выходит наружу.',
    'transitionsStory.stateImages.title': 'Сначала - дверь на картинках',
    'transitionsStory.stateImages.caption':
        'Это реальные ситуации, которые контроллер позже представит формальными обозначениями состояний.',
    'transitionsStory.states.title': 'Автомат запоминает положение двери',
    'transitionsStory.states.actuatorNote':
        'Упрощение: движение здесь мгновенное или выполняется отдельным приводом после команды OPEN DOOR либо CLOSE DOOR.',
    'transitionsStory.construction.progress': 'Шаг {current} из {total}',
    'transitionsStory.mooreSteps.title': 'Построение автомата Мура',
    'transitionsStory.mooreSteps.action.openState':
        'Добавлены стрелка сброса и DOOR IS OPEN / OPEN DOOR.',
    'transitionsStory.mooreSteps.action.closedState':
        'Добавлена DOOR IS CLOSED / CLOSE DOOR, а сброс перенесён на безопасный старт.',
    'transitionsStory.mooreSteps.action.closeTransition':
        'Добавлен переход DOOR IS OPEN - person = 0 → DOOR IS CLOSED.',
    'transitionsStory.mooreSteps.action.openTransition':
        'Добавлен переход DOOR IS CLOSED - person = 1 → DOOR IS OPEN. Автомат Мура готов.',
    'transitionsStory.mealySteps.title': 'Перевод Мура в Мили',
    'transitionsStory.mealySteps.action.removeOutputs':
        'Выходы убраны из нод, потому что у Мили они хранятся на переходах.',
    'transitionsStory.mealySteps.action.mergeStates':
        'Равнозначные ноды объединены в WAIT, потому что команду выбирает сам сигнал датчика.',
    'transitionsStory.mealySteps.action.openTransition':
        'Добавлена первая петля WAIT: person = 1 / OPEN DOOR.',
    'transitionsStory.mealySteps.action.closeTransition':
        'Добавлена person = 0 / CLOSE DOOR. Автомат Мили готов.',
    'transitionsStory.mooreBuild.title': 'Построй автомат Мура',
    'transitionsStory.mooreBuild.outputsInstruction':
        'Сначала назначь выход каждому состоянию.',
    'transitionsStory.mooreBuild.aa4Instruction':
        'Собери автомат Мура из нод, переходов и маркера начальной ноды.',
    'transitionsStory.mooreBuild.sandboxInstruction':
        'Создай автомат в Sandbox: q0 = DOOR IS CLOSED с выходом CLOSE DOOR, q1 = DOOR IS OPEN с выходом OPEN DOOR; q0 - начальная нода. Добавь q0 - person = 1 → q1 и q1 - person = 0 → q0.',
    'transitionsStory.mooreBuild.question.closed':
        'Какой выход назначим ноде DOOR IS CLOSED?',
    'transitionsStory.mooreBuild.question.open':
        'Какой выход назначим ноде DOOR IS OPEN?',
    'transitionsStory.mooreBuild.answerCorrect':
        'Верно: у ноды {state} теперь виден выход {output}.',
    'transitionsStory.mooreBuild.answerWrong':
        'Этот выход не соответствует положению двери. Попробуй другой.',
    'transitionsStory.mooreBuild.transitionsInstruction':
        'Теперь добавь два перехода по сигналам датчика.',
    'transitionsStory.mooreBuild.complete':
        'Готово: у Мура выходы находятся внутри состояний.',
    'transitionsStory.mooreSim.title': 'Запусти автомат Мура',
    'transitionsStory.mooreSim.personAppears': 'Установить person = 1',
    'transitionsStory.mooreSim.personLeaves': 'Установить person = 0',
    'transitionsStory.mooreSim.sequence':
        'вход → переход → новое состояние → выход состояния',
    'transitionsStory.mealyTransform.title': 'Преобразуй Мура в Мили',
    'transitionsStory.mealyTransform.instruction':
        'Перенеси оба выхода из состояний на реакции на входы.',
    'transitionsStory.mealyTransform.aa4Instruction':
        'Собери преобразованный автомат Мили с помощью того же конструктора AA4.',
    'transitionsStory.mealyTransform.sandboxInstruction':
        'WAIT и первая петля уже добавлены. Дополни автомат в Sandbox недостающей петлёй person = 0 / CLOSE DOOR.',
    'transitionsStory.mealyTransform.move': 'Перенести {output} на переход',
    'transitionsStory.mealyTransform.complete':
        'Для этого упрощённого командного контроллера теперь достаточно одного состояния WAIT.',
    'transitionsStory.mealySim.title': 'Запусти автомат Мили',
    'transitionsStory.mealySim.stateStays':
        'WAIT не меняется: состояние и вход сразу определяют выход.',
    'transitionsStory.compare.title': 'Мур и Мили рядом',
    'transitionsStory.compare.moore.states': '2 состояния в этом примере',
    'transitionsStory.compare.moore.output': 'Выход внутри состояния',
    'transitionsStory.compare.moore.reaction':
        'Выход меняется после входа в новое состояние',
    'transitionsStory.compare.mealy.states': '1 состояние в этом примере',
    'transitionsStory.compare.mealy.output': 'Выход на переходе',
    'transitionsStory.compare.mealy.reaction':
        'Состояние и вход определяют выход',
    'transitionsStory.compare.row.location': 'Где находится выход?',
    'transitionsStory.compare.row.location.moore': 'в состоянии',
    'transitionsStory.compare.row.location.mealy': 'на переходе',
    'transitionsStory.compare.row.depends': 'От чего он зависит?',
    'transitionsStory.compare.row.depends.moore': 'состояние',
    'transitionsStory.compare.row.depends.mealy': 'состояние + вход',
    'transitionsStory.compare.row.count': 'Состояния в упрощённом примере',
    'transitionsStory.errors.title': 'Исправь перепутанные выходы',
    'transitionsStory.errors.fix': 'Исправить выходы',
    'transitionsStory.errors.fixed': 'Исправлено',
    'transitionsStory.errors.complete':
        'Верно: person = 1 открывает, person = 0 закрывает.',
    'transitionsStory.realistic.title': 'Вернёмся к реалистичной модели',
    'transitionsStory.realistic.conclusion':
        'Мили не всегда означает меньше состояний. Если контроллер должен помнить движение, состояния DOOR IS OPENING и DOOR IS CLOSING тоже могут быть необходимы.',
    'transitionsStory.ready.title': 'Главная идея понятна',
    'transitionsStory.ready.moore': 'Выход Мура зависит от текущего состояния.',
    'transitionsStory.ready.mealy':
        'Выход Мили зависит от текущего состояния и входа.',
    'transitionsStory.ready.count':
        'Мили часто использует меньше состояний, но не всегда.',
    'transitionsStory.ready.keyPhrase':
        'Мур помещает действие в состояние, а Мили - в реакцию на вход.',
    'transitionsStory.door.open': 'Дверь открыта',
    'transitionsStory.door.closed': 'Дверь закрыта',
    'transitionsStory.machine.moore': 'Автомат Мура',
    'transitionsStory.machine.mealy': 'Автомат Мили',
    'transitionsStory.nodeLegend.q0': 'q0 = "дверь закрыта"',
    'transitionsStory.nodeLegend.q1': 'q1 = "дверь открывается"',
    'transitionsStory.nodeLegend.mealy.q1': 'q1 = "дверь открыта"',
    'transitionsStory.nodeLegend.simple.q0': 'q0 = "дверь закрыта"',
    'transitionsStory.nodeLegend.simple.q1': 'q1 = "дверь открыта"',
    'transitionsStory.nodeLegend.mealy.q0': 'q0 = "WAIT"',
    'transitionsStory.nodeLegend.q2': 'q2 = "дверь открыта"',
    'transitionsStory.nodeLegend.q3': 'q3 = "дверь закрывается"',
    'transitionsStory.mooreCaption':
        'Мур: каждая фаза движения - отдельная нода, выход которой управляет мотором.',
    'transitionsStory.mealyCaption': 'Мили: выход создаёт сработавший переход.',
    'transitionsStory.simulator.mooreOutput': 'Выход текущей ноды: {output}',
    'transitionsStory.simulator.mealyOutput':
        'Выход последнего перехода: {output}',
    'transitionsStory.simulator.applyInput': 'Применить вход {input}',
    'transitionsStory.comparisonTitle': 'Одна дверь - разное строение',
    'transitionsStory.comparison.moore':
        'OPEN записан внутри q1: в автомате Мура выход определяет текущая нода.',
    'transitionsStory.comparison.mealy':
        'OPEN записан на PERSON / OPEN: в автомате Мили выход создаёт сработавший переход.',
    'transitionsStory.comparison.sameTitle': 'Что остаётся одинаковым',
    'transitionsStory.comparison.same':
        'Оба выполняют одно видимое правило: открыть для человека и закрыть, когда проход свободен.',
    'transitionsStory.placementTitle': 'Где находится выход?',
    'transitionsStory.onNode': 'В ноде',
    'transitionsStory.onTransition': 'На переходе',
    'transitionsStory.placement.correct': 'Точно: Мур → нода, Мили → переход.',
    'transitionsStory.placement.retry':
        'Почти! Сравни подписи в нодах с форматом вход / выход на стрелках.',
    'transitionsStory.placement.tryOther': 'Попробуй другой элемент схемы.',
    'answer.outputsBothOnNodes': 'Оба автомата записывают выходы в нодах',
    'answer.mooreNodeMealyTransition': 'Мур: нода; Мили: переход',
    'answer.mooreTransitionMealyNode': 'Мур: переход; Мили: нода',
    'answer.doorOpens': 'Дверь открывается',
    'answer.outputDisappears': 'Автомат не выдаёт выход',
    'answer.doorStaysClosed': 'Дверь остаётся закрытой',
    'answer.nodeQ1WithOutput': 'Нода q1 с y = OPEN',
    'answer.personTransitionWithoutOutput': 'Переход q0 -"PERSON"→ q1',
    'answer.clearCloseTransition': 'Переход q1 -"CLEAR / CLOSE"→ q0',
    'answer.currentStateOnly': 'Только текущее состояние',
    'answer.inputOnly': 'Только входной сигнал',
    'answer.stateAndInput': 'Текущее состояние и входной сигнал',
    'answer.personOneCloseTransition': '"person = 1 / CLOSE DOOR"',
    'answer.personZeroOpenTransition': '"person = 0 / OPEN DOOR"',
    'answer.waitState': 'Состояние WAIT',
    'answer.putCloseInsideWait': 'Записать CLOSE DOOR внутри ноды WAIT',
    'answer.closeWhenPersonDetected':
        'Заменить выход перехода "person = 1" на CLOSE DOOR',
    'answer.changePersonToZero': 'Заменить "person = 1" на "person = 0"',
    'task.transitions.outputPlacement.prompt':
        'Где записывается выход в автомате Мура?',
    'task.transitions.outputPlacement.instruction':
        'Выбери определяющее правило автомата Мура.',
    'task.transitions.outputPlacement.hint':
        'Ищи y = выход внутри состояния автомата Мура.',
    'task.transitions.changeTarget.prompt':
        'На схеме Мили показан переход "person = 1 / CLOSE DOOR", а WAIT не изменился. От чего зависит этот выход?',
    'task.transitions.changeTarget.instruction':
        'Сравни изменённую подпись перехода с неизменным текущим состоянием.',
    'task.transitions.changeTarget.hint':
        'Выход Мили выбирается парой: текущее состояние + текущий вход.',
    'task.transitions.findErrors.prompt':
        'Оба выхода автомата Мили перепутаны. Выбери два неверных перехода.',
    'task.transitions.findErrors.instruction':
        'Переход "person = 1 / OPEN DOOR" должен открывать дверь, а "person = 0 / CLOSE DOOR" - закрывать.',
    'task.transitions.findErrors.hint':
        'Выбери "person = 1 / CLOSE DOOR" и "person = 0 / OPEN DOOR".',
    'task.transitions.validateMoore.prompt':
        'Реальному контроллеру нужно помнить, движется ли дверь. Всегда ли достаточно этой модели Мили с одним состоянием?',
    'task.transitions.validateMoore.instruction':
        'Реши, всегда ли автомат Мили позволяет убрать состояния движения.',
    'task.transitions.validateMoore.hint':
        'Мили может сократить состояния, различающиеся только выходом, но не может убрать необходимую память о процессе.',
    'task.transitions.buildMoore.prompt':
        'Собери упрощённый автомат Мура для двери из двух состояний.',
    'task.transitions.buildMoore.instruction':
        'Создай q0 DOOR IS CLOSED/CLOSE DOOR и q1 DOOR IS OPEN/OPEN DOOR; назначь q0 начальным и добавь "person = 1" и "person = 0".',
    'task.transitions.buildMoore.hint':
        'Выходы Мура находятся в состояниях, а значения датчика подписывают два направленных перехода.',
    'task.transitions.traceMoore.prompt':
        'Проследи упрощённый автомат Мура через "person = 1" и "person = 0".',
    'task.transitions.traceMoore.instruction':
        'Выбери текущее состояние до входа и после обоих значений датчика.',
    'task.transitions.traceMoore.hint':
        'Пройди DOOR IS CLOSED → DOOR IS OPEN → DOOR IS CLOSED.',
    'task.transitions.completeMealy.prompt':
        'Дополни автомат Мили с одним состоянием недостающей второй петлёй.',
    'task.transitions.completeMealy.instruction':
        'Добавь к WAIT петлю с точной подписью "person = 0 / CLOSE DOOR".',
    'task.transitions.completeMealy.hint':
        'Состояние остаётся WAIT; вход и выход вместе записаны на петле.',
    'task.transitions.closeOnPerson.prompt':
        'Что нужно сделать, чтобы дверь закрывалась, как только датчик обнаруживал человека?',
    'task.transitions.closeOnPerson.instruction':
        'Выбери изменение реакции автомата Мили на "person = 1".',
    'task.transitions.closeOnPerson.hint':
        'Оставь вход "person = 1" и измени выход, записанный после косой черты.',
    'lesson.scrollHint': 'Прокрути вниз, чтобы продолжить',
    'home.chapter3.unit': 'Раздел 3',
    'home.chapter4.unit': 'Раздел 4',
    'home.chapter5.unit': 'Экзамен',
    'lesson.chapter2.diagram.title': 'Как понимать схемы FSM',
    'lesson.chapter2.gates.title': 'Цифровые Gatter: путь сигнала',
    'lesson.chapter2.gates.subtitle': 'Короткое интерактивное повторение',
    'lesson.chapter2.diagram.subtitle':
        'Разберём состояния, переходы, сброс и детерминизм',
    'lesson.chapter2.testSubtitle': 'Схемы и основы Мура/Мили',
    'lesson.chapter4.title': 'Дополняем автоматы',
    'lesson.chapter4.subtitle': 'Ищем недостающие переходы и выходы',
    'lesson.chapter4.testSubtitle': 'Проверка полноты',
    'lesson.chapter5.title': 'Создаём автоматы',
    'lesson.chapter5.subtitle': 'Строим FSM и описываем его таблицей переходов',
    'lesson.chapter5.testSubtitle': 'Проверка построения',
    'lesson.bonus.title': 'Экзаменационные задачи по FSM',
    'lesson.bonus.subtitle':
        'Шесть практических уроков с экзаменационными задачами',
    'concept.determinism': 'Детерминизм',
    'concept.transitionTable': 'Таблица переходов',
    'answer.idleState': 'Состояние IDLE',
    'answer.activeState': 'Состояние ACTIVE',
    'answer.oneTransition': 'Переход с меткой "1"',
    'answer.duplicateOneFirst': 'q0 --"1"--> q1',
    'answer.duplicateOneSecond': 'q0 --"1"--> q0',
    'answer.oneTransitionPerInput': 'Ровно один переход на каждый вход',
    'answer.anyNumberTransitions': 'Любое число переходов для одного входа',
    'answer.noTransitionsNeeded': 'Переходы не нужны',
    'answer.defineStatesThenTransitions':
        'Сначала определить состояния, затем соединить их',
    'answer.onlyDrawArrows':
        'Рисовать только стрелки; состояния не обязательны',
    'answer.randomLabels': 'Использовать случайные метки и исправить потом',
    'answer.trafficFirstTimer': 'q0 --"timer"--> q1',
    'answer.trafficSecondTimer': 'q0 --"timer"--> q2',
    'answer.trafficGreenTimer': 'q1 --"timer"--> q2',
    'path.chapter2.lesson.title': 'Читаем схемы FSM',
    'path.chapter2.lesson.subtitle': '3 задания',
    'path.chapter2.test.title': 'Тест раздела 2',
    'path.chapter2.test.subtitle': '5 вопросов',
    'chapter2Story.intro':
        'Ты уже умеешь читать цифровые схемы. Теперь проследи сигналы, чтобы понять работу этого детерминированного FSM. Каждый цветной путь иллюстрирует объяснение.',
    'chapter2Story.purpose':
        'Эта схема - FSM. Она хранит текущее состояние, вычисляет следующее состояние по входу и формирует выход. Мы разберём её слева направо, блок за блоком.',
    'chapter2Story.stateBits':
        'Два flip-flop хранят текущее состояние. Сначала прочитай их выходы как пару битов S₁S₀, а затем переходи к логике следующего состояния.',
    'chapter2Story.bitDecomposition':
        'Разложим состояние на два провода: S₁S₀ = 00 означает S₁ = 0 и S₀ = 0. Вместе эти два бита образуют S.',
    'chapter2Story.clockStep':
        'Сначала логика вычисляет новые значения. Только фронт CLK записывает их во flip-flop, поэтому FSM меняет состояние в определённый момент.',
    'chapter2Story.outputStep':
        'В конце сохранённое состояние проходит через логику выхода. Это выход Мура: Y определяется состоянием S, а не напрямую входом A.',
    'chapter2Story.signalPath':
        'Чтобы найти следующее состояние, начни с A и сохранённых битов. Следуй по подсвеченным стрелкам через логику к D-входам; затем такт сохраняет эти значения.',
    'chapter2Story.simulator':
        'Выбери состояние и вход. Схема подсветит соответствующий путь. Нажми CLK, чтобы записать вычисленное следующее состояние в память.',
    'chapter2Story.transitionTable':
        'Таблица переходов содержит следующее состояние для каждой допустимой пары текущего состояния S и входа A. Нажми на строку, чтобы сверить её с анимированной схемой, а затем заполни таблицу.',
    'chapter2Story.outputTable':
        'Логика выхода находится отдельно. Это автомат Мура: Y зависит только от сохранённого состояния, а не напрямую от A. Нажми на строку, чтобы сверить её с анимированной схемой, а затем заполни таблицу выходов.',
    'chapter2Story.transitionTableTitle': 'Таблица переходов',
    'chapter2Story.outputTableTitle': 'Таблица выходов',
    'chapter2Story.completeOverview':
        'Вот так мы смогли разобрать весь автомат: узнать, какими правилами он руководствуется и какие значения выдаёт. Это очень пригодится тебе на Klausur! Главное - понимать, как автомат работает внутри, то есть как работают его гейты.',
    'chapter2Story.ready':
        'Теперь ты умеешь читать схему как FSM: декодировать S₁S₀, проходить по логике следующего состояния, применять CLK и считывать Y из логики выхода.',
    'chapter2Story.predictNextState': 'S′ vor CLK vorhersagen.',
    'chapter2Story.predictionHint':
        'Verfolge beide markierten Wege noch einmal.',
    'chapter2Story.startTasks': 'Начать задания',
    'chapter2Gates.intro':
        'Добро пожаловать в главу 2! В этой главе мы научимся читать цифровые схемы FSM: прослеживать входные сигналы через гейты и понимать, как схема изменяет своё состояние. Надеюсь, ты хорошо помнишь базовые логические гейты, изученные во время учёбы в университете.',
    'chapter2Gates.xor':
        'Измени оба входа и наблюдай, как бит проходит через XOR.',
    'chapter2Gates.andBubble':
        'Кружок на входе AND инвертирует этот вход перед объединением сигналов в гейте.',
    'chapter2Gates.andNot':
        'Теперь проследи инвертированный вход через NOT и AND.',
    'chapter2Gates.clock':
        'Сначала Gatter вычисляют результат. CLK сохраняет его как новое состояние.',
    'chapter2Gates.summary':
        'Отлично! Теперь ты должен уметь распознавать, что делает каждая часть этой FSM-схемы. В следующем уроке мы пошагово разберём всю схему.',
    'chapter2Gates.introCard':
        'В этой главе ты научишься понимать эту FSM-схему: прослеживать вход, читать гейты и видеть, как меняется состояние. Надеюсь, ты ещё помнишь базовые гейты, изученные во время учёбы в университете.',
    'chapter2Gates.summaryCard':
        'Теперь ты можешь найти в этом FSM вход A, память состояния S₁S₀, гейты, CLK и выход Y. В следующем уроке мы подробно проследим весь путь сигнала.',
    'chapter2Gates.showSignal': 'Показать путь сигнала',
    'chapter2Gates.xorTitle': 'XOR: разные входы дают 1',
    'chapter2Gates.xorBody':
        'XOR выдаёт 1, если ровно один вход равен 1. Измени A или S₀ и наблюдай за сигналом.',
    'chapter2Gates.notSymbolTitle': 'NOT: кружок означает инверсию',
    'chapter2Gates.notSymbolBody':
        'Маленький кружок на выходе - это знак инверсии. Он превращает 0 в 1, а 1 в 0.',
    'chapter2Gates.notBubbleTitle': 'Знак NOT может стоять отдельно',
    'chapter2Gates.notBubbleBody':
        'Отдельный NOT-гейт нужен не всегда. Кружок на линии уже означает NOT. Измени A и наблюдай за Ā.',
    'chapter2Gates.andBubbleTitle': 'NOT на одном входе AND',
    'chapter2Gates.andBubbleBody':
        'Маленький кружок на входе AND означает инверсию этого входа. Отдельный NOT-гейт не нужен: перед AND сигнал A превращается в Ā и объединяется с S₁.',
    'chapter2Gates.andNotTitle': 'NOT и AND: инверсия и объединение',
    'chapter2Gates.andNotBody':
        'Кружок означает NOT: A превращается в Ā. AND выдаёт 1 только при всех входах 1.',
    'chapter2Gates.flipFlop':
        'Flip-Flop - это минимальный элемент памяти: он хранит один бит, пока тактовый сигнал не разрешит обновление.',
    'chapter2Gates.flipFlopTitle': 'Flip-Flop хранит один бит',
    'chapter2Gates.flipFlopBody':
        'Flip-Flop - это память для одного бита. Он получает бит на входе D и записывает его в Q только на фронте CLK. До этого в Q остаётся старое значение.',
    'chapter2Gates.flipFlopPrompt': 'Выбери бит, который приходит на D:',
    'chapter2Gates.flipFlopApply': 'Применить CLK',
    'chapter2Gates.flipFlopApplied': 'Бит сохранён',
    'chapter2Gates.clockTitle': 'CLK записывает D-биты в память',
    'chapter2Gates.clockBody':
        'В FSM flip-flops являются памятью состояния. Гейты вычисляют D₁ и D₀ по входу и текущему состоянию. На переднем фронте CLK flip-flops копируют их в S₁/S₀. Поэтому состояние меняется чёткими отдельными шагами.',
    'chapter2Gates.clockPrompt': 'Что происходит на фронте CLK?',
    'chapter2Gates.clockChoice0': 'Состояние меняется сразу',
    'chapter2Gates.clockChoice1': 'CLK сохраняет вычисленные биты',
    'chapter2Gates.clockChoice2': 'A напрямую меняет состояние',
    'chapter2Gates.check': 'Я понимаю путь сигнала',
    'chapter2Gates.checked': 'Готово к таблицам FSM',
    'chapter2Gates.startLesson': 'Начать урок FSM',
    'chapter2Story.legend.input': 'вход',
    'chapter2Story.legend.memory': 'память состояния',
    'chapter2Story.legend.output': 'выход',
    'chapter2Story.stateEncoding': 'Кодирование состояний',
    'chapter2Story.purposeTitle': 'Что делает этот FSM?',
    'chapter2Story.purposeInput':
        'A - внешний вход, который может измениться между двумя тактовыми циклами.',
    'chapter2Story.purposeMemory':
        'S₁ и S₀ - два сохранённых бита состояния. Вместе они образуют текущее состояние S.',
    'chapter2Story.purposeLogic':
        'Вентили вычисляют следующее состояние по A и текущим битам.',
    'chapter2Story.purposeOutput':
        'Логика выхода превращает сохранённое состояние в выход Y.',
    'chapter2Story.clockTitle': 'Когда меняется состояние?',
    'chapter2Story.clockBefore':
        'До CLK вентили вычисляют S₁′ и S₀′, но старое состояние остаётся сохранённым.',
    'chapter2Story.clockEdge':
        'Фронт CLK переносит вычисленные значения в память.',
    'chapter2Story.clockAfter':
        'После CLK новая пара S₁S₀ становится текущим состоянием S.',
    'chapter2Story.clockQuestion': 'Что происходит на фронте CLK?',
    'chapter2Story.clockChoice0': 'Состояние меняется сразу',
    'chapter2Story.clockChoice1': 'CLK сохраняет вычисленные биты',
    'chapter2Story.clockChoice2': 'A напрямую меняет состояние',
    'chapter2Story.clockCorrect':
        'Верно: CLK переносит значения D во Flip-Flops.',
    'chapter2Story.clockTimeline':
        'Пример: текущее состояние → вычисленное следующее → сохранённое после CLK',
    'chapter2Story.flipFlops': 'Flip-Flops',
    'chapter2Story.unusedState':
        'Пара 11 возможна при двух битах, но этот FSM её не использует.',
    'chapter2Story.resetActive': 'Reset включён: S₁S₀ = 00 → S = 0',
    'chapter2Story.resetInactive':
        'Reset выключен: состояние может измениться при CLK.',
    'chapter2Story.applyReset': 'Включить Reset',
    'chapter2Story.releaseReset': 'Выключить Reset',
    'chapter2Story.outputStepTitle': 'Как FSM формирует Y?',
    'chapter2Story.outputStepBody':
        'Прочитай текущее состояние из S₁S₀, затем проследи логику выхода до Y. Для выхода Мура вход A не нужен.',
    'chapter2Story.bitDecompositionTitle':
        'S₁S₀ - это одно двухбитное состояние',
    'chapter2Story.bitDecompositionBody':
        'Два провода S₁ и S₀ вместе образуют одно состояние S. Первый бит - S₁, второй бит - S₀.',
    'chapter2Story.bitDecompositionFormula':
        'S₁S₀ = {bits}  →  S₁ = {s1}, S₀ = {s0}  →  S = {state}',
    'chapter2Story.workedExample':
        'Разберём одну строку полностью: S = 0 и A = 0.',
    'chapter2Story.resetStep':
        'Reset переводит Flip-Flops в заданное начальное состояние. Это не обычный вход A.',
    'chapter2Story.workedExampleTitle': 'Пример: вычисляем оба следующих бита',
    'chapter2Story.workedExampleBody':
        'Для S = 0 и A = 0 проследи каждую подсвеченную линию: A и сохранённые биты S₁/S₀ входят в гейты и формируют S₀′ и S₁′.',
    'chapter2Story.workedExamplePrompt': 'Выбери оба вычисленных бита.',
    'chapter2Story.workedExampleCorrect':
        'Верно: эти два бита образуют следующее состояние.',
    'chapter2Story.predictNextBits': 'Предскажи S₀′ и S₁′ до применения CLK.',
    'chapter2Story.resetBody':
        'Reset переводит регистр в заданное начальное состояние. После этого CLK управляет обычными изменениями состояния.',
    'chapter2Story.unused': 'здесь не используется',
    'chapter2Story.flow.input': 'Вход A и биты текущего состояния',
    'chapter2Story.flow.logic':
        'Логика следующего состояния вычисляет S0\' и S1\'',
    'chapter2Story.flow.clock': 'CLK переносит D-входы во flip-flop',
    'chapter2Story.formulaS0': 'S₀′ = A ∧ (S₁ XOR S₀)',
    'chapter2Story.formulaS1': 'S₁′ = Ā ∧ ¬S₁ ∧ ¬S₀',
    'chapter2Story.formulaY': 'Y = S₁ ∧ ¬S₀',
    'chapter2Story.flow.state':
        'Сохранённые биты становятся новым текущим состоянием',
    'chapter2Story.chooseState': 'Выбери текущее состояние',
    'chapter2Story.chooseInput': 'Выбери вход',
    'chapter2Story.clock': 'Применить CLK',
    'chapter2Story.transitionInstruction':
        'Выбери следующее состояние для каждой строки.',
    'chapter2Story.outputInstruction':
        'Выбери Y для каждого сохранённого состояния.',
    'chapter2Story.fillEveryRow': 'Заполни все строки, чтобы продолжить.',
    'chapter2Story.summary':
        'Схема превращается в таблицу FSM, когда ты отдельно вычисляешь каждую комбинацию состояния и входа.',
    'path.chapter4.unlocked': 'Раздел про дополнение открыт',
    'path.chapter4.lesson.title': 'Дополняем автоматы',
    'path.chapter4.lesson.subtitle': '3 задания',
    'path.chapter4.test.subtitle': '5 вопросов',
    'path.chapter5.test.title': 'Экзаменационные задания',
    'path.chapter5.test.subtitle': 'Шесть тренировочных уроков',
    'path.chapter5.title': 'Глава 5: Экзаменационные задачи',
    'path.chapter5.locked': 'Сначала пройди тест раздела 4',
    'path.chapter5.unlocked': 'Экзаменационные задачи открыты',
    'path.chapter5.lesson.title': 'Шесть уроков с экзаменационными задачами',
    'path.chapter5.lesson.subtitle': '6 уроков, по 3 задания',
    'path.chapter5.theory.title': 'Теоретические задания',
    'path.chapter5.theory.subtitle': '3 вопроса',
    'path.chapter5.completion.title': 'Дополнение автомата',
    'path.chapter5.completion.subtitle': '3 задания на построение',
    'path.chapter5.creation.title': 'Создание автомата',
    'path.chapter5.creation.subtitle': '3 задания на построение',
    'path.chapter5.diagnostics.title': 'Анализ автомата',
    'path.chapter5.diagnostics.subtitle': '3 задания',
    'chapter5.lesson.theory.title': 'Теоретические задания',
    'chapter5.lesson.theory.subtitle': 'Мур, Мили и синхронные схемы',
    'chapter5.lesson.tables.title': 'Автоматы по таблицам',
    'chapter5.lesson.tables.subtitle': 'Читаем таблицы переходов и выходов',
    'chapter5.lesson.completion.title': 'Дополнение автомата',
    'chapter5.lesson.completion.subtitle':
        'Поиск отсутствующих состояний и переходов',
    'chapter5.lesson.creation.title': 'Создание автомата',
    'chapter5.lesson.creation.subtitle': 'Построение полного автомата',
    'chapter5.lesson.diagnostics.title': 'Анализ автомата',
    'chapter5.lesson.diagnostics.subtitle':
        'Трассировка и проверка детерминизма',
    'chapter5.theory.instruction': 'Укажи правильное утверждение.',
    'chapter5.theory.mooreOutput.prompt':
        'Укажите, от чего зависит выход автомата Мура.',
    'chapter5.theory.mooreOutput.hint':
        'У автомата Мура выход связан с текущим состоянием.',
    'chapter5.theory.mealyOutput.prompt':
        'Укажите, от чего зависит выход автомата Мили.',
    'chapter5.theory.mealyOutput.hint':
        'У автомата Мили выход записывается на переходе вместе со входом.',
    'chapter5.theory.timing.prompt':
        'Назовите существенное различие во временном поведении выходов автоматов Мили и Мура.',
    'chapter5.theory.timing.hint':
        'Сравните реакцию выхода на изменение входа.',
    'chapter5.theory.realization.prompt':
        'Как реализовать автомат как синхронную последовательностную схему? Кратко объясните с помощью эскиза или описания.',
    'chapter5.theory.realization.instruction':
        'Укажи описание с регистром состояния, комбинационной логикой и тактовым сигналом.',
    'chapter5.theory.realization.hint':
        'Регистр хранит состояние, а логика вычисляет следующее состояние и выход.',
    'chapter5.answer.stateOutput': 'Он зависит от текущего состояния.',
    'chapter5.answer.inputOnly': 'Он зависит только от входа.',
    'chapter5.answer.nextStateOnly':
        'Он зависит только от следующего состояния.',
    'chapter5.answer.transitionInput':
        'Он зависит от текущего состояния и входного перехода.',
    'chapter5.answer.stateOnly': 'Он зависит только от имени состояния.',
    'chapter5.answer.clockOnly': 'Он зависит только от тактового сигнала.',
    'chapter5.answer.mealyImmediate':
        'Мили может сразу реагировать на изменение входа, а Мур меняет выход вместе с состоянием.',
    'chapter5.answer.sameTiming': 'Они всегда реагируют точно одновременно.',
    'chapter5.answer.mooreImmediate': 'Мур всегда реагирует раньше Мили.',
    'chapter5.answer.registerLogic':
        'Тактовый регистр состояния, комбинационная логика следующего состояния и выхода, общий тактовый сигнал.',
    'chapter5.answer.onlyRegister':
        'Только регистр состояния без комбинационной логики.',
    'chapter5.answer.onlyCombinational':
        'Только комбинационная логика без тактового регистра состояния.',
    'chapter5.tables.instruction':
        'Создай автомат из показанных таблиц. Начальное состояние - q0. Для каждого состояния и действия задай ровно один переход.',
    'chapter5.tables.moore.prompt':
        'Построй автомат Moore по таблицам переходов и выходов.',
    'chapter5.tables.moore.hint':
        'Для каждого входа найдите следующее состояние и перенесите выход таблицы в состояние.',
    'chapter5.tables.mealy.prompt':
        'Создайте автомат Мили по таблице переходов с обозначениями вход/выход.',
    'chapter5.tables.mealy.hint': 'На каждой стрелке укажите вход и выход.',
    'chapter5.completion.prompt':
        'Детектор запускается в q0. Вход 0 переводит q0 → q1 → q2 → q3. Для входа 1 заданы переходы: q0 → q0, q1 → q0, q2 → q1 и q3 → q1. Выход 1 назначен только q1; в q0, q2 и q3 выход равен 0. Заполни недостающие выходы и переходы.',
    'chapter5.completion.instruction':
        'Добавьте отсутствующие данные состояний и переходы из условия.',
    'chapter5.completion.hint':
        'Проверьте каждую пару состояние/вход ровно один раз.',
    'chapter5.creation.prompt':
        'Турникет начинает работу закрытым в состоянии q0. Вход 1 означает, что считан правильный билет: турникет открывается, автомат переходит в q1 и выдаёт OPEN (1). Вход 0 означает сброс или неправильный билет: из q0 турникет остаётся закрытым с выходом 0, а из q1 закрывается и возвращается в q0 с выходом 0. Ещё один правильный билет при открытом турникете сохраняет q1, но не выдаёт OPEN повторно. Создайте полный автомат Мили по этому описанию.',
    'chapter5.creation.instruction':
        'Разместите состояния, выберите начальное состояние и соедините все переходы.',
    'chapter5.creation.hint':
        'У автомата Мили выход записывается после косой черты на переходе.',
    'chapter5.analysis.prompt':
        'Проследите работу автомата для данной последовательности входов.',
    'chapter5.analysis.instruction':
        'Укажи состояние до первого входа и после каждого входа.',
    'chapter5.analysis.hint':
        'Для каждого входного символа пройдите ровно по одному переходу.',
    'chapter5.diagnostics.prompt':
        'Какое утверждение правильно диагностирует показанный автомат?',
    'chapter5.diagnostics.instruction':
        'Укажи утверждение о повторяющемся переходе с одним входом.',
    'chapter5.diagnostics.hint':
        'В детерминированном автомате для пары состояние/вход может быть не более одной цели.',
    'chapter5.answer.deterministic': 'Автомат детерминирован.',
    'chapter5.answer.conflict':
        'Из одного состояния выходят два перехода с одним и тем же входом.',
    'task.chapter2.readDiagram.prompt': 'Какие состояния хранит эта схема?',
    'task.chapter2.readDiagram.instruction':
        'Выбери все три состояния, которые хранятся в этой схеме.',
    'task.chapter2.readDiagram.hint':
        'Допустимы коды 00, 01 и 10. Они обозначают S = 0, 1 и 2.',
    'task.chapter2.trace.prompt':
        'Проследи последовательность состояний схемы для входов 0, 1, 0, 1.',
    'task.chapter2.trace.instruction':
        'Начни с S = 0 и укажи состояние после каждого такта CLK.',
    'task.chapter2.trace.hint':
        'Начни с S = 0 и проходи схему по одному такту CLK. После каждого шага считывай оба бита состояния.',
    'task.chapter2.mooreMealy.prompt':
        'Где находятся выходы в автоматах Мура и Мили?',
    'task.chapter2.mooreMealy.instruction':
        'Выбери утверждение из обозначений модуля Digitaltechnik.',
    'task.chapter2.mooreMealy.hint':
        'У Мура выход записан в состоянии, у Мили вход/выход - на переходе.',
    'task.chapter2.determinism.prompt':
        'Какие элементы делают этот автомат недетерминированным?',
    'task.chapter2.determinism.instruction':
        'Выбери оба перехода с одним и тем же входом из q0.',
    'task.chapter2.determinism.hint':
        'Для одного состояния и входа детерминированный FSM может иметь только одну цель.',
    'task.chapter2.gatesCheck.prompt': 'Что выдаёт XOR при входах 0 и 1?',
    'task.chapter2.gatesCheck.instruction': 'Выбери значение на выходе XOR.',
    'task.chapter2.gatesCheck.hint':
        'Рассмотри оба входа как пару. XOR реагирует на их соотношение, а не на один вход отдельно.',
    'task.chapter2.gatesCheck.feedback.xorZero':
        'Посмотри ещё раз на оба входа. Что сравнивает XOR перед формированием выхода?',
    'task.chapter2.gatesCheck.feedback.andOne':
        'Это правило другого гейта. Подумай, что делает XOR, когда его входы не совпадают.',
    'answer.xorOne': '1 - входы различаются',
    'answer.xorZero': '0 - входы одинаковые',
    'answer.andOne': '1 - AND всегда выдаёт 1',
    'task.chapter4.completeMoore.prompt': 'Дополни автомат Мура для турникета.',
    'task.chapter4.completeMoore.instruction':
        'Добавь недостающий переход для "coin", когда турникет уже UNLOCKED.',
    'task.chapter4.completeMoore.hint':
        'После "coin" открытый турникет остаётся в состоянии UNLOCKED.',
    'task.chapter4.completeMealy.prompt':
        'Дополни автомат двери Мили недостающей реакцией.',
    'task.chapter4.completeMealy.instruction':
        'Добавь к WAIT петлю "person = 0 / CLOSE DOOR".',
    'task.chapter4.completeMealy.hint':
        'В недостающей метке есть и вход, и выход после косой черты.',
    'task.chapter4.missingOutput.prompt': 'Полон ли этот автомат Мили?',
    'task.chapter4.missingOutput.instruction':
        'Проверь, есть ли у каждого перехода вход и выход.',
    'task.chapter4.missingOutput.hint':
        'У перехода Мили без текста после / выход не определён.',
    'task.chapter4.determinismRule.prompt':
        'Какое условие должно выполняться для детерминированного FSM?',
    'task.chapter4.determinismRule.instruction':
        'Выбери правило для проверки каждой пары "состояние - вход".',
    'task.chapter4.determinismRule.hint':
        'Один и тот же вход из одного состояния не может вести по двум разным переходам.',
    'task.chapter5.createMoore.prompt':
        'Построй автомат Мура для турникета по описанию.',
    'task.chapter5.createMoore.instruction':
        'Используй LOCKED/STOP и UNLOCKED/GO, затем добавь переходы "coin" и "passage".',
    'task.chapter5.createMoore.hint':
        'У Мура STOP и GO записываются внутри состояний, а не на стрелках.',
    'task.chapter5.buildTable.prompt':
        'Составь таблицу переходов для турникета.',
    'task.chapter5.buildTable.instruction':
        'Для каждого состояния укажи цели "coin" и "passage" и скопируй его выход Мура.',
    'task.chapter5.buildTable.hint':
        '"coin" открывает закрытый турникет, а "passage" запускает его автоматическую блокировку.',
    'task.chapter5.createMealy.prompt':
        'Построй автомат Мили для турникета с выходами на переходах.',
    'task.chapter5.createMealy.instruction':
        'Создай LOCKED и UNLOCKED и добавь все четыре реакции вход / выход.',
    'task.chapter5.createMealy.hint':
        'Оставь поля выходов состояний пустыми и записывай реакцию после /.',
    'task.chapter5.chooseWorkflow.prompt':
        'Какой порядок действий надёжнее всего при создании FSM?',
    'task.chapter5.chooseWorkflow.instruction':
        'Выбери последовательность, после которой схему легко проверить.',
    'task.chapter5.chooseWorkflow.hint':
        'Сначала определи ситуации, затем опиши изменения под действием входов.',
    'task.chapter5.outputPlacement.prompt':
        'Где записывается выход Мура на схеме?',
    'task.chapter5.outputPlacement.instruction':
        'Выбери место, которое использует представление Мура.',
    'task.chapter5.outputPlacement.hint':
        'Выход Мура описывает текущее состояние.',
    'task.bonus.buildTraffic.prompt':
        'Построй трёхсостоянийный автомат Мура для светофора.',
    'task.bonus.buildTraffic.instruction':
        'Используй RED/STOP, GREEN/GO и YELLOW/SLOW с циклом "timer".',
    'task.bonus.buildTraffic.hint':
        'Цикл "timer" выглядит так: RED → GREEN → YELLOW → RED.',
    'task.bonus.completeTurnstile.prompt':
        'Дополни турникет одним недостающим переходом.',
    'task.bonus.completeTurnstile.instruction':
        'Найди пару "состояние - вход", для которой нет исходящего перехода.',
    'task.bonus.completeTurnstile.hint':
        'Из UNLOCKED вход "coin" оставляет турникет в UNLOCKED.',
    'task.bonus.completeDoorMealy.prompt':
        'Дополни автомат двери Мили в условиях экзамена.',
    'task.bonus.completeDoorMealy.instruction':
        'Добавь недостающую петлю "person = 0 / CLOSE DOOR", не меняя состояние.',
    'task.bonus.completeDoorMealy.hint':
        'Это автомат с одним состоянием: обе стрелки - петли на WAIT.',
    'task.bonus.buildTable.prompt':
        'Составь таблицу переходов для цикла светофора.',
    'task.bonus.buildTable.instruction':
        'Для каждого цвета укажи следующее состояние и выход Мура.',
    'task.bonus.buildTable.hint':
        'В каждой строке одна цель "timer" - следующий цвет цикла.',
    'task.bonus.findError.prompt':
        'Найди ошибку детерминизма в этом FSM светофора.',
    'task.bonus.findError.instruction':
        'Выбери оба конфликтующих перехода "timer" из RED.',
    'task.bonus.findError.hint':
        'При одном и том же "timer" RED не может вести и в GREEN, и в YELLOW.',
    'task.bonus.traceTurnstile.prompt':
        'Проследи турникет после входов "coin", "passage", "coin".',
    'task.bonus.traceTurnstile.instruction':
        'Укажи начальное состояние и состояние после каждого входа.',
    'task.bonus.traceTurnstile.hint':
        '"coin" открывает, "passage" запускает автоматическую блокировку, последняя "coin" снова открывает.',
    'profile.title': 'Профиль',
    'profile.subtitle': 'Твой путь в FSM и награды',
    'profile.loadFailed': 'Не получилось загрузить профиль.',
    'profile.saveFailed': 'Не получилось сохранить профиль.',
    'profile.username': 'Имя пользователя',
    'profile.unknown': 'Имя пользователя не указано',
    'profile.edit': 'Изменить профиль',
    'profile.editTitle': 'Изменить профиль',
    'profile.usernameHint': 'Введи имя пользователя',
    'profile.usernameHelper':
        'Можно выбрать псевдоним - настоящее имя не нужно.',
    'profile.stats.level': 'Уровень {level}',
    'profile.stats.xp': '{xp} XP',
    'profile.stats.stars': '{stars} звёзд',
    'profile.stats.coins': '{coins} монет',
    'profile.stats.streak': 'Серия: {days} дн.',
    'profile.chapterProgress.title': 'Прогресс по разделам',
    'profile.chapterProgress.item': '{chapter}: {completed}/{total} уроков',
    'profile.chapterProgress.chapter': 'Глава {number}',
    'profile.shop.title': 'Гардероб Фини',
    'profile.shop.subtitle': 'Трать монеты и открывай новый образ Фини.',
    'profile.shop.buy': 'Купить',
    'profile.shop.equip': 'Надеть',
    'profile.shop.equipped': 'Надето',
    'profile.shop.owned': 'Уже есть',
    'profile.shop.notEnoughCoins': 'Для этого предмета нужно больше монет.',
    'profile.shop.purchaseSuccess': 'Новый образ открыт!',
    'profile.shop.equipSuccess': 'Теперь Фини носит его.',
    'profile.shop.cap.title': 'Учебная кепка',
    'profile.shop.cap.description': 'Кепка для сосредоточенных занятий FSM.',
    'profile.shop.scarf.title': 'Шарф сигналов',
    'profile.shop.scarf.description': 'Яркий шарф для каждого перехода.',
    'profile.shop.glasses.title': 'Очки логики',
    'profile.shop.glasses.description':
        'Помогают быстрее замечать детерминированные пути.',
    'profile.shop.crown.title': 'Корона FSM',
    'profile.shop.crown.description':
        'Награда для тех, кто уверенно строит автоматы.',
    'fsmWorkspace.mooreMode': 'Мур: выход записан в состояниях',
    'fsmWorkspace.mealyMode': 'Мили: вход / выход записан на переходах',
    'fsmWorkspace.moore': 'Мур',
    'fsmWorkspace.mealy': 'Мили',
    'task.chapter2.buildTable.prompt':
        'Какая таблица правильно описывает эту схему?',
    'task.chapter2.buildTable.instruction':
        'Прочитай S₁S₀, проследи логические элементы, примени CLK и составь таблицу.',
    'task.chapter2.buildTable.hint':
        'Отдельно вычисли переход для каждой пары "состояние - значение входа", затем примени тактовый импульс, чтобы получить следующее состояние.',
    'task.chapter2.stateCode.prompt': 'Какое состояние обозначает S₁S₀ = 10?',
    'task.chapter2.stateCode.instruction':
        'Прочитай два сохранённых бита слева направо.',
    'task.chapter2.stateCode.hint': 'S₁ имеет вес 2, а S₀ - вес 1.',
    'answer.stateCodeTwo': 'S = 2',
    'answer.stateCodeOne': 'S = 1',
    'answer.stateCodeInvalid': 'Эта пара битов не является состоянием',
    'task.chapter2.mooreOutput.prompt':
        'Каким будет выход при текущем состоянии S = 2?',
    'task.chapter2.mooreOutput.instruction':
        'Прочитай логику выхода сохранённого состояния. Не используй A напрямую.',
    'task.chapter2.mooreOutput.hint':
        'В автомате Мура считывай Y из сохранённого состояния. Вход A в этой проверке не используется.',
    'answer.outputStateTwo': 'Y = 1, потому что S = 2',
    'answer.outputStateZero': 'Y = 0, потому что S = 0',
    'answer.outputInputA': 'Y напрямую равен A',
    'chapter4.story.welcome':
        'Добро пожаловать в главу 3. Ты будешь читать описание работы автомата и дополнять недостающие части схемы.',
    'chapter4.story.intro':
        'Добро пожаловать в главу 3: "Дополняем автоматы". Ты научишься находить недостающие состояния и переходы в реальной ситуации и добавлять их.',
    'chapter4.story.coinMachine':
        'Этот автомат принимает монеты по одной. Вход 1 добавляет монету, вход 0 отменяет покупку. После двух монет он выдаёт напиток.',
    'chapter4.story.stateMeaning':
        'Сначала переведём рассказ в состояния: q0 - нет монет, q1 - одна монета, q2 - напиток выдан.',
    'chapter4.story.missingTransition':
        'Теперь дополним недостающую реакцию. Из q1 ещё одна монета должна привести к состоянию выдачи q2.',
    'chapter4.story.completenessCheck':
        'В конце проверь каждый узел: для каждого возможного входа должен быть ровно один подходящий переход.',
    'chapter4.story.summary':
        'Метод такой: прочитай ситуацию, назови состояния, добавь недостающие переходы и проверь каждую пару "состояние - вход".',
    'chapter4.visual.welcome.title': 'Дополняем автоматы',
    'chapter4.visual.intro.title': 'Добро пожаловать в главу 3',
    'chapter4.visual.intro.body':
        'Мы прочитаем жизненную ситуацию, превратим её в состояния и переходы и пошагово дополним автомат.',
    'chapter4.visual.partial.title': 'Неполный монетный автомат',
    'chapter4.visual.partial.rule':
        'Не хватает стрелки из q1 для входа 1. Рассказ подсказывает, куда она должна вести.',
    'chapter4.visual.states.title': 'Что означает q1?',
    'chapter4.visual.transition.title': 'Добавляем недостающий переход',
    'chapter4.visual.transition.rule':
        'В q1 уже сохранена одна монета. Вторая ведёт в q2, где Y = 1 выдаёт напиток.',
    'chapter4.visual.check.title': 'Проверяем каждый узел и вход',
    'chapter4.visual.check.rule':
        'У полного детерминированного автомата из каждого состояния есть по одному переходу для входов 0 и 1.',
    'chapter4.visual.complete.title': 'Монетный автомат готов',
    'chapter4.visual.complete.rule':
        'Используй тот же чек-лист: состояния, переходы, затем полнота.',
    'chapter4.visual.step': 'Шаг дополнения {current} из {total}',
    'chapter4.check.state.question':
        'Какое состояние означает, что вставлена ровно одна монета?',
    'chapter4.check.state.correct':
        'Верно: q1 хранит информацию об одной монете.',
    'chapter4.check.state.incorrect': 'q0 - нет монет, q1 - одна, q2 - выдача.',
    'chapter4.check.transition.question':
        'Какой переход соответствует описанию?',
    'chapter4.check.transition.correct':
        'Верно: q1 --1--> q2 обрабатывает вторую монету.',
    'chapter4.check.transition.incorrect':
        'Из q1 вход 1 - это вторая монета, поэтому нужно перейти в q2.',
    'chapter4.check.complete.question':
        'Полон и детерминирован ли автомат для входов 0 и 1?',
    'chapter4.check.complete.correct':
        'Да. У каждого состояния есть ровно один переход для каждого входа.',
    'chapter4.check.complete.incorrect':
        'Для каждого состояния нужны ровно один переход на 0 и один на 1.',
    'chapter4.answer.q0': 'q0',
    'chapter4.answer.q1': 'q1',
    'chapter4.answer.q2': 'q2',
    'chapter4.answer.q1toQ2': 'q1 --1--> q2',
    'chapter4.answer.q1toQ0': 'q1 --1--> q0',
    'chapter4.answer.q0toQ2': 'q0 --1--> q2',
    'chapter4.answer.complete': 'Да, он полный',
    'chapter4.answer.missing': 'Нет, не хватает перехода',
    'chapter4.answer.duplicate': 'Нет, у входа два перехода',
    'chapter4.task.coin.prompt':
        'Автомат напитков начинает в q0 (нет монет, выход 0). Вход 1 - монета: из q0 переход в q1 (одна монета, выход 0), из q1 - в q2 (выдача напитка, выход 1). Вход 0 - отмена: из q0 или q1 переход в q0. После выдачи в q2 любой вход возвращает в q0. Дополни этот автомат Moore.',
    'chapter4.task.coin.instruction':
        'Добавь недостающее состояние q2, задай его выход и дополни все отсутствующие переходы по описанию.',
    'chapter4.task.coin.hint': 'Вторая монета запускает q2.',
    'chapter4.test.switch.prompt':
        'Дополни двухсостоячный выключатель. 0 переключает его, 1 сохраняет настройку.',
    'chapter4.test.switch.instruction':
        'Добавь недостающий переход через tap-and-select.',
    'chapter4.test.switch.hint': 'Из q1 вход 0 переключает свет обратно в q0.',
    'chapter4.test.ticket.prompt':
        'Билетный автомат начинает в q0 (ожидание, выход 0). Вход 0 - оплата, вход 1 - подтверждение. Из q0 оплата ведёт в q1 (оплачено, выход 0), подтверждение оставляет q0. В q1 повторная оплата сохраняет q1, подтверждение ведёт в q2 (билет готов, выход 1). В q2 оплата начинает новый цикл в q0, подтверждение сохраняет q2. Добавь недостающее состояние и переходы.',
    'chapter4.test.ticket.instruction':
        'Добавь подготовленное состояние и его переходы через tap-and-select.',
    'chapter4.test.ticket.hint': 'Последнее состояние выдаёт Y = 1.',
    'chapter4.test.lock.prompt':
        'Кодовый замок начинает в q0. Вход 0 переводит q0 в q1, q1 в q2, q2 в q3. Вход 1 возвращает q0 и q1 в q0, но переводит q2 в q1. Из q3 любой вход возвращает в q0. Выход равен 1 только в q3 (открыто), а в q0, q1 и q2 равен 0. Дополни автомат Moore.',
    'chapter4.test.lock.instruction':
        'Добавь все недостающие подготовленные переходы через tap-and-select.',
    'chapter4.test.lock.hint': 'Проверь 0 и 1 отдельно из q2 и q3.',
    'path.chapter5.description.title': 'По описанию',
    'path.chapter5.description.subtitle': 'Строим по реальной ситуации',
    'path.chapter5.tables.title': 'По таблицам',
    'path.chapter5.tables.subtitle': 'Строим по данным переходов',
    'chapter5.test.subtitle': 'Создай три разных автомата.',
    'chapter5.test.coffee.prompt':
        'Создай автомат Мура для кофейного автомата. Он начинает в WAITING с выходом WAIT. Монета переводит в PAID с выходом CHOOSE. Выбор напитка или отмена возвращает в WAITING. Остальные события сохраняют состояние.',
    'chapter5.test.coffee.instruction':
        'Создай два состояния, задай их выходы и начальное состояние. Для каждого состояния задай переходы по coin, choose drink и cancel. Для событий без указанной смены состояния добавь петлю.',
    'chapter5.test.coffee.hint':
        'Только coin переводит WAITING в PAID. Оба действия из PAID ведут в WAITING.',
    'chapter5.test.locker.prompt':
        'Ячейка для посылок сначала пуста, затем хранит посылку. Верный PIN открывает её, неверный оставляет закрытой, закрытие двери снова делает ячейку пустой. Создай автомат.',
    'chapter5.test.locker.instruction':
        'Создай три готовых состояния и соедини каждое событие через tap-and-select.',
    'chapter5.test.locker.hint': 'wrong PIN - петля на PARCEL STORED.',
    'chapter5.test.washingMachine.prompt':
        'Создай автомат Мура с начальным состоянием IDLE и выходом READY. События start, wash done, rinse done и door opened ведут через WASHING (WASH), RINSING (RINSE), DONE (DONE) обратно в IDLE. Остальные события сохраняют состояние.',
    'chapter5.test.washingMachine.instruction':
        'Создай четыре состояния, задай их выходы и начальное состояние. Для каждого состояния и события задай ровно один переход. Для событий без смены состояния используй петли.',
    'chapter5.test.washingMachine.hint':
        'Следуй реальному порядку: start, wash done, rinse done, door opened.',
    'task.chapter2.gatesAnd.prompt': 'Какой выход даст AND при входах 0 и 1?',
    'task.chapter2.gatesAnd.instruction': 'Выбери значение на выходе.',
    'task.chapter2.gatesAnd.hint':
        'AND выдаёт 1, только если оба входа равны 1.',
    'task.chapter2.gatesOr.prompt': 'Какой выход даст OR при входах 0 и 1?',
    'task.chapter2.gatesOr.instruction': 'Выбери значение на выходе.',
    'task.chapter2.gatesOr.hint':
        'OR выдаёт 1, если хотя бы один вход равен 1.',
    'chapter1.final.determinism.prompt':
        'Сколько исходящих переходов может быть у детерминированного FSM для каждой пары "состояние - вход"?',
    'chapter1.final.mooreOutput.prompt':
        'Автомат Мура начинает в q0 с выходом 0. Вход 1 переводит его в q1, у которого выход 1. Какой выход активен после перехода?',
    'chapter1.final.trace.prompt':
        'Начни в q0 и выполни входы 1, затем 0. В каком состоянии окажется автомат?',
    'chapter1.final.complete.prompt':
        'Полон ли показанный FSM для алфавита входов {start, stop}?',
    'chapter1.final.conflict.prompt':
        'Выбери все переходы, создающие конфликт: один и тот же вход из одного состояния ведёт в разные состояния.',
    'chapter1.final.edge.q0q1': 'q0 --0--> q1',
    'chapter1.final.edge.q0q2': 'q0 --0--> q2',
    'chapter1.final.edge.q1q2': 'q1 --1--> q2',
    'chapter2.final.andTable.prompt':
        'Используй схему с AND, чтобы вычислить все элементы таблиц переходов и выходов.',
    'chapter2.final.mixedTable.prompt':
        'Разбери схему с несколькими логическими элементами и составь таблицы переходов и выходов.',
    'chapter2.final.xorTable.prompt':
        'Используй показанную схему с XOR, чтобы вычислить таблицы переходов и выходов.',
    'chapter2.final.stateBits.prompt':
        'Сколько разных комбинаций можно представить двумя битами состояния до исключения неиспользуемых кодов?',
    'chapter2.final.xor.prompt': 'Что выдаёт XOR, если оба его входа равны 1?',
    'chapter4.final.completeness.prompt':
        'Считается ли детерминированный FSM полным, если хотя бы для одной пары "состояние - вход" не задан переход?',
    'chapter4.final.transitionCount.prompt':
        'Сколько переходов нужно для полного детерминированного FSM с тремя состояниями и двумя входами?',
    'chapter4.answer.fiveTransitions': '5 переходов',
    'chapter4.answer.sixTransitions': '6 переходов',
    'chapter4.answer.sevenTransitions': '7 переходов',
    'chapter4.task.water.prompt':
        'Дополни автомат Мура для уровня воды. Вход 0 опустошает бак, вход 1 наполняет его. В полном баке выход равен 1.',
    'chapter4.task.water.instruction':
        'Добавь отсутствующий переход из HIGH по входу 1.',
    'chapter4.task.water.hint':
        'Если бак уже полон, вход 1 оставляет автомат в HIGH.',
    'chapter4.task.pump.prompt':
        'Дополни автомат Мили для насоса с одним состоянием: sensor = 1 запускает насос, sensor = 0 останавливает его.',
    'chapter4.task.pump.instruction':
        'Добавь отсутствующую петлю sensor = 0 / STOP PUMP.',
    'chapter4.task.pump.hint':
        'Переход автомата Мили содержит и вход датчика, и выход насоса.',
    'chapter5.tables.practice.prompt':
        'Построй автомат Мили по показанной таблице переходов с тремя состояниями.',
    'chapter5.tables.practice.hint':
        'Перенеси каждую заданную строку таблицы в переход, сохранив вход и выход.',
    'chapter5.completion.second.prompt':
        'Дополни трёхсостоянийный автомат Мура. Вход 0 задаёт цикл q0 → q1 → q2 → q0. Для входа 1: q0 → q2, q1 → q0 и q2 → q1. В q0 и q2 выход равен 1, в q1 - 0.',
    'chapter5.completion.second.hint':
        'Проверь, какого перехода для входа 1 не хватает в q2.',
    'chapter5.completion.third.prompt':
        'Дополни двухсостоянийный автомат Мура. Вход 0 переключает q0 и q1, вход 1 сохраняет текущее состояние. В q0 выход равен 0, в q1 - 1.',
    'chapter5.completion.third.hint':
        'Укажи недостающий выход в q0 и добавь отсутствующую петлю из q1 по входу 1.',
    'chapter5.diagnostics.missingTransition.prompt':
        'В каком состоянии показанного автомата отсутствует исходящий переход по входу 1?',
  },
};
