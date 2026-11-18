import 'dart:math' as math;

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:bachelor/core/widgets/fsm_diagram_labels.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_scroll_continue_button.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_interaction_hint.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_lesson_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Führt in endliche Automaten ein und verbindet Erklärszenen mit interaktiven Beispielen.
class IntroFsmStory extends StatefulWidget {
  const IntroFsmStory({
    required this.onFinished,
    this.onProgressChanged,
    super.key,
  });

  final VoidCallback onFinished;
  final ValueChanged<double>? onProgressChanged;

  @override
  State<IntroFsmStory> createState() => _IntroFsmStoryState();
}

class _IntroFsmStoryState extends State<IntroFsmStory> {
  final _scrollController = ScrollController();
  int _step = 0;
  int _interactionHintSignal = 0;
  final Set<int> _completedInteractiveSteps = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copyFor(context);
    final isLastStep = _step == copy.steps.length - 1;

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
                    _MascotLessonBubble(text: copy.steps[_step], step: _step),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: 280.ms,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _currentStep(),
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
            key: ValueKey('intro-scroll-next-$_step'),
            controller: _scrollController,
            requireReadAcknowledgement: true,
            onContinue: _nextStep,
          )
        else
          _StepActions(
            copy: copy,
            controller: _scrollController,
            scrollKey: ValueKey('intro-scroll-next-$_step'),
            isLastStep: isLastStep,
            onBack: _previousStep,
            onNext: isLastStep
                ? widget.onFinished
                : () => _handlePrimaryAction(_nextStep),
          ),
      ],
    );
  }

  Widget _currentStep() {
    return switch (_step) {
      0 => Step01(),
      1 => Step021(),
      2 => Step022(),
      3 => Step023(),
      4 => Step024(),
      5 => Step025(),
      6 => Step026(),
      7 => Step027(),
      8 => Step028(),
      9 => Step029(),
      10 => Step03(),
      11 => Step04(),
      12 => Step041(),
      13 => Step042(),
      14 => Step043(),
      15 => Step044(),
      16 => Step045(),
      17 => Step046(),
      18 => Step047(),
      19 => Step048(),
      20 => Step049(),
      _ => Step05(),
    };
  }

  // ignore: non_constant_identifier_names
  Widget Step01() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-incomplete-fsm'),
      firstNodeKey: ValueKey('intro-large-traffic-light'),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step021() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-021'),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step022() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-022'),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step023() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-023'),
      highlightedNode: 0,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step024() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-024'),
      highlightedTransition: 0,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step025() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-025'),
      highlightedNode: 1,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step026() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-026'),
      highlightedTransition: 1,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step027() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-027'),
      highlightedNode: 2,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step028() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-028'),
      highlightedTransition: 2,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step029() {
    return const _StaticTrafficLightScene(
      key: ValueKey('traffic-light-step-029'),
      highlightedNode: 3,
      highlightedTransition: 3,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step03() {
    return _AnimatedTrafficFsmScene(
      key: const ValueKey('traffic-scene-fsm'),
      interactionHintSignal: _interactionHintSignal,
      onInteractionComplete: _completeCurrentInteraction,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step04() {
    return const TrafficLightFsmScene(key: ValueKey('fsm-scene'));
  }

  // ignore: non_constant_identifier_names
  Widget Step041() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-reset'),
      highlightedNode: null,
      highlightReset: true,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step042() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-node-0'),
      highlightedNode: 0,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step043() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-transition-0'),
      highlightedTransition: 0,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step044() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-node-1'),
      highlightedNode: 1,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step045() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-transition-1'),
      highlightedTransition: 1,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step046() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-node-2'),
      highlightedNode: 2,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step047() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-transition-2'),
      highlightedTransition: 2,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step048() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-node-3'),
      highlightedNode: 3,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step049() {
    return const TrafficLightFsmScene(
      key: ValueKey('fsm-scene-transition-3'),
      highlightedTransition: 3,
    );
  }

  // ignore: non_constant_identifier_names
  Widget Step05() {
    return const _LessonReadyScene(key: ValueKey('lesson-ready'));
  }

  void _nextStep() {
    setState(() => _step++);
    widget.onProgressChanged?.call(
      _step / (_copyFor(context).steps.length - 1),
    );
    _scrollToTopAfterStepChange();
  }

  void _previousStep() {
    if (_step == 0) return;
    setState(() => _step--);
    widget.onProgressChanged?.call(
      _step / (_copyFor(context).steps.length - 1),
    );
    _scrollToTopAfterStepChange();
  }

  void _handlePrimaryAction(VoidCallback action) {
    const interactiveSteps = {10};
    if (interactiveSteps.contains(_step) &&
        !_completedInteractiveSteps.contains(_step)) {
      setState(() => _interactionHintSignal++);
      showLessonInteractionPrompt(context, _scrollController);
      return;
    }

    if (!_isScrolledToBottom) {
      _scrollToBottomAndLockNext();
      return;
    }

    action();
  }

  void _completeCurrentInteraction() {
    if (_completedInteractiveSteps.contains(_step)) return;
    setState(() => _completedInteractiveSteps.add(_step));
  }

  bool get _isScrolledToBottom {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return position.pixels >= position.maxScrollExtent - 12;
  }

  void _scrollToBottomAndLockNext() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToTopAfterStepChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }
}

class _LessonReadyScene extends StatelessWidget {
  const _LessonReadyScene({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 64,
            color: context.colors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.t('introFsm.readyTitle'),
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.t('introFsm.readyBody'),
            textAlign: TextAlign.center,
            style: context.textStyles.body,
          ),
        ],
      ),
    );
  }
}

