import 'dart:async';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:bachelor/core/widgets/fsm_diagram_labels.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_interaction_hint.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_scroll_continue_button.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter1/lesson_state_image.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_lesson_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const _doorClosedState = 'DOOR IS CLOSED';
const _doorOpenState = 'DOOR IS OPEN';
const _doorOpeningState = 'DOOR IS OPENING';
const _doorClosingState = 'DOOR IS CLOSING';
const _openDoorOutput = 'OPEN DOOR';
const _closeDoorOutput = 'CLOSE DOOR';
const _stopMotorOutput = 'STOP MOTOR';

ButtonStyle _mutedOutlinedButtonStyle(BuildContext context) {
  return OutlinedButton.styleFrom(
    foregroundColor: context.colors.mutedText,
    side: BorderSide(color: context.colors.mutedText.withValues(alpha: 0.62)),
  );
}

/// Erklärt Zustandsübergänge sowie Moore- und Mealy-Ausgaben anhand einer automatischen Tür.
class TransitionsLessonStory extends StatefulWidget {
  const TransitionsLessonStory({
    required this.onFinished,
    this.onProgressChanged,
    super.key,
  });

  final VoidCallback onFinished;
  final ValueChanged<double>? onProgressChanged;

  @override
  State<TransitionsLessonStory> createState() => _TransitionsLessonStoryState();
}

class _TransitionsLessonStoryState extends State<TransitionsLessonStory> {
  static const _interactiveSteps = {1, 2, 9, 14};
  static const _stepKeys = [
    'transitionsDoorStory.step.01',
    'transitionsDoorStory.step.02',
    'transitionsDoorStory.step.03',
    'transitionsDoorStory.step.04',
    'transitionsDoorStory.step.05',
    'transitionsDoorStory.step.06',
    'transitionsDoorStory.step.07',
    'transitionsDoorStory.step.08',
    'transitionsDoorStory.step.09',
    'transitionsDoorStory.step.10',
    'transitionsDoorStory.step.11',
    'transitionsDoorStory.step.12',
    'transitionsDoorStory.step.13',
    'transitionsDoorStory.step.14',
    'transitionsDoorStory.step.15',
    'transitionsDoorStory.step.16',
    'transitionsDoorStory.step.17',
    'transitionsDoorStory.step.18',
  ];

