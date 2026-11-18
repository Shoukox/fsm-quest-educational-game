import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/digital_gate_diagram.dart';
import 'package:bachelor/core/widgets/preserve_scroll_position.dart';
import 'package:bachelor/features/lesson/domain/logic/digital_gate_logic.dart';
import 'package:bachelor/core/widgets/circuit_diagram.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_interaction_hint.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_scroll_continue_button.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_lesson_speech.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wiederholt Gatter, Negation, Flipflops und Takt mit bedienbaren Beispielen vor der Schaltungslektion.
class DigitalGatesReviewStory extends StatefulWidget {
  const DigitalGatesReviewStory({
    required this.onFinished,
    this.onProgressChanged,
    super.key,
  });

  final VoidCallback onFinished;
  final ValueChanged<double>? onProgressChanged;

  @override
  State<DigitalGatesReviewStory> createState() =>
      _DigitalGatesReviewStoryState();
}

class _DigitalGatesReviewStoryState extends State<DigitalGatesReviewStory> {
  static const _steps = [
    'chapter2Gates.intro',
    'chapter2Gates.xor',
    'chapter2Gates.andBubble',
    'chapter2Gates.andNot',
    'chapter2Gates.flipFlop',
    'chapter2Gates.clock',
    'chapter2Gates.summary',
  ];

  final _scrollController = ScrollController();
  int _step = 0;
  bool _checked = false;
  final _completedInteractiveSteps = <int>{};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _step == _steps.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  key: const PageStorageKey('chapter2-gates-review-scroll'),
                  controller: _scrollController,
                  children: [
                    MascotLessonSpeech(
                      message: context.l10n.t(_steps[_step]),
                      pose: isLast ? MascotPose.celebrate : MascotPose.speaking,
                      animationId: 'chapter2-gates-$_step',
                    ),
                    const SizedBox(height: 14),
                    _scene(context),
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
                  label: context.l10n.t('common.back'),
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previous,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: isLast
                  ? AppButton(
                      label: context.l10n.t('chapter2Gates.startLesson'),
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: widget.onFinished,
                    )
                  : LessonScrollContinueButton(
                      key: ValueKey('chapter2-gates-scroll-next-$_step'),
                      controller: _scrollController,
                      onContinue: _handleNext,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _scene(BuildContext context) {
    return switch (_step) {
      0 => _IntroScene(
        onContinue: () {
          _completeCurrentInteraction();
          _next();
        },
      ),
      1 => _XorScene(
        key: const ValueKey('xor-scene'),
        onInteractionComplete: _completeCurrentInteraction,
      ),
      2 => _AndBubbleScene(
        key: const ValueKey('and-bubble-scene'),
        onInteractionComplete: _completeCurrentInteraction,
      ),
      3 => _AndNotScene(
        key: const ValueKey('and-not-scene'),
        onInteractionComplete: _completeCurrentInteraction,
      ),
      4 => _FlipFlopScene(onCheck: _checkCurrent, checked: _checked),
      5 => _ClockScene(onCheck: _checkCurrent, checked: _checked),
      _ => const _SummaryScene(),
    };
  }

  void _checkCurrent() {
    AppHaptics.success();
    setState(() {
      _checked = true;
      _completedInteractiveSteps.add(_step);
    });
  }

  void _completeCurrentInteraction() {
    if (_completedInteractiveSteps.contains(_step)) return;
    setState(() => _completedInteractiveSteps.add(_step));
  }

  void _handleNext() {
    const interactiveSteps = {0, 1, 2, 3, 4, 5};
    if (interactiveSteps.contains(_step) &&
        !_completedInteractiveSteps.contains(_step)) {
      showLessonInteractionPrompt(context, _scrollController);
      return;
    }
    _next();
  }

  void _next() {
    if (_step >= _steps.length - 1) return;
    setState(() {
      _step++;
      _checked = false;
    });
    widget.onProgressChanged?.call(_step / (_steps.length - 1));
    _scrollController.jumpTo(0);
  }

  void _previous() {
    if (_step == 0) return;
    setState(() {
      _step--;
      _checked = false;
    });
    widget.onProgressChanged?.call(_step / (_steps.length - 1));
    _scrollController.jumpTo(0);
  }
}

class _SummaryScene extends StatelessWidget {
  const _SummaryScene();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const CircuitDiagram(),
          const SizedBox(height: 12),
          Text(
            context.l10n.t('chapter2Gates.summaryCard'),
            style: context.textStyles.body,
          ),
        ],
      ),
    );
  }
}

