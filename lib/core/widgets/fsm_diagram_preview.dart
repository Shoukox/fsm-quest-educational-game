import 'package:flutter/material.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';

/// Erzeugt eine schreibgeschützte Automatenvorschau mit optional markierten Zuständen und Kanten.
class FsmDiagramPreview extends StatelessWidget {
  const FsmDiagramPreview({
    required this.fsm,
    this.height,
    this.highlightedStateIds = const {},
    this.highlightedTransitionIds = const {},
    super.key,
  });

  final Fsm fsm;
  final double? height;
  final Set<String> highlightedStateIds;
  final Set<String> highlightedTransitionIds;

  @override
  Widget build(BuildContext context) {
    final count = fsm.states.length;
    final diagramHeight = height ?? (count > 3 ? 270 : 230);
    return FsmDiagram(
      height: diagramHeight,
      nodes: [
        for (var i = 0; i < count; i++)
          () {
            final state = fsm.states[i];
            final isHighlighted = highlightedStateIds.contains(state.id);
            return FsmDiagramNode(
              center: Offset(
                count == 1
                    ? .5
                    : count == 2
                    ? .34 + i * .32
                    : .18 + (i % 3) * .32,
                count <= 3 ? .5 : .25 + (i ~/ 3) * .5,
              ),
              width: 86,
              radius: 43,
              child: Container(
                width: 86,
                height: 86,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHighlighted
                      ? context.colors.primary.withValues(alpha: .14)
                      : context.colors.surfaceRaised,
                  border: Border.all(
                    color: context.colors.primary,
                    width: isHighlighted ? 5 : 3,
                  ),
                ),
                child: Text(
                  fsm.outputMode == FsmOutputMode.moore &&
                          state.output.isNotEmpty
                      ? '${state.label}\nY=${state.output}'
                      : state.label,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }(),
      ],
      transitions: [
        for (final transition in fsm.transitions)
          FsmDiagramTransition(
            from: fsm.states.indexWhere((s) => s.id == transition.fromStateId),
            to: fsm.states.indexWhere((s) => s.id == transition.toStateId),
            color: context.colors.primary,
            label: transition.symbol,
            isHighlighted: highlightedTransitionIds.contains(transition.id),
            isMuted:
                highlightedTransitionIds.isNotEmpty &&
                !highlightedTransitionIds.contains(transition.id),
          ),
      ],
    );
  }
}
