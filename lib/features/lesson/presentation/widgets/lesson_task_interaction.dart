import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:bachelor/core/widgets/fsm_diagram_labels.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_preset.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/controllers/fsm_editor_controller.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/widgets/fsm_workspace.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_kind.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:bachelor/features/lesson/domain/models/task_submission.dart';
import 'package:bachelor/features/lesson/domain/models/task_feedback.dart';
import 'package:bachelor/features/lesson/presentation/widgets/task_feedback_view.dart';
import 'package:bachelor/features/lesson/presentation/widgets/answer_button.dart';
import 'package:bachelor/core/widgets/circuit_diagram.dart';
import 'package:bachelor/core/widgets/circuit_tables.dart';
import 'package:bachelor/core/widgets/fsm_tables.dart';
import 'package:flutter/material.dart';
import 'package:bachelor/features/lesson/domain/logic/task_action_alphabet.dart';

/// Wählt anhand der Aufgabendaten die passende Interaktion und erzeugt typisierte Abgaben.
/// Aktionsbuchstaben werden für die Anzeige vereinheitlicht und vor der Übergabe
/// an die Bewertung wieder in die ursprünglichen Eingabesymbole übersetzt.
class LessonTaskInteraction extends StatelessWidget {
  const LessonTaskInteraction({
    required this.task,
    required this.enabled,
    required this.onSubmitted,
    this.feedback,
    this.onEdited,
    super.key,
  });

  final LessonTask task;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;
  final StructuredTaskFeedback? feedback;
  final VoidCallback? onEdited;