class _IntroScene extends StatelessWidget {
  const _IntroScene({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const CircuitDiagram(),
          const SizedBox(height: 12),
          Text(
            context.l10n.t('chapter2Gates.introCard'),
            style: context.textStyles.body,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: context.l10n.t('chapter2Gates.showSignal'),
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _XorScene extends StatefulWidget {
  const _XorScene({required this.onInteractionComplete, super.key});

  final VoidCallback onInteractionComplete;

  @override
  State<_XorScene> createState() => _XorSceneState();
}

class _XorSceneState extends State<_XorScene> {
  final _inputs = _TwoInputModel(first: 0, second: 1);

  @override
  void dispose() {
    _inputs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GateCard(
      title: context.l10n.t('chapter2Gates.xorTitle'),
      explanation: context.l10n.t('chapter2Gates.xorBody'),
      diagram: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _inputs,
          builder: (context, _) {
            final output = DigitalGateLogic.evaluate(DigitalGateType.xor, [
              _inputs.first,
              _inputs.second,
            ]);
            return DigitalGateDiagram(
              type: DigitalGateType.xor,
              inputs: [_inputs.first, _inputs.second],
              inputLabels: const ['A', 'S₀'],
              outputLabel: 'Y',
              label: 'XOR = $output',
            );
          },
        ),
      ),
      extra: AnimatedBuilder(
        animation: _inputs,
        builder: (context, _) => _TruthTable(
          type: DigitalGateType.xor,
          activeInputs: [_inputs.first, _inputs.second],
          inputLabels: const ['A', 'S₀'],
          outputLabel: 'Y',
        ),
      ),
      controls: [
        _ListenableBitChoice(
          label: 'A',
          value: _inputs.firstListenable,
          onChanged: (value) {
            _inputs.setFirst(value);
            widget.onInteractionComplete();
          },
        ),
        _ListenableBitChoice(
          label: 'S₀',
          value: _inputs.secondListenable,
          onChanged: (value) {
            _inputs.setSecond(value);
            widget.onInteractionComplete();
          },
        ),
      ],
    );
  }
}

class _AndBubbleScene extends StatefulWidget {
  const _AndBubbleScene({required this.onInteractionComplete, super.key});

  final VoidCallback onInteractionComplete;

  @override
  State<_AndBubbleScene> createState() => _AndBubbleSceneState();
}

class _AndBubbleSceneState extends State<_AndBubbleScene> {
  final _inputs = _TwoInputModel(first: 0, second: 1);

  @override
  void dispose() {
    _inputs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GateCard(
      title: context.l10n.t('chapter2Gates.andBubbleTitle'),
      explanation: context.l10n.t('chapter2Gates.andBubbleBody'),
      diagram: AnimatedBuilder(
        animation: _inputs,
        builder: (context, _) {
          final inverted = DigitalGateLogic.evaluate(DigitalGateType.not, [
            _inputs.first,
          ]);
          final output = DigitalGateLogic.evaluate(DigitalGateType.and, [
            inverted,
            _inputs.second,
          ]);
          return DigitalGateDiagram(
            type: DigitalGateType.and,
            inputs: [_inputs.first, _inputs.second],
            inputLabels: const ['A', 'S₁'],
            inputInverted: const [true, false],
            outputLabel: 'Y',
            label: 'Ā ∧ S₁ = Y ($output)',
          );
        },
      ),
      controls: [
        _ListenableBitChoice(
          label: 'A',
          value: _inputs.firstListenable,
          onChanged: (value) {
            _inputs.setFirst(value);
            widget.onInteractionComplete();
          },
        ),
        _ListenableBitChoice(
          label: 'S₁',
          value: _inputs.secondListenable,
          onChanged: (value) {
            _inputs.setSecond(value);
            widget.onInteractionComplete();
          },
        ),
      ],
    );
  }
}

class _AndNotScene extends StatefulWidget {
  const _AndNotScene({required this.onInteractionComplete, super.key});

  final VoidCallback onInteractionComplete;

  @override
  State<_AndNotScene> createState() => _AndNotSceneState();
}

class _AndNotSceneState extends State<_AndNotScene> {
  final _inputs = _TwoInputModel(first: 0, second: 1);

  @override
  void dispose() {
    _inputs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GateCard(
      title: context.l10n.t('chapter2Gates.andNotTitle'),
      explanation: context.l10n.t('chapter2Gates.andNotBody'),
      diagram: AnimatedBuilder(
        animation: _inputs,
        builder: (context, _) {
          final inverted = DigitalGateLogic.evaluate(DigitalGateType.not, [
            _inputs.first,
          ]);
          final output = DigitalGateLogic.evaluate(DigitalGateType.and, [
            inverted,
            _inputs.second,
          ]);
          return NotAndGateChainDiagram(
            input: _inputs.first,
            andInput: _inputs.second,
            label: 'S₁′ = $output',
          );
        },
      ),
      extra: AnimatedBuilder(
        animation: _inputs,
        builder: (context, _) {
          final inverted = DigitalGateLogic.evaluate(DigitalGateType.not, [
            _inputs.first,
          ]);
          return _TruthTable(
            type: DigitalGateType.and,
            activeInputs: [inverted, _inputs.second],
            inputLabels: const ['Ā', 'S₁'],
            outputLabel: 'S₁′',
          );
        },
      ),
      controls: [
        _ListenableBitChoice(
          label: 'A',
          value: _inputs.firstListenable,
          onChanged: (value) {
            _inputs.setFirst(value);
            widget.onInteractionComplete();
          },
        ),
        _ListenableBitChoice(
          label: 'S₁',
          value: _inputs.secondListenable,
          onChanged: (value) {
            _inputs.setSecond(value);
            widget.onInteractionComplete();
          },
        ),
      ],
    );
  }
}

class _FlipFlopScene extends StatefulWidget {
  const _FlipFlopScene({required this.onCheck, required this.checked});

  final VoidCallback onCheck;
  final bool checked;

  @override
  State<_FlipFlopScene> createState() => _FlipFlopSceneState();
}

class _FlipFlopSceneState extends State<_FlipFlopScene> {
  int? _selected;
  bool _clocked = false;

  @override
  Widget build(BuildContext context) {
    final value = _selected ?? 0;
    return _GateCard(
      title: context.l10n.t('chapter2Gates.flipFlopTitle'),
      explanation: context.l10n.t('chapter2Gates.flipFlopBody'),
      diagram: FlipFlopDiagram(input: value, output: _clocked ? value : 0),
      controls: [
        Text(context.l10n.t('chapter2Gates.flipFlopPrompt')),
        for (final option in [0, 1])
          ChoiceChip(
            label: Text('$option'),
            selected: _selected == option,
            onSelected: widget.checked
                ? null
                : (_) => setState(() => _selected = option),
          ),
        AppButton(
          label: _clocked
              ? context.l10n.t('chapter2Gates.flipFlopApplied')
              : context.l10n.t('chapter2Gates.flipFlopApply'),
          onPressed: widget.checked || _selected == null
              ? null
              : () {
                  setState(() => _clocked = true);
                  widget.onCheck();
                },
        ),
      ],
    );
  }
}

class _ClockScene extends StatefulWidget {
  const _ClockScene({required this.onCheck, required this.checked});
  final VoidCallback onCheck;
  final bool checked;

  @override
  State<_ClockScene> createState() => _ClockSceneState();
}

class _ClockSceneState extends State<_ClockScene> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return _GateCard(
      title: context.l10n.t('chapter2Gates.clockTitle'),
      explanation: context.l10n.t('chapter2Gates.clockBody'),
      diagram: Column(
        children: [
          const ClockStorageDiagram(calculatedBits: [1, 0], storedBits: [1, 0]),
        ],
      ),
      controls: [
        Text(context.l10n.t('chapter2Gates.clockPrompt')),
        for (final option in [0, 1, 2])
          ChoiceChip(
            label: _ScrollableChoiceLabel(
              text: context.l10n.t('chapter2Gates.clockChoice$option'),
            ),
            selected: _selected == option,
            onSelected: widget.checked
                ? null
                : (_) => setState(() => _selected = option),
          ),
        AppButton(
          label: widget.checked
              ? context.l10n.t('chapter2Gates.checked')
              : context.l10n.t('chapter2Gates.check'),
          onPressed: widget.checked || _selected != 1 ? null : widget.onCheck,
        ),
      ],
    );
  }
}

