import 'package:bachelor/core/widgets/circuit_diagram.dart';
import 'package:bachelor/core/widgets/circuit_tables.dart';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/preserve_scroll_position.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_interaction_hint.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_scroll_continue_button.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_lesson_speech.dart';
import 'package:flutter/material.dart';

/// Führt vom Signalfluss einer digitalen Schaltung zur Übergangs- und Ausgabetabelle ihres Automaten.
class CircuitTablesStory extends StatefulWidget {
  const CircuitTablesStory({
    required this.onFinished,
    this.onProgressChanged,
    super.key,
  });

  final VoidCallback onFinished;
  final ValueChanged<double>? onProgressChanged;

  @override
  State<CircuitTablesStory> createState() => _CircuitTablesStoryState();
}

class _CircuitTablesStoryState extends State<CircuitTablesStory> {
  static const _steps = [
    'chapter2Story.intro',
    'chapter2Story.purpose',
    'chapter2Story.stateBits',
    'chapter2Story.bitDecomposition',
    'chapter2Story.signalPath',
    'chapter2Story.workedExample',
    'chapter2Story.clockStep',
    'chapter2Story.resetStep',
    'chapter2Story.outputStep',
    'chapter2Story.simulator',
    'chapter2Story.transitionTable',
    'chapter2Story.outputTable',
    'chapter2Story.completeOverview',
    'chapter2Story.ready',
  ];

