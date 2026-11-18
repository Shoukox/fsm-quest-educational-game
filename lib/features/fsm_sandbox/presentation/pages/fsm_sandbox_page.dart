import 'dart:async';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/widgets/fsm_tables.dart';
import 'package:bachelor/features/fsm_sandbox/data/fsm_sandbox_storage.dart';
import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_sandbox_tools.dart';
import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_validator.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/controllers/fsm_editor_controller.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/widgets/fsm_workspace.dart';
import 'package:flutter/material.dart';

enum _SandboxPanel { none, check, simulation }

/// Verbindet den freien Automateneditor mit Speicherung, Strukturprüfung und schrittweiser Simulation.
class FsmSandboxPage extends StatefulWidget {
  const FsmSandboxPage({this.storage, this.persist = true, super.key});

  /// Optionaler Speicher für den Entwurf; standardmäßig wird die lokale App-Datenbank verwendet.
  final FsmSandboxStorage? storage;

  /// Bestimmt, ob der Automat zwischen Besuchen geladen und gespeichert wird.
  final bool persist;

  @override
  State<FsmSandboxPage> createState() => _FsmSandboxPageState();
}

class _FsmSandboxPageState extends State<FsmSandboxPage> {
  late final FsmEditorController _controller = FsmEditorController(
    boundedCanvas: false,
  );
  late final FsmSandboxStorage? _storage = widget.persist
      ? widget.storage ?? FsmSandboxStorage()
      : null;
  final _inputController = TextEditingController();

  Fsm _lastFsm = Fsm.empty;
  bool _loaded = false;
  Timer? _saveTimer;