class _ScrollableChoiceLabel extends StatefulWidget {
  const _ScrollableChoiceLabel({required this.text});

  final String text;

  @override
  State<_ScrollableChoiceLabel> createState() => _ScrollableChoiceLabelState();
}

class _ScrollableChoiceLabelState extends State<_ScrollableChoiceLabel> {
  final ScrollController _controller = ScrollController();
  bool _scrolling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runMarquee() async {
    if (_scrolling || !_controller.hasClients) return;
    _scrolling = true;

    await Future.delayed(const Duration(milliseconds: 600));

    while (mounted && _controller.hasClients) {
      final maxExtent = _controller.position.maxScrollExtent;
      if (maxExtent <= 0) break;

      final duration = Duration(
        milliseconds: (maxExtent * 30).clamp(800, 6000).toInt(),
      );

      await _controller.animateTo(
        maxExtent,
        duration: duration,
        curve: Curves.linear,
      );
      if (!mounted || !_controller.hasClients) break;
      await Future.delayed(const Duration(milliseconds: 600));

      await _controller.animateTo(0, duration: duration, curve: Curves.linear);
      if (!mounted || !_controller.hasClients) break;
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _scrolling = false;
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = (MediaQuery.sizeOf(context).width - 72)
        .clamp(120.0, 420.0)
        .toDouble();

    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: DefaultTextStyle.of(context).style,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    final overflows = textPainter.width > maxWidth;

    // Der Text passt: Er wird unverändert übergeben, der Chip passt sich dem Inhalt an.
    if (!overflows) {
      return Text(widget.text, softWrap: false, maxLines: 1);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _runMarquee());

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(widget.text, softWrap: false, maxLines: 1),
      ),
    );
  }
}

