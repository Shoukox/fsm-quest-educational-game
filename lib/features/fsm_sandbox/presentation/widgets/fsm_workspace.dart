import 'dart:math' as math;

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_preset.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_state.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/controllers/fsm_editor_controller.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_widget.dart';
import 'package:bachelor/features/mascot/presentation/widgets/speech_bubble.dart';
import 'package:flutter/material.dart';

/// Gemeinsame Zeichen- und Bearbeitungsfläche für Aufgaben und freie Sandbox.
/// Aufgaben können Werkzeuge und Vorgaben einschränken; die Sandbox kann eigene Werte,
/// Ausgabemoduswechsel und das Verschieben der Ansicht freigeben.
class FsmWorkspace extends StatefulWidget {
  const FsmWorkspace({
    required this.controller,
    this.allowedTools = const {
      FsmEditorTool.select,
      FsmEditorTool.addState,
      FsmEditorTool.addTransition,
      FsmEditorTool.setInitial,
      FsmEditorTool.editOutput,
      FsmEditorTool.delete,
    },
    this.readOnly = false,
    this.showToolbar = true,
    this.height = 420,
    this.statePresets = const [],
    this.transitionPresets = const [],
    this.readyPresetsOnly = false,
    this.requireTransitionEndpoints = false,
    this.showGuide = false,
    this.allowModeSwitch = false,
    this.allowCustomValues = false,
    this.allowPanning = false,
    this.showStateIdentifiers = false,
    this.onChanged,
    this.highlightedStateIds = const {},
    this.highlightedTransitionIds = const {},
    this.activeStateIds = const {},
    super.key,
  });

  final FsmEditorController controller;
  final Set<FsmEditorTool> allowedTools;
  final bool readOnly;
  final bool showToolbar;
  final double height;
  final List<FsmStatePreset> statePresets;
  final List<FsmTransitionPreset> transitionPresets;
  final bool readyPresetsOnly;
  final bool requireTransitionEndpoints;
  final bool showGuide;
  final bool allowModeSwitch;

  /// Erlaubt freie Texteingaben und das Bearbeiten von Übergangsbeschriftungen.
  final bool allowCustomValues;

  /// Erlaubt das Verschieben der Ansicht durch Ziehen auf einer freien Fläche.
  final bool allowPanning;
  final bool showStateIdentifiers;
  final ValueChanged<Fsm>? onChanged;
  final Set<String> highlightedStateIds;
  final Set<String> highlightedTransitionIds;

  /// Durch die laufende Simulation erreichte Zustände; sie erhalten die Akzentfarbe.
  final Set<String> activeStateIds;

  @override
  State<FsmWorkspace> createState() => _FsmWorkspaceState();
}

class _FsmWorkspaceState extends State<FsmWorkspace> {
  static const Object _customValueRequest = Object();

  bool _guideVisible = false;
  int _guideStep = 0;

  /// Verschiebung der Zeichenfläche innerhalb des sichtbaren Bereichs in Pixeln.
  /// Die relativen Modellkoordinaten bleiben unverändert; nur die Ansicht bewegt sich.
  Offset _panOffset = Offset.zero;

  Offset _toModel(Offset viewPosition) => viewPosition - _panOffset;

