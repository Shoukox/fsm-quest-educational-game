import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_theme.dart';
import 'package:bachelor/core/widgets/fsm_tables.dart';
import 'package:bachelor/features/fsm_sandbox/data/fsm_sandbox_storage.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/pages/fsm_sandbox_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kippschalter, dessen Zustand "An" keinen Übergang für Eingabe 0 hat.
const _incompleteToggle = Fsm(
  initialStateId: 'q0',
  states: [
    FsmState(id: 'q0', label: 'Aus', output: '0', x: .3, y: .5),
    FsmState(id: 'q1', label: 'An', output: '1', x: .7, y: .5),
  ],
  transitions: [
    FsmTransition(fromStateId: 'q0', toStateId: 'q0', symbol: '0'),
    FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: '1'),
    FsmTransition(fromStateId: 'q1', toStateId: 'q0', symbol: '1'),
  ],
);

class _FakeStorage implements FsmSandboxStorage {
  _FakeStorage(this.stored);

  Fsm? stored;
  int saves = 0;

  @override
  Future<Fsm?> load() async => stored;

  @override
  Future<void> save(Fsm fsm) async {
    saves++;
    stored = fsm;
  }
}

Future<_FakeStorage> _pumpSandbox(WidgetTester tester, {Fsm? stored}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final storage = _FakeStorage(stored);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => AppLocalizations(
        language: AppLanguage.en,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(body: FsmSandboxPage(storage: storage)),
    ),
  );
  await tester.pumpAndSettle();
  return storage;
}

void main() {
  testWidgets('loads the stored automaton and builds its tables with the gap', (
    tester,
  ) async {
    await _pumpSandbox(tester, stored: _incompleteToggle);
    await tester.tap(find.byKey(const ValueKey('sandbox-action-tables')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sandbox-tables-sheet')), findsOneWidget);
    expect(find.byType(FsmTransitionTable), findsOneWidget);
    expect(find.byType(FsmOutputTable), findsOneWidget);
    expect(find.text('Next state'), findsOneWidget);
    expect(find.text('→ Aus'), findsWidgets);
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('check names the missing transition with the state name', (
    tester,
  ) async {
    await _pumpSandbox(tester, stored: _incompleteToggle);
    final checkButton = find.byKey(const ValueKey('sandbox-action-check'));
    final buttonTop = tester.getTopLeft(checkButton).dy;
    await tester.tap(find.byKey(const ValueKey('sandbox-action-check')));
    await tester.pumpAndSettle();

    // Das Ergebnis öffnet sich als Blatt über der Seite, statt den Arbeitsbereich
    // und die Aktionsleiste nach oben zu schieben.
    expect(find.byKey(const ValueKey('sandbox-check-sheet')), findsOneWidget);
    expect(tester.getTopLeft(checkButton).dy, buttonTop);
    expect(find.byKey(const ValueKey('sandbox-check-result')), findsOneWidget);
    expect(
      find.textContaining('State An has no outgoing transition for input 0'),
      findsOneWidget,
    );
  });

  testWidgets('simulation steps through states and stops at the gap', (
    tester,
  ) async {
    await _pumpSandbox(tester, stored: _incompleteToggle);
    await tester.tap(find.byKey(const ValueKey('sandbox-action-simulate')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('sandbox-sim-input')),
      '1 0',
    );
    await tester.tap(find.byKey(const ValueKey('sandbox-sim-run')));
    await tester.pumpAndSettle();

    expect(find.text('Step 0 of 1'), findsOneWidget);
    expect(find.text('Outputs: 0'), findsOneWidget);
    expect(
      find.textContaining(
        'stops in state An: there is no transition for input 0',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('sandbox-sim-next')));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 1'), findsOneWidget);
    expect(find.text('Outputs: 0, 1'), findsOneWidget);
  });

  testWidgets('changes are saved', (tester) async {
    final storage = await _pumpSandbox(tester, stored: _incompleteToggle);
    await tester.tap(find.byTooltip('Clear automaton'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(storage.saves, greaterThan(0));
    expect(storage.stored!.states, isEmpty);
  });
}