  @override
  Widget build(BuildContext context) {
    final alphabet = TaskActionAlphabet(task);
    final payload = alphabet.payload(task.payload);
    final displayedFeedback = alphabet.feedback(feedback);
    void onSubmitted(TaskSubmission submission) =>
        this.onSubmitted(alphabet.restore(submission));
    Widget withAlphabet(Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (task.prompt.startsWith('task.chapter2.') &&
            !task.prompt.contains('gatesCheck')) ...[
          Text(
            context.l10n.t('taskInteraction.chapter2Legend'),
            key: const ValueKey('chapter2-notation-legend'),
            style: context.textStyles.caption,
          ),
          const SizedBox(height: 8),
        ],
        if (alphabet.actions.isNotEmpty) ...[
          Text(
            context.l10n.t(
              'taskInteraction.actionAlphabet',
              args: {
                'mapping': alphabet.actions.entries
                    .map((e) => '${e.value} = ${e.key}')
                    .join('; '),
              },
            ),
            key: const ValueKey('task-action-alphabet'),
          ),
          const SizedBox(height: 12),
        ],
        child,
      ],
    );
    final interaction = switch (task.resolvedKind) {
      TaskKind.aa1MutationOutcome when payload is Aa1MutationOutcomePayload =>
        _MutationOutcomeInteraction(
          task: task,
          payload: payload,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      TaskKind.aa2FindError when payload is Aa2FindErrorPayload =>
        _FindErrorInteraction(
          payload: payload,
          feedback: displayedFeedback,
          onEdited: onEdited,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      TaskKind.aa3ValidateAutomaton
          when payload is Aa3ValidateAutomatonPayload =>
        _ValidateAutomatonInteraction(
          task: task,
          payload: payload,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      TaskKind.aa4BuildAutomaton when payload is Aa4BuildAutomatonPayload =>
        _FsmEditingInteraction(
          initialFsm: payload.initialFsm,
          expectedFsm: payload.expectedFsm,
          allowedTools: payload.allowedTools,
          readyPresetsOnly: payload.readyPresetsOnly,
          requireTransitionEndpoints: payload.requireTransitionEndpoints,
          showGuide: _showFsmGuide(task),
          outputTraceLength: payload.outputTrace?.length,
          feedback: displayedFeedback,
          onEdited: onEdited,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      TaskKind.aa6BuildTable when payload is Aa6BuildTablePayload =>
        _TableInteraction(
          taskId: task.id,
          payload: payload,
          feedback: displayedFeedback,
          onEdited: onEdited,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      TaskKind.aa7TraceState when payload is Aa7TraceStatePayload =>
        _TraceInteraction(
          taskId: task.id,
          payload: payload,
          feedback: displayedFeedback,
          onEdited: onEdited,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      TaskKind.aa8CompleteAutomaton
          when payload is Aa8CompleteAutomatonPayload =>
        _FsmEditingInteraction(
          initialFsm: payload.partialFsm,
          expectedFsm: payload.expectedFsm,
          allowedTools: payload.allowedTools,
          readyPresetsOnly: payload.readyPresetsOnly,
          showGuide: _showFsmGuide(task),
          feedback: displayedFeedback,
          onEdited: onEdited,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      TaskKind.aa9Theory when payload is DiagramSelectionPayload =>
        _DiagramSelectionInteraction(
          payload: payload,
          feedback: displayedFeedback,
          onEdited: onEdited,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      TaskKind.aa9Theory
          when payload is Aa9TheoryPayload &&
              payload.responseType == TheoryResponseType.freeText =>
        _FreeTextInteraction(enabled: enabled, onSubmitted: onSubmitted),
      _ => _ChoiceInteraction(
        answers: _answersFor(task),
        enabled: enabled,
        onSubmitted: onSubmitted,
      ),
    };
    final illustration = task.illustration == null
        ? null
        : alphabet.machine(task.illustration!);
    final sourceFsm = switch (payload) {
      Aa4BuildAutomatonPayload(sourceFsm: final source?) => source,
      _ => null,
    };
    final sourceInputs = switch (payload) {
      Aa4BuildAutomatonPayload(inputAlphabet: final inputs) => inputs,
      _ => const <String>[],
    };
    if (illustration == null && sourceFsm == null) {
      return withAlphabet(interaction);
    }

    return withAlphabet(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sourceFsm != null &&
              payload is Aa4BuildAutomatonPayload &&
              payload.tableRequirement) ...[
            FsmTransitionTable(fsm: sourceFsm, inputAlphabet: sourceInputs),
            const SizedBox(height: 12),
            if (sourceFsm.outputMode == FsmOutputMode.moore)
              FsmOutputTable(fsm: sourceFsm),
          ] else if (sourceFsm != null &&
              task.id == 'chapter5-tables-moore') ...[
            FsmTransitionTable(fsm: sourceFsm, inputAlphabet: sourceInputs),
            const SizedBox(height: 12),
            FsmOutputTable(fsm: sourceFsm),
          ] else if (sourceFsm != null && task.id == 'chapter5-tables-mealy')
            FsmTransitionTable(fsm: sourceFsm, inputAlphabet: sourceInputs)
          else if (sourceFsm != null)
            _FsmPreview(fsm: sourceFsm)
          else
            _TaskFsmDiagramPreview(
              fsm: illustration!,
              legendKeys: task.illustrationLegendKeys,
              showStateIdentifiers: task.showStateIdentifiers,
            ),
          const SizedBox(height: 12),
          interaction,
        ],
      ),
    );
  }

  bool _showFsmGuide(LessonTask task) {
    return task.resolvedKind == TaskKind.aa4BuildAutomaton ||
        task.resolvedKind == TaskKind.aa8CompleteAutomaton;
  }

  List<String> _answersFor(LessonTask task) {
    final payload = task.payload;
    if (task.answers.isNotEmpty) return task.answers;
    if (payload is Aa3ValidateAutomatonPayload ||
        payload is Aa9TheoryPayload &&
            payload.responseType == TheoryResponseType.trueFalse) {
      return const ['answer.true', 'answer.false'];
    }
    return const [];
  }
}

class _ChoiceInteraction extends StatelessWidget {
  const _ChoiceInteraction({
    required this.answers,
    required this.enabled,
    required this.onSubmitted,
  });

  final List<String> answers;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final answer in answers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnswerButton(
              label: context.l10n.t(answer),
              onPressed: enabled
                  ? () => onSubmitted(ChoiceTaskSubmission(answer))
                  : null,
            ),
          ),
      ],
    );
  }
}

class _MutationOutcomeInteraction extends StatelessWidget {
  const _MutationOutcomeInteraction({
    required this.task,
    required this.payload,
    required this.enabled,
    required this.onSubmitted,
  });