class _StepActions extends StatelessWidget {
  const _StepActions({
    required this.copy,
    required this.controller,
    required this.scrollKey,
    required this.isLastStep,
    required this.onBack,
    required this.onNext,
  });

  final _IntroCopy copy;
  final ScrollController controller;
  final Key scrollKey;
  final bool isLastStep;
  final VoidCallback onBack;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppOutlinedButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: copy.back,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: isLastStep
              ? AppButton(
                  label: copy.startTasks,
                  onPressed: onNext,
                  icon: const Icon(Icons.play_arrow_rounded),
                )
              : LessonScrollContinueButton(
                  key: scrollKey,
                  controller: controller,
                  onContinue: onNext,
                ),
        ),
      ],
    );
  }
}

class _StaticTrafficLightScene extends StatelessWidget {
  const _StaticTrafficLightScene({
    this.highlightedNode,
    this.highlightedTransition,
    this.firstNodeKey,
    super.key,
  });

  final int? highlightedNode;
  final int? highlightedTransition;
  final Key? firstNodeKey;

  @override
  Widget build(BuildContext context) {
    final sceneHeight = (MediaQuery.sizeOf(context).height * 0.48).clamp(
      300.0,
      460.0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        var lightHeight = (sceneHeight * 0.3).clamp(104.0, 150.0);
        final maxHeightForWidth = (availableWidth * 0.22) / 0.42;
        if (lightHeight > maxHeightForWidth) {
          lightHeight = maxHeightForWidth;
        }
        final lightWidth = (lightHeight * 0.42).clamp(42.0, 178.0);
        final nodeRadius = lightHeight / 2;

        return FsmDiagram(
          height: sceneHeight,
          nodes: [
            FsmDiagramNode(
              center: const Offset(0.18, 0.25),
              width: lightWidth,
              radius: nodeRadius,
              child: _StaticTrafficLight(
                key: firstNodeKey,
                height: lightHeight,
                activeLamps: const [true, false, false],
                isHighlighted: highlightedNode == 0,
              ),
            ),
            FsmDiagramNode(
              center: const Offset(0.82, 0.25),
              width: lightWidth,
              radius: nodeRadius,
              child: _StaticTrafficLight(
                height: lightHeight,
                activeLamps: const [true, true, false],
                isHighlighted: highlightedNode == 1,
              ),
            ),
            FsmDiagramNode(
              center: const Offset(0.82, 0.75),
              width: lightWidth,
              radius: nodeRadius,
              child: _StaticTrafficLight(
                height: lightHeight,
                activeLamps: const [false, false, true],
                isHighlighted: highlightedNode == 2,
              ),
            ),
            FsmDiagramNode(
              center: const Offset(0.18, 0.75),
              width: lightWidth,
              radius: nodeRadius,
              child: _StaticTrafficLight(
                height: lightHeight,
                activeLamps: const [false, true, false],
                isHighlighted: highlightedNode == 3,
              ),
            ),
          ],
          transitions: [
            FsmDiagramTransition(
              from: 0,
              to: 1,
              color: _transitionColor(context, 0),
              label: null,
              isMuted: _isMutedTransition(0),
              isHighlighted: highlightedTransition == 0,
            ),
            FsmDiagramTransition(
              from: 1,
              to: 2,
              color: _transitionColor(context, 1),
              label: null,
              isMuted: _isMutedTransition(1),
              isHighlighted: highlightedTransition == 1,
            ),
            FsmDiagramTransition(
              from: 2,
              to: 3,
              color: _transitionColor(context, 2),
              label: null,
              isMuted: _isMutedTransition(2),
              isHighlighted: highlightedTransition == 2,
            ),
            FsmDiagramTransition(
              from: 3,
              to: 0,
              color: _transitionColor(context, 3),
              label: null,
              isMuted: _isMutedTransition(3),
              isHighlighted: highlightedTransition == 3,
            ),
          ],
          resetTransition: null,
        );
      },
    );
  }

  Color _transitionColor(BuildContext context, int index) {
    return highlightedTransition == null || highlightedTransition == index
        ? context.colors.primary
        : context.colors.mutedText;
  }

  bool _isMutedTransition(int index) {
    return highlightedTransition != index;
  }
}