class _GateCard extends StatelessWidget {
  const _GateCard({
    required this.title,
    required this.explanation,
    required this.diagram,
    required this.controls,
    this.extra,
  });
  final String title;
  final String explanation;
  final Widget diagram;
  final List<Widget> controls;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.textStyles.heading),
          const SizedBox(height: 8),
          Text(explanation, style: context.textStyles.body),
          const SizedBox(height: 12),
          diagram,
          if (extra != null) ...[const SizedBox(height: 10), extra!],
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 8, children: controls),
        ],
      ),
    );
  }
}

class _TruthTable extends StatelessWidget {
  const _TruthTable({
    required this.type,
    required this.activeInputs,
    required this.inputLabels,
    required this.outputLabel,
  });
  final DigitalGateType type;
  final List<int> activeInputs;
  final List<String> inputLabels;
  final String outputLabel;

  @override
  Widget build(BuildContext context) {
    final rows = type == DigitalGateType.xor
        ? const [
            [0, 0],
            [0, 1],
            [1, 0],
            [1, 1],
          ]
        : const [
            [0, 0],
            [0, 1],
            [1, 0],
            [1, 1],
          ];
    return DataTable(
      headingRowHeight: 32,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 32,
      horizontalMargin: 8,
      columnSpacing: 14,
      columns: [
        DataColumn(label: Text(inputLabels[0])),
        DataColumn(label: Text(inputLabels[1])),
        DataColumn(label: Text(outputLabel)),
      ],
      rows: [
        for (final row in rows)
          DataRow(
            selected: listEquals(row, activeInputs),
            cells: [
              DataCell(Text('${row[0]}')),
              DataCell(Text('${row[1]}')),
              DataCell(Text('${DigitalGateLogic.evaluate(type, row)}')),
            ],
          ),
      ],
    );
  }
}

class _TwoInputModel extends ChangeNotifier {
  _TwoInputModel({required int first, required int second})
    : firstListenable = ValueNotifier(first),
      secondListenable = ValueNotifier(second);

  final ValueNotifier<int> firstListenable;
  final ValueNotifier<int> secondListenable;

  int get first => firstListenable.value;
  int get second => secondListenable.value;

  void setFirst(int value) {
    if (first == value) return;
    firstListenable.value = value;
    notifyListeners();
  }

  void setSecond(int value) {
    if (second == value) return;
    secondListenable.value = value;
    notifyListeners();
  }

  @override
  void dispose() {
    firstListenable.dispose();
    secondListenable.dispose();
    super.dispose();
  }
}

class _ListenableBitChoice extends StatelessWidget {
  const _ListenableBitChoice({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final ValueListenable<int> value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: value,
      builder: (context, current, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label =', style: context.textStyles.body),
          const SizedBox(width: 6),
          for (final bit in [0, 1])
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ChoiceChip(
                label: Text('$bit'),
                selected: current == bit,
                onSelected: (_) {
                  AppHaptics.selection();
                  preserveScrollablePosition(context, () => onChanged(bit));
                },
              ),
            ),
        ],
      ),
    );
  }
}