  final LessonTask task;
  final Aa1MutationOutcomePayload payload;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewPair(before: payload.before, after: payload.after),
        const SizedBox(height: 8),
        Text(
          context.l10n.t(
            'taskInteraction.input',
            args: {'input': payload.input},
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _ChoiceInteraction(
          answers: task.answers,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _FindErrorInteraction extends StatefulWidget {
  const _FindErrorInteraction({
    required this.payload,
    required this.enabled,
    required this.onSubmitted,
    this.feedback,
    this.onEdited,
  });

  final Aa2FindErrorPayload payload;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;
  final StructuredTaskFeedback? feedback;
  final VoidCallback? onEdited;

  @override
  State<_FindErrorInteraction> createState() => _FindErrorInteractionState();
}

class _FindErrorInteractionState extends State<_FindErrorInteraction> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FsmPreview(fsm: widget.payload.fsm),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final target in widget.payload.targets)
              FilterChip(
                key: ValueKey('selection-chip-${target.id}'),
                selected: _selectedIds.contains(target.id),
                side: _wrongIds(widget.feedback).contains(target.id)
                    ? BorderSide(color: context.colors.danger, width: 2)
                    : null,
                label: Text(context.l10n.t(target.label)),
                onSelected: widget.enabled
                    ? AppHaptics.wrapSelection<bool>((selected) {
                        setState(() {
                          if (selected) {
                            _selectedIds.add(target.id);
                          } else {
                            _selectedIds.remove(target.id);
                          }
                        });
                        widget.onEdited?.call();
                      })
                    : null,
              ),
          ],
        ),
        if (widget.feedback?.issues.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          TaskFeedbackView(feedback: widget.feedback!),
        ],
        const SizedBox(height: 12),
        AppButton(
          label: context.l10n.t('taskInteraction.check'),
          onPressed: widget.enabled && _selectedIds.isNotEmpty
              ? () => widget.onSubmitted(
                  ElementSelectionTaskSubmission({..._selectedIds}),
                )
              : null,
        ),
      ],
    );
  }
}

class _DiagramSelectionInteraction extends StatefulWidget {
  const _DiagramSelectionInteraction({
    required this.payload,
    required this.enabled,
    required this.onSubmitted,
    this.feedback,
    this.onEdited,
  });

  final DiagramSelectionPayload payload;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;
  final StructuredTaskFeedback? feedback;
  final VoidCallback? onEdited;

  @override
  State<_DiagramSelectionInteraction> createState() =>
      _DiagramSelectionInteractionState();
}

class _DiagramSelectionInteractionState
    extends State<_DiagramSelectionInteraction> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TaskFsmDiagramPreview(fsm: widget.payload.fsm),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final target in widget.payload.targets)
              FilterChip(
                key: ValueKey('selection-chip-${target.id}'),
                selected: _selectedIds.contains(target.id),
                side: _wrongIds(widget.feedback).contains(target.id)
                    ? BorderSide(color: context.colors.danger, width: 2)
                    : null,
                label: Text(context.l10n.t(target.label)),
                onSelected: widget.enabled
                    ? AppHaptics.wrapSelection<bool>((selected) {
                        setState(() {
                          if (selected) {
                            _selectedIds.add(target.id);
                          } else {
                            _selectedIds.remove(target.id);
                          }
                        });
                        widget.onEdited?.call();
                      })
                    : null,
              ),
          ],
        ),
        if (widget.feedback?.issues.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          TaskFeedbackView(feedback: widget.feedback!),
        ],
        const SizedBox(height: 12),
        AppButton(
          label: context.l10n.t('taskInteraction.check'),
          onPressed: widget.enabled && _selectedIds.isNotEmpty
              ? () => widget.onSubmitted(
                  ElementSelectionTaskSubmission({..._selectedIds}),
                )
              : null,
        ),
      ],
    );
  }
}

class _TaskFsmDiagramPreview extends StatelessWidget {
  const _TaskFsmDiagramPreview({
    required this.fsm,
    this.legendKeys = const [],
    this.showStateIdentifiers = true,
  });

  final Fsm fsm;
  final List<String> legendKeys;
  final bool showStateIdentifiers;