  final _scrollController = ScrollController();
  final Set<int> _completedInteractiveSteps = {};
  int _step = 0;
  int _interactionHintSignal = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    _MascotBubble(
                      text: context.l10n.t(_stepKeys[_step]),
                      step: _step,
                      isLastStep: isLastStep,
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: 280.ms,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _sceneForStep(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_step == 0)
          LessonScrollContinueButton(
            key: ValueKey('transitions-scroll-next-$_step'),
            controller: _scrollController,
            onContinue: _handleNextPressed,
          )
        else
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: context.l10n.t('common.back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: isLastStep
                    ? AppButton(
                        label: context.l10n.t(
                          'transitionsDoorStory.startTasks',
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        onPressed: widget.onFinished,
                      )
                    : LessonScrollContinueButton(
                        key: ValueKey('transitions-scroll-next-$_step'),
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
      0 => const _TransitionsWelcomeScene(key: ValueKey('transitions-welcome')),
      1 => _DoorReactionScene(
        key: const ValueKey('door-reaction'),
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      2 => _SignalClassificationScene(
        key: const ValueKey('signal-classification'),
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      3 => const _DoorStateImagesScene(key: ValueKey('door-state-images')),
      4 => const _SimplifiedStateScene(key: ValueKey('simplified-door-states')),
      5 => const _MooreConstructionScene(
        key: ValueKey('moore-add-open-state'),
        stage: _MooreConstructionStage.openState,
      ),
      6 => const _MooreConstructionScene(
        key: ValueKey('moore-add-closed-state'),
        stage: _MooreConstructionStage.closedState,
      ),
      7 => const _MooreConstructionScene(
        key: ValueKey('moore-add-close-transition'),
        stage: _MooreConstructionStage.closeTransition,
      ),
      8 => const _MooreConstructionScene(
        key: ValueKey('moore-add-open-transition'),
        stage: _MooreConstructionStage.openTransition,
      ),
      9 => _MooreSimulationScene(
        key: const ValueKey('simulate-moore'),
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      10 => const _MealyConversionScene(
        key: ValueKey('mealy-remove-outputs'),
        stage: _MealyConversionStage.removeOutputs,
      ),
      11 => const _MealyConversionScene(
        key: ValueKey('mealy-merge-states'),
        stage: _MealyConversionStage.mergeStates,
      ),
      12 => const _MealyConversionScene(
        key: ValueKey('mealy-add-open-transition'),
        stage: _MealyConversionStage.openTransition,
      ),
      13 => const _MealyConversionScene(
        key: ValueKey('mealy-add-close-transition'),
        stage: _MealyConversionStage.closeTransition,
      ),
      14 => _MealySimulationScene(
        key: const ValueKey('simulate-mealy'),
        interactionHintSignal: _interactionHintSignal,
        onInteractionComplete: _completeCurrentInteraction,
      ),
      15 => const _MooreMealyComparisonScene(
        key: ValueKey('moore-mealy-comparison'),
      ),
      16 => const _RealisticDoorScene(
        key: ValueKey('realistic-four-state-door'),
      ),
      _ => const _LessonReadyScene(key: ValueKey('transitions-ready')),
    };
  }

  void _handleNextPressed() {
    if (_interactiveSteps.contains(_step) &&
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
    setState(() => _step++);
    widget.onProgressChanged?.call(_step / (_stepKeys.length - 1));
    _scrollToTop();
  }

  void _previousStep() {
    if (_step == 0) return;
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

class _MascotBubble extends StatelessWidget {
  const _MascotBubble({
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
      animationId: 'transitions-$step',
    );
  }
}

class _TransitionsWelcomeScene extends StatelessWidget {
  const _TransitionsWelcomeScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
      child: Column(
        children: [
          Text(
            context.l10n.t('transitionsStory.welcome.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 8),
          FsmDiagram(
            key: const ValueKey('transitions-welcome-fsm'),
            height: 235,
            nodes: const [
              FsmDiagramNode(
                center: Offset(0.20, 0.52),
                width: 112,
                radius: 56,
                child: LessonDoorImageNode(
                  label: 'q0',
                  state: LessonDoorImageState.closed,
                  isMuted: true,
                ),
              ),
              FsmDiagramNode(
                center: Offset(0.80, 0.52),
                width: 112,
                radius: 56,
                child: LessonDoorImageNode(
                  label: 'q1',
                  state: LessonDoorImageState.open,
                  isMuted: true,
                ),
              ),
            ],
            transitions: const [],
          ),
          const SizedBox(height: 8),
          const _TransitionStateMeaningLegend(
            keys: [
              'transitionsStory.nodeLegend.simple.q0',
              'transitionsStory.nodeLegend.simple.q1',
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.t('transitionsStory.welcome.models'),
            textAlign: TextAlign.center,
            style: context.textStyles.heading.copyWith(
              color: context.colors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoorStateImagesScene extends StatelessWidget {
  const _DoorStateImagesScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('transitionsStory.stateImages.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 12),
          FsmDiagram(
            key: const ValueKey('door-state-images-fsm'),
            height: 220,
            nodes: const [
              FsmDiagramNode(
                center: Offset(0.20, 0.52),
                width: 112,
                radius: 56,
                child: LessonDoorImageNode(
                  label: 'q0',
                  state: LessonDoorImageState.closed,
                  isMuted: true,
                ),
              ),
              FsmDiagramNode(
                center: Offset(0.80, 0.52),
                width: 112,
                radius: 56,
                child: LessonDoorImageNode(
                  label: 'q1',
                  state: LessonDoorImageState.open,
                  isMuted: true,
                ),
              ),
            ],
            transitions: const [],
          ),
          const SizedBox(height: 8),
          const _TransitionStateMeaningLegend(
            keys: [
              'transitionsStory.nodeLegend.simple.q0',
              'transitionsStory.nodeLegend.simple.q1',
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.t('transitionsStory.stateImages.caption'),
            textAlign: TextAlign.center,
            style: context.textStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _DoorReactionScene extends StatefulWidget {
  const _DoorReactionScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_DoorReactionScene> createState() => _DoorReactionSceneState();
}

class _DoorReactionSceneState extends State<_DoorReactionScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _doorController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  Timer? _turnaroundTimer;
  String? _selected;

  bool get _isCorrect => _selected == 'open';

  @override
  void initState() {
    super.initState();
    _doorController.addStatusListener(_onDoorAnimationStatus);
    _doorController.forward();
  }

  @override
  void dispose() {
    _turnaroundTimer?.cancel();
    _doorController
      ..removeStatusListener(_onDoorAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _doorController,
          builder: (context, _) => _DoorVisual(
            progress: Curves.easeInOutCubic.transform(_doorController.value),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('transitionsStory.reaction.question'),
                textAlign: TextAlign.center,
                style: context.textStyles.title,
              ),
              const SizedBox(height: 12),
              for (final answer in const ['open', 'stay', 'close'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LessonInteractionHint(
                    signal: _isCorrect ? 0 : widget.interactionHintSignal,
                    child: OutlinedButton(
                      key: ValueKey('door-reaction-$answer'),
                      onPressed: AppHaptics.wrapButton(() => _select(answer)),
                      child: Text(
                        context.l10n.t(
                          'transitionsStory.reaction.answer.$answer',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              if (_selected != null)
                _FeedbackText(
                  isCorrect: _isCorrect,
                  textKey: _isCorrect
                      ? 'transitionsStory.reaction.correct'
                      : 'transitionsStory.reaction.wrong',
                ),
              if (_isCorrect) ...[
                const SizedBox(height: 10),
                const _SignalValues(
                  input: 'person = 1',
                  output: 'motor command = OPEN DOOR',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _select(String answer) {
    setState(() => _selected = answer);
    if (answer == 'open') widget.onInteractionComplete();
  }

  void _onDoorAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed) {
      return;
    }
    _turnaroundTimer?.cancel();
    _turnaroundTimer = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      if (status == AnimationStatus.completed) {
        _doorController.reverse();
      } else {
        _doorController.forward();
      }
    });
  }
}

class _DoorVisual extends StatelessWidget {
  const _DoorVisual({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final sensorPulse = 0.35 + progress * 0.65;
    return AppCard(
      isTransparent: true,
      child: Column(
        children: [
          Transform.scale(
            key: const ValueKey('door-sensor-pulse'),
            scale: 0.9 + sensorPulse * 0.16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.warning.withValues(
                      alpha: 0.18 + sensorPulse * 0.38,
                    ),
                    blurRadius: 10 + sensorPulse * 18,
                    spreadRadius: sensorPulse * 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.sensors_rounded,
                size: 44,
                color: Color.lerp(
                  context.colors.secondary,
                  context.colors.warning,
                  sensorPulse,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: context.colors.mutedText.withValues(alpha: 0.62),
                      width: 3,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final travel = constraints.maxWidth * 0.38 * progress;
                      return Stack(
                        key: const ValueKey('door-animation'),
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: progress,
                            child: Icon(
                              Icons.directions_walk_rounded,
                              size: 72,
                              color: context.colors.warning,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Transform.translate(
                                    key: const ValueKey('door-left-panel'),
                                    offset: Offset(-travel, 0),
                                    child: const _DoorPanel(isLeft: true),
                                  ),
                                ),
                                Expanded(
                                  child: Transform.translate(
                                    key: const ValueKey('door-right-panel'),
                                    offset: Offset(travel, 0),
                                    child: const _DoorPanel(isLeft: false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoorPanel extends StatelessWidget {
  const _DoorPanel({required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.lerp(
          context.colors.surfaceRaised,
          context.colors.primary,
          0.16,
        ),
        border: Border.all(
          color: context.colors.mutedText.withValues(alpha: 0.62),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(
        isLeft ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
        color: context.colors.primary,
        size: 38,
      ),
    );
  }
}

class _SignalClassificationScene extends StatefulWidget {
  const _SignalClassificationScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_SignalClassificationScene> createState() =>
      _SignalClassificationSceneState();
}

class _SignalClassificationSceneState
    extends State<_SignalClassificationScene> {
  bool? _personIsInput;
  bool? _motorIsOutput;

  bool get _isComplete => _personIsInput == true && _motorIsOutput == true;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('transitionsStory.signals.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 12),
          _SignalClassifier(
            key: const ValueKey('classify-person'),
            icon: Icons.sensors_rounded,
            signal: 'person',
            value: '0 / 1',
            selectedCorrectly: _personIsInput,
            interactionHintSignal: _personIsInput == true
                ? 0
                : widget.interactionHintSignal,
            onInput: () => _setPerson(true),
            onOutput: () => _setPerson(false),
          ),
          const SizedBox(height: 12),
          _SignalClassifier(
            key: const ValueKey('classify-motor'),
            icon: Icons.settings_remote_rounded,
            signal: 'motor',
            value: 'OPEN / CLOSE',
            selectedCorrectly: _motorIsOutput,
            interactionHintSignal: _motorIsOutput == true
                ? 0
                : widget.interactionHintSignal,
            onInput: () => _setMotor(false),
            onOutput: () => _setMotor(true),
          ),
          if (_isComplete) ...[
            const SizedBox(height: 12),
            _FeedbackText(
              isCorrect: true,
              textKey: 'transitionsStory.signals.correct',
            ),
          ],
        ],
      ),
    );
  }

  void _setPerson(bool isCorrect) {
    setState(() => _personIsInput = isCorrect);
    _completeIfReady();
  }

  void _setMotor(bool isCorrect) {
    setState(() => _motorIsOutput = isCorrect);
    _completeIfReady();
  }

  void _completeIfReady() {
    if (_isComplete) widget.onInteractionComplete();
  }
}

class _SignalClassifier extends StatelessWidget {
  const _SignalClassifier({
    required this.icon,
    required this.signal,
    required this.value,
    required this.selectedCorrectly,
    required this.interactionHintSignal,
    required this.onInput,
    required this.onOutput,
    super.key,
  });

  final IconData icon;
  final String signal;
  final String value;
  final bool? selectedCorrectly;
  final int interactionHintSignal;
  final VoidCallback onInput;
  final VoidCallback onOutput;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: selectedCorrectly == true
              ? context.colors.primary
              : context.colors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: context.colors.warning),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$signal = $value',
                  textAlign: TextAlign.center,
                  style: context.textStyles.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LessonInteractionHint(
                  signal: interactionHintSignal,
                  child: OutlinedButton(
                    onPressed: AppHaptics.wrapButton(
                      selectedCorrectly == true ? null : onInput,
                    ),
                    style: selectedCorrectly == true
                        ? _mutedOutlinedButtonStyle(context)
                        : null,
                    child: Text(
                      context.l10n.t('transitionsStory.signal.input'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LessonInteractionHint(
                  signal: interactionHintSignal,
                  child: OutlinedButton(
                    onPressed: AppHaptics.wrapButton(
                      selectedCorrectly == true ? null : onOutput,
                    ),
                    style: selectedCorrectly == true
                        ? _mutedOutlinedButtonStyle(context)
                        : null,
                    child: Text(
                      context.l10n.t('transitionsStory.signal.output'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selectedCorrectly == false)
            _FeedbackText(
              isCorrect: false,
              textKey: 'transitionsStory.signals.wrong',
            ),
        ],
      ),
    );
  }
}

class _SimplifiedStateScene extends StatelessWidget {
  const _SimplifiedStateScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                context.l10n.t('transitionsStory.states.title'),
                textAlign: TextAlign.center,
                style: context.textStyles.title,
              ),
              const SizedBox(height: 8),
              const _TwoStateMooreDiagram(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ActuatorNote(),
      ],
    );
  }
}

class _ActuatorNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: context.colors.mutedText.withValues(alpha: 0.62),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: context.colors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.t('transitionsStory.states.actuatorNote'),
              style: context.textStyles.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MooreConstructionStage {
  openState,
  closedState,
  closeTransition,
  openTransition,
}

class _MooreConstructionScene extends StatelessWidget {
  const _MooreConstructionScene({required this.stage, super.key});

  final _MooreConstructionStage stage;

  @override
  Widget build(BuildContext context) {
    final diagram = switch (stage) {
      _MooreConstructionStage.openState => const _TwoStateMooreDiagram(
        showClosedState: false,
        showOpenOutput: true,
        resetToOpen: true,
      ),
      _MooreConstructionStage.closedState => const _TwoStateMooreDiagram(
        showOutputs: true,
      ),
      _MooreConstructionStage.closeTransition => const _TwoStateMooreDiagram(
        showOutputs: true,
        showPersonZeroTransition: true,
      ),
      _MooreConstructionStage.openTransition => const _TwoStateMooreDiagram(
        showOutputs: true,
        showTransitions: true,
      ),
    };
    final actionKey = switch (stage) {
      _MooreConstructionStage.openState =>
        'transitionsStory.mooreSteps.action.openState',
      _MooreConstructionStage.closedState =>
        'transitionsStory.mooreSteps.action.closedState',
      _MooreConstructionStage.closeTransition =>
        'transitionsStory.mooreSteps.action.closeTransition',
      _MooreConstructionStage.openTransition =>
        'transitionsStory.mooreSteps.action.openTransition',
    };

    return _ConstructionStepCard(
      titleKey: 'transitionsStory.mooreSteps.title',
      actionKey: actionKey,
      currentStep: stage.index + 1,
      totalSteps: _MooreConstructionStage.values.length,
      diagram: diagram,
      isComplete: stage == _MooreConstructionStage.openTransition,
    );
  }
}

class _ConstructionStepCard extends StatelessWidget {
  const _ConstructionStepCard({
    required this.titleKey,
    required this.actionKey,
    required this.currentStep,
    required this.totalSteps,
    required this.diagram,
    required this.isComplete,
  });

  final String titleKey;
  final String actionKey;
  final int currentStep;
  final int totalSteps;
  final Widget diagram;
  final bool isComplete;

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
          const SizedBox(height: 6),
          Text(
            context.l10n.t(
              'transitionsStory.construction.progress',
              args: {'current': '$currentStep', 'total': '$totalSteps'},
            ),
            textAlign: TextAlign.center,
            style: context.textStyles.caption.copyWith(
              color: context.colors.mutedText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          diagram,
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: context.colors.mutedText.withValues(alpha: 0.62),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isComplete
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_rounded,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    context.l10n.t(actionKey),
                    style: context.textStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MooreSimulationScene extends StatefulWidget {
  const _MooreSimulationScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_MooreSimulationScene> createState() => _MooreSimulationSceneState();
}

class _MooreSimulationSceneState extends State<_MooreSimulationScene> {
  int _currentState = 0;
  int? _highlightedTransition;
  bool _openedOnce = false;

  bool get _isComplete => _openedOnce && _currentState == 0;

  @override
  Widget build(BuildContext context) {
    final expectedInput = _currentState == 0 ? 'person = 1' : 'person = 0';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('transitionsStory.mooreSim.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 8),
          _TwoStateMooreDiagram(
            showOutputs: true,
            showTransitions: true,
            currentState: _currentState,
            highlightedTransition: _highlightedTransition,
          ),
          const SizedBox(height: 10),
          _SignalValues(
            input: expectedInput,
            output: _currentState == 0
                ? 'motor command = CLOSE DOOR'
                : 'motor command = OPEN DOOR',
          ),
          const SizedBox(height: 10),
          LessonInteractionHint(
            signal: _isComplete ? 0 : widget.interactionHintSignal,
            child: AppButton(
              label: context.l10n.t(
                _currentState == 0
                    ? 'transitionsStory.mooreSim.personAppears'
                    : 'transitionsStory.mooreSim.personLeaves',
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: AppHaptics.wrapButton(_advance),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.t('transitionsStory.mooreSim.sequence'),
            textAlign: TextAlign.center,
            style: context.textStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _advance() {
    setState(() {
      if (_currentState == 0) {
        _highlightedTransition = 0;
        _currentState = 1;
        _openedOnce = true;
      } else {
        _highlightedTransition = 1;
        _currentState = 0;
      }
    });
    if (_isComplete) widget.onInteractionComplete();
  }
}

/*
class _SandboxMealyBuilderScene extends StatelessWidget {
  const _SandboxMealyBuilderScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('transitionsStory.mealyTransform.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 8),
          const _TwoStateMooreDiagram(showOutputs: true, showTransitions: true),
          const SizedBox(height: 10),
          Text(
            context.l10n.t(
              'transitionsStory.mealyTransform.sandboxInstruction',
            ),
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          LessonInteractionHint(
            signal: interactionHintSignal,
            child: _LessonSandboxBuilder(
              key: const ValueKey('sandbox-mealy-builder'),
              expectedFsm: _storyMealyFsm,
              initialFsm: _partialStoryMealyFsm,
              allowedTools: const {
                FsmEditorTool.select,
                FsmEditorTool.addTransition,
                FsmEditorTool.delete,
              },
              onCorrect: onInteractionComplete,
            ),
          ),
        ],
      ),
    );
  }
}

// Bleibt vorübergehend für die abwärtskompatible Zustandswiederherstellung beim Hot Reload erhalten.
// ignore: unused_element
class _MealyTransformScene extends StatefulWidget {
  const _MealyTransformScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_MealyTransformScene> createState() => _MealyTransformSceneState();
}

class _MealyTransformSceneState extends State<_MealyTransformScene> {
  final Set<String> _movedOutputs = {};

  bool get _isComplete => _movedOutputs.length == 2;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('transitionsStory.mealyTransform.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: 220.ms,
            child: _isComplete
                ? const _MealyWaitDiagram(key: ValueKey('mealy-wait-ready'))
                : const _TwoStateMooreDiagram(
                    key: ValueKey('moore-before-transform'),
                    showOutputs: true,
                    showTransitions: true,
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.t('transitionsStory.mealyTransform.instruction'),
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final output in const ['OPEN', 'CLOSE'])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _BuilderAction(
                key: ValueKey('move-$output-to-transition'),
                label: context.l10n.t(
                  'transitionsStory.mealyTransform.move',
                  args: {
                    'output': output == 'OPEN'
                        ? _openDoorOutput
                        : _closeDoorOutput,
                  },
                ),
                completed: _movedOutputs.contains(output),
                signal: widget.interactionHintSignal,
                onPressed: AppHaptics.wrapButton(() => _moveOutput(output)),
              ),
            ),
          if (_isComplete)
            _FeedbackText(
              isCorrect: true,
              textKey: 'transitionsStory.mealyTransform.complete',
            ),
        ],
      ),
    );
  }

  void _moveOutput(String output) {
    if (_movedOutputs.contains(output)) return;
    setState(() => _movedOutputs.add(output));
    if (_isComplete) widget.onInteractionComplete();
  }
}

*/

enum _MealyConversionStage {
  removeOutputs,
  mergeStates,
  openTransition,
  closeTransition,
}

class _MealyConversionScene extends StatelessWidget {
  const _MealyConversionScene({required this.stage, super.key});

  final _MealyConversionStage stage;

  @override
  Widget build(BuildContext context) {
    final diagram = switch (stage) {
      _MealyConversionStage.removeOutputs => const _TwoStateMooreDiagram(
        showTransitions: true,
      ),
      _MealyConversionStage.mergeStates => const _MealyWaitDiagram(
        showOpenTransition: false,
        showCloseTransition: false,
      ),
      _MealyConversionStage.openTransition => const _MealyWaitDiagram(
        showCloseTransition: false,
      ),
      _MealyConversionStage.closeTransition => const _MealyWaitDiagram(),
    };
    final actionKey = switch (stage) {
      _MealyConversionStage.removeOutputs =>
        'transitionsStory.mealySteps.action.removeOutputs',
      _MealyConversionStage.mergeStates =>
        'transitionsStory.mealySteps.action.mergeStates',
      _MealyConversionStage.openTransition =>
        'transitionsStory.mealySteps.action.openTransition',
      _MealyConversionStage.closeTransition =>
        'transitionsStory.mealySteps.action.closeTransition',
    };

    return _ConstructionStepCard(
      titleKey: 'transitionsStory.mealySteps.title',
      actionKey: actionKey,
      currentStep: stage.index + 1,
      totalSteps: _MealyConversionStage.values.length,
      diagram: diagram,
      isComplete: stage == _MealyConversionStage.closeTransition,
    );
  }
}

class _MealySimulationScene extends StatefulWidget {
  const _MealySimulationScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_MealySimulationScene> createState() => _MealySimulationSceneState();
}

class _MealySimulationSceneState extends State<_MealySimulationScene> {
  final Set<int> _usedInputs = {};
  int? _lastInput;

  bool get _isComplete => _usedInputs.length == 2;

  @override
  Widget build(BuildContext context) {
    final output = _lastInput == null
        ? '-'
        : _lastInput == 1
        ? 'motor command = OPEN DOOR'
        : 'motor command = CLOSE DOOR';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('transitionsStory.mealySim.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 8),
          _MealyWaitDiagram(highlightedInput: _lastInput),
          const SizedBox(height: 10),
          _SignalValues(
            input: _lastInput == null ? 'person = -' : 'person = $_lastInput',
            output: output,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final input in const [1, 0]) ...[
                if (input == 0) const SizedBox(width: 8),
                Expanded(
                  child: LessonInteractionHint(
                    signal: _usedInputs.contains(input)
                        ? 0
                        : widget.interactionHintSignal,
                    child: OutlinedButton(
                      key: ValueKey('mealy-input-$input'),
                      onPressed: AppHaptics.wrapButton(
                        () => _applyInput(input),
                      ),
                      child: Text('person = $input'),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.t('transitionsStory.mealySim.stateStays'),
            textAlign: TextAlign.center,
            style: context.textStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _applyInput(int input) {
    setState(() {
      _lastInput = input;
      _usedInputs.add(input);
    });
    if (_isComplete) widget.onInteractionComplete();
  }
}

class _MooreMealyComparisonScene extends StatelessWidget {
  const _MooreMealyComparisonScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                context.l10n.t('transitionsStory.compare.title'),
                textAlign: TextAlign.center,
                style: context.textStyles.title,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 720) {
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _MooreComparisonCard()),
                        SizedBox(width: 12),
                        Expanded(child: _MealyComparisonCard()),
                      ],
                    );
                  }
                  return const Column(
                    children: [
                      _MooreComparisonCard(),
                      SizedBox(height: 12),
                      _MealyComparisonCard(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ComparisonTable(),
      ],
    );
  }
}

class _MooreComparisonCard extends StatelessWidget {
  const _MooreComparisonCard();

  @override
  Widget build(BuildContext context) {
    return _ComparisonCardShell(
      title: 'Moore',
      color: context.colors.primary,
      diagram: const _TwoStateMooreDiagram(
        showOutputs: true,
        showTransitions: true,
      ),
      facts: [
        context.l10n.t('transitionsStory.compare.moore.states'),
        context.l10n.t('transitionsStory.compare.moore.output'),
        context.l10n.t('transitionsStory.compare.moore.reaction'),
      ],
    );
  }
}

class _MealyComparisonCard extends StatelessWidget {
  const _MealyComparisonCard();

  @override
  Widget build(BuildContext context) {
    return _ComparisonCardShell(
      title: 'Mealy',
      color: context.colors.warning,
      diagram: const _MealyWaitDiagram(),
      facts: [
        context.l10n.t('transitionsStory.compare.mealy.states'),
        context.l10n.t('transitionsStory.compare.mealy.output'),
        context.l10n.t('transitionsStory.compare.mealy.reaction'),
      ],
    );
  }
}

class _ComparisonCardShell extends StatelessWidget {
  const _ComparisonCardShell({
    required this.title,
    required this.color,
    required this.diagram,
    required this.facts,
  });

  final String title;
  final Color color;
  final Widget diagram;
  final List<String> facts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: context.colors.mutedText.withValues(alpha: 0.62),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.heading.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          diagram,
          for (final fact in facts)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, size: 18, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(fact, style: context.textStyles.caption),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          for (final row in [
            (
              key: 'transitionsStory.compare.row.location',
              moore: 'transitionsStory.compare.row.location.moore',
              mealy: 'transitionsStory.compare.row.location.mealy',
            ),
            (
              key: 'transitionsStory.compare.row.depends',
              moore: 'transitionsStory.compare.row.depends.moore',
              mealy: 'transitionsStory.compare.row.depends.mealy',
            ),
            (key: 'transitionsStory.compare.row.count', moore: '2', mealy: '1'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.t(row.key),
                    textAlign: TextAlign.center,
                    style: context.textStyles.caption.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Moore: ${context.l10n.t(row.moore)}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Mealy: ${context.l10n.t(row.mealy)}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorCorrectionScene extends StatefulWidget {
  const _ErrorCorrectionScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_ErrorCorrectionScene> createState() => _ErrorCorrectionSceneState();
}

class _ErrorCorrectionSceneState extends State<_ErrorCorrectionScene> {
  bool _mooreFixed = false;
  bool _mealyFixed = false;

  bool get _isComplete => _mooreFixed && _mealyFixed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t('transitionsStory.errors.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 12),
          _ErrorCard(
            key: const ValueKey('fix-moore-error'),
            title: 'Moore',
            wrongText:
                'DOOR IS CLOSED / OPEN DOOR\n'
                'DOOR IS OPEN / CLOSE DOOR',
            correctText:
                'DOOR IS CLOSED / CLOSE DOOR\n'
                'DOOR IS OPEN / OPEN DOOR',
            isFixed: _mooreFixed,
            signal: widget.interactionHintSignal,
            onFix: () => _fix(isMoore: true),
          ),
          const SizedBox(height: 12),
          _ErrorCard(
            key: const ValueKey('fix-mealy-error'),
            title: 'Mealy',
            wrongText: 'person=1 / CLOSE DOOR\nperson=0 / OPEN DOOR',
            correctText: 'person=1 / OPEN DOOR\nperson=0 / CLOSE DOOR',
            isFixed: _mealyFixed,
            signal: widget.interactionHintSignal,
            onFix: () => _fix(isMoore: false),
          ),
          if (_isComplete)
            _FeedbackText(
              isCorrect: true,
              textKey: 'transitionsStory.errors.complete',
            ),
        ],
      ),
    );
  }

  void _fix({required bool isMoore}) {
    setState(() {
      if (isMoore) {
        _mooreFixed = true;
      } else {
        _mealyFixed = true;
      }
    });
    if (_isComplete) widget.onInteractionComplete();
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.title,
    required this.wrongText,
    required this.correctText,
    required this.isFixed,
    required this.signal,
    required this.onFix,
    super.key,
  });

  final String title;
  final String wrongText;
  final String correctText;
  final bool isFixed;
  final int signal;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final color = isFixed ? context.colors.mutedText : context.colors.danger;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.heading,
          ),
          const SizedBox(height: 8),
          Text(
            isFixed ? correctText : wrongText,
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          LessonInteractionHint(
            signal: isFixed ? 0 : signal,
            child: OutlinedButton.icon(
              onPressed: AppHaptics.wrapButton(isFixed ? null : onFix),
              style: isFixed ? _mutedOutlinedButtonStyle(context) : null,
              icon: Icon(
                isFixed ? Icons.check_rounded : Icons.build_circle_outlined,
              ),
              label: Text(
                context.l10n.t(
                  isFixed
                      ? 'transitionsStory.errors.fixed'
                      : 'transitionsStory.errors.fix',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RealisticDoorScene extends StatelessWidget {
  const _RealisticDoorScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                context.l10n.t('transitionsStory.realistic.title'),
                textAlign: TextAlign.center,
                style: context.textStyles.title,
              ),
              const SizedBox(height: 8),
              const _FourStateDoorDiagram(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: context.colors.mutedText.withValues(alpha: 0.62),
              width: 2,
            ),
          ),
          child: Text(
            context.l10n.t('transitionsStory.realistic.conclusion'),
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonReadyScene extends StatelessWidget {
  const _LessonReadyScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(Icons.verified_rounded, size: 68, color: context.colors.primary),
          const SizedBox(height: 10),
          Text(
            context.l10n.t('transitionsStory.ready.title'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 10),
          for (final key in const [
            'transitionsStory.ready.moore',
            'transitionsStory.ready.mealy',
            'transitionsStory.ready.count',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(context.l10n.t(key))),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            context.l10n.t('transitionsStory.ready.keyPhrase'),
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(
              color: context.colors.warning,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoStateMooreDiagram extends StatelessWidget {
  const _TwoStateMooreDiagram({
    this.showClosedState = true,
    this.showOutputs = false,
    this.showOpenOutput = false,
    this.showTransitions = false,
    this.showPersonZeroTransition = false,
    this.currentState,
    this.highlightedTransition,
    this.resetToOpen = false,
  });

  final bool showClosedState;
  final bool showOutputs;
  final bool showOpenOutput;
  final bool showTransitions;
  final bool showPersonZeroTransition;
  final int? currentState;
  final int? highlightedTransition;
  final bool resetToOpen;

  @override
  Widget build(BuildContext context) {
    final hasBothStates = showClosedState;
    final closedIndex = showClosedState ? 0 : null;
    final openIndex = showClosedState ? 1 : 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FsmDiagram(
          height: 220,
          nodes: [
            if (showClosedState)
              FsmDiagramNode(
                center: const Offset(0.20, 0.52),
                width: 92,
                radius: 44,
                child: _DoorStateNode(
                  id: 'q0',
                  output: showOutputs ? _closeDoorOutput : null,
                  isCurrent: currentState == 0,
                ),
              ),
            FsmDiagramNode(
              center: Offset(showClosedState ? 0.80 : 0.50, 0.52),
              width: 92,
              radius: 44,
              child: _DoorStateNode(
                id: 'q1',
                output: showOutputs || showOpenOutput ? _openDoorOutput : null,
                isCurrent: currentState == 1,
              ),
            ),
          ],
          transitions: [
            if (hasBothStates && showTransitions)
              FsmDiagramTransition(
                from: closedIndex!,
                to: openIndex,
                color: context.colors.primary,
                label: 'person = 1',
                curveDepth: 0.34,
                curveSide: 1,
                isHighlighted: highlightedTransition == 0,
              ),
            if (hasBothStates && (showTransitions || showPersonZeroTransition))
              FsmDiagramTransition(
                from: openIndex,
                to: closedIndex!,
                color: context.colors.warning,
                label: 'person = 0',
                curveDepth: 0.34,
                curveSide: 1,
                isHighlighted: highlightedTransition == 1,
              ),
          ],
          resetTransition: FsmResetTransition(
            to: resetToOpen ? openIndex : closedIndex!,
            label: FsmDiagramLabels.reset,
            color: context.colors.mutedText,
            start: const Offset(0.06, 0.12),
            isMuted: true,
          ),
        ),
        const SizedBox(height: 8),
        const _TransitionStateMeaningLegend(
          keys: [
            'transitionsStory.nodeLegend.simple.q0',
            'transitionsStory.nodeLegend.simple.q1',
          ],
        ),
      ],
    );
  }
}

class _MealyWaitDiagram extends StatelessWidget {
  const _MealyWaitDiagram({
    this.highlightedInput,
    this.showOpenTransition = true,
    this.showCloseTransition = true,
  });

  final int? highlightedInput;
  final bool showOpenTransition;
  final bool showCloseTransition;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FsmDiagram(
          height: 290,
          nodes: [
            FsmDiagramNode(
              center: const Offset(0.50, 0.50),
              width: 96,
              radius: 46,
              child: _DoorStateNode(id: 'q0', isCurrent: true),
            ),
          ],
          transitions: [
            if (showOpenTransition)
              FsmDiagramTransition(
                from: 0,
                to: 0,
                color: context.colors.primary,
                label: 'person = 1\n/ OPEN DOOR',
                curveSide: -1,
                isHighlighted: highlightedInput == 1,
              ),
            if (showCloseTransition)
              FsmDiagramTransition(
                from: 0,
                to: 0,
                color: context.colors.warning,
                label: 'person = 0\n/ CLOSE DOOR',
                curveSide: 1,
                isHighlighted: highlightedInput == 0,
              ),
          ],
          resetTransition: FsmResetTransition(
            to: 0,
            label: FsmDiagramLabels.reset,
            color: context.colors.mutedText,
            start: const Offset(0.50, 0.04),
            isMuted: true,
          ),
        ),
        const SizedBox(height: 8),
        const _TransitionStateMeaningLegend(
          keys: ['transitionsStory.nodeLegend.mealy.q0'],
        ),
      ],
    );
  }
}

class _FourStateDoorDiagram extends StatelessWidget {
  const _FourStateDoorDiagram();

  @override
  Widget build(BuildContext context) {
    const states = [
      (_doorClosedState, _stopMotorOutput),
      (_doorOpeningState, _openDoorOutput),
      (_doorOpenState, _stopMotorOutput),
      (_doorClosingState, _closeDoorOutput),
    ];
    const centers = [
      Offset(0.20, 0.24),
      Offset(0.80, 0.24),
      Offset(0.80, 0.76),
      Offset(0.20, 0.76),
    ];
    const labels = ['PERSON', 'OPEN LIMIT', 'TIMEOUT', 'CLOSED LIMIT'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FsmDiagram(
          height: 330,
          nodes: [
            for (var index = 0; index < states.length; index++)
              FsmDiagramNode(
                center: centers[index],
                width: 86,
                radius: 40,
                child: _DoorStateNode(
                  id: 'q$index',
                  output: states[index].$2,
                  isCurrent: index == 0,
                ),
              ),
          ],
          transitions: [
            for (var index = 0; index < states.length; index++)
              FsmDiagramTransition(
                from: index,
                to: (index + 1) % states.length,
                color: [
                  context.colors.primary,
                  context.colors.warning,
                  context.colors.secondary,
                  context.colors.danger,
                ][index],
                label: labels[index],
              ),
          ],
          resetTransition: FsmResetTransition(
            to: 0,
            label: FsmDiagramLabels.reset,
            color: context.colors.mutedText,
            start: const Offset(0.06, 0.06),
            isMuted: true,
          ),
        ),
        const SizedBox(height: 8),
        const _TransitionStateMeaningLegend(
          keys: [
            'transitionsStory.nodeLegend.q0',
            'transitionsStory.nodeLegend.q1',
            'transitionsStory.nodeLegend.q2',
            'transitionsStory.nodeLegend.q3',
          ],
        ),
      ],
    );
  }
}

class _DoorStateNode extends StatelessWidget {
  const _DoorStateNode({required this.id, this.output, this.isCurrent = false});

  final String id;
  final String? output;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = isCurrent ? context.colors.warning : context.colors.mutedText;
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surfaceRaised,
        border: Border.all(color: color, width: isCurrent ? 5 : 3),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 18,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                id,
                textAlign: TextAlign.center,
                style: context.textStyles.caption.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (output case final value?)
                Text(
                  'y =\n$value',
                  textAlign: TextAlign.center,
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.warning,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransitionStateMeaningLegend extends StatelessWidget {
  const _TransitionStateMeaningLegend({required this.keys});

  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 4,
      children: [
        for (final key in keys)
          Text(
            context.l10n.t(key),
            textAlign: TextAlign.center,
            style: context.textStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _SignalValues extends StatelessWidget {
  const _SignalValues({required this.input, required this.output});

  final String input;
  final String output;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SignalValue(
            title: context.l10n.t('transitionsStory.signal.input'),
            value: input,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SignalValue(
            title: context.l10n.t('transitionsStory.signal.output'),
            value: output,
          ),
        ),
      ],
    );
  }
}

class _SignalValue extends StatelessWidget {
  const _SignalValue({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.mutedText.withValues(alpha: 0.62),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: context.textStyles.caption.copyWith(
              color: context.colors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: context.textStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackText extends StatelessWidget {
  const _FeedbackText({required this.isCorrect, required this.textKey});

  final bool isCorrect;
  final String textKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        context.l10n.t(textKey),
        textAlign: TextAlign.center,
        style: context.textStyles.body.copyWith(
          color: isCorrect ? context.colors.primary : context.colors.danger,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