  final _scrollController = ScrollController();
  final _completedInteractions = <int>{};
  final _transitionAnswers = <int, int>{};
  final _outputAnswers = <int, int>{};
  int _step = 0;
  int _hintSignal = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _step == _steps.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  key: const PageStorageKey('chapter2-circuit-tables-scroll'),
                  controller: _scrollController,
                  children: [
                    MascotLessonSpeech(
                      message: context.l10n.t(_steps[_step]),
                      pose: isLastStep
                          ? MascotPose.celebrate
                          : MascotPose.speaking,
                      animationId: 'chapter2-circuit-$_step',
                    ),
                    const SizedBox(height: 14),
                    _sceneForStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_step > 0) ...[
              Expanded(
                child: AppOutlinedButton(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: context.l10n.t('common.back'),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: isLastStep
                  ? AppButton(
                      label: context.l10n.t('chapter2Story.startTasks'),
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: widget.onFinished,
                    )
                  : LessonScrollContinueButton(
                      key: ValueKey('chapter2-scroll-next-$_step'),
                      controller: _scrollController,
                      onContinue: _handleNext,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sceneForStep() {
    return switch (_step) {
      0 => const _CircuitOverview(key: ValueKey('chapter2-circuit-overview')),
      1 => const _PurposeScene(key: ValueKey('chapter2-purpose')),
      2 => const _StateBitsScene(key: ValueKey('chapter2-state-bits')),
      3 => _BitDecompositionScene(
        key: ValueKey('chapter2-bit-decomposition'),
        onInteractionComplete: _completeCurrentInteraction,
      ),
      4 => const _SignalPathScene(key: ValueKey('chapter2-signal-path')),
      5 => _WorkedExampleScene(
        key: const ValueKey('chapter2-worked-example'),
        onInteractionComplete: _completeCurrentInteraction,
      ),
      6 => _ClockScene(
        key: const ValueKey('chapter2-clock'),
        onInteractionComplete: _completeCurrentInteraction,
      ),
      7 => _ResetScene(
        key: const ValueKey('chapter2-reset'),
        onInteractionComplete: _completeCurrentInteraction,
      ),
      8 => const _OutputExplanationScene(key: ValueKey('chapter2-output')),
      9 => _CircuitSimulator(
        key: const ValueKey('chapter2-circuit-simulator'),
        hintSignal: _hintSignal,
        onComplete: () => _completeInteraction(9),
      ),
      10 => _TransitionTablePractice(
        key: const ValueKey('chapter2-transition-table-practice'),
        hintSignal: _hintSignal,
        answers: _transitionAnswers,
        onAnswerSaved: _saveTransitionAnswer,
        onComplete: () => _completeInteraction(10),
      ),
      11 => _OutputTablePractice(
        key: const ValueKey('chapter2-output-table-practice'),
        hintSignal: _hintSignal,
        answers: _outputAnswers,
        onAnswerSaved: _saveOutputAnswer,
        onComplete: () => _completeInteraction(11),
      ),
      12 => const _CompleteOverviewScene(
        key: ValueKey('chapter2-complete-overview'),
      ),
      _ => const _CircuitReadyScene(key: ValueKey('chapter2-circuit-ready')),
    };
  }

  void _handleNext() {
    const interactiveSteps = {3, 5, 6, 7, 9, 10, 11};
    if (interactiveSteps.contains(_step) &&
        !_completedInteractions.contains(_step)) {
      setState(() => _hintSignal++);
      showLessonInteractionPrompt(context, _scrollController);
      return;
    }
    _nextStep();
  }

  void _completeInteraction(int step) {
    if (_completedInteractions.contains(step)) return;
    setState(() => _completedInteractions.add(step));
  }

  void _completeCurrentInteraction() => _completeInteraction(_step);

  void _saveTransitionAnswer(int row, int value) {
    setState(() => _transitionAnswers[row] = value);
  }

  void _saveOutputAnswer(int state, int value) {
    setState(() => _outputAnswers[state] = value);
  }

  void _nextStep() {
    if (_step >= _steps.length - 1) return;
    setState(() => _step++);
    widget.onProgressChanged?.call(_step / (_steps.length - 1));
    _scrollToTop();
  }

  void _previousStep() {
    if (_step == 0) return;
    setState(() => _step--);
    widget.onProgressChanged?.call(_step / (_steps.length - 1));
    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }
}

class _CircuitOverview extends StatelessWidget {
  const _CircuitOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircuitDiagram(),
        const SizedBox(height: 12),
        _Legend(
          items: [
            _LegendItem('A', context.l10n.t('chapter2Story.legend.input')),
            _LegendItem(
              'S₁, S₀',
              context.l10n.t('chapter2Story.legend.memory'),
            ),
            _LegendItem('Y', context.l10n.t('chapter2Story.legend.output')),
          ],
        ),
      ],
    );
  }
}

class _PurposeScene extends StatelessWidget {
  const _PurposeScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircuitDiagram(),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('chapter2Story.purposeTitle'),
                style: context.textStyles.heading,
              ),
              const SizedBox(height: 10),
              _ExplanationRow(
                icon: Icons.input_rounded,
                text: context.l10n.t('chapter2Story.purposeInput'),
              ),
              _ExplanationRow(
                icon: Icons.memory_rounded,
                text: context.l10n.t('chapter2Story.purposeMemory'),
              ),
              _ExplanationRow(
                icon: Icons.account_tree_rounded,
                text: context.l10n.t('chapter2Story.purposeLogic'),
              ),
              _ExplanationRow(
                icon: Icons.output_rounded,
                text: context.l10n.t('chapter2Story.purposeOutput'),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClockScene extends StatefulWidget {
  const _ClockScene({required this.onInteractionComplete, super.key});

  final VoidCallback onInteractionComplete;

  @override
  State<_ClockScene> createState() => _ClockSceneState();
}

class _ClockSceneState extends State<_ClockScene> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircuitDiagram(highlight: CircuitHighlight.memory),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('chapter2Story.clockTitle'),
                style: context.textStyles.heading,
              ),
              const SizedBox(height: 12),
              _ExplanationRow(
                icon: Icons.calculate_rounded,
                text: context.l10n.t('chapter2Story.clockBefore'),
              ),
              _ExplanationRow(
                icon: Icons.bolt_rounded,
                text: context.l10n.t('chapter2Story.clockEdge'),
              ),
              _ExplanationRow(
                icon: Icons.save_alt_rounded,
                text: context.l10n.t('chapter2Story.clockAfter'),
              ),
              const SizedBox(height: 12),
              const _RegisterFlow(),
              const SizedBox(height: 12),
              _StateTimeline(
                label: context.l10n.t('chapter2Story.clockTimeline'),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.t('chapter2Story.clockQuestion'),
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in [0, 1, 2])
                    ChoiceChip(
                      label: Text(
                        context.l10n.t('chapter2Story.clockChoice$option'),
                      ),
                      selected: _selected == option,
                      onSelected: (_) {
                        setState(() => _selected = option);
                        widget.onInteractionComplete();
                      },
                    ),
                ],
              ),
              if (_selected == 1) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.t('chapter2Story.clockCorrect'),
                  textAlign: TextAlign.center,
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RegisterFlow extends StatelessWidget {
  const _RegisterFlow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _FlowBox(label: 'D₀ = S₀′\nD₁ = S₁′', color: context.colors.secondary),
        const Icon(Icons.arrow_forward_rounded),
        _FlowBox(
          label: context.l10n.t('chapter2Story.flipFlops'),
          color: context.colors.primary,
        ),
        const Icon(Icons.arrow_forward_rounded),
        _FlowBox(
          label: 'Q₀ = S₀\nQ₁ = S₁',
          color: context.colors.stateHighlight,
        ),
      ],
    );
  }
}

