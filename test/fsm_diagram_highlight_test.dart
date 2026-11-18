import 'dart:math' as math;

import 'package:bachelor/app/theme/app_theme.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('highlighted FSM transition renders without painter errors', (
    tester,
  ) async {
    const highlightedTransition = FsmDiagramTransition(
      from: 0,
      to: 1,
      color: Colors.orange,
      label: 'timer',
      isHighlighted: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: FsmDiagram(
                height: 260,
                nodes: const [
                  FsmDiagramNode(
                    center: Offset(0.2, 0.5),
                    width: 64,
                    radius: 32,
                    child: _TestNode(),
                  ),
                  FsmDiagramNode(
                    center: Offset(0.8, 0.5),
                    width: 64,
                    radius: 32,
                    child: _TestNode(),
                  ),
                ],
                transitions: [highlightedTransition],
              ),
            ),
          ),
        ),
      ),
    );

    expect(highlightedTransition.isHighlighted, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long transition label fits a short arrow without truncation', (
    tester,
  ) async {
    const longLabel = 'VERY LONG INPUT / VERY LONG OUTPUT';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              child: FsmDiagram(
                height: 180,
                nodes: const [
                  FsmDiagramNode(
                    center: Offset(0.18, 0.5),
                    width: 54,
                    radius: 27,
                    child: _TestNode(),
                  ),
                  FsmDiagramNode(
                    center: Offset(0.82, 0.5),
                    width: 54,
                    radius: 27,
                    child: _TestNode(),
                  ),
                ],
                transitions: const [
                  FsmDiagramTransition(
                    from: 0,
                    to: 1,
                    color: Colors.orange,
                    label: longLabel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final diagram = tester.widget<FsmDiagram>(find.byType(FsmDiagram));
    expect(diagram.transitions.single.label, longLabel);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two labeled self-loops render around one Mealy state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              child: FsmDiagram(
                height: 210,
                nodes: const [
                  FsmDiagramNode(
                    center: Offset(0.5, 0.55),
                    width: 70,
                    radius: 35,
                    child: _TestNode(),
                  ),
                ],
                transitions: const [
                  FsmDiagramTransition(
                    from: 0,
                    to: 0,
                    color: Colors.orange,
                    label: 'person = 1 / OPEN',
                    curveSide: -1,
                  ),
                  FsmDiagramTransition(
                    from: 0,
                    to: 0,
                    color: Colors.blue,
                    label: 'person = 0 / CLOSE',
                    curveSide: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final diagram = tester.widget<FsmDiagram>(find.byType(FsmDiagram));
    expect(diagram.transitions, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('repeated self-loops are separated when no side is specified', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              child: FsmDiagram(
                height: 210,
                nodes: const [
                  FsmDiagramNode(
                    center: Offset(0.5, 0.55),
                    width: 70,
                    radius: 35,
                    child: _TestNode(),
                  ),
                ],
                transitions: const [
                  FsmDiagramTransition(
                    from: 0,
                    to: 0,
                    color: Colors.orange,
                    label: 'person = 1 / CLOSE DOOR',
                  ),
                  FsmDiagramTransition(
                    from: 0,
                    to: 0,
                    color: Colors.blue,
                    label: 'person = 0 / OPEN DOOR',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('wide transition keeps clearance from an unrelated node', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final diagramWidth in const [600.0, 760.0, 1000.0]) {
      await tester.binding.setSurfaceSize(Size(diagramWidth + 40, 320));
      final paintedPaths = <Path>[];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: diagramWidth,
                child: FsmDiagram(
                  height: 300,
                  debugOnTransitionPathPainted: paintedPaths.add,
                  nodes: const [
                    FsmDiagramNode(
                      center: Offset(0.12, 0.5),
                      width: 80,
                      radius: 40,
                      child: _TestNode(),
                    ),
                    FsmDiagramNode(
                      center: Offset(0.50, 0.5),
                      width: 80,
                      radius: 40,
                      child: SizedBox(
                        key: ValueKey('middle-node'),
                        width: 80,
                        height: 80,
                      ),
                    ),
                    FsmDiagramNode(
                      center: Offset(0.88, 0.5),
                      width: 80,
                      radius: 40,
                      child: _TestNode(),
                    ),
                  ],
                  transitions: const [
                    FsmDiagramTransition(
                      from: 0,
                      to: 2,
                      color: Colors.orange,
                      label: 'A = 0',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(paintedPaths, hasLength(1));
      final canvasBox = tester.renderObject<RenderBox>(
        find.descendant(
          of: find.byType(FsmDiagram),
          matching: find.byType(CustomPaint),
        ),
      );
      final middle = canvasBox.globalToLocal(
        tester.getCenter(find.byKey(const ValueKey('middle-node'))),
      );
      var minimumDistance = double.infinity;
      final metric = paintedPaths.single.computeMetrics().single;
      for (var offset = 0.0; offset <= metric.length; offset += 2) {
        final tangent = metric.getTangentForOffset(offset);
        if (tangent != null) {
          minimumDistance = math.min(
            minimumDistance,
            (tangent.position - middle).distance,
          );
        }
      }
      expect(
        minimumDistance,
        greaterThanOrEqualTo(58),
        reason: 'transition must clear the middle node at width $diagramWidth',
      );
    }
  });
}

class _TestNode extends StatelessWidget {
  const _TestNode();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 64, height: 64);
  }
}