  @override
  Widget build(BuildContext context) {
    final stateIndexes = {
      for (var index = 0; index < fsm.states.length; index++)
        fsm.states[index].id: index,
    };
    final transitions = <FsmDiagramTransition>[];
    for (final transition in fsm.transitions) {
      final from = stateIndexes[transition.fromStateId];
      final to = stateIndexes[transition.toStateId];
      if (from == null || to == null) continue;
      transitions.add(
        FsmDiagramTransition(
          from: from,
          to: to,
          label: transition.symbol,
          color: context.colors.secondary,
        ),
      );
    }
    final initialIndex = stateIndexes[fsm.initialStateId];

    final legend = legendKeys.isNotEmpty
        ? [for (final key in legendKeys) context.l10n.t(key)]
        : [for (final state in fsm.states) '${state.id} = "${state.label}"'];

    return AppCard(
      isTransparent: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FsmDiagram(
            height: 260,
            nodes: [
              for (final state in fsm.states)
                FsmDiagramNode(
                  center: Offset(state.x, state.y),
                  width: 76,
                  radius: 36,
                  child: Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.surfaceRaised,
                      border: Border.all(
                        color: context.colors.primary,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.22),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            showStateIdentifiers ? state.id : state.label,
                            style: context.textStyles.heading.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (fsm.outputMode == FsmOutputMode.moore &&
                              state.output.isNotEmpty)
                            Text(
                              'y = ${state.output}',
                              style: context.textStyles.caption.copyWith(
                                color: context.colors.warning,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            transitions: transitions,
            resetTransition: initialIndex == null
                ? null
                : FsmResetTransition(
                    to: initialIndex,
                    label: FsmDiagramLabels.reset,
                    color: context.colors.primary,
                    start: const Offset(0.05, 0.05),
                  ),
          ),
          if (showStateIdentifiers) ...[
            const SizedBox(height: 8),
            _TaskFsmMeaningLegend(labels: legend),
          ],
        ],
      ),
    );
  }
}

class _TaskFsmMeaningLegend extends StatelessWidget {
  const _TaskFsmMeaningLegend({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final label in labels)
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _ValidateAutomatonInteraction extends StatelessWidget {
  const _ValidateAutomatonInteraction({
    required this.task,
    required this.payload,
    required this.enabled,
    required this.onSubmitted,
  });

  final LessonTask task;
  final Aa3ValidateAutomatonPayload payload;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TaskFsmDiagramPreview(
          fsm: payload.fsm,
          showStateIdentifiers: task.showStateIdentifiers,
        ),
        const SizedBox(height: 12),
        _ChoiceInteraction(
          answers: task.answers.isEmpty
              ? const ['answer.true', 'answer.false']
              : task.answers,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _FsmEditingInteraction extends StatefulWidget {
  const _FsmEditingInteraction({
    required this.initialFsm,
    required this.expectedFsm,
    required this.allowedTools,
    required this.readyPresetsOnly,
    this.requireTransitionEndpoints = false,
    required this.showGuide,
    this.outputTraceLength,
    this.feedback,
    this.onEdited,
    required this.enabled,
    required this.onSubmitted,
  });

  final Fsm initialFsm;
  final Fsm expectedFsm;
  final Set<FsmEditorTool> allowedTools;
  final bool readyPresetsOnly;
  final bool requireTransitionEndpoints;
  final bool showGuide;
  final int? outputTraceLength;
  final StructuredTaskFeedback? feedback;
  final VoidCallback? onEdited;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;

  @override
  State<_FsmEditingInteraction> createState() => _FsmEditingInteractionState();
}

class _FsmEditingInteractionState extends State<_FsmEditingInteraction> {
  late final FsmEditorController _controller = FsmEditorController(
    initialFsm: widget.initialFsm.copyWith(
      outputMode: widget.expectedFsm.outputMode,
    ),
  );
  final _traceController = TextEditingController();
  late Fsm _lastFsm;

  @override
  void initState() {
    super.initState();
    _lastFsm = _controller.fsm;
    _controller.addListener(_onModelChanged);
  }

  void _onModelChanged() {
    if (identical(_lastFsm, _controller.fsm)) return;
    _lastFsm = _controller.fsm;
    widget.onEdited?.call();
  }

  @override
  void dispose() {
    _controller.removeListener(_onModelChanged);
    _controller.dispose();
    _traceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final issues = widget.feedback?.issues ?? const <TaskFeedbackIssue>[];
    final highlightedStates = {
      for (final issue in issues)
        if (issue.targetId != null) issue.targetId!,
    };
    final highlightedTransitions = {
      for (final issue in issues)
        if (issue.code != 'missingTransition')
          for (final transition in _controller.fsm.transitions)
            if (transition.fromStateId == issue.targetId &&
                transition.inputSymbol == issue.args['input'])
              transition.id,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FsmWorkspace(
          controller: _controller,
          highlightedStateIds: highlightedStates,
          highlightedTransitionIds: highlightedTransitions,
          allowedTools: {...widget.allowedTools, FsmEditorTool.editOutput},
          readOnly: !widget.enabled,
          height: 390,
          showStateIdentifiers: true,
          statePresets: statePresetsFromFsm(widget.expectedFsm),
          transitionPresets: transitionPresetsFromFsm(
            widget.expectedFsm,
            includeEndpoints: false,
          ),
          readyPresetsOnly: widget.readyPresetsOnly,
          requireTransitionEndpoints: widget.requireTransitionEndpoints,
          showGuide: widget.showGuide,
        ),
        const SizedBox(height: 8),
        if (issues.isNotEmpty) ...[
          TaskFeedbackView(feedback: widget.feedback!),
          const SizedBox(height: 8),
        ],
        if (widget.readyPresetsOnly)
          _TaskFsmMeaningLegend(
            labels: [
              for (final state in widget.expectedFsm.states)
                '${state.id} = "${state.label}"',
            ],
          ),
        const SizedBox(height: 12),
        if (widget.outputTraceLength != null) ...[
          TextField(
            controller: _traceController,
            onChanged: (_) => widget.onEdited?.call(),
            decoration: const InputDecoration(
              labelText: 'Output trace',
              hintText: '0, 1, 0',
            ),
          ),
          const SizedBox(height: 12),
        ],
        AppButton(
          label: context.l10n.t('taskInteraction.checkAutomaton'),
          onPressed: widget.enabled
              ? () => widget.onSubmitted(
                  FsmTaskSubmission(
                    _controller.fsm,
                    outputTrace: widget.outputTraceLength == null
                        ? null
                        : _traceController.text
                              .split(',')
                              .map((value) => value.trim())
                              .where((value) => value.isNotEmpty)
                              .toList(),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _Chapter2BuildTables extends StatelessWidget {
  const _Chapter2BuildTables({
    required this.values,
    required this.stateIds,
    required this.inputSymbols,
    required this.enabled,
    required this.onChanged,
    this.wrongTransitions = const {},
    this.wrongOutputs = const {},
  });

  final Map<String, String> values;
  final List<String> stateIds;
  final List<String> inputSymbols;

  /// Vom Feedback als falsch gemeldete `stateId::input`-Schlüssel und Zustands-IDs.
  final Set<String> wrongTransitions;
  final Set<String?> wrongOutputs;
  final bool enabled;
  final void Function(String key, String value) onChanged;

  String _number(String stateId) => stateId.replaceFirst('s', '');

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CircuitTransitionTable(
        scaleToFit: true,
        errorRows: {
          for (var s = 0; s < stateIds.length; s++)
            for (var i = 0; i < inputSymbols.length; i++)
              if (wrongTransitions.contains(
                '${stateIds[s]}::${inputSymbols[i]}',
              ))
                s * inputSymbols.length + i,
        },
        rows: [
          for (final stateId in stateIds)
            for (final symbol in inputSymbols)
              CircuitTransitionRow(
                state: _number(stateId),
                input: symbol,
                nextState: values['$stateId::$symbol'] ?? '',
              ),
        ],
        nextStateCellBuilder: (context, row, _) {
          final stateId = 's${row.state}';
          final key = '$stateId::${row.input}';
          return DropdownButton<String>(
            isExpanded: true,
            value: values[key],
            hint: const Text('-', textAlign: TextAlign.center),
            items: [
              for (final target in stateIds)
                DropdownMenuItem(
                  value: target,
                  child: Center(child: Text(_number(target))),
                ),
            ],
            onChanged: enabled
                ? (value) {
                    if (value != null) onChanged(key, value);
                  }
                : null,
          );
        },
      ),
      const SizedBox(height: 12),
      CircuitOutputTable(
        scaleToFit: true,
        errorRows: {
          for (var s = 0; s < stateIds.length; s++)
            if (wrongOutputs.contains(stateIds[s])) s,
        },
        rows: [
          for (final stateId in stateIds)
            CircuitOutputRow(
              state: _number(stateId),
              output: values['$stateId::output'] ?? '',
            ),
        ],
        outputCellBuilder: (context, row, _) {
          final key = 's${row.state}::output';
          return TextFormField(
            enabled: enabled,
            initialValue: values[key],
            textAlign: TextAlign.center,
            decoration: const InputDecoration(isDense: true),
            onChanged: (value) => onChanged(key, value),
          );
        },
      ),
    ],
  );
}

class _TableInteraction extends StatefulWidget {
  const _TableInteraction({
    required this.taskId,
    required this.payload,
    required this.enabled,
    required this.onSubmitted,
    this.feedback,
    this.onEdited,
  });

  final String taskId;
  final Aa6BuildTablePayload payload;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;
  final StructuredTaskFeedback? feedback;
  final VoidCallback? onEdited;

  @override
  State<_TableInteraction> createState() => _TableInteractionState();
}

class _TableInteractionState extends State<_TableInteraction> {
  final Map<String, String> _values = {};

  List<String> get _stateIds =>
      widget.payload.expectedRows.map((row) => row.stateId).toList();

  void _change(String key, String value) {
    setState(() => _values[key] = value);
    widget.onEdited?.call();
  }

  @override
  Widget build(BuildContext context) {
    final sourceFsm = widget.payload.sourceFsm;
    final issues = widget.feedback?.issues ?? const <TaskFeedbackIssue>[];
    final wrongTransitions = {
      for (final issue in issues)
        if (issue.code.startsWith('tableTransition'))
          '${issue.targetId}::${issue.args['input']}',
    };
    final wrongOutputs = {
      for (final issue in issues)
        if (issue.code.startsWith('tableOutput')) issue.targetId,
    };
    final wrongStates = {for (final issue in issues) issue.targetId};
    final circuitVariant = CircuitDiagramVariant.fromId(
      widget.payload.circuitDiagramId,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.payload.sourceDescriptionKey case final description?)
          AppCard(child: Text(context.l10n.t(description))),
        if (sourceFsm != null) ...[
          circuitVariant != null
              ? CircuitDiagram(variant: circuitVariant)
              : _FsmPreview(fsm: sourceFsm),
          const SizedBox(height: 12),
        ],
        circuitVariant != null
            ? _Chapter2BuildTables(
                values: _values,
                stateIds: _stateIds,
                inputSymbols: widget.payload.inputSymbols,
                wrongTransitions: wrongTransitions,
                wrongOutputs: wrongOutputs,
                enabled: widget.enabled,
                onChanged: _change,
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(context.l10n.t('taskInteraction.state')),
                    ),
                    for (final symbol in widget.payload.inputSymbols)
                      DataColumn(label: Text(symbol)),
                    DataColumn(
                      label: Text(context.l10n.t('taskInteraction.output')),
                    ),
                  ],
                  rows: [
                    for (final stateId in _stateIds)
                      DataRow(
                        color: wrongStates.contains(stateId)
                            ? WidgetStatePropertyAll(
                                context.colors.danger.withValues(alpha: .14),
                              )
                            : null,
                        cells: [
                          DataCell(Text(stateId)),
                          for (final symbol in widget.payload.inputSymbols)
                            DataCell(
                              DropdownButton<String>(
                                value: _values['$stateId::$symbol'],
                                hint: const Text('-'),
                                items: [
                                  for (final target in _stateIds)
                                    DropdownMenuItem(
                                      value: target,
                                      child: Text(target),
                                    ),
                                ],
                                onChanged: widget.enabled
                                    ? AppHaptics.wrapSelection<String?>((
                                        value,
                                      ) {
                                        if (value == null) return;
                                        _change('$stateId::$symbol', value);
                                      })
                                    : null,
                              ),
                            ),
                          DataCell(
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                enabled: widget.enabled,
                                initialValue: _values['$stateId::output'],
                                onChanged: (value) {
                                  _values['$stateId::output'] = value;
                                  widget.onEdited?.call();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
        if (issues.isNotEmpty) ...[
          const SizedBox(height: 8),
          TaskFeedbackView(feedback: widget.feedback!),
        ],
        const SizedBox(height: 12),
        AppButton(
          label: context.l10n.t('taskInteraction.checkTable'),
          onPressed: widget.enabled ? _submit : null,
        ),
      ],
    );
  }

  void _submit() {
    widget.onSubmitted(
      FsmTableTaskSubmission([
        for (final stateId in _stateIds)
          FsmTableRow(
            stateId: stateId,
            transitions: {
              for (final symbol in widget.payload.inputSymbols)
                symbol: _values['$stateId::$symbol'] ?? '',
            },
            output: _values['$stateId::output'] ?? '',
          ),
      ]),
    );
  }
}

class _TraceInteraction extends StatefulWidget {
  const _TraceInteraction({
    required this.taskId,
    required this.payload,
    required this.enabled,
    required this.onSubmitted,
    this.feedback,
    this.onEdited,
  });

  final String taskId;
  final Aa7TraceStatePayload payload;
  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;
  final StructuredTaskFeedback? feedback;
  final VoidCallback? onEdited;

  @override
  State<_TraceInteraction> createState() => _TraceInteractionState();
}

class _TraceInteractionState extends State<_TraceInteraction> {
  late final List<String?> _states = List.filled(
    widget.payload.expectedStateIds.length,
    null,
  );

  @override
  Widget build(BuildContext context) {
    final issues = widget.feedback?.issues ?? const <TaskFeedbackIssue>[];
    final wrongIndex = issues.isEmpty
        ? null
        : int.tryParse(issues.first.targetId ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.taskId == 'chapter2-trace'
            ? const CircuitDiagram(variant: CircuitDiagramVariant.practiceX)
            : _FsmPreview(fsm: widget.payload.fsm),
        const SizedBox(height: 12),
        for (var index = 0; index < _states.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DropdownButtonFormField<String>(
              key: ValueKey('trace-step-$index'),
              initialValue: _states[index],
              decoration: InputDecoration(
                errorText: wrongIndex == index
                    ? context.l10n.t('taskFeedback.traceCheckHere')
                    : null,
                labelText: index == 0
                    ? context.l10n.t('taskInteraction.startState')
                    : context.l10n.t(
                        'taskInteraction.afterInput',
                        args: {'input': widget.payload.inputSymbols[index - 1]},
                      ),
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final state in widget.payload.fsm.states)
                  DropdownMenuItem(value: state.id, child: Text(state.label)),
              ],
              onChanged: widget.enabled
                  ? AppHaptics.wrapSelection<String?>((value) {
                      setState(() => _states[index] = value);
                      widget.onEdited?.call();
                    })
                  : null,
            ),
          ),
        if (issues.isNotEmpty) ...[
          TaskFeedbackView(feedback: widget.feedback!),
          const SizedBox(height: 8),
        ],
        AppButton(
          label: context.l10n.t('taskInteraction.checkTrace'),
          onPressed: widget.enabled && _states.every((state) => state != null)
              ? () => widget.onSubmitted(
                  StateTraceTaskSubmission(_states.cast<String>()),
                )
              : null,
        ),
      ],
    );
  }
}

class _FreeTextInteraction extends StatefulWidget {
  const _FreeTextInteraction({
    required this.enabled,
    required this.onSubmitted,
  });

  final bool enabled;
  final ValueChanged<TaskSubmission> onSubmitted;

  @override
  State<_FreeTextInteraction> createState() => _FreeTextInteractionState();
}

class _FreeTextInteractionState extends State<_FreeTextInteraction> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: context.l10n.t('taskInteraction.freeTextHint'),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: context.l10n.t('taskInteraction.check'),
          onPressed: widget.enabled && _controller.text.trim().isNotEmpty
              ? () => widget.onSubmitted(TextTaskSubmission(_controller.text))
              : null,
        ),
      ],
    );
  }
}

class _PreviewPair extends StatelessWidget {
  const _PreviewPair({required this.before, required this.after});

  final Fsm before;
  final Fsm after;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 620;
        Widget preview(String label, Fsm fsm) {
          return Column(
            children: [
              Text(context.l10n.t(label), style: context.textStyles.caption),
              _FsmPreview(fsm: fsm),
            ],
          );
        }

        if (horizontal) {
          return Row(
            children: [
              Expanded(child: preview('taskInteraction.before', before)),
              const Icon(Icons.arrow_forward),
              Expanded(child: preview('taskInteraction.after', after)),
            ],
          );
        }
        return Column(
          children: [
            preview('taskInteraction.before', before),
            const Icon(Icons.arrow_downward),
            preview('taskInteraction.after', after),
          ],
        );
      },
    );
  }
}

class _FsmPreview extends StatelessWidget {
  const _FsmPreview({required this.fsm});

  final Fsm fsm;

  @override
  Widget build(BuildContext context) {
    return _TaskFsmDiagramPreview(fsm: fsm);
  }
}

/// Ausgewählte Elemente, die laut Feedback nicht zur Aufgabe passen.
Set<String> _wrongIds(StructuredTaskFeedback? feedback) => {
  for (final issue in feedback?.issues ?? const <TaskFeedbackIssue>[])
    if (issue.code == 'selectionExtra' && issue.targetId != null)
      issue.targetId!,
};
