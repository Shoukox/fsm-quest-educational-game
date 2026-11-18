import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:bachelor/core/widgets/fsm_diagram_labels.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter1/intro_fsm_story.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_interaction_hint.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_scroll_continue_button.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter1/lesson_state_image.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_lesson_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Erarbeitet Zustände, Startzustand und Ausgabezuordnung anhand geführter Türbeispiele.
class StatesLessonStory extends StatefulWidget {
  const StatesLessonStory({
    required this.onFinished,
    this.onProgressChanged,
    super.key,
  });

  final VoidCallback onFinished;
  final ValueChanged<double>? onProgressChanged;

  @override
  State<StatesLessonStory> createState() => _StatesLessonStoryState();
}

class _StatesLessonStoryState extends State<StatesLessonStory> {
  final _scrollController = ScrollController();
  final Set<int> _completedInteractiveSteps = {};
  int _step = 0;
  final Set<int> _advancedFromSteps = {};
  int _interactionHintSignal = 0;

  static const _stepKeys = [
    'statesStory.intro.01',
    'statesStory.intro.02',
    'statesStory.intro.03',
    'statesStory.step.01',
    'statesStory.step.02',
    'statesStory.step.04',
    'statesStory.step.05',
    'statesStory.step.06',
    'statesStory.step.08',
    'statesStory.step.09',
    'statesStory.step.10',
    'statesStory.step.12',
    'statesStory.step.13',
    'statesStory.step.14',
    'statesStory.step.15',
    'statesStory.step.16',
    'statesStory.step.18',
    'statesStory.step.19',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLastStep = _step == _stepKeys.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: [
                    _MascotTeacherBubble(
                      text: l10n.t(_stepKeys[_step]),
                      step: _step,
                      isLastStep: isLastStep,
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
        if (_step == 0)
          LessonScrollContinueButton(
            key: ValueKey('states-scroll-next-$_step'),
            controller: _scrollController,
            onContinue: _nextStep,
          )
        else
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: l10n.t('common.back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: isLastStep
                    ? AppButton(
                        label: l10n.t('statesStory.startTasks'),
                        icon: const Icon(Icons.play_arrow_rounded),
                        onPressed: widget.onFinished,
                      )
                    : LessonScrollContinueButton(
                        key: ValueKey('states-scroll-next-$_step'),
                        controller: _scrollController,
                        onContinue: _handleNextPressed,
                      ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _sceneForStep() {
    return switch (_step) {
      0 => const TrafficLightFsmScene(
        key: ValueKey('states-intro-traffic-light'),
      ),
      1 => const _StatesMachineTypesIntroScene(
        key: ValueKey('states-intro-machine-types'),
      ),
      2 => const _StatesAbstractAutomatonScene(
        key: ValueKey('states-intro-example'),
      ),
      3 => const _StateQuestionScene(key: ValueKey('states-question')),
      4 => const _DoorPairScene(key: ValueKey('door-pair')),
      5 => const _DoorDiagram(
        key: ValueKey('named-state-nodes'),
        currentState: null,
      ),
      6 => const _DoorDiagram(key: ValueKey('current-locked'), currentState: 0),
      7 => _DoorSimulatorScene(
        key: const ValueKey('door-simulator'),
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      8 => const _DoorDiagram(
        key: ValueKey('initial-state'),
        currentState: 0,
        showReset: true,
      ),
      9 => const _InitialStateScene(key: ValueKey('initial-role')),
      10 => _DoorSimulatorScene(
        key: const ValueKey('reset-simulator'),
        emphasizeReset: true,
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      11 => _OutputStatePicker(
        key: const ValueKey('output-picker'),
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      12 => const _DoorDiagram(
        key: ValueKey('current-and-output'),
        currentState: 1,
        showOutputs: true,
        showReset: true,
      ),
      13 => const _MooreMealyComparisonScene(
        key: ValueKey('moore-mealy-comparison'),
      ),
      14 => _MooreMealyPlacementScene(
        key: const ValueKey('moore-mealy-placement'),
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      15 => _MealyOutputSimulationScene(
        key: const ValueKey('mealy-output-simulation'),
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      16 => const _StateRolesSummary(key: ValueKey('state-roles-summary')),
      _ => const _StatesReadyScene(key: ValueKey('states-ready')),
    };
  }

  void _handleNextPressed() {
    const interactiveSteps = {7, 10, 11, 14, 15};
    if (interactiveSteps.contains(_step) &&
        !_completedInteractiveSteps.contains(_step)) {
      setState(() => _interactionHintSignal++);
      showLessonInteractionPrompt(context, _scrollController);
      return;
    }
    _nextStep();
  }

  void _completeCurrentInteraction() {
    if (_completedInteractiveSteps.contains(_step)) return;
    setState(() => _completedInteractiveSteps.add(_step));
  }

  void _nextStep() {
    if (_step >= _stepKeys.length - 1) return;
    if (!_advancedFromSteps.add(_step)) return;
    setState(() => _step++);
    widget.onProgressChanged?.call(_step / (_stepKeys.length - 1));
    _scrollToTop();
  }

  void _previousStep() {
    if (_step == 0) return;
    _advancedFromSteps.remove(_step - 1);
    setState(() => _step--);
    widget.onProgressChanged?.call(_step / (_stepKeys.length - 1));
    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }
}

class _MascotTeacherBubble extends StatelessWidget {
  const _MascotTeacherBubble({
    required this.text,
    required this.step,
    required this.isLastStep,
  });

  final String text;
  final int step;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    final pose = isLastStep
        ? MascotPose.celebrate
        : step.isEven
        ? MascotPose.speaking
        : MascotPose.thinking;

    return MascotLessonSpeech(
      message: text,
      pose: pose,
      animationId: 'states-$step',
    );
  }
}

class _StatesMachineTypesIntroScene extends StatelessWidget {
  const _StatesMachineTypesIntroScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _MachineTypeIntroTile(
            label: context.l10n.t('statesStory.intro.mealy'),
            color: context.colors.primary,
          ),
          const SizedBox(height: 14),
          _MachineTypeIntroTile(
            label: context.l10n.t('statesStory.intro.moore'),
            color: context.colors.secondary,
          ),
        ],
      ),
    );
  }
}

class _MachineTypeIntroTile extends StatelessWidget {
  const _MachineTypeIntroTile({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 104),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: context.textStyles.heading.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatesAbstractAutomatonScene extends StatelessWidget {
  const _StatesAbstractAutomatonScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: SizedBox(
        height: 220,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AbstractAutomatonConnectorPainter(
                      color: context.colors.mutedText,
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.04,
                  top: 14,
                  child: const _AbstractAutomatonSymbol(
                    symbol: 'q',
                    size: 64,
                    isCircle: true,
                  ),
                ),
                Positioned(
                  left: width * 0.29,
                  top: 42,
                  child: _AbstractAutomatonSymbol(
                    symbol: '→',
                    size: 42,
                    color: context.colors.primary,
                  ),
                ),
                Positioned(
                  left: width * 0.65,
                  top: 8,
                  child: _AbstractAutomatonSymbol(
                    symbol: 'Σ',
                    size: 70,
                    color: context.colors.secondary,
                  ),
                ),
                Positioned(
                  left: width * 0.20,
                  top: 124,
                  child: _AbstractAutomatonSymbol(
                    symbol: '0',
                    size: 48,
                    color: context.colors.warning,
                    isCircle: true,
                  ),
                ),
                Positioned(
                  left: width * 0.56,
                  top: 108,
                  child: _AbstractAutomatonSymbol(
                    symbol: '1',
                    size: 82,
                    color: context.colors.primary,
                    isCircle: true,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AbstractAutomatonSymbol extends StatelessWidget {
  const _AbstractAutomatonSymbol({
    required this.symbol,
    required this.size,
    this.color,
    this.isCircle = false,
  });

  final String symbol;
  final double size;
  final Color? color;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final symbolColor = color ?? context.colors.primary;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: symbolColor.withValues(alpha: 0.10),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        border: Border.all(color: symbolColor, width: 3),
        borderRadius: isCircle ? null : BorderRadius.circular(size * 0.12),
      ),
      child: Text(
        symbol,
        style: context.textStyles.heading.copyWith(
          fontSize: size * 0.42,
          color: symbolColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AbstractAutomatonConnectorPainter extends CustomPainter {
  const _AbstractAutomatonConnectorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final points = [
      Offset(size.width * 0.24, size.height * 0.28),
      Offset(size.width * 0.68, size.height * 0.27),
      Offset(size.width * 0.59, size.height * 0.68),
      Offset(size.width * 0.29, size.height * 0.73),
    ];
    for (var index = 0; index < points.length; index++) {
      final start = points[index];
      final end = points[(index + 1) % points.length];
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AbstractAutomatonConnectorPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _StateQuestionScene extends StatelessWidget {
  const _StateQuestionScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      isTransparent: true,
      child: Column(
        children: [
          FsmDiagram(
            key: const ValueKey('single-state-diagram'),
            height: 245,
            nodes: [
              FsmDiagramNode(
                center: const Offset(0.20, 0.52),
                width: 112,
                radius: 56,
                child: LessonTurnstileImageNode(
                  label: FsmDiagramLabels.locked,
                  state: LessonTurnstileImageState.locked,
                  isMuted: true,
                ),
              ),
              FsmDiagramNode(
                center: const Offset(0.80, 0.52),
                width: 112,
                radius: 56,
                child: LessonTurnstileImageNode(
                  label: FsmDiagramLabels.unlocked,
                  state: LessonTurnstileImageState.unlocked,
                  isMuted: true,
                ),
              ),
            ],
            transitions: const [],
          ),
        ],
      ),
    );
  }
}

class _DoorPairScene extends StatelessWidget {
  const _DoorPairScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('statesStory.snapshotTitle'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 18),
          const _DoorFsmDiagram(
            key: ValueKey('two-state-diagram'),
            currentState: null,
            height: 190,
            showTransitions: false,
            showIdentifiers: false,
            showMeaningLegend: false,
            showTurnstileImages: true,
          ),
        ],
      ),
    );
  }
}

class _DoorFsmDiagram extends StatelessWidget {
  const _DoorFsmDiagram({
    required this.currentState,
    this.showReset = false,
    this.showOutputs = false,
    this.showTransitions = true,
    this.height = 245,
    this.onStateTap,
    this.interactionHintSignal = 0,
    this.hintedStateIndexes = const {0, 1},
    this.showIdentifiers = true,
    this.showMeaningLegend = true,
    this.showTurnstileImages = false,
    super.key,
  });

  final int? currentState;
  final bool showReset;
  final bool showOutputs;
  final bool showTransitions;
  final double height;
  final ValueChanged<int>? onStateTap;
  final int interactionHintSignal;
  final Set<int> hintedStateIndexes;
  final bool showIdentifiers;
  final bool showMeaningLegend;
  final bool showTurnstileImages;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FsmDiagram(
          height: height,
          nodes: [
            FsmDiagramNode(
              center: const Offset(0.20, 0.50),
              width: 108,
              radius: 52,
              child: _InteractiveDoorStateNode(
                index: 0,
                onStateTap: onStateTap,
                interactionHintSignal: hintedStateIndexes.contains(0)
                    ? interactionHintSignal
                    : 0,
                child: _DoorStateNode(
                  isLocked: true,
                  isCurrent: currentState == 0,
                  isInitial: showReset,
                  showOutput: showOutputs,
                  isInteractive: onStateTap != null,
                  showIdentifier: showIdentifiers,
                  showTurnstileImage: showTurnstileImages,
                ),
              ),
            ),
            FsmDiagramNode(
              center: const Offset(0.80, 0.70),
              width: 108,
              radius: 52,
              child: _InteractiveDoorStateNode(
                index: 1,
                onStateTap: onStateTap,
                interactionHintSignal: hintedStateIndexes.contains(1)
                    ? interactionHintSignal
                    : 0,
                child: _DoorStateNode(
                  isLocked: false,
                  isCurrent: currentState == 1,
                  isInitial: false,
                  showOutput: showOutputs,
                  isInteractive: onStateTap != null,
                  showIdentifier: showIdentifiers,
                  showTurnstileImage: showTurnstileImages,
                ),
              ),
            ),
          ],
          transitions: showTransitions
              ? [
                  FsmDiagramTransition(
                    from: 0,
                    to: 1,
                    color: context.colors.primary,
                    label: FsmDiagramLabels.coin,
                    curveDepth: 0.34,
                    curveSide: 1,
                  ),
                  FsmDiagramTransition(
                    from: 1,
                    to: 0,
                    color: context.colors.secondary,
                    label: FsmDiagramLabels.passage,
                    curveDepth: 0.34,
                    curveSide: 1,
                  ),
                ]
              : const [],
          resetTransition: showReset
              ? FsmResetTransition(
                  to: 0,
                  label: FsmDiagramLabels.reset,
                  color: context.colors.mutedText,
                  start: const Offset(0.08, 0.06),
                  isMuted: true,
                )
              : null,
        ),
        if (showMeaningLegend) ...[
          const SizedBox(height: 8),
          const _StateMeaningLegend(),
        ],
      ],
    );
  }
}

class _InteractiveDoorStateNode extends StatelessWidget {
  const _InteractiveDoorStateNode({
    required this.index,
    required this.onStateTap,
    required this.interactionHintSignal,
    required this.child,
  });

  final int index;
  final ValueChanged<int>? onStateTap;
  final int interactionHintSignal;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final onTap = onStateTap;
    if (onTap == null) return child;

    return LessonInteractionHint(
      signal: interactionHintSignal,
      circular: true,
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: AppHaptics.wrapButton(() => onTap(index)),
          customBorder: const CircleBorder(),
          child: child,
        ),
      ),
    );
  }
}

class _DoorDiagram extends StatelessWidget {
  const _DoorDiagram({
    required this.currentState,
    this.showReset = false,
    this.showOutputs = false,
    super.key,
  });

  final int? currentState;
  final bool showReset;
  final bool showOutputs;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DoorFsmDiagram(
            currentState: currentState,
            showReset: showReset,
            showOutputs: showOutputs,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              if (currentState != null)
                _LegendItem(
                  icon: Icons.location_on_rounded,
                  label: context.l10n.t('statesStory.current'),
                  color: context.colors.primary,
                ),
              if (showOutputs)
                _LegendItem(
                  icon: Icons.output_rounded,
                  label: context.l10n.t('statesStory.output'),
                  color: context.colors.warning,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoorStateNode extends StatelessWidget {
  const _DoorStateNode({
    required this.isLocked,
    required this.isCurrent,
    required this.isInitial,
    required this.showOutput,
    this.isInteractive = false,
    this.showIdentifier = true,
    this.showTurnstileImage = false,
  });

  final bool isLocked;
  final bool isCurrent;
  final bool isInitial;
  final bool showOutput;
  final bool isInteractive;
  final bool showIdentifier;
  final bool showTurnstileImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: 220.ms,
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? context.colors.primary
                  : isInteractive
                  ? context.colors.secondary
                  : context.colors.mutedText,
              width: isCurrent ? 7 : 3,
            ),
            boxShadow: [
              if (isCurrent)
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.72),
                  blurRadius: 14,
                  spreadRadius: 3,
                ),
              if (isCurrent)
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.48),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              if (isCurrent)
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.24),
                  blurRadius: 48,
                  spreadRadius: 12,
                ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showTurnstileImage)
                  LessonTurnstileImage(
                    state: isLocked
                        ? LessonTurnstileImageState.locked
                        : LessonTurnstileImageState.unlocked,
                    size: 38,
                    color: isInteractive
                        ? context.colors.secondary
                        : context.colors.mutedText,
                  ),
                Text(
                  showIdentifier
                      ? (isLocked ? 'q0' : 'q1')
                      : (isLocked
                            ? FsmDiagramLabels.locked
                            : FsmDiagramLabels.unlocked),
                  style: context.textStyles.title.copyWith(
                    color: isLocked
                        ? context.colors.danger
                        : context.colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (showOutput) ...[
                  const SizedBox(height: 2),
                  Text(
                    isLocked
                        ? FsmDiagramLabels.stateStopOutput
                        : FsmDiagramLabels.stateGoOutput,
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.warning,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isInitial)
          Positioned(
            left: -4,
            top: -8,
            child: _StateRoleBadge(
              icon: Icons.flag_rounded,
              color: context.colors.primary,
            ),
          ),
        if (isCurrent)
          Positioned(
            right: -4,
            top: -8,
            child: _StateRoleBadge(
              icon: Icons.location_on_rounded,
              color: context.colors.primary,
            ),
          ),
      ],
    );
  }
}

class _StateRoleBadge extends StatelessWidget {
  const _StateRoleBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.32),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, size: 17, color: color),
    );
  }
}