class _StaticTrafficLight extends StatelessWidget {
  const _StaticTrafficLight({
    required this.height,
    required this.activeLamps,
    this.isHighlighted = false,
    this.highlightProgress = 1,
    super.key,
  });

  final double height;
  final List<bool> activeLamps;
  final bool isHighlighted;
  final double highlightProgress;

  @override
  Widget build(BuildContext context) {
    final lightHeight = height.clamp(86.0, 350.0);
    final lightWidth = (lightHeight * 0.42).clamp(42.0, 178.0);
    final lampSize = (lightWidth * 0.58).clamp(24.0, 104.0);
    final borderColor = isHighlighted
        ? Color.lerp(
            context.colors.primary,
            context.colors.text,
            1 - highlightProgress,
          )!
        : context.colors.border;
    final glowAlpha = isHighlighted ? 0.18 + highlightProgress * 0.22 : 0.0;

    return Container(
      width: lightWidth,
      height: lightHeight,
      padding: EdgeInsets.all(lightWidth * 0.13),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        border: Border.all(color: borderColor, width: isHighlighted ? 4 : 3),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? context.colors.primary.withValues(alpha: glowAlpha)
                : context.colors.shadow,
            blurRadius: isHighlighted ? 28 : 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StaticLamp(
            color: context.colors.danger,
            size: lampSize,
            isActive: activeLamps[0],
          ),
          _StaticLamp(
            color: context.colors.warning,
            size: lampSize,
            isActive: activeLamps[1],
          ),
          _StaticLamp(
            color: const Color(0xFF42D67A),
            size: lampSize,
            isActive: activeLamps[2],
          ),
        ],
      ),
    );
  }
}

class _StaticLamp extends StatelessWidget {
  const _StaticLamp({
    required this.color,
    required this.size,
    required this.isActive,
  });

  final Color color;
  final double size;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : context.colors.surface,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.34),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }
}

class _MascotLessonBubble extends StatelessWidget {
  const _MascotLessonBubble({required this.text, required this.step});

  final String text;
  final int step;

  @override
  Widget build(BuildContext context) {
    final pose = switch (step) {
      0 => MascotPose.speaking,
      1 => MascotPose.thinking,
      2 => MascotPose.speaking,
      _ => MascotPose.thinking,
    };

    return MascotLessonSpeech(
      message: text,
      pose: pose,
      animationId: 'intro-$step',
    );
  }
}