  _SandboxPanel _panel = _SandboxPanel.none;
  List<FsmValidationIssue>? _issues;
  FsmSimulationResult? _simulation;
  int _step = 0;
  String? _simulationHint;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onModelChanged);
    unawaited(_load());
  }

  Future<void> _load() async {
    final storage = _storage;
    if (storage == null) {
      _loaded = true;
      return;
    }
    Fsm? stored;
    try {
      stored = await storage.load();
    } on Object {
      stored = null;
    }
    if (!mounted) return;
    // Zeichnungen während des Ladens haben Vorrang vor dem älteren gespeicherten Entwurf.
    if (stored != null && identical(_controller.fsm, Fsm.empty)) {
      _controller.replaceFsm(stored);
    }
    _loaded = true;
  }

  void _onModelChanged() {
    if (identical(_lastFsm, _controller.fsm)) return;
    _lastFsm = _controller.fsm;
    // Ergebnisse der vorherigen Zeichnung passen nach einer Modelländerung nicht mehr.
    if (_issues != null || _simulation != null || _simulationHint != null) {
      setState(() {
        _issues = null;
        _simulation = null;
        _simulationHint = null;
        _step = 0;
      });
    }
    _scheduleSave();
  }

  /// Bündelt schnelle Änderungen durch eine Speicherpause von 400 Millisekunden.
  void _scheduleSave() {
    if (!_loaded || _storage == null) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _saveNow);
  }

  void _saveNow() {
    final storage = _storage;
    if (storage == null || !_loaded) return;
    unawaited(storage.save(_controller.fsm).catchError((Object _) {}));
  }

  @override
  void dispose() {
    if (_saveTimer?.isActive ?? false) {
      _saveTimer!.cancel();
      _saveNow();
    }
    _controller.removeListener(_onModelChanged);
    _controller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // Aktionen -----------------------------------------------------------------

  void _togglePanel(_SandboxPanel panel) {
    setState(() {
      if (_panel == panel) {
        _panel = _SandboxPanel.none;
        _issues = null;
        _simulation = null;
        _simulationHint = null;
        return;
      }
      _panel = panel;
      _issues = panel == _SandboxPanel.check ? _runCheck() : null;
      if (panel != _SandboxPanel.simulation) {
        _simulation = null;
        _simulationHint = null;
      }
    });
  }

  List<FsmValidationIssue> _runCheck() {
    final fsm = _controller.fsm;
    final alphabet = deriveInputAlphabet(fsm);
    return const FsmValidator().validate(
      fsm,
      inputAlphabet: alphabet,
      requireTotal: alphabet.isNotEmpty,
    );
  }

  void _runSimulation() {
    final fsm = _controller.fsm;
    final alphabet = deriveInputAlphabet(fsm);
    final symbols = parseInputSequence(_inputController.text, alphabet);
    setState(() {
      if (symbols.isEmpty) {
        _simulation = null;
        _simulationHint = 'sandbox.sim.emptyInput';
        return;
      }
      _simulationHint = null;
      _simulation = simulateWithDiagnosis(fsm, symbols);
      _step = 0;
    });
  }

  void _setStep(int step) {
    final steps = _simulation?.steps ?? const [];
    if (steps.isEmpty) return;
    setState(() => _step = step.clamp(0, steps.length - 1));
  }

  Future<void> _showTables() {
    final fsm = _controller.fsm;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        maxChildSize: .95,
        builder: (context, scrollController) =>
            _SandboxTablesSheet(fsm: fsm, scrollController: scrollController),
      ),
    );
  }

  /// Zeigt das Prüfergebnis wie die Tabellen als Blatt über der Seite.
  /// Solange es geöffnet ist, bleiben die Probleme auf der Zeichenfläche hervorgehoben.
  Future<void> _showCheck() async {
    setState(() {
      _panel = _SandboxPanel.check;
      _issues = _runCheck();
      _simulation = null;
      _simulationHint = null;
    });
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .5,
        minChildSize: .25,
        maxChildSize: .95,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setSheetState) => ListView(
            key: const ValueKey('sandbox-check-sheet'),
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            children: [
              Text(
                context.l10n.t('sandbox.check.title'),
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              _CheckResult(
                fsm: _controller.fsm,
                issues: _issues ?? const [],
                onRecheck: () {
                  setState(() => _issues = _runCheck());
                  setSheetState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || _panel != _SandboxPanel.check) return;
    setState(() {
      _panel = _SandboxPanel.none;
      _issues = null;
    });
  }

  // Hervorhebungen -----------------------------------------------------------

  Set<String> get _issueStateIds => {
    for (final issue in _issues ?? const <FsmValidationIssue>[])
      if (issue.stateId != null) issue.stateId!,
  };

  Set<String> get _issueTransitionIds => {
    for (final issue in _issues ?? const <FsmValidationIssue>[])
      if (issue.type != FsmValidationIssueType.missingTransition)
        for (final transition in _controller.fsm.transitions)
          if (transition.fromStateId == issue.stateId &&
              transition.inputSymbol == issue.inputSymbol)
            transition.id,
  };

  Set<String> get _activeStateIds {
    final steps = _simulation?.steps ?? const [];
    if (_panel != _SandboxPanel.simulation || steps.isEmpty) return const {};
    return {steps[_step.clamp(0, steps.length - 1)].stateId};
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final panelMaxHeight = constraints.maxHeight * .42;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => FsmWorkspace(
                    controller: _controller,
                    height: double.infinity,
                    showGuide: true,
                    allowModeSwitch: true,
                    allowCustomValues: true,
                    allowPanning: true,
                    highlightedStateIds: _issueStateIds,
                    highlightedTransitionIds: _issueTransitionIds,
                    activeStateIds: _activeStateIds,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _SandboxActionBar(
                active: _panel,
                onTables: _showTables,
                onCheck: _showCheck,
                onSimulate: () => _togglePanel(_SandboxPanel.simulation),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.topCenter,
                // Nur die Simulation bleibt eingebettet, weil sie zusammen mit der
                // Zeichenfläche genutzt wird. Die Prüfung öffnet sich als Blatt (siehe _showCheck).
                child: _panel != _SandboxPanel.simulation
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: panelMaxHeight,
                          ),
                          child: _panelCard(context),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _panelCard(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.t('sandbox.sim.title'),
                    style: context.textStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('sandbox-panel-close'),
                  tooltip: l10n.t('sandbox.panel.close'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => _togglePanel(_panel),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => _SimulationPanel(
                  fsm: _controller.fsm,
                  inputController: _inputController,
                  result: _simulation,
                  hintKey: _simulationHint,
                  step: _step,
                  onRun: _runSimulation,
                  onStep: _setStep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Verwendet in Meldungen den sichtbaren Zustandsnamen; IDs sind intern.
String _stateLabel(Fsm fsm, String? stateId) {
  if (stateId == null) return '';
  return fsm.stateById(stateId)?.label ?? stateId;
}

class _SandboxActionBar extends StatelessWidget {
  const _SandboxActionBar({
    required this.active,
    required this.onTables,
    required this.onCheck,
    required this.onSimulate,
  });

  final _SandboxPanel active;
  final VoidCallback onTables;
  final VoidCallback onCheck;
  final VoidCallback onSimulate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget button({
      required String name,
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
      bool selected = false,
    }) {
      final child = FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      );
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: selected
              ? FilledButton(
                  key: ValueKey('sandbox-action-$name'),
                  onPressed: onPressed,
                  child: child,
                )
              : FilledButton.tonal(
                  key: ValueKey('sandbox-action-$name'),
                  onPressed: onPressed,
                  child: child,
                ),
        ),
      );
    }

    return Row(
      children: [
        button(
          name: 'tables',
          icon: Icons.table_chart_outlined,
          label: l10n.t('sandbox.action.tables'),
          onPressed: onTables,
        ),
        button(
          name: 'check',
          icon: Icons.fact_check_outlined,
          label: l10n.t('sandbox.action.check'),
          onPressed: onCheck,
          selected: active == _SandboxPanel.check,
        ),
        button(
          name: 'simulate',
          icon: Icons.play_circle_outline_rounded,
          label: l10n.t('sandbox.action.simulate'),
          onPressed: onSimulate,
          selected: active == _SandboxPanel.simulation,
        ),
      ],
    );
  }
}

class _SandboxTablesSheet extends StatelessWidget {
  const _SandboxTablesSheet({
    required this.fsm,
    required this.scrollController,
  });

  final Fsm fsm;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final alphabet = deriveInputAlphabet(fsm);
    final isMoore = fsm.outputMode == FsmOutputMode.moore;
    final heading = context.textStyles.body.copyWith(
      fontWeight: FontWeight.w800,
    );
    final muted = TextStyle(color: context.colors.mutedText);

    return ListView(
      key: const ValueKey('sandbox-tables-sheet'),
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        Text(
          l10n.t('sandbox.tables.title'),
          style: heading.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (fsm.states.isEmpty)
          Text(l10n.t('sandbox.tables.empty'), style: muted)
        else ...[
          if (alphabet.isEmpty)
            Text(l10n.t('sandbox.tables.noTransitions'), style: muted)
          else ...[
            Text(
              l10n.t(
                'sandbox.tables.alphabet',
                args: {'symbols': alphabet.join(', ')},
              ),
              style: muted,
            ),
            const SizedBox(height: 12),
            Text(l10n.t('sandbox.tables.transitionTitle'), style: heading),
            const SizedBox(height: 8),
            FsmTransitionTable(
              fsm: fsm,
              inputAlphabet: alphabet,
              showStateLabels: true,
              markInitialState: true,
              markConflicts: true,
              localizedHeaders: true,
            ),
          ],
          if (isMoore) ...[
            const SizedBox(height: 18),
            Text(l10n.t('sandbox.tables.outputTitle'), style: heading),
            const SizedBox(height: 8),
            FsmOutputTable(
              fsm: fsm,
              showStateLabels: true,
              markInitialState: true,
              localizedHeaders: true,
            ),
          ],
          const SizedBox(height: 14),
          Text(l10n.t('sandbox.tables.legend'), style: muted),
        ],
      ],
    );
  }
}

class _CheckResult extends StatelessWidget {
  const _CheckResult({
    required this.fsm,
    required this.issues,
    required this.onRecheck,
  });

  final Fsm fsm;
  final List<FsmValidationIssue> issues;
  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ok = issues.isEmpty;
    return Column(
      key: const ValueKey('sandbox-check-result'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: ok ? context.colors.primary : context.colors.danger,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ok
                    ? l10n.t('sandbox.check.ok')
                    : l10n.t(
                        'sandbox.check.issues',
                        args: {'count': issues.length},
                      ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 32),
            child: Text(
              '• ${l10n.t('fsmFeedback.${issue.type.name}', args: {'state': _stateLabel(fsm, issue.stateId), 'input': issue.inputSymbol ?? ''})}',
            ),
          ),
        const SizedBox(height: 10),
        Text(
          l10n.t('sandbox.check.scope'),
          style: TextStyle(color: context.colors.mutedText, fontSize: 13),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: const ValueKey('sandbox-check-again'),
            onPressed: onRecheck,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.t('sandbox.action.check')),
          ),
        ),
      ],
    );
  }
}