class _StateMeaningLegend extends StatelessWidget {
  const _StateMeaningLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: [
        _StateMeaning(label: context.l10n.t('statesStory.meaning.q0')),
        _StateMeaning(label: context.l10n.t('statesStory.meaning.q1')),
      ],
    );
  }
}

class _StateMeaning extends StatelessWidget {
  const _StateMeaning({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: context.textStyles.caption,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

class _DoorSimulatorScene extends StatefulWidget {
  const _DoorSimulatorScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    this.emphasizeReset = false,
    super.key,
  });

  final bool emphasizeReset;
  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_DoorSimulatorScene> createState() => _DoorSimulatorSceneState();
}

class _DoorSimulatorSceneState extends State<_DoorSimulatorScene> {
  bool _isLocked = true;
  String _actionKey = 'statesStory.sim.ready';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LessonTurnstileAnimation(
          key: const ValueKey('turnstile-animation'),
          isUnlocked: !_isLocked,
        ),
        const SizedBox(height: 8),
        _DoorDiagram(
          currentState: _isLocked ? 0 : 1,
          showReset: widget.emphasizeReset,
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t(_actionKey),
                textAlign: TextAlign.center,
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  LessonInteractionHint(
                    signal: !widget.emphasizeReset || _isLocked
                        ? widget.interactionHintSignal
                        : 0,
                    child: FilledButton.icon(
                      onPressed: AppHaptics.wrapButton(_insertCoin),
                      icon: const Icon(Icons.monetization_on_outlined),
                      label: Text(context.l10n.t('statesStory.coin')),
                    ),
                  ),
                  LessonInteractionHint(
                    signal: widget.emphasizeReset
                        ? 0
                        : widget.interactionHintSignal,
                    child: OutlinedButton.icon(
                      onPressed: AppHaptics.wrapButton(_passThrough),
                      icon: const Icon(Icons.directions_walk_rounded),
                      label: Text(context.l10n.t('statesStory.passage')),
                    ),
                  ),
                  if (widget.emphasizeReset)
                    LessonInteractionHint(
                      signal: _isLocked ? 0 : widget.interactionHintSignal,
                      child: OutlinedButton.icon(
                        onPressed: AppHaptics.wrapButton(_reset),
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: Text(context.l10n.t('common.reset')),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _insertCoin() {
    setState(() {
      if (_isLocked) {
        _isLocked = false;
        _actionKey = 'statesStory.sim.coinUnlocked';
      } else {
        _actionKey = 'statesStory.sim.alreadyUnlocked';
      }
    });
    if (!widget.emphasizeReset) widget.onInteractionComplete();
  }

  void _passThrough() {
    setState(() {
      if (_isLocked) {
        _actionKey = 'statesStory.sim.passageLocked';
      } else {
        _isLocked = true;
        _actionKey = 'statesStory.sim.passageLockedAgain';
      }
    });
    if (!widget.emphasizeReset) widget.onInteractionComplete();
  }

  void _reset() {
    final completesInteraction = widget.emphasizeReset && !_isLocked;
    setState(() {
      _isLocked = true;
      _actionKey = 'statesStory.sim.resetLocked';
    });
    if (completesInteraction) widget.onInteractionComplete();
  }
}

class _InitialStateScene extends StatelessWidget {
  const _InitialStateScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            context.l10n.t('statesStory.initialTitle'),
            style: context.textStyles.title,
            textAlign: TextAlign.center,
          ),
          const _DoorFsmDiagram(
            key: ValueKey('initial-state-role-diagram'),
            currentState: 0,
            showReset: true,
            showTransitions: false,
            height: 190,
          ),
          const SizedBox(height: 12),
          for (final key in const [
            'statesStory.initialFact.1',
            'statesStory.initialFact.2',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(context.l10n.t(key))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OutputStatePicker extends StatefulWidget {
  const _OutputStatePicker({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_OutputStatePicker> createState() => _OutputStatePickerState();
}

class _OutputStatePickerState extends State<_OutputStatePicker> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final feedbackKey = switch (_selected) {
      0 => 'statesStory.outputPicker.locked',
      1 => 'statesStory.outputPicker.unlocked',
      _ => 'statesStory.outputPicker.prompt',
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('statesStory.outputPicker.title'),
            style: context.textStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _DoorFsmDiagram(
            key: const ValueKey('output-picker-diagram'),
            currentState: _selected,
            showOutputs: _selected != null,
            height: 220,
            interactionHintSignal: widget.interactionHintSignal,
            hintedStateIndexes: _selected == null ? const {0, 1} : const {1},
            onStateTap: (index) {
              setState(() => _selected = index);
              if (index == 1) widget.onInteractionComplete();
            },
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.t(feedbackKey),
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(
              color: _selected == 1
                  ? context.colors.primary
                  : context.colors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MooreMealyComparisonScene extends StatelessWidget {
  const _MooreMealyComparisonScene({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          Expanded(
            child: _MachineTypeCard(
              titleKey: 'statesStory.moore.title',
              descriptionKey: 'statesStory.moore.description',
              isMoore: true,
            ),
          ),
          Expanded(
            child: _MachineTypeCard(
              titleKey: 'statesStory.mealy.title',
              descriptionKey: 'statesStory.mealy.description',
              isMoore: false,
            ),
          ),
        ];
        if (constraints.maxWidth >= 680) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [cards.first, const SizedBox(width: 12), cards.last],
          );
        }
        return Column(
          children: [
            _MachineTypeCard(
              titleKey: 'statesStory.moore.title',
              descriptionKey: 'statesStory.moore.description',
              isMoore: true,
            ),
            const SizedBox(height: 12),
            _MachineTypeCard(
              titleKey: 'statesStory.mealy.title',
              descriptionKey: 'statesStory.mealy.description',
              isMoore: false,
            ),
          ],
        );
      },
    );
  }
}

class _MachineTypeCard extends StatelessWidget {
  const _MachineTypeCard({
    required this.titleKey,
    required this.descriptionKey,
    required this.isMoore,
  });

  final String titleKey;
  final String descriptionKey;
  final bool isMoore;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t(titleKey),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.t(descriptionKey),
            textAlign: TextAlign.center,
            style: context.textStyles.caption,
          ),
          const SizedBox(height: 8),
          _MachineOutputDiagram(isMoore: isMoore),
        ],
      ),
    );
  }
}

class _MachineOutputDiagram extends StatelessWidget {
  const _MachineOutputDiagram({
    required this.isMoore,
    this.mealyTriggered = false,
    this.height = 190,
  });