class _FlowBox extends StatelessWidget {
  const _FlowBox({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

class _StateTimeline extends StatelessWidget {
  const _StateTimeline({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            _FlowBox(
              label: 'S = 0\nS₁S₀ = 00',
              color: context.colors.mutedText,
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
            _FlowBox(
              label: 'S′ = 2\nS₁′S₀′ = 10',
              color: context.colors.secondary,
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
            _FlowBox(
              label: 'S = 2\nS₁S₀ = 10',
              color: context.colors.stateHighlight,
            ),
          ],
        ),
      ],
    );
  }
}

class _OutputExplanationScene extends StatelessWidget {
  const _OutputExplanationScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircuitDiagram(highlight: CircuitHighlight.output),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('chapter2Story.outputStepTitle'),
                style: context.textStyles.heading,
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.t('chapter2Story.outputStepBody'),
                style: context.textStyles.body,
              ),
              const SizedBox(height: 12),
              _OutputMapping(state: '0', output: '0', isLast: false),
              _OutputMapping(state: '1', output: '0', isLast: false),
              _OutputMapping(state: '2', output: '1', isLast: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExplanationRow extends StatelessWidget {
  const _ExplanationRow({
    required this.icon,
    required this.text,
    this.isLast = false,
  });

  final IconData icon;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.textStyles.body)),
        ],
      ),
    );
  }
}

class _OutputMapping extends StatelessWidget {
  const _OutputMapping({
    required this.state,
    required this.output,
    required this.isLast,
  });