class _SimulationPanel extends StatelessWidget {
  const _SimulationPanel({
    required this.fsm,
    required this.inputController,
    required this.result,
    required this.hintKey,
    required this.step,
    required this.onRun,
    required this.onStep,
  });

  final Fsm fsm;
  final TextEditingController inputController;
  final FsmSimulationResult? result;
  final String? hintKey;
  final int step;
  final VoidCallback onRun;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final alphabet = deriveInputAlphabet(fsm);
    if (alphabet.isEmpty) {
      return Text(
        l10n.t('sandbox.sim.noTransitions'),
        style: TextStyle(color: context.colors.mutedText),
      );
    }
    final result = this.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('sandbox-sim-input'),
                controller: inputController,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => onRun(),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: l10n.t('sandbox.sim.inputLabel'),
                  hintText: l10n.t('sandbox.sim.inputHint'),
                  helperText: l10n.t(
                    'sandbox.sim.alphabet',
                    args: {'symbols': alphabet.join(', ')},
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const ValueKey('sandbox-sim-run'),
              onPressed: onRun,
              child: Text(l10n.t('sandbox.sim.run')),
            ),
          ],
        ),
        if (hintKey != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.t(hintKey!),
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        if (result != null) ...[
          const SizedBox(height: 10),
          _SimulationTrace(fsm: fsm, result: result, step: step),
          if (result.steps.length > 1) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const ValueKey('sandbox-sim-first'),
                  tooltip: l10n.t('sandbox.sim.first'),
                  onPressed: step > 0 ? () => onStep(0) : null,
                  icon: const Icon(Icons.first_page_rounded),
                ),
                IconButton(
                  key: const ValueKey('sandbox-sim-previous'),
                  tooltip: l10n.t('sandbox.sim.previous'),
                  onPressed: step > 0 ? () => onStep(step - 1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  l10n.t(
                    'sandbox.sim.step',
                    args: {'step': step, 'total': result.steps.length - 1},
                  ),
                ),
                IconButton(
                  key: const ValueKey('sandbox-sim-next'),
                  tooltip: l10n.t('sandbox.sim.next'),
                  onPressed: step < result.steps.length - 1
                      ? () => onStep(step + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                IconButton(
                  key: const ValueKey('sandbox-sim-last'),
                  tooltip: l10n.t('sandbox.sim.last'),
                  onPressed: step < result.steps.length - 1
                      ? () => onStep(result.steps.length - 1)
                      : null,
                  icon: const Icon(Icons.last_page_rounded),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            _stopMessage(context, result),
            key: const ValueKey('sandbox-sim-status'),
            style: TextStyle(
              color: result.isComplete
                  ? context.colors.mutedText
                  : context.colors.danger,
              fontWeight: result.isComplete ? null : FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  String _stopMessage(BuildContext context, FsmSimulationResult result) {
    if (result.isComplete) return context.l10n.t('sandbox.sim.done');
    return context.l10n.t(
      'sandbox.sim.stop.${result.stop.name}',
      args: {
        'state': _stateLabel(fsm, result.stopStateId),
        'input': result.stopSymbol ?? '',
      },
    );
  }
}

class _SimulationTrace extends StatelessWidget {
  const _SimulationTrace({
    required this.fsm,
    required this.result,
    required this.step,
  });

  final Fsm fsm;
  final FsmSimulationResult result;
  final int step;

  @override
  Widget build(BuildContext context) {
    final steps = result.steps;
    if (steps.isEmpty) return const SizedBox.shrink();
    final isMoore = fsm.outputMode == FsmOutputMode.moore;
    // Moore meldet auch die Anfangsausgabe; Mealy-Ausgaben gehören zu den Schritten.
    final outputs = [
      for (var index = isMoore ? 0 : 1; index <= step; index++)
        steps[index].output.isEmpty ? '-' : steps[index].output,
    ];

    Widget chip(String text, {required bool current}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: current ? context.colors.stateHighlight : context.colors.surface,
        border: Border.all(
          color: current ? context.colors.primary : context.colors.border,
          width: current ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: current ? FontWeight.w800 : null),
      ),
    );

    return Column(
      key: const ValueKey('sandbox-sim-trace'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              if (index > 0)
                Text(
                  '-${steps[index].consumedSymbol}→',
                  style: TextStyle(
                    color: index <= step
                        ? context.colors.text
                        : context.colors.mutedText,
                  ),
                ),
              chip(
                _stateLabel(fsm, steps[index].stateId),
                current: index == step,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.t(
            'sandbox.sim.outputs',
            args: {'outputs': outputs.isEmpty ? '-' : outputs.join(', ')},
          ),
          key: const ValueKey('sandbox-sim-outputs'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