class _AnimatedTrafficFsmScene extends StatefulWidget {
  const _AnimatedTrafficFsmScene({
    required this.interactionHintSignal,
    required this.onInteractionComplete,
    super.key,
  });

  final int interactionHintSignal;
  final VoidCallback onInteractionComplete;

  @override
  State<_AnimatedTrafficFsmScene> createState() =>
      _AnimatedTrafficFsmSceneState();
}

class _AnimatedTrafficFsmSceneState extends State<_AnimatedTrafficFsmScene>
    with SingleTickerProviderStateMixin {
  static const _stateCount = 4;

  late final AnimationController _transitionController;
  bool _isAuto = true;
  bool _isTransitionRunning = false;
  int _currentNode = 0;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..addStatusListener(_handleTransitionStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startTransition();
    });
  }

  @override
  void dispose() {
    _transitionController
      ..removeStatusListener(_handleTransitionStatus)
      ..dispose();
    super.dispose();
  }

  void _handleTransitionStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;

    setState(() {
      _currentNode = (_currentNode + 1) % _stateCount;
      _isTransitionRunning = false;
    });
    widget.onInteractionComplete();
    _transitionController.reset();

    // Eine Vorführung ist endlich. Eine Wiederholung erfordert eine bewusste Aktion
    // über den Auto/Manuell-Schalter; eine endlose Animation ließe die Szene nie
    // zur Ruhe kommen und konkurrierte mit den Bedienelementen der Lektion.
  }

  void _setAuto(bool value) {
    setState(() => _isAuto = value);
    widget.onInteractionComplete();
    if (value) {
      if (_isTransitionRunning) {
        _transitionController.forward();
      } else {
        _startTransition();
      }
    } else {
      _transitionController.stop();
    }
  }

  void _startTransition() {
    if (!mounted || _transitionController.isAnimating) return;
    setState(() => _isTransitionRunning = true);
    _transitionController.forward(from: 0);
  }

  void _goToNextTransition() {
    setState(() {
      _isAuto = false;
      _currentNode = (_currentNode + 1) % _stateCount;
      _isTransitionRunning = false;
    });
    widget.onInteractionComplete();
    _transitionController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final sceneHeight = (MediaQuery.sizeOf(context).height * 0.52).clamp(
      330.0,
      500.0,
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: AnimatedBuilder(
        animation: _transitionController,
        builder: (context, _) {
          final pulse =
              0.82 +
              (math.sin(_transitionController.value * math.pi * 2) + 1) * 0.09;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.t('introFsm.ruleTitle'),
                    style: context.textStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  LessonInteractionHint(
                    signal: widget.interactionHintSignal,
                    child: _AutoSwitch(value: _isAuto, onChanged: _setAuto),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : MediaQuery.sizeOf(context).width;
                  var lightHeight = (sceneHeight * 0.3).clamp(104.0, 150.0);
                  final maxHeightForWidth = (availableWidth * 0.22) / 0.42;
                  if (lightHeight > maxHeightForWidth) {
                    lightHeight = maxHeightForWidth;
                  }
                  final lightWidth = (lightHeight * 0.42).clamp(42.0, 178.0);
                  final nodeRadius = lightHeight / 2;

                  return FsmDiagram(
                    height: sceneHeight,
                    nodes: [
                      _trafficNode(
                        center: const Offset(0.18, 0.25),
                        width: lightWidth,
                        radius: nodeRadius,
                        height: lightHeight,
                        activeLamps: const [true, false, false],
                        isHighlighted: _currentNode == 0,
                        highlightProgress: pulse,
                      ),
                      _trafficNode(
                        center: const Offset(0.82, 0.25),
                        width: lightWidth,
                        radius: nodeRadius,
                        height: lightHeight,
                        activeLamps: const [true, true, false],
                        isHighlighted: _currentNode == 1,
                        highlightProgress: pulse,
                      ),
                      _trafficNode(
                        center: const Offset(0.82, 0.75),
                        width: lightWidth,
                        radius: nodeRadius,
                        height: lightHeight,
                        activeLamps: const [false, false, true],
                        isHighlighted: _currentNode == 2,
                        highlightProgress: pulse,
                      ),
                      _trafficNode(
                        center: const Offset(0.18, 0.75),
                        width: lightWidth,
                        radius: nodeRadius,
                        height: lightHeight,
                        activeLamps: const [false, true, false],
                        isHighlighted: _currentNode == 3,
                        highlightProgress: pulse,
                      ),
                    ],
                    transitions: [
                      _trafficTransition(context, from: 0, to: 1),
                      _trafficTransition(context, from: 1, to: 2),
                      _trafficTransition(context, from: 2, to: 3),
                      _trafficTransition(context, from: 3, to: 0),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.t('introFsm.stateExplanation'),
                style: context.textStyles.caption,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: LessonInteractionHint(
                  signal: widget.interactionHintSignal,
                  child: AppOutlinedButton(
                    onPressed: _goToNextTransition,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: context.l10n.t('common.next'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FsmDiagramNode _trafficNode({
    required Offset center,
    required double width,
    required double radius,
    required double height,
    required List<bool> activeLamps,
    required bool isHighlighted,
    required double highlightProgress,
  }) {
    return FsmDiagramNode(
      center: center,
      width: width,
      radius: radius,
      child: _StaticTrafficLight(
        height: height,
        activeLamps: activeLamps,
        isHighlighted: isHighlighted,
        highlightProgress: highlightProgress,
      ),
    );
  }

  FsmDiagramTransition _trafficTransition(
    BuildContext context, {
    required int from,
    required int to,
  }) {
    final isActive = from == _currentNode;
    return FsmDiagramTransition(
      from: from,
      to: to,
      color: isActive ? context.colors.primary : context.colors.mutedText,
      isMuted: !isActive,
      isHighlighted: isActive,
      label: from.isEven
          ? FsmDiagramLabels.duration60
          : FsmDiagramLabels.duration10,
    );
  }
}

class _AutoSwitch extends StatelessWidget {
  const _AutoSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.t('introFsm.auto'),
          style: context.textStyles.caption,
        ),
        Switch(
          value: value,
          onChanged: AppHaptics.wrapSelection<bool>(onChanged),
          activeThumbColor: context.colors.primary,
        ),
      ],
    );
  }
}

class TrafficLightFsmScene extends StatelessWidget {
  const TrafficLightFsmScene({
    this.highlightedNode,
    this.highlightedTransition,
    this.highlightReset = false,
    super.key,
  });

  static const _diagramHeight = 330.0;
  static const _nodeRadius = 41.0;
  static const _nodeWidth = 82.0;

  final int? highlightedNode;
  final int? highlightedTransition;
  final bool highlightReset;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FsmDiagram(
            height: _diagramHeight,
            nodes: [
              FsmDiagramNode(
                center: Offset(0.16, 0.18),
                width: _nodeWidth,
                radius: _nodeRadius,
                child: _FsmState(
                  label: FsmDiagramLabels.red,
                  isHighlighted: _nodeIsHighlighted(0),
                  isMuted: _nodeIsMuted(0),
                ),
              ),
              FsmDiagramNode(
                center: Offset(0.84, 0.42),
                width: _nodeWidth,
                radius: _nodeRadius,
                child: _FsmState(
                  label: FsmDiagramLabels.redYellow,
                  isHighlighted: _nodeIsHighlighted(1),
                  isMuted: _nodeIsMuted(1),
                ),
              ),
              FsmDiagramNode(
                center: Offset(0.84, 0.82),
                width: _nodeWidth,
                radius: _nodeRadius,
                child: _FsmState(
                  label: FsmDiagramLabels.green,
                  isHighlighted: _nodeIsHighlighted(2),
                  isMuted: _nodeIsMuted(2),
                ),
              ),
              FsmDiagramNode(
                center: Offset(0.16, 0.75),
                width: _nodeWidth,
                radius: _nodeRadius,
                child: _FsmState(
                  label: FsmDiagramLabels.yellow,
                  isHighlighted: _nodeIsHighlighted(3),
                  isMuted: _nodeIsMuted(3),
                ),
              ),
            ],
            transitions: [
              FsmDiagramTransition(
                from: 0,
                to: 1,
                color: _transitionColor(context, 0),
                label: FsmDiagramLabels.duration60,
                isMuted: _transitionIsMuted(0),
                isHighlighted: highlightedTransition == 0,
              ),
              FsmDiagramTransition(
                from: 1,
                to: 2,
                color: _transitionColor(context, 1),
                label: FsmDiagramLabels.duration10,
                isMuted: _transitionIsMuted(1),
                isHighlighted: highlightedTransition == 1,
              ),
              FsmDiagramTransition(
                from: 2,
                to: 3,
                color: _transitionColor(context, 2),
                label: FsmDiagramLabels.duration60,
                isMuted: _transitionIsMuted(2),
                isHighlighted: highlightedTransition == 2,
              ),
              FsmDiagramTransition(
                from: 3,
                to: 0,
                color: _transitionColor(context, 3),
                label: FsmDiagramLabels.duration10,
                isMuted: _transitionIsMuted(3),
                isHighlighted: highlightedTransition == 3,
              ),
            ],
            resetTransition: FsmResetTransition(
              to: 0,
              label: FsmDiagramLabels.reset,
              color: highlightReset
                  ? context.colors.primary
                  : context.colors.mutedText,
              start: const Offset(0.03, 0.03),
              isMuted: !highlightReset,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.t('introFsm.fsmExplanation'),
            style: context.textStyles.caption,
          ),
        ],
      ),
    );
  }

  bool _nodeIsHighlighted(int index) {
    if (!_hasComponentFocus) return true;
    return highlightedNode == index;
  }

  bool _nodeIsMuted(int index) {
    return _hasComponentFocus && highlightedNode != index;
  }

  Color _transitionColor(BuildContext context, int index) {
    return !_hasComponentFocus || highlightedTransition == index
        ? context.colors.primary
        : context.colors.mutedText;
  }

  bool _transitionIsMuted(int index) {
    return _hasComponentFocus && highlightedTransition != index;
  }

  bool get _hasComponentFocus =>
      highlightReset ||
      highlightedNode != null ||
      highlightedTransition != null;
}

class _FsmState extends StatelessWidget {
  const _FsmState({
    required this.label,
    this.isHighlighted = true,
    this.isMuted = false,
  });

  final String label;
  final bool isHighlighted;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final borderColor = isMuted
        ? context.colors.mutedText
        : context.colors.primary;

    return Container(
      width: 82,
      height: 82,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: isHighlighted ? 4 : 3),
        boxShadow: [
          if (isHighlighted)
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroCopy {
  const _IntroCopy({
    required this.steps,
    required this.back,
    required this.next,
    required this.startTasks,
  });

  final List<String> steps;
  final String back;
  final String next;
  final String startTasks;
}

_IntroCopy _copyFor(BuildContext context) {
  final l10n = context.l10n;

  return _IntroCopy(
    steps: [
      l10n.t('introFsm.step.1'),
      l10n.t('introFsm.step.021'),
      l10n.t('introFsm.step.022'),
      l10n.t('introFsm.step.023'),
      l10n.t('introFsm.step.024'),
      l10n.t('introFsm.step.025'),
      l10n.t('introFsm.step.026'),
      l10n.t('introFsm.step.027'),
      l10n.t('introFsm.step.028'),
      l10n.t('introFsm.step.029'),
      l10n.t('introFsm.step.3'),
      l10n.t('introFsm.step.4'),
      l10n.t('introFsm.step.041'),
      l10n.t('introFsm.step.042'),
      l10n.t('introFsm.step.043'),
      l10n.t('introFsm.step.044'),
      l10n.t('introFsm.step.045'),
      l10n.t('introFsm.step.046'),
      l10n.t('introFsm.step.047'),
      l10n.t('introFsm.step.048'),
      l10n.t('introFsm.step.049'),
      l10n.t('introFsm.step.5'),
    ],
    back: l10n.t('common.back'),
    next: l10n.t('common.next'),
    startTasks: l10n.t('introFsm.startTasks'),
  );
}