  final String state;
  final String output;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('S = $state', style: context.textStyles.body),
          const SizedBox(width: 18),
          const Icon(Icons.arrow_forward, size: 18),
          const SizedBox(width: 18),
          Text(
            'Y = $output',
            style: context.textStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateBitsScene extends StatelessWidget {
  const _StateBitsScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircuitDiagram(highlight: CircuitHighlight.memory),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('chapter2Story.stateEncoding'),
                style: context.textStyles.heading,
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StateCode(state: 0, bits: '00'),
                  _StateCode(state: 1, bits: '01'),
                  _StateCode(state: 2, bits: '10'),
                  _StateCode(state: 3, bits: '11', unused: true),
                ],
              ),
              const SizedBox(height: 12),
              _ExplanationRow(
                icon: Icons.help_outline_rounded,
                text: context.l10n.t('chapter2Story.unusedState'),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Eigener visueller Schritt für die Bitreihenfolge der Schaltung.
///
/// Er ist bewusst von der kompakten Übersicht der Zustandskodierung getrennt:
/// Lernende sollen sehen, dass S₁S₀ ein einziger Zwei-Bit-Wert ist, während S₁ und S₀
/// die einzelnen Leitungen sind, aus denen er besteht.
class _BitDecompositionScene extends StatefulWidget {
  const _BitDecompositionScene({
    required this.onInteractionComplete,
    super.key,
  });

  final VoidCallback onInteractionComplete;

  @override
  State<_BitDecompositionScene> createState() => _BitDecompositionSceneState();
}

class _BitDecompositionSceneState extends State<_BitDecompositionScene> {
  String _bits = '00';

  @override
  Widget build(BuildContext context) {
    final s1 = _bits[0];
    final s0 = _bits[1];
    final state = int.parse(_bits, radix: 2);
    final colors = context.colors;

    return Column(
      children: [
        CircuitDiagram(highlight: CircuitHighlight.memory, state: state),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('chapter2Story.bitDecompositionTitle'),
                style: context.textStyles.heading,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.t('chapter2Story.bitDecompositionBody'),
                style: context.textStyles.body,
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  for (final bits in const ['00', '10'])
                    ChoiceChip(
                      label: Text('S₁S₀ = $bits'),
                      selected: bits == _bits,
                      onSelected: (_) {
                        setState(() => _bits = bits);
                        widget.onInteractionComplete();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BitCard(label: 'S₁', value: s1, color: colors.primary),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('+', style: context.textStyles.heading),
                  ),
                  _BitCard(label: 'S₀', value: s0, color: colors.primary),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('=', style: context.textStyles.heading),
                  ),
                  _BitCard(
                    label: 'S',
                    value: '$state',
                    color: colors.stateHighlight,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.t(
                  'chapter2Story.bitDecompositionFormula',
                  args: {'bits': _bits, 's1': s1, 's0': s0, 'state': '$state'},
                ),
                textAlign: TextAlign.center,
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BitCard extends StatelessWidget {
  const _BitCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(label, style: context.textStyles.caption),
          Text(value, style: context.textStyles.heading.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _WorkedExampleScene extends StatefulWidget {
  const _WorkedExampleScene({required this.onInteractionComplete, super.key});

  final VoidCallback onInteractionComplete;

  @override
  State<_WorkedExampleScene> createState() => _WorkedExampleSceneState();
}

class _WorkedExampleSceneState extends State<_WorkedExampleScene> {
  int? _s0Prime;
  int? _s1Prime;

  @override
  Widget build(BuildContext context) {
    final complete = _s0Prime == 0 && _s1Prime == 1;
    return Column(
      children: [
        const CircuitDiagram(highlight: CircuitHighlight.nextState),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('chapter2Story.workedExampleTitle'),
                style: context.textStyles.heading,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.t('chapter2Story.workedExampleBody'),
                style: context.textStyles.body,
              ),
              const SizedBox(height: 12),
              _WorkedBitChoice(
                label: 'S₀′',
                value: _s0Prime,
                onChanged: (value) {
                  setState(() => _s0Prime = value);
                  if (_s1Prime != null && _s0Prime != null) {
                    widget.onInteractionComplete();
                  }
                },
              ),
              _WorkedBitChoice(
                label: 'S₁′',
                value: _s1Prime,
                onChanged: (value) {
                  setState(() => _s1Prime = value);
                  if (_s1Prime != null && _s0Prime != null) {
                    widget.onInteractionComplete();
                  }
                },
              ),
              const SizedBox(height: 10),
              Text(
                complete
                    ? context.l10n.t('chapter2Story.workedExampleCorrect')
                    : context.l10n.t('chapter2Story.workedExamplePrompt'),
                textAlign: TextAlign.center,
                style: context.textStyles.body.copyWith(
                  color: complete ? context.colors.primary : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (complete)
                Text(
                  'S₁′S₀′ = 10 → S′ = 2',
                  textAlign: TextAlign.center,
                  style: context.textStyles.heading,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkedBitChoice extends StatelessWidget {
  const _WorkedBitChoice({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label =', style: context.textStyles.body),
        const SizedBox(width: 8),
        for (final bit in [0, 1])
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text('$bit'),
              selected: value == bit,
              onSelected: (_) {
                AppHaptics.selection();
                onChanged(bit);
              },
            ),
          ),
      ],
    );
  }
}

class _ResetScene extends StatefulWidget {
  const _ResetScene({required this.onInteractionComplete, super.key});

  final VoidCallback onInteractionComplete;

  @override
  State<_ResetScene> createState() => _ResetSceneState();
}

class _ResetSceneState extends State<_ResetScene> {
  bool _resetActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircuitDiagram(
          highlight: _resetActive
              ? CircuitHighlight.memory
              : CircuitHighlight.none,
          state: _resetActive ? 0 : 2,
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ExplanationRow(
                icon: Icons.restart_alt_rounded,
                text: context.l10n.t('chapter2Story.resetBody'),
              ),
              Text(
                _resetActive
                    ? context.l10n.t('chapter2Story.resetActive')
                    : context.l10n.t('chapter2Story.resetInactive'),
                textAlign: TextAlign.center,
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: _resetActive
                    ? context.l10n.t('chapter2Story.releaseReset')
                    : context.l10n.t('chapter2Story.applyReset'),
                icon: const Icon(Icons.restart_alt_rounded),
                onPressed: () {
                  setState(() => _resetActive = !_resetActive);
                  widget.onInteractionComplete();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignalPathScene extends StatelessWidget {
  const _SignalPathScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircuitDiagram(highlight: CircuitHighlight.nextState),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              _FlowLine(
                label: context.l10n.t('chapter2Story.flow.input'),
                icon: Icons.input_rounded,
              ),
              _FlowLine(
                label: context.l10n.t('chapter2Story.flow.logic'),
                icon: Icons.account_tree_rounded,
              ),
              _FlowLine(
                label: context.l10n.t('chapter2Story.flow.clock'),
                icon: Icons.bolt_rounded,
              ),
              _FlowLine(
                label: context.l10n.t('chapter2Story.flow.state'),
                icon: Icons.memory_rounded,
                isLast: true,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                context.l10n.t('chapter2Story.formulaS0'),
                textAlign: TextAlign.center,
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                context.l10n.t('chapter2Story.formulaS1'),
                textAlign: TextAlign.center,
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                context.l10n.t('chapter2Story.formulaY'),
                textAlign: TextAlign.center,
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircuitSimulator extends StatefulWidget {
  const _CircuitSimulator({
    required this.hintSignal,
    required this.onComplete,
    super.key,
  });

  final int hintSignal;
  final VoidCallback onComplete;

  @override
  State<_CircuitSimulator> createState() => _CircuitSimulatorState();
}

class _CircuitSimulatorState extends State<_CircuitSimulator> {
  final _stateValue = ValueNotifier(0);
  final _inputValue = ValueNotifier(0);
  final _clockedValue = ValueNotifier(false);
  final _predictionS0Value = ValueNotifier<int?>(null);
  final _predictionS1Value = ValueNotifier<int?>(null);

  late final _changes = Listenable.merge([
    _stateValue,
    _inputValue,
    _clockedValue,
    _predictionS0Value,
    _predictionS1Value,
  ]);

  int get _state => _stateValue.value;
  int get _input => _inputValue.value;
  bool get _clocked => _clockedValue.value;
  int? get _predictionS0 => _predictionS0Value.value;
  int? get _predictionS1 => _predictionS1Value.value;

  int get _nextState => _nextStates[_state][_input];
  int get _nextS1 => (_nextState >> 1) & 1;
  int get _nextS0 => _nextState & 1;
  int get _output => _outputs[_state];

  void _setState(int state) {
    AppHaptics.selection();
    _stateValue.value = state;
    _clockedValue.value = false;
    _predictionS0Value.value = null;
    _predictionS1Value.value = null;
  }

  void _setInput(int input) {
    AppHaptics.selection();
    _inputValue.value = input;
    _clockedValue.value = false;
    _predictionS0Value.value = null;
    _predictionS1Value.value = null;
  }

  void _clock() {
    AppHaptics.success();
    _stateValue.value = _nextState;
    _clockedValue.value = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _stateValue.dispose();
    _inputValue.dispose();
    _clockedValue.dispose();
    _predictionS0Value.dispose();
    _predictionS1Value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _changes,
          builder: (context, _) => CircuitDiagram(
            highlight: _clocked
                ? CircuitHighlight.memory
                : CircuitHighlight.nextState,
            state: _state,
            input: _input,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _changes,
          builder: (context, _) => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.t('chapter2Story.chooseState'),
                  style: context.textStyles.body,
                ),
                const SizedBox(height: 6),
                _ChoiceRow(
                  values: const [0, 1, 2],
                  selected: _state,
                  onSelected: _setState,
                  labelBuilder: (value) => 'S = $value',
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.t('chapter2Story.chooseInput'),
                  style: context.textStyles.body,
                ),
                const SizedBox(height: 6),
                _ChoiceRow(
                  values: const [0, 1],
                  selected: _input,
                  onSelected: _setInput,
                  labelBuilder: (value) => 'A = $value',
                ),
                const SizedBox(height: 12),
                _ResultStrip(
                  state: _state,
                  input: _input,
                  nextState:
                      _predictionS0 == _nextS0 && _predictionS1 == _nextS1
                      ? _nextState
                      : null,
                  output: _output,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.t('chapter2Story.predictNextBits'),
                  style: context.textStyles.body,
                ),
                const SizedBox(height: 6),
                _ChoiceRow(
                  values: const [0, 1],
                  selected: _predictionS0 ?? -1,
                  onSelected: (value) {
                    AppHaptics.selection();
                    _predictionS0Value.value = value;
                  },
                  labelBuilder: (value) => 'S₀′ = $value',
                ),
                _ChoiceRow(
                  values: const [0, 1],
                  selected: _predictionS1 ?? -1,
                  onSelected: (value) {
                    AppHaptics.selection();
                    _predictionS1Value.value = value;
                  },
                  labelBuilder: (value) => 'S₁′ = $value',
                ),
                if ((_predictionS0 != null || _predictionS1 != null) &&
                    !(_predictionS0 == _nextS0 &&
                        _predictionS1 == _nextS1)) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.t('chapter2Story.predictionHint'),
                    textAlign: TextAlign.center,
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.warning,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                LessonInteractionHint(
                  signal: widget.hintSignal,
                  child: AppButton(
                    label: context.l10n.t('chapter2Story.clock'),
                    icon: const Icon(Icons.bolt_rounded),
                    onPressed:
                        _predictionS0 == _nextS0 && _predictionS1 == _nextS1
                        ? _clock
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TransitionTablePractice extends StatefulWidget {
  const _TransitionTablePractice({
    required this.hintSignal,
    required this.answers,
    required this.onAnswerSaved,
    required this.onComplete,
    super.key,
  });

  final int hintSignal;
  final Map<int, int> answers;
  final void Function(int row, int value) onAnswerSaved;
  final VoidCallback onComplete;

  @override
  State<_TransitionTablePractice> createState() =>
      _TransitionTablePracticeState();
}

class _TransitionTablePracticeState extends State<_TransitionTablePractice> {
  int? _selectedRow;

  void _selectRow(int row) {
    setState(() => _selectedRow = row);
  }

  void _answer(int row, int value) {
    final isCorrect = _transitionRows[row].nextState == value;
    if (!isCorrect) {
      AppHaptics.warning();
      return;
    }
    AppHaptics.success();
    widget.onAnswerSaved(row, value);
    if (widget.answers.length == _transitionRows.length) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('chapter2Story.transitionInstruction'),
            style: context.textStyles.body,
          ),
          const SizedBox(height: 12),
          _TransitionTraceDiagram(
            row: _selectedRow == null ? null : _transitionRows[_selectedRow!],
          ),
          const SizedBox(height: 12),
          _UniversityTransitionTable(
            answers: widget.answers,
            selectedRow: _selectedRow,
            onSelectRow: _selectRow,
            onAnswer: _answer,
          ),
          if (widget.answers.length < _transitionRows.length) ...[
            const SizedBox(height: 12),
            LessonInteractionHint(
              signal: widget.hintSignal,
              child: Text(
                context.l10n.t('chapter2Story.fillEveryRow'),
                textAlign: TextAlign.center,
                style: context.textStyles.caption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OutputTablePractice extends StatefulWidget {
  const _OutputTablePractice({
    required this.hintSignal,
    required this.answers,
    required this.onAnswerSaved,
    required this.onComplete,
    super.key,
  });

  final int hintSignal;
  final Map<int, int> answers;
  final void Function(int state, int value) onAnswerSaved;
  final VoidCallback onComplete;

  @override
  State<_OutputTablePractice> createState() => _OutputTablePracticeState();
}

class _OutputTablePracticeState extends State<_OutputTablePractice> {
  int? _selectedState;

  void _selectState(int state) {
    setState(() => _selectedState = state);
  }

  void _answer(int state, int value) {
    if (_outputs[state] != value) {
      AppHaptics.warning();
      return;
    }
    AppHaptics.success();
    widget.onAnswerSaved(state, value);
    if (widget.answers.length == _outputs.length) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OutputTraceDiagram(state: _selectedState),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('chapter2Story.outputInstruction'),
                style: context.textStyles.body,
              ),
              const SizedBox(height: 12),
              _UniversityOutputTable(
                answers: widget.answers,
                selectedState: _selectedState,
                onSelectState: _selectState,
                onAnswer: (state, value) {
                  _selectState(state);
                  _answer(state, value);
                },
              ),
              if (widget.answers.length < _outputs.length) ...[
                const SizedBox(height: 12),
                LessonInteractionHint(
                  signal: widget.hintSignal,
                  child: Text(
                    context.l10n.t('chapter2Story.fillEveryRow'),
                    textAlign: TextAlign.center,
                    style: context.textStyles.caption,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CompleteOverviewScene extends StatelessWidget {
  const _CompleteOverviewScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircuitDiagram(highlight: CircuitHighlight.all),
        const SizedBox(height: 12),
        _CompactTransitionTable(
          title: context.l10n.t('chapter2Story.transitionTableTitle'),
        ),
        const SizedBox(height: 12),
        _CompactOutputTable(
          title: context.l10n.t('chapter2Story.outputTableTitle'),
        ),
      ],
    );
  }
}

class _CompactTransitionTable extends StatelessWidget {
  const _CompactTransitionTable({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.textStyles.heading),
          const SizedBox(height: 6),
          CircuitTransitionTable(
            rows: [
              for (final row in _transitionRows)
                CircuitTransitionRow(
                  state: '${row.state}',
                  input: '${row.input}',
                  nextState: '${row.nextState}',
                ),
            ],
            nextStateCellBuilder: (context, row, _) => Text(
              row.nextState,
              textAlign: TextAlign.center,
              style: context.textStyles.body.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactOutputTable extends StatelessWidget {
  const _CompactOutputTable({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.textStyles.heading),
          const SizedBox(height: 6),
          CircuitOutputTable(
            rows: [
              for (var state = 0; state < _outputs.length; state++)
                CircuitOutputRow(state: '$state', output: '${_outputs[state]}'),
            ],
            outputCellBuilder: (context, row, _) => Text(
              row.output,
              textAlign: TextAlign.center,
              style: context.textStyles.body.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircuitReadyScene extends StatelessWidget {
  const _CircuitReadyScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircuitDiagram(highlight: CircuitHighlight.all),
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: context.colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.t('chapter2Story.summary'),
                  style: context.textStyles.body,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});
  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final item in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(label: Text(item.symbol)),
                const SizedBox(width: 5),
                Text(item.description, style: context.textStyles.caption),
              ],
            ),
        ],
      ),
    );
  }
}

class _LegendItem {
  const _LegendItem(this.symbol, this.description);
  final String symbol;
  final String description;
}

class _StateCode extends StatelessWidget {
  const _StateCode({
    required this.state,
    required this.bits,
    this.unused = false,
  });
  final int state;
  final String bits;
  final bool unused;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: unused
          ? context.colors.mutedText.withValues(alpha: .12)
          : context.colors.primary.withValues(alpha: .12),
      label: Text(
        unused
            ? '11 - ${context.l10n.t('chapter2Story.unused')}'
            : '$bits -> S = $state',
      ),
    );
  }
}

class _FlowLine extends StatelessWidget {
  const _FlowLine({
    required this.label,
    required this.icon,
    this.isLast = false,
  });
  final String label;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: context.textStyles.body)),
          ],
        ),
        if (!isLast)
          Icon(Icons.arrow_downward_rounded, color: context.colors.secondary),
      ],
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.values,
    required this.selected,
    required this.onSelected,
    required this.labelBuilder,
  });
  final List<int> values;
  final int selected;
  final ValueChanged<int> onSelected;
  final String Function(int) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final value in values)
          ChoiceChip(
            label: Text(labelBuilder(value)),
            selected: selected == value,
            onSelected: (_) =>
                preserveScrollablePosition(context, () => onSelected(value)),
          ),
      ],
    );
  }
}

class _ResultStrip extends StatelessWidget {
  const _ResultStrip({
    required this.state,
    required this.input,
    required this.nextState,
    required this.output,
  });
  final int state;
  final int input;
  final int? nextState;
  final int output;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'S = $state, A = $input  →  S\' = ${nextState ?? '?'}',
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

/// Die Adapter von Kapitel 2 halten lektionsspezifische Antwortelemente aus dem
/// gemeinsamen Tabellenmodul heraus und überlassen ihm das gesamte Tabellenlayout.
class _UniversityTransitionTable extends StatelessWidget {
  const _UniversityTransitionTable({
    required this.answers,
    required this.selectedRow,
    required this.onSelectRow,
    required this.onAnswer,
  });

  final Map<int, int> answers;
  final int? selectedRow;
  final ValueChanged<int> onSelectRow;
  final void Function(int row, int value) onAnswer;

  @override
  Widget build(BuildContext context) => CircuitTransitionTable(
    rows: [
      for (final row in _transitionRows)
        CircuitTransitionRow(
          state: '${row.state}',
          input: '${row.input}',
          nextState: '${row.nextState}',
        ),
    ],
    selectedRow: selectedRow,
    onSelectRow: onSelectRow,
    nextStateCellBuilder: (context, _, index) {
      final answer = answers[index];
      if (answer != null) {
        return Text(
          '$answer',
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w800,
          ),
        );
      }
      return _ChoiceRow(
        values: const [0, 1, 2],
        selected: -1,
        onSelected: (value) {
          onSelectRow(index);
          onAnswer(index, value);
        },
        labelBuilder: (value) => '$value',
      );
    },
  );
}

class _UniversityOutputTable extends StatelessWidget {
  const _UniversityOutputTable({
    required this.answers,
    required this.selectedState,
    required this.onSelectState,
    required this.onAnswer,
  });

  final Map<int, int> answers;
  final int? selectedState;
  final ValueChanged<int> onSelectState;
  final void Function(int state, int value) onAnswer;

  @override
  Widget build(BuildContext context) => CircuitOutputTable(
    rows: [
      for (var state = 0; state < _outputs.length; state++)
        CircuitOutputRow(state: '$state', output: '${_outputs[state]}'),
    ],
    selectedRow: selectedState,
    onSelectRow: onSelectState,
    outputCellBuilder: (context, _, index) {
      final answer = answers[index];
      if (answer != null) {
        return Text(
          '$answer',
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w800,
          ),
        );
      }
      return _ChoiceRow(
        values: const [0, 1],
        selected: -1,
        onSelected: (value) {
          onSelectState(index);
          onAnswer(index, value);
        },
        labelBuilder: (value) => '$value',
      );
    },
  );
}

// Bleibt zur Kompatibilität mit älteren Story-Ständen erhalten.
// ignore: unused_element
class _TransitionRow extends StatelessWidget {
  const _TransitionRow({
    required this.row,
    required this.answer,
    required this.selected,
    required this.onSelect,
    required this.onAnswer,
  });
  final _TransitionTableRow row;
  final int? answer;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? context.colors.primary.withValues(alpha: .10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text('S = ${row.state}, A = ${row.input}')),
              const Text("S' = "),
              if (answer != null)
                Chip(label: Text('$answer'))
              else
                _ChoiceRow(
                  values: const [0, 1, 2],
                  selected: -1,
                  onSelected: (value) {
                    onSelect();
                    onAnswer(value);
                  },
                  labelBuilder: (value) => '$value',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransitionTraceDiagram extends StatefulWidget {
  const _TransitionTraceDiagram({required this.row});

  final _TransitionTableRow? row;

  @override
  State<_TransitionTraceDiagram> createState() =>
      _TransitionTraceDiagramState();
}

class _TransitionTraceDiagramState extends State<_TransitionTraceDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didUpdateWidget(covariant _TransitionTraceDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.row != oldWidget.row && widget.row != null) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        children: [
          CircuitDiagram(
            highlight: row == null
                ? CircuitHighlight.none
                : CircuitHighlight.nextState,
            state: row?.state ?? 0,
            input: row?.input ?? 0,
            signalProgress: row == null ? null : _controller.value,
          ),
          if (row != null) ...[
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: _controller.value >= .95 ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Text(
                "S′ = ${row.nextState}",
                style: context.textStyles.body.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Bleibt zur Kompatibilität mit älteren Story-Ständen erhalten.
// ignore: unused_element
class _OutputRow extends StatelessWidget {
  const _OutputRow({
    required this.state,
    required this.answer,
    required this.selected,
    required this.onSelect,
    required this.onAnswer,
  });
  final int state;
  final int? answer;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? context.colors.primary.withValues(alpha: .10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text('S = $state')),
              const Text('Y = '),
              if (answer != null)
                Chip(label: Text('$answer'))
              else
                _ChoiceRow(
                  values: const [0, 1],
                  selected: -1,
                  onSelected: (value) {
                    onSelect();
                    onAnswer(value);
                  },
                  labelBuilder: (value) => '$value',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutputTraceDiagram extends StatefulWidget {
  const _OutputTraceDiagram({required this.state});

  final int? state;

  @override
  State<_OutputTraceDiagram> createState() => _OutputTraceDiagramState();
}

class _OutputTraceDiagramState extends State<_OutputTraceDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didUpdateWidget(covariant _OutputTraceDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state && widget.state != null) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        children: [
          CircuitDiagram(
            highlight: state == null
                ? CircuitHighlight.none
                : CircuitHighlight.output,
            state: state ?? 0,
            signalProgress: state == null ? null : _controller.value,
          ),
          if (state != null) ...[
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: _controller.value >= .95 ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Text(
                'Y = ${_outputs[state]}',
                style: context.textStyles.body.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransitionTableRow {
  const _TransitionTableRow(this.state, this.input, this.nextState);
  final int state;
  final int input;
  final int nextState;
}

const _transitionRows = [
  _TransitionTableRow(0, 0, 2),
  _TransitionTableRow(0, 1, 0),
  _TransitionTableRow(1, 0, 0),
  _TransitionTableRow(1, 1, 1),
  _TransitionTableRow(2, 0, 0),
  _TransitionTableRow(2, 1, 1),
];

const _nextStates = [
  [2, 0],
  [0, 1],
  [0, 1],
];

const _outputs = [0, 0, 1];