  @override
  void initState() {
    super.initState();
    _guideVisible = widget.showGuide && !widget.readOnly;
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FsmWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.showGuide && widget.showGuide && !widget.readOnly) {
      _openGuide();
    }
    if (widget.readOnly) _guideVisible = false;
    if (widget.highlightedStateIds.isNotEmpty ||
        widget.highlightedTransitionIds.isNotEmpty) {
      _guideVisible = false;
    }
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    widget.onChanged?.call(widget.controller.fsm);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final guideSteps = _guideSteps();
        final activeGuideTarget = _guideVisible
            ? guideSteps[_guideStep.clamp(0, guideSteps.length - 1)].target
            : null;
        return Container(
          height: widget.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised,
            border: Border.all(color: context.colors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_guideVisible)
                Flexible(
                  fit: FlexFit.tight,
                  child: _FsmWorkspaceGuide(
                    step: _guideStep,
                    steps: guideSteps,
                    onPrevious: _previousGuideStep,
                    onNext: _nextGuideStep,
                    onClose: _closeGuide,
                    allowCustomValues: widget.allowCustomValues,
                  ),
                ),
              if (_guideVisible && widget.showToolbar && !widget.readOnly)
                _FsmWorkspaceToolbar(
                  selectedTool: widget.controller.tool,
                  allowedTools: widget.allowedTools,
                  onSelected: _onToolSelected,
                  canUndo: widget.controller.canUndo,
                  onUndo: widget.controller.undo,
                  onClear: _clear,
                  onAutoArrange: _autoArrange,
                  hasMultipleStates: widget.controller.fsm.states.length > 1,
                  onHelp: widget.showGuide ? _openGuide : null,
                  highlightedTarget: activeGuideTarget,
                  allowCustomValues: widget.allowCustomValues,
                ),
              if (!_guideVisible)
                Expanded(
                  child: Column(
                    children: [
                      _OutputModeBanner(
                        mode: widget.controller.fsm.outputMode,
                        allowModeSwitch: widget.allowModeSwitch,
                        onModeChanged: widget.controller.setOutputMode,
                      ),
                      if (widget.showToolbar && !widget.readOnly)
                        _FsmWorkspaceToolbar(
                          selectedTool: widget.controller.tool,
                          allowedTools: widget.allowedTools,
                          onSelected: _onToolSelected,
                          canUndo: widget.controller.canUndo,
                          onUndo: widget.controller.undo,
                          onClear: _clear,
                          onAutoArrange: _autoArrange,
                          hasMultipleStates:
                              widget.controller.fsm.states.length > 1,
                          onHelp: widget.showGuide ? _openGuide : null,
                          highlightedTarget: activeGuideTarget,
                          allowCustomValues: widget.allowCustomValues,
                        ),
                      if (widget.controller.fsm.transitions.isNotEmpty)
                        _TransitionStrip(
                          fsm: widget.controller.fsm,
                          readOnly: widget.readOnly,
                          onDeleted: widget.controller.removeTransition,
                          showStateIdentifiers: widget.showStateIdentifiers,
                        ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final size = constraints.biggest;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: widget.readOnly
                                  ? null
                                  : (details) => _onCanvasTap(
                                      _toModel(details.localPosition),
                                      size,
                                    ),
                              // Zustandsknoten haben eigene Zieh-Handler, daher
                              // greift dies nur beim Ziehen auf freier Fläche.
                              onPanUpdate: widget.allowPanning
                                  ? (details) => setState(
                                      () => _panOffset += details.delta,
                                    )
                                  : null,
                              child: CustomPaint(
                                key: const ValueKey('fsm-workspace-canvas'),
                                painter: _FsmWorkspacePainter(
                                  panOffset: _panOffset,
                                  fsm: widget.controller.fsm,
                                  lineColor: context.colors.text,
                                  outlineColor: context.colors.primary,
                                  labelColor: context.colors.warning,
                                  labelBackgroundColor:
                                      context.colors.surfaceRaised,
                                  outputColor: context.colors.primaryDark,
                                  accentColor: context.colors.primary,
                                  mutedColor: context.colors.mutedText,
                                  diagnosticColor: context.colors.danger,
                                  highlightedTransitionIds:
                                      widget.highlightedTransitionIds,
                                ),
                                child: Stack(
                                  children: [
                                    for (final state
                                        in widget.controller.fsm.states)
                                      _positionedState(context, state, size),
                                    if (widget.allowPanning &&
                                        _panOffset != Offset.zero)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: IconButton.filledTonal(
                                          key: const ValueKey(
                                            'fsm-workspace-reset-view',
                                          ),
                                          tooltip: context.l10n.t(
                                            'fsmWorkspace.resetView',
                                          ),
                                          icon: const Icon(
                                            Icons.center_focus_strong_outlined,
                                          ),
                                          onPressed: () => setState(
                                            () => _panOffset = Offset.zero,
                                          ),
                                        ),
                                      ),
                                    if (widget.controller.fsm.states.isEmpty)
                                      Center(
                                        child: Text(
                                          context.l10n.t(
                                            widget.readOnly
                                                ? 'fsmWorkspace.empty'
                                                : 'fsmWorkspace.tapToAdd',
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: context.colors.mutedText,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _positionedState(
    BuildContext context,
    FsmState state,
    Size canvasSize,
  ) {
    const diameter = 64.0;
    final modelCenter = Offset(
      state.x * canvasSize.width,
      state.y * canvasSize.height,
    );
    final center = modelCenter + _panOffset;
    final isSelected = widget.controller.selectedStateId == state.id;
    final hasIssue = widget.highlightedStateIds.contains(state.id);
    final isActive = widget.activeStateIds.contains(state.id);
    // Während einer Simulation darf eine Auswahl die Markierung nicht verdecken.
    final selected = isSelected && widget.activeStateIds.isEmpty;

    return Positioned(
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      child: GestureDetector(
        onTap: AppHaptics.wrapButton(
          widget.readOnly ? null : () => _onStateTap(state),
        ),
        onLongPress: widget.readOnly ? null : () => _renameState(state),
        onPanUpdate:
            widget.readOnly || widget.controller.tool != FsmEditorTool.select
            ? null
            : (details) {
                widget.controller.moveState(
                  state.id,
                  x: (modelCenter.dx + details.delta.dx) / canvasSize.width,
                  y: (modelCenter.dy + details.delta.dy) / canvasSize.height,
                );
              },
        onPanStart:
            widget.readOnly || widget.controller.tool != FsmEditorTool.select
            ? null
            : (_) => widget.controller.beginStateMove(),
        onPanEnd:
            widget.readOnly || widget.controller.tool != FsmEditorTool.select
            ? null
            : (_) => widget.controller.endStateMove(),
        onPanCancel:
            widget.readOnly || widget.controller.tool != FsmEditorTool.select
            ? null
            : widget.controller.endStateMove,
        child: Semantics(
          button: !widget.readOnly,
          selected: selected,
          label: widget.showStateIdentifiers
              ? '${state.id}: ${state.label}'
              : state.label,
          child: Container(
            key: ValueKey('fsm-workspace-state-${state.id}'),
            width: diameter,
            height: diameter,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? context.colors.primary
                  : isActive
                  ? context.colors.stateHighlight
                  : context.colors.surfaceRaised,
              border: Border.all(
                color: hasIssue
                    ? context.colors.danger
                    : isActive
                    ? context.colors.primary
                    : selected
                    ? context.colors.primaryDark
                    : context.colors.text,
                width: hasIssue || isActive ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? context.colors.primary.withValues(alpha: .55)
                      : context.colors.shadow,
                  blurRadius: isActive ? 12 : 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.showStateIdentifiers ? state.id : state.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected
                            ? context.colors.onPrimary
                            : context.colors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (widget.controller.fsm.outputMode ==
                            FsmOutputMode.moore &&
                        state.output.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'y = ${state.output}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? context.colors.onPrimary
                              : context.colors.primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Anordnen und Leeren platzieren Zustände im Standardbereich, daher
  // kehrt auch die Ansicht dorthin zurück.
  void _autoArrange() {
    setState(() => _panOffset = Offset.zero);
    widget.controller.arrangeStatesZigzag();
  }

  void _clear() {
    setState(() => _panOffset = Offset.zero);
    widget.controller.clear();
  }

  void _onToolSelected(FsmEditorTool tool) {
    if (!widget.readOnly) widget.controller.setTool(tool);
  }

  List<FsmStatePreset> get _stateChoices => widget.statePresets.isNotEmpty
      ? widget.statePresets
      : [
          for (var i = 0; i < 26; i++)
            FsmStatePreset(id: 'q$i', label: 'q$i', output: ''),
        ];

  Future<String?> _choose(
    String titleKey,
    Iterable<String> values, {
    String? initialValue,
    String? subtitle,
  }) {
    final options = values.toSet();
    if (initialValue != null && initialValue.isNotEmpty) {
      options.add(initialValue);
    }
    if (widget.allowCustomValues && titleKey == 'fsmWorkspace.stateOutput') {
      options.add('');
    }
    return showModalBottomSheet<Object?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                sheetContext.l10n.t(titleKey),
                style: sheetContext.textStyles.title,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(subtitle),
              ),
            if (widget.allowCustomValues)
              ListTile(
                key: const ValueKey('fsm-choice-custom'),
                leading: const Icon(Icons.edit_outlined),
                title: Text(sheetContext.l10n.t('fsmWorkspace.customValue')),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_customValueRequest),
              ),
            for (final value in options)
              ListTile(
                key: ValueKey('fsm-choice-$value'),
                title: Text(
                  value.isEmpty
                      ? sheetContext.l10n.t('fsmWorkspace.noOutput')
                      : value,
                ),
                onTap: () => Navigator.of(sheetContext).pop(value),
              ),
          ],
        ),
      ),
    ).then((selection) {
      if (!mounted || selection == null) return null;
      if (identical(selection, _customValueRequest)) {
        return _showCustomValueDialog(
          context,
          titleKey,
          initialValue: initialValue,
          subtitle: subtitle,
        );
      }
      return selection as String;
    });
  }

  Future<String?> _showCustomValueDialog(
    BuildContext parentContext,
    String titleKey, {
    String? initialValue,
    String? subtitle,
  }) {
    return showDialog<String>(
      context: parentContext,
      builder: (_) => _CustomValueDialog(
        titleKey: titleKey,
        initialValue: initialValue ?? '',
        subtitle: subtitle,
      ),
    );
  }

  Future<void> _placeState(Offset position, Size size) async {
    final available = _stateChoices.where(
      (preset) => !widget.controller.fsm.states.any(
        (state) => preset.id != null
            ? state.id == preset.id
            : state.label == preset.label,
      ),
    );
    final names = {
      for (final preset in available)
        (preset.id != null && preset.id != preset.label
                ? '${preset.id}: ${preset.label}'
                : preset.label):
            preset,
    };
    final name = await _choose('fsmWorkspace.chooseState', names.keys);
    if (!mounted || name == null) return;
    final preset = names[name];
    widget.controller.addState(
      id: preset?.id,
      label: preset?.label ?? name,
      x: position.dx / size.width,
      y: position.dy / size.height,
    );
    widget.controller.selectState(null);
  }

  Iterable<String> get _inputChoices => widget.transitionPresets.isEmpty
      ? [for (var i = 0; i < 26; i++) String.fromCharCode(97 + i)]
      : widget.transitionPresets.map(
          (preset) => preset.symbol.split('/').first.trim(),
        );

  Iterable<String> get _outputChoices {
    final outputs = {
      for (final preset in widget.statePresets)
        if (preset.output.isNotEmpty) preset.output,
      for (final preset in widget.transitionPresets)
        if (preset.symbol.contains('/'))
          preset.symbol.split('/').skip(1).join('/').trim(),
    };
    return outputs.isEmpty ? const ['0', '1'] : outputs;
  }

  List<_FsmGuideStep> _guideSteps() {
    final steps = [
      _FsmGuideStep(
        widget.allowCustomValues
            ? 'fsmGuide.customWelcome'
            : widget.readyPresetsOnly
            ? 'fsmGuide.readyWelcome'
            : 'fsmGuide.welcome',
      ),
    ];
    if (!widget.showToolbar) return steps;

    return [
      ...steps,
      for (final tool in FsmEditorTool.values)
        if (widget.allowedTools.contains(tool))
          _FsmGuideStep(
            _guideKeyForTool(tool),
            target: _FsmGuideTarget.forTool(tool),
          ),
      const _FsmGuideStep('fsmGuide.undo', target: _FsmGuideTarget.undo),
      const _FsmGuideStep('fsmGuide.clear', target: _FsmGuideTarget.clear),
      const _FsmGuideStep('fsmGuide.help', target: _FsmGuideTarget.help),
    ];
  }

  String _guideKeyForTool(FsmEditorTool tool) {
    if (widget.allowCustomValues) {
      return switch (tool) {
        FsmEditorTool.addState => 'fsmGuide.addStateCustom',
        FsmEditorTool.addTransition => 'fsmGuide.addTransitionCustom',
        FsmEditorTool.editOutput => 'fsmGuide.customize',
        _ => 'fsmGuide.${tool.name}',
      };
    }
    if (widget.readyPresetsOnly && tool == FsmEditorTool.addState) {
      return 'fsmGuide.addStateReady';
    }
    if (widget.readyPresetsOnly && tool == FsmEditorTool.addTransition) {
      return widget.requireTransitionEndpoints
          ? 'fsmGuide.addTransitionChooseEndpoints'
          : 'fsmGuide.addTransitionReady';
    }
    return 'fsmGuide.${tool.name}';
  }

  void _openGuide() {
    if (!widget.showGuide || widget.readOnly) return;
    AppHaptics.hint();
    setState(() {
      _guideStep = 0;
      _guideVisible = true;
    });
  }

  void _closeGuide() {
    setState(() => _guideVisible = false);
  }

  void _previousGuideStep() {
    if (_guideStep == 0) return;
    setState(() => _guideStep--);
  }

  void _nextGuideStep() {
    final lastStep = _guideSteps().length - 1;
    if (_guideStep >= lastStep) {
      _closeGuide();
      return;
    }
    setState(() => _guideStep++);
  }

  void _onCanvasTap(Offset position, Size size) {
    switch (widget.controller.tool) {
      case FsmEditorTool.addState:
        _placeState(position, size);
      case FsmEditorTool.delete:
        final transitionId = _transitionAt(position, size);
        if (transitionId != null) {
          AppHaptics.selection();
          widget.controller.removeTransition(transitionId);
        }
      case FsmEditorTool.select:
      case FsmEditorTool.setInitial:
        break;
      case FsmEditorTool.editOutput:
        final id = _transitionAt(position, size);
        if (id != null) {
          // Im Mealy-Modus setzt das Ausgabewerkzeug nur die Übergangsausgabe;
          // das Eingabesymbol bleibt unverändert.
          if (widget.controller.fsm.outputMode == FsmOutputMode.mealy) {
            _editTransitionOutput(id);
          } else if (widget.allowCustomValues) {
            _editTransitionLabels(id);
          }
        }
        break;
      case FsmEditorTool.addTransition:
        break;
    }
  }

  String? _transitionAt(Offset position, Size size) {
    final fsm = widget.controller.fsm;
    final centers = {
      for (final state in fsm.states)
        state.id: Offset(state.x * size.width, state.y * size.height),
    };
    for (final transition in fsm.transitions.reversed) {
      final from = centers[transition.fromStateId];
      final to = centers[transition.toStateId];
      if (from == null || to == null) continue;
      final geometry = _WorkspaceTransitionGeometry.fromTransition(
        transition: transition,
        transitions: fsm.transitions,
        from: from,
        to: to,
      );
      if (geometry.distanceTo(position) <= 18) return transition.id;
    }
    return null;
  }

  Future<void> _onStateTap(FsmState state) async {
    switch (widget.controller.tool) {
      case FsmEditorTool.select:
        widget.controller.selectState(state.id);
      case FsmEditorTool.addState:
        break;
      case FsmEditorTool.setInitial:
        widget.controller.setInitialState(state.id);
      case FsmEditorTool.editOutput:
        await _editStateOutput(state);
      case FsmEditorTool.delete:
        widget.controller.removeState(state.id);
      case FsmEditorTool.addTransition:
        final fromStateId = widget.controller.selectedStateId;
        if (fromStateId == null) {
          widget.controller.selectState(state.id);
          return;
        }
        final input = await _choose(
          'fsmWorkspace.transitionSymbol',
          _inputChoices,
        );
        if (input == null || !mounted) return;
        var symbol = input;
        if (widget.controller.fsm.outputMode == FsmOutputMode.mealy) {
          final output = await _choose(
            'fsmWorkspace.transitionOutput',
            _outputChoices,
          );
          if (!mounted || output == null) return;
          symbol = '$input / $output';
        }
        widget.controller.addTransition(
          fromStateId: fromStateId,
          toStateId: state.id,
          symbol: symbol,
        );
    }
  }

  Future<void> _renameState(FsmState state) async {
    final label = await _choose(
      'fsmWorkspace.stateLabel',
      _stateChoices.map((p) => p.label),
      initialValue: state.label,
    );
    if (mounted && label != null) {
      widget.controller.renameState(state.id, label);
    }
  }

  Future<void> _editStateOutput(FsmState state) async {
    if (widget.controller.fsm.outputMode != FsmOutputMode.moore) return;
    final output = await _choose(
      'fsmWorkspace.stateOutput',
      _outputChoices,
      initialValue: state.output,
    );
    if (mounted && output != null) {
      widget.controller.setStateOutput(state.id, output);
    }
  }

  Future<void> _editTransitionOutput(String id) async {
    final fsm = widget.controller.fsm;
    final transition = fsm.transitions.firstWhere((t) => t.id == id);
    String labelOf(String stateId) => fsm.states
        .firstWhere(
          (s) => s.id == stateId,
          orElse: () => FsmState(id: stateId, label: stateId, x: 0, y: 0),
        )
        .label;
    final output = await _choose(
      'fsmWorkspace.setTransitionOutput',
      _outputChoices,
      initialValue: transition.outputValue,
      subtitle: context.l10n.t(
        'fsmWorkspace.setTransitionOutputHint',
        args: {
          'from': labelOf(transition.fromStateId),
          'to': labelOf(transition.toStateId),
          'input': transition.inputSymbol,
        },
      ),
    );
    if (mounted && output != null) {
      widget.controller.setTransitionSymbol(
        id,
        '${transition.inputSymbol} / $output',
      );
    }
  }

  Future<void> _editTransitionLabels(String id) async {
    final transition = widget.controller.fsm.transitions.firstWhere(
      (item) => item.id == id,
    );
    final input = await _choose(
      'fsmWorkspace.transitionSymbol',
      _inputChoices,
      initialValue: transition.inputSymbol,
    );
    if (!mounted || input == null) return;
    var symbol = input;
    if (widget.controller.fsm.outputMode == FsmOutputMode.mealy) {
      final output = await _choose(
        'fsmWorkspace.transitionOutput',
        _outputChoices,
        initialValue: transition.outputValue,
      );
      if (!mounted || output == null) return;
      symbol = '$input / $output';
    }
    widget.controller.setTransitionSymbol(id, symbol);
  }
}

/// Strukturelle Verbindung zwischen dem Hilfeschritt und dem erklärten Bedienelement.
/// Die Unabhängigkeit vom übersetzten Hilfetext verhindert, dass eine Textänderung
/// den visuellen Hinweis unbemerkt unterbricht.
enum _FsmGuideTarget {
  select,
  addState,
  addTransition,
  setInitial,
  editOutput,
  delete,
  undo,
  clear,
  help;

  static _FsmGuideTarget forTool(FsmEditorTool tool) {
    return switch (tool) {
      FsmEditorTool.select => _FsmGuideTarget.select,
      FsmEditorTool.addState => _FsmGuideTarget.addState,
      FsmEditorTool.addTransition => _FsmGuideTarget.addTransition,
      FsmEditorTool.setInitial => _FsmGuideTarget.setInitial,
      FsmEditorTool.editOutput => _FsmGuideTarget.editOutput,
      FsmEditorTool.delete => _FsmGuideTarget.delete,
    };
  }

  String get labelKey {
    return switch (this) {
      _FsmGuideTarget.select => 'fsmTool.select',
      _FsmGuideTarget.addState => 'fsmTool.addState',
      _FsmGuideTarget.addTransition => 'fsmTool.addTransition',
      _FsmGuideTarget.setInitial => 'fsmTool.setInitial',
      _FsmGuideTarget.editOutput => 'fsmTool.editOutput',
      _FsmGuideTarget.delete => 'fsmTool.delete',
      _FsmGuideTarget.undo => 'fsmWorkspace.undo',
      _FsmGuideTarget.clear => 'fsmWorkspace.clear',
      _FsmGuideTarget.help => 'fsmWorkspace.help',
    };
  }

  IconData get icon {
    return switch (this) {
      _FsmGuideTarget.select => Icons.pan_tool_alt_outlined,
      _FsmGuideTarget.addState => Icons.add_circle_outline,
      _FsmGuideTarget.addTransition => Icons.arrow_forward_rounded,
      _FsmGuideTarget.setInitial => Icons.first_page_rounded,
      _FsmGuideTarget.editOutput => Icons.output_rounded,
      _FsmGuideTarget.delete => Icons.delete_outline_rounded,
      _FsmGuideTarget.undo => Icons.undo_rounded,
      _FsmGuideTarget.clear => Icons.restart_alt_rounded,
      _FsmGuideTarget.help => Icons.help_outline_rounded,
    };
  }
}

class _FsmGuideStep {
  const _FsmGuideStep(this.textKey, {this.target});

  final String textKey;
  final _FsmGuideTarget? target;
}

class _CustomValueDialog extends StatefulWidget {
  const _CustomValueDialog({
    required this.titleKey,
    required this.initialValue,
    this.subtitle,
  });

  final String titleKey;
  final String initialValue;
  final String? subtitle;

  @override
  State<_CustomValueDialog> createState() => _CustomValueDialogState();
}

class _CustomValueDialogState extends State<_CustomValueDialog> {
  late final TextEditingController _valueController = TextEditingController(
    text: widget.initialValue,
  );
  String? _validationError;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _save() {
    final value = _valueController.text.trim();
    if (value.isEmpty) return;
    if (widget.titleKey == 'fsmWorkspace.transitionSymbol' &&
        value.contains('/')) {
      setState(
        () => _validationError = context.l10n.t(
          'fsmWorkspace.transitionSymbolSlashError',
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.t(widget.titleKey)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.subtitle != null) ...[
            Text(widget.subtitle!),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _valueController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: context.l10n.t('fsmWorkspace.customValueHint'),
              errorText: _validationError,
            ),
            onChanged: (_) => setState(() => _validationError = null),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.t('common.cancel')),
        ),
        FilledButton(
          onPressed: _valueController.text.trim().isEmpty ? null : _save,
          child: Text(context.l10n.t('common.save')),
        ),
      ],
    );
  }
}

class _FsmWorkspaceGuide extends StatelessWidget {
  const _FsmWorkspaceGuide({
    required this.step,
    required this.steps,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.allowCustomValues,
  });

  final int step;
  final List<_FsmGuideStep> steps;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final bool allowCustomValues;

  @override
  Widget build(BuildContext context) {
    final isLast = step >= steps.length - 1;
    final current = steps[step.clamp(0, steps.length - 1)];

    return Card(
      key: const ValueKey('fsm-workspace-guide'),
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: MascotWidget(pose: MascotPose.speaking, size: 56),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: current.target == null
                        ? SpeechBubble(message: context.l10n.t(current.textKey))
                        : SpeechBubble(
                            messageSpan: _messageSpan(context, current),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 2,
                children: [
                  Text(
                    '${step + 1} / ${steps.length}',
                    style: context.textStyles.caption,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: AppHaptics.wrapButton(onClose),
                    child: Text(context.l10n.t('fsmGuide.skip')),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: AppHaptics.wrapButton(
                        step == 0 ? null : onPrevious,
                      ),
                      child: Text(context.l10n.t('common.back')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: AppHaptics.wrapButton(onNext),
                      child: Text(
                        context.l10n.t(
                          isLast ? 'fsmGuide.done' : 'common.next',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InlineSpan _messageSpan(BuildContext context, _FsmGuideStep current) {
    final message = context.l10n.t(current.textKey);
    final target = current.target;
    if (target == null || !message.contains('{control}')) {
      return TextSpan(text: message);
    }
    final targetLabelKey =
        allowCustomValues && target == _FsmGuideTarget.editOutput
        ? 'fsmTool.customize'
        : target.labelKey;

    final parts = message.split('{control}');
    return TextSpan(
      children: [
        TextSpan(text: parts.first),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(
            target.icon,
            key: ValueKey('fsm-guide-inline-icon-${target.name}'),
            size: 17,
            color: context.colors.primary,
            semanticLabel: context.l10n.t(targetLabelKey),
          ),
        ),
        TextSpan(text: ' ${context.l10n.t(targetLabelKey)}'),
        for (final part in parts.skip(1)) TextSpan(text: part),
      ],
    );
  }
}

class _TransitionStrip extends StatelessWidget {
  const _TransitionStrip({
    required this.fsm,
    required this.readOnly,
    required this.onDeleted,
    required this.showStateIdentifiers,
  });

  final Fsm fsm;
  final bool readOnly;
  final ValueChanged<String> onDeleted;
  final bool showStateIdentifiers;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final transition in fsm.transitions)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InputChip(
                  label: Text(
                    '${_stateName(transition.fromStateId)}'
                    ' -${transition.symbol}→ '
                    '${_stateName(transition.toStateId)}',
                  ),
                  onDeleted: readOnly ? null : () => onDeleted(transition.id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _stateName(String stateId) {
    if (showStateIdentifiers) return stateId;
    return fsm.stateById(stateId)?.label ?? stateId;
  }
}

class _OutputModeBanner extends StatelessWidget {
  const _OutputModeBanner({
    required this.mode,
    required this.allowModeSwitch,
    required this.onModeChanged,
  });

  final FsmOutputMode mode;
  final bool allowModeSwitch;
  final ValueChanged<FsmOutputMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final isMoore = mode == FsmOutputMode.moore;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      color: isMoore
          ? context.colors.primary.withValues(alpha: 0.10)
          : context.colors.secondary.withValues(alpha: 0.10),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 2,
        children: [
          Icon(
            isMoore ? Icons.circle_outlined : Icons.alt_route_rounded,
            size: 18,
            color: isMoore
                ? context.colors.primaryDark
                : context.colors.secondary,
          ),
          SizedBox(
            width: allowModeSwitch ? 120 : null,
            child: Text(
              context.l10n.t(
                isMoore ? 'fsmWorkspace.mooreMode' : 'fsmWorkspace.mealyMode',
              ),
              style: context.textStyles.caption.copyWith(
                color: context.colors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (allowModeSwitch)
            DropdownButton<FsmOutputMode>(
              value: mode,
              isDense: true,
              underline: const SizedBox.shrink(),
              onChanged: AppHaptics.wrapSelection<FsmOutputMode?>((value) {
                if (value != null) onModeChanged(value);
              }),
              items: [
                DropdownMenuItem(
                  value: FsmOutputMode.moore,
                  child: Text(context.l10n.t('fsmWorkspace.moore')),
                ),
                DropdownMenuItem(
                  value: FsmOutputMode.mealy,
                  child: Text(context.l10n.t('fsmWorkspace.mealy')),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FsmWorkspaceToolbar extends StatefulWidget {
  const _FsmWorkspaceToolbar({
    required this.selectedTool,
    required this.allowedTools,
    required this.onSelected,
    required this.canUndo,
    required this.onUndo,
    required this.onClear,
    required this.onAutoArrange,
    required this.hasMultipleStates,
    required this.onHelp,
    required this.highlightedTarget,
    required this.allowCustomValues,
  });

  final FsmEditorTool selectedTool;
  final Set<FsmEditorTool> allowedTools;
  final ValueChanged<FsmEditorTool> onSelected;
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onAutoArrange;
  final bool hasMultipleStates;
  final VoidCallback? onHelp;
  final _FsmGuideTarget? highlightedTarget;
  final bool allowCustomValues;

  @override
  State<_FsmWorkspaceToolbar> createState() => _FsmWorkspaceToolbarState();
}

class _FsmWorkspaceToolbarState extends State<_FsmWorkspaceToolbar> {
  late final Map<_FsmGuideTarget, GlobalKey> _targetKeys = {
    for (final target in _FsmGuideTarget.values) target: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _revealHighlightedTarget();
  }

  @override
  void didUpdateWidget(covariant _FsmWorkspaceToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightedTarget != widget.highlightedTarget) {
      _revealHighlightedTarget();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _revealHighlightedTarget() {
    final target = widget.highlightedTarget;
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = _targetKeys[target]?.currentContext;
      if (targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        alignment: .5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: context.colors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Wrap(
            spacing: 2,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (widget.onHelp != null) ...[
                _highlightControl(
                  _FsmGuideTarget.help,
                  IconButton.filledTonal(
                    iconSize: 18,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: context.l10n.t('fsmWorkspace.help'),
                    key: const ValueKey('fsm-workspace-control-help'),
                    onPressed: widget.onHelp,
                    icon: const Icon(Icons.help_outline_rounded),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              for (final tool in FsmEditorTool.values)
                if (widget.allowedTools.contains(tool))
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _highlightControl(
                      _FsmGuideTarget.forTool(tool),
                      IconButton.filledTonal(
                        iconSize: 18,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                        padding: EdgeInsets.zero,
                        key: ValueKey('fsm-workspace-control-${tool.name}'),
                        isSelected: widget.selectedTool == tool,
                        tooltip: context.l10n.t(
                          widget.allowCustomValues &&
                                  tool == FsmEditorTool.editOutput
                              ? 'fsmTool.customize'
                              : 'fsmTool.${tool.name}',
                        ),
                        onPressed: AppHaptics.wrapButton(
                          () => widget.onSelected(tool),
                        ),
                        icon: Icon(_toolIcon(tool)),
                      ),
                    ),
                  ),
              _highlightControl(
                _FsmGuideTarget.undo,
                IconButton(
                  iconSize: 18,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  padding: EdgeInsets.zero,
                  key: const ValueKey('fsm-workspace-control-undo'),
                  tooltip: context.l10n.t('fsmWorkspace.undo'),
                  onPressed: AppHaptics.wrapButton(
                    widget.canUndo ? widget.onUndo : null,
                  ),
                  icon: const Icon(Icons.undo_rounded),
                ),
              ),
              IconButton.filledTonal(
                iconSize: 18,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                padding: EdgeInsets.zero,
                key: const ValueKey('fsm-workspace-control-auto-arrange'),
                tooltip: context.l10n.t('fsmWorkspace.autoArrange'),
                onPressed: AppHaptics.wrapButton(
                  widget.hasMultipleStates ? widget.onAutoArrange : null,
                ),
                icon: const Icon(Icons.alt_route_rounded),
              ),
              const SizedBox(width: 4),
              _highlightControl(
                _FsmGuideTarget.clear,
                IconButton(
                  iconSize: 18,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  padding: EdgeInsets.zero,
                  key: const ValueKey('fsm-workspace-control-clear'),
                  tooltip: context.l10n.t('fsmWorkspace.clear'),
                  onPressed: AppHaptics.wrapButton(widget.onClear),
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _toolIcon(FsmEditorTool tool) {
    return switch (tool) {
      FsmEditorTool.select => Icons.pan_tool_alt_outlined,
      FsmEditorTool.addState => Icons.add_circle_outline,
      FsmEditorTool.addTransition => Icons.arrow_forward_rounded,
      FsmEditorTool.setInitial => Icons.first_page_rounded,
      FsmEditorTool.editOutput => Icons.output_rounded,
      FsmEditorTool.delete => Icons.delete_outline_rounded,
    };
  }

  Widget _highlightControl(_FsmGuideTarget target, Widget child) {
    return _FsmGuideControlHighlight(
      key: _targetKeys[target],
      target: target,
      highlighted: widget.highlightedTarget == target,
      child: child,
    );
  }
}

class _FsmGuideControlHighlight extends StatelessWidget {
  const _FsmGuideControlHighlight({
    required this.target,
    required this.highlighted,
    required this.child,
    super.key,
  });

  final _FsmGuideTarget target;
  final bool highlighted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (highlighted)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                key: ValueKey('fsm-workspace-guide-highlight-${target.name}'),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: context.colors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: .42),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FsmWorkspacePainter extends CustomPainter {
  const _FsmWorkspacePainter({
    required this.panOffset,
    required this.fsm,
    required this.lineColor,
    required this.outlineColor,
    required this.labelColor,
    required this.labelBackgroundColor,
    required this.outputColor,
    required this.accentColor,
    required this.mutedColor,
    required this.diagnosticColor,
    required this.highlightedTransitionIds,
  });

  /// Um wie viel die Kontur breiter ist als die umschlossene Übergangslinie.
  static const double _outlineExtraWidth = 3;

  final Offset panOffset;
  final Fsm fsm;
  final Color lineColor;
  final Color outlineColor;
  final Color labelColor;
  final Color labelBackgroundColor;
  final Color outputColor;
  final Color accentColor;
  final Color mutedColor;
  final Color diagnosticColor;
  final Set<String> highlightedTransitionIds;

  @override
  void paint(Canvas canvas, Size size) {
    final stateCenters = {
      for (final state in fsm.states)
        state.id:
            Offset(state.x * size.width, state.y * size.height) + panOffset,
    };
    final transitionPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    // Wird als Rahmen unter jede Linie und Pfeilspitze gezeichnet.
    final outlinePaint = Paint()
      ..color = outlineColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final transition in fsm.transitions) {
      final hasIssue = highlightedTransitionIds.contains(transition.id);
      transitionPaint
        ..color = hasIssue ? diagnosticColor : lineColor
        ..strokeWidth = hasIssue ? 4 : 2;
      outlinePaint.strokeWidth =
          transitionPaint.strokeWidth + _outlineExtraWidth;
      final from = stateCenters[transition.fromStateId];
      final to = stateCenters[transition.toStateId];
      if (from == null || to == null) continue;
      final geometry = _WorkspaceTransitionGeometry.fromTransition(
        transition: transition,
        transitions: fsm.transitions,
        from: from,
        to: to,
      );
      for (final paint in [outlinePaint, transitionPaint]) {
        canvas.drawPath(geometry.path, paint);
        _drawArrowHead(
          canvas,
          geometry.arrowTip,
          geometry.arrowDirection.direction,
          paint,
        );
      }
      _drawLabel(canvas, size, transition, geometry.labelCenter);
    }

    final initialCenter = stateCenters[fsm.initialStateId];
    if (initialCenter != null) {
      final start = Offset(
        math.max(4, initialCenter.dx - 78),
        initialCenter.dy,
      );
      final end = initialCenter.translate(-36, 0);
      final initialPaint = Paint()
        ..color = accentColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, initialPaint);
      _drawArrowHead(canvas, end, 0, initialPaint);
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Paint paint) {
    const length = 10.0;
    const spread = 0.55;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - length * math.cos(angle - spread),
        tip.dy - length * math.sin(angle - spread),
      )
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - length * math.cos(angle + spread),
        tip.dy - length * math.sin(angle + spread),
      );
    canvas.drawPath(path, paint);
  }

  void _drawLabel(
    Canvas canvas,
    Size size,
    FsmTransition transition,
    Offset center,
  ) {
    // Mealy-Ausgaben erscheinen wie Moore-Ausgaben an Zuständen: Die Eingabe bleibt
    // in der Beschriftung, die Ausgabe folgt darunter als kleine Zeile `y = …`.
    final output = fsm.outputMode == FsmOutputMode.mealy
        ? transition.outputValue
        : '';
    final input = output.isEmpty ? transition.symbol : transition.inputSymbol;

    TextPainter layoutLabel(double scale) => TextPainter(
      text: TextSpan(
        text: input,
        style: TextStyle(
          color: labelColor,
          fontSize: 13 * scale,
          fontWeight: FontWeight.w800,
        ),
        children: [
          if (output.isNotEmpty)
            TextSpan(
              text: '\ny = $output',
              style: TextStyle(
                color: outputColor,
                fontSize: 11 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 126);

    var painter = layoutLabel(1);
    if (painter.width > 126) painter = layoutLabel(10 / 13);
    final width = painter.width + 10;
    final height = painter.height + 6;
    final clampedCenter = Offset(
      center.dx.clamp(width / 2 + 4, size.width - width / 2 - 4),
      center.dy.clamp(height / 2 + 4, size.height - height / 2 - 4),
    );
    final rect = Rect.fromCenter(
      center: clampedCenter,
      width: width,
      height: height,
    );
    // Die deckende Füllung verbirgt die Übergangslinie hinter dem Text; der dünne schwarze
    // Rahmen trennt die Beschriftung von der Linie, auf der sie liegt.
    final labelShape = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas
      ..drawRRect(labelShape, Paint()..color = labelBackgroundColor)
      ..drawRRect(
        labelShape,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke,
      );
    painter.paint(
      canvas,
      clampedCenter - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _FsmWorkspacePainter oldDelegate) {
    return oldDelegate.panOffset != panOffset ||
        oldDelegate.fsm != fsm ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.outlineColor != outlineColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.labelBackgroundColor != labelBackgroundColor ||
        oldDelegate.outputColor != outputColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.mutedColor != mutedColor ||
        oldDelegate.diagnosticColor != diagnosticColor ||
        oldDelegate.highlightedTransitionIds != highlightedTransitionIds;
  }
}

class _WorkspaceTransitionGeometry {
  const _WorkspaceTransitionGeometry({
    required this.path,
    required this.arrowTip,
    required this.arrowDirection,
    required this.labelCenter,
  });

  factory _WorkspaceTransitionGeometry.fromTransition({
    required FsmTransition transition,
    required List<FsmTransition> transitions,
    required Offset from,
    required Offset to,
  }) {
    if (from == to) {
      final related = transitions
          .where(
            (candidate) =>
                candidate.fromStateId == transition.fromStateId &&
                candidate.toStateId == transition.toStateId,
          )
          .toList();
      final lane = related.indexWhere((item) => item.id == transition.id);
      final side = lane.isEven ? -1.0 : 1.0;
      final level = lane ~/ 2;
      final center = from.translate(level * 28, side * (48 + level * 8));
      final rect = Rect.fromCircle(center: center, radius: 23);
      final path = Path()..addArc(rect, math.pi * 0.1, math.pi * 1.8);
      final metric = path.computeMetrics().first;
      final endTangent = metric.getTangentForOffset(metric.length)!;
      return _WorkspaceTransitionGeometry(
        path: path,
        arrowTip: endTangent.position,
        arrowDirection: endTangent.vector,
        labelCenter: center.translate(0, side * 35),
      );
    }

    final direction = to - from;
    final distance = direction.distance;
    final unit = direction / distance;
    final start = from + unit * 34;
    final end = to - unit * 37;
    final related = transitions
        .where(
          (candidate) =>
              candidate.fromStateId == transition.fromStateId &&
                  candidate.toStateId == transition.toStateId ||
              candidate.fromStateId == transition.toStateId &&
                  candidate.toStateId == transition.fromStateId,
        )
        .toList();
    final lane = related.indexWhere((item) => item.id == transition.id);
    final laneOffset = (lane - (related.length - 1) / 2) * 74;
    final canonicalDirection =
        transition.fromStateId.compareTo(transition.toStateId) <= 0
        ? direction
        : -direction;
    final canonicalUnit = canonicalDirection / canonicalDirection.distance;
    final canonicalNormal = Offset(-canonicalUnit.dy, canonicalUnit.dx);
    final control =
        Offset.lerp(start, end, 0.5)! + canonicalNormal * laneOffset;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    final metric = path.computeMetrics().first;
    final endTangent = metric.getTangentForOffset(metric.length)!;
    final middleTangent = metric.getTangentForOffset(metric.length / 2)!;
    return _WorkspaceTransitionGeometry(
      path: path,
      arrowTip: endTangent.position,
      arrowDirection: endTangent.vector,
      labelCenter: middleTangent.position,
    );
  }

  final Path path;
  final Offset arrowTip;
  final Offset arrowDirection;
  final Offset labelCenter;

  double distanceTo(Offset point) {
    var closest = double.infinity;
    for (final metric in path.computeMetrics()) {
      final segments = math.max(12, (metric.length / 8).ceil());
      Offset? previous;
      for (var index = 0; index <= segments; index++) {
        final tangent = metric.getTangentForOffset(
          metric.length * index / segments,
        );
        if (tangent == null) continue;
        final current = tangent.position;
        if (previous != null) {
          closest = math.min(
            closest,
            _distanceToSegment(point, previous, current),
          );
        }
        previous = current;
      }
    }
    return closest;
  }

  static double _distanceToSegment(Offset point, Offset start, Offset end) {
    final delta = end - start;
    final lengthSquared = delta.dx * delta.dx + delta.dy * delta.dy;
    if (lengthSquared == 0) return (point - start).distance;
    final projection =
        ((point.dx - start.dx) * delta.dx + (point.dy - start.dy) * delta.dy) /
        lengthSquared;
    final t = projection.clamp(0.0, 1.0);
    final closest = start + delta * t;
    return (point - closest).distance;
  }
}
