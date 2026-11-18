import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_theme.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_preset.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/controllers/fsm_editor_controller.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/widgets/fsm_workspace.dart';
import 'package:bachelor/features/mascot/presentation/widgets/speech_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';

void main() {
  for (final width in [280.0, 320.0, 375.0]) {
    testWidgets('all toolbar controls fit at width $width', (tester) async {
      final controller = FsmEditorController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _TestApp(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: FsmWorkspace(
                controller: controller,
                height: 390,
                showGuide: true,
                allowModeSwitch: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final name in [
        'help',
        ...FsmEditorTool.values.map((t) => t.name),
        'undo',
        'clear',
      ]) {
        final control = find.byKey(ValueKey('fsm-workspace-control-$name'));
        final rect = tester.getRect(control);
        expect(rect.left, greaterThanOrEqualTo(0), reason: name);
        expect(rect.right, lessThanOrEqualTo(width), reason: name);
        expect(control.hitTestable(), findsOneWidget, reason: name);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('manual placement chooses names but not outputs or reset', (
    tester,
  ) async {
    final controller = FsmEditorController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _TestApp(
        child: FsmWorkspace(
          controller: controller,
          height: 500,
          readyPresetsOnly: true,
          statePresets: const [
            FsmStatePreset(id: 'q0', label: 'q0', output: '0'),
            FsmStatePreset(id: 'q1', label: 'q1', output: '1'),
          ],
        ),
      ),
    );
    await tester.tap(find.byTooltip('Add state'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNothing);
    final canvas = tester.getRect(
      find.byKey(const ValueKey('fsm-workspace-canvas')),
    );
    await tester.tapAt(
      canvas.topLeft + Offset(canvas.width * .75, canvas.height * .5),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const ValueKey('fsm-choice-q1')));
    await tester.pumpAndSettle();
    expect(controller.fsm.states.single.id, 'q1');
    expect(controller.fsm.states.single.x, closeTo(.75, .01));
    expect(controller.fsm.states.single.output, isEmpty);
    expect(controller.fsm.initialStateId, isNull);
    controller.setTool(FsmEditorTool.editOutput);
    await tester.pump();
    await tester.tap(find.text('q1'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fsm-choice-0')));
    await tester.pumpAndSettle();
    // Falsche Ausgaben müssen möglich bleiben; die Liste darf die Antwort nicht verraten oder erzwingen.
    expect(controller.fsm.states.single.output, '0');
    controller.setTool(FsmEditorTool.setInitial);
    await tester.pump();
    await tester.tap(find.text('q1'));
    await tester.pumpAndSettle();
    expect(controller.fsm.initialStateId, 'q1');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Mealy arrows use tapped endpoints and independent input/output lists',
    (tester) async {
      final controller = FsmEditorController(
        initialFsm: const Fsm(
          outputMode: FsmOutputMode.mealy,
          states: [
            FsmState(id: 'q0', label: 'q0', x: .25, y: .5),
            FsmState(id: 'q1', label: 'q1', x: .75, y: .5),
          ],
          transitions: [],
        ),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _TestApp(
          child: FsmWorkspace(
            controller: controller,
            height: 500,
            readyPresetsOnly: true,
            transitionPresets: const [
              FsmTransitionPreset(
                symbol: 'a / 0',
                fromLabel: 'q0',
                toLabel: 'q1',
              ),
              FsmTransitionPreset(
                symbol: 'b / 1',
                fromLabel: 'q1',
                toLabel: 'q0',
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byTooltip('Add transition'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
      await tester.tap(find.text('q1'));
      await tester.tap(find.text('q0'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('fsm-choice-a')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('fsm-choice-1')));
      await tester.pumpAndSettle();
      final arrow = controller.fsm.transitions.single;
      expect(arrow.fromStateId, 'q1');
      expect(arrow.toStateId, 'q0');
      expect(arrow.symbol, 'a / 1');
      expect(find.byType(TextField), findsNothing);
      // Das Ausgabewerkzeug bearbeitet einen vorhandenen Pfeil, ohne ihn zu löschen.
      controller.setTool(FsmEditorTool.editOutput);
      await tester.pump();
      final canvas = tester.getRect(
        find.byKey(const ValueKey('fsm-workspace-canvas')),
      );
      await tester.tapAt(canvas.center);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('fsm-choice-0')));
      await tester.pumpAndSettle();
      expect(controller.fsm.transitions.single.symbol, 'a / 0');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Sandbox output tool opens an output dialog for Mealy transitions',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = FsmEditorController(
        initialFsm: const Fsm(
          outputMode: FsmOutputMode.mealy,
          states: [
            FsmState(id: 'q0', label: 'q0', x: .25, y: .5),
            FsmState(id: 'q1', label: 'q1', x: .75, y: .5),
          ],
          transitions: [
            FsmTransition(fromStateId: 'q0', toStateId: 'q1', symbol: 'a / 0'),
          ],
        ),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _TestApp(
          child: FsmWorkspace(
            controller: controller,
            height: 500,
            allowCustomValues: true,
          ),
        ),
      );
      controller.setTool(FsmEditorTool.editOutput);
      await tester.pump();
      final canvas = tester.getRect(
        find.byKey(const ValueKey('fsm-workspace-canvas')),
      );
      await tester.tapAt(canvas.center);
      await tester.pumpAndSettle();

      expect(
        find.text(
          translate(AppLanguage.en, 'fsmWorkspace.setTransitionOutput'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(translate(AppLanguage.en, 'fsmWorkspace.transitionSymbol')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('fsm-choice-1')));
      await tester.pumpAndSettle();
      expect(controller.fsm.transitions.single.symbol, 'a / 1');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dragging empty space pans the sandbox field', (tester) async {
    final controller = FsmEditorController(
      boundedCanvas: false,
      initialFsm: const Fsm(
        states: [FsmState(id: 'q0', label: 'q0', x: .5, y: .5)],
        transitions: [],
      ),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _TestApp(
        child: FsmWorkspace(
          controller: controller,
          height: 500,
          allowPanning: true,
        ),
      ),
    );
    final node = find.byKey(const ValueKey('fsm-workspace-state-q0'));
    final before = tester.getCenter(node);
    final canvas = tester.getRect(
      find.byKey(const ValueKey('fsm-workspace-canvas')),
    );

    await tester.dragFrom(
      canvas.topLeft + const Offset(20, 40),
      const Offset(-120, 0),
    );
    await tester.pumpAndSettle();

    // Die Ansicht wurde verschoben, die Modellkoordinaten nicht.
    expect(tester.getCenter(node).dx, closeTo(before.dx - 120, 30));
    expect(controller.fsm.states.single.x, .5);

    await tester.tap(find.byKey(const ValueKey('fsm-workspace-reset-view')));
    await tester.pumpAndSettle();
    expect(tester.getCenter(node).dx, closeTo(before.dx, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('HELP repeats the Fini sandbox introduction', (tester) async {
    final controller = FsmEditorController(initialFsm: Fsm.empty);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _TestApp(
        child: FsmWorkspace(
          controller: controller,
          height: 500,
          showGuide: true,
        ),
      ),
    );

    final welcome = translate(AppLanguage.en, 'fsmGuide.welcome');
    expect(find.text(welcome), findsOneWidget);
    await tester.tap(find.text(translate(AppLanguage.en, 'fsmGuide.skip')));
    await tester.pumpAndSettle();
    expect(find.text(welcome), findsNothing);

    await tester.tap(find.byTooltip('HELP'));
    await tester.pumpAndSettle();
    expect(find.text(welcome), findsOneWidget);
    expect(find.byType(SpeechBubble), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guide fits the compact workspace without flex overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(230, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = FsmEditorController(initialFsm: Fsm.empty);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _TestApp(
        child: FsmWorkspace(
          controller: controller,
          height: 390,
          showGuide: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('fsm-workspace-guide')), findsOneWidget);
    expect(find.byTooltip('Add state'), findsOneWidget);
  });

  testWidgets('guide highlights and reveals the control Fini is explaining', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = FsmEditorController(initialFsm: Fsm.empty);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _TestApp(
        child: FsmWorkspace(
          controller: controller,
          height: 500,
          showGuide: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'guide welcome');
    expect(
      find.text(translate(AppLanguage.en, 'fsmWorkspace.mooreMode')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('fsm-workspace-canvas')), findsNothing);
    expect(find.byTooltip('Add state'), findsOneWidget);

    expect(
      find.byKey(const ValueKey('fsm-workspace-guide-highlight-select')),
      findsNothing,
    );

    final workspaceRect = tester.getRect(find.byType(FsmWorkspace));
    const guideTargets = [
      'select',
      'addState',
      'addTransition',
      'setInitial',
      'editOutput',
      'delete',
      'undo',
      'clear',
      'help',
    ];
    for (final target in guideTargets) {
      await _nextGuide(tester);
      expect(
        find.byKey(ValueKey('fsm-guide-inline-icon-$target')),
        findsOneWidget,
      );
      final highlight = find.byKey(
        ValueKey('fsm-workspace-guide-highlight-$target'),
      );
      expect(highlight, findsOneWidget);

      final highlightRect = tester.getRect(highlight);
      expect(highlightRect.left, greaterThanOrEqualTo(workspaceRect.left));
      expect(highlightRect.right, lessThanOrEqualTo(workspaceRect.right));
      expect(tester.takeException(), isNull, reason: 'target: $target');
    }
  });
}

Future<void> _nextGuide(WidgetTester tester) async {
  final guide = find.byKey(const ValueKey('fsm-workspace-guide'));
  await tester.tap(
    find.descendant(of: guide, matching: find.text('Next')).last,
  );
  await tester.pumpAndSettle();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => AppLocalizations(
        language: AppLanguage.en,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(body: child),
    );
  }
}