  final bool isMoore;
  final bool mealyTriggered;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FsmDiagram(
          height: height,
          nodes: [
            FsmDiagramNode(
              center: const Offset(0.20, 0.50),
              width: 90,
              radius: 42,
              child: _OutputExampleNode(
                stateId: 'q0',
                output: isMoore ? FsmDiagramLabels.stateStopOutput : null,
                isCurrent: !mealyTriggered,
              ),
            ),
            FsmDiagramNode(
              center: const Offset(0.80, 0.50),
              width: 90,
              radius: 42,
              child: _OutputExampleNode(
                stateId: 'q1',
                output: isMoore ? FsmDiagramLabels.stateGoOutput : null,
                isCurrent: mealyTriggered,
              ),
            ),
          ],
          transitions: [
            FsmDiagramTransition(
              from: 0,
              to: 1,
              label: isMoore
                  ? FsmDiagramLabels.coin
                  : FsmDiagramLabels.mealyCoinGo,
              color: mealyTriggered
                  ? context.colors.primary
                  : context.colors.secondary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _StateMeaningLegend(),
      ],
    );
  }
}

class _OutputExampleNode extends StatelessWidget {
  const _OutputExampleNode({
    required this.stateId,
    required this.output,
    required this.isCurrent,
  });

  final String stateId;
  final String? output;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 180.ms,
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent
            ? context.colors.stateHighlight
            : context.colors.surfaceRaised,
        border: Border.all(
          color: isCurrent ? context.colors.primary : context.colors.mutedText,
          width: isCurrent ? 6 : 2,
        ),
        boxShadow: [
          if (isCurrent)
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.68),
              blurRadius: 12,
              spreadRadius: 3,
            ),
          if (isCurrent)
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.42),
              blurRadius: 26,
              spreadRadius: 7,
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stateId,
            style: context.textStyles.heading.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (output != null)
            Text(
              output!,
              style: context.textStyles.caption.copyWith(
                color: context.colors.warning,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

enum _OutputLocation { state, transition }

class _MooreMealyPlacementScene extends StatefulWidget {
  const _MooreMealyPlacementScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_MooreMealyPlacementScene> createState() =>
      _MooreMealyPlacementSceneState();
}

class _MooreMealyPlacementSceneState extends State<_MooreMealyPlacementScene> {
  _OutputLocation? _moore;
  _OutputLocation? _mealy;

  bool get _hasBoth => _moore != null && _mealy != null;
  bool get _isCorrect =>
      _moore == _OutputLocation.state && _mealy == _OutputLocation.transition;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('statesStory.placement.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 14),
          _OutputLocationRow(
            title: 'Moore',
            isMoore: true,
            value: _moore,
            interactionHintSignal: widget.interactionHintSignal,
            onChanged: _setMoore,
          ),
          const SizedBox(height: 12),
          _OutputLocationRow(
            title: 'Mealy',
            isMoore: false,
            value: _mealy,
            interactionHintSignal: widget.interactionHintSignal,
            onChanged: _setMealy,
          ),
          if (_hasBoth) ...[
            const SizedBox(height: 14),
            Text(
              context.l10n.t(
                _isCorrect
                    ? 'statesStory.placement.correct'
                    : 'statesStory.placement.wrong',
              ),
              textAlign: TextAlign.center,
              style: context.textStyles.body.copyWith(
                color: _isCorrect
                    ? context.colors.primary
                    : context.colors.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _setMoore(_OutputLocation value) {
    setState(() => _moore = value);
    _completeIfCorrect();
  }

  void _setMealy(_OutputLocation value) {
    setState(() => _mealy = value);
    _completeIfCorrect();
  }

  void _completeIfCorrect() {
    if (_isCorrect) widget.onInteractionComplete();
  }
}

class _OutputLocationRow extends StatelessWidget {
  const _OutputLocationRow({
    required this.title,
    required this.isMoore,
    required this.value,
    required this.interactionHintSignal,
    required this.onChanged,
  });

  final String title;
  final bool isMoore;
  final _OutputLocation? value;
  final int interactionHintSignal;
  final ValueChanged<_OutputLocation> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textStyles.heading),
        _MachineOutputDiagram(isMoore: isMoore, height: 150),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final location in _OutputLocation.values)
              LessonInteractionHint(
                signal: interactionHintSignal,
                child: ChoiceChip(
                  selected: value == location,
                  label: Text(
                    context.l10n.t(
                      location == _OutputLocation.state
                          ? 'statesStory.placement.state'
                          : 'statesStory.placement.transition',
                    ),
                  ),
                  onSelected: AppHaptics.wrapSelection<bool>(
                    (_) => onChanged(location),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MealyOutputSimulationScene extends StatefulWidget {
  const _MealyOutputSimulationScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_MealyOutputSimulationScene> createState() =>
      _MealyOutputSimulationSceneState();
}

class _MealyOutputSimulationSceneState
    extends State<_MealyOutputSimulationScene> {
  bool _triggered = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('statesStory.mealy.simulationTitle'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 8),
          _MachineOutputDiagram(isMoore: false, mealyTriggered: _triggered),
          const SizedBox(height: 10),
          LessonInteractionHint(
            signal: widget.interactionHintSignal,
            child: AppButton(
              label: context.l10n.t(
                _triggered
                    ? 'statesStory.mealy.simulationReset'
                    : 'statesStory.mealy.simulationRun',
              ),
              icon: Icon(
                _triggered ? Icons.replay_rounded : Icons.play_arrow_rounded,
              ),
              onPressed: _toggleSimulation,
            ),
          ),
          if (_triggered) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.t('statesStory.mealy.simulationFeedback'),
              textAlign: TextAlign.center,
              style: context.textStyles.body.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleSimulation() {
    final isFirstRun = !_triggered;
    setState(() => _triggered = !_triggered);
    if (isFirstRun) widget.onInteractionComplete();
  }
}

class _StateRolesSummary extends StatelessWidget {
  const _StateRolesSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('statesStory.rolesTitle'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const _DoorFsmDiagram(
            key: ValueKey('state-roles-diagram'),
            currentState: 0,
            showReset: true,
            showOutputs: true,
            height: 220,
          ),
          const SizedBox(height: 14),
          _RoleTile(
            icon: Icons.flag_rounded,
            titleKey: 'statesStory.initial',
            bodyKey: 'statesStory.roles.initial',
          ),
          _RoleTile(
            icon: Icons.location_on_rounded,
            titleKey: 'statesStory.current',
            bodyKey: 'statesStory.roles.current',
          ),
          _RoleTile(
            icon: Icons.output_rounded,
            titleKey: 'statesStory.output',
            bodyKey: 'statesStory.roles.output',
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.t('statesStory.rolesOverlap'),
            textAlign: TextAlign.center,
            style: context.textStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
  });

  final IconData icon;
  final String titleKey;
  final String bodyKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.colors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.t(titleKey),
                  style: context.textStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  context.l10n.t(bodyKey),
                  style: context.textStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatesReadyScene extends StatelessWidget {
  const _StatesReadyScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 68,
            color: context.colors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.t('statesStory.readyTitle'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.t('statesStory.readyBody'),
            textAlign: TextAlign.center,
            style: context.textStyles.body,
          ),
        ],
      ),
    );
  }
}
