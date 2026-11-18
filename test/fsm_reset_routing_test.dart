import 'package:bachelor/app/theme/app_theme.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RESET arrow points into a looped node near the canvas edge', (
    tester,
  ) async {
    for (final targetX in [0.05, 0.5, 0.95]) {
      final reset = await _paintReset(tester, center: Offset(targetX, 0.55));
      final wings = reset.arrow.computeMetrics().toList();
      final tip = wings.first.getTangentForOffset(0)!.position;
      final base =
          (wings[0].getTangentForOffset(wings[0].length)!.position +
              wings[1].getTangentForOffset(wings[1].length)!.position) /
          2;
      final pointing = (tip - base) / (tip - base).distance;
      final towardNode = (reset.center - tip) / (reset.center - tip).distance;
      expect(
        pointing.dx * towardNode.dx + pointing.dy * towardNode.dy,
        greaterThan(0.99),
        reason: 'RESET must point into the initial state at x=$targetX',
      );
      final shaft = reset.path.computeMetrics().single;
      for (final distance in [4.0, 10.0, 18.0]) {
        final behind = shaft
            .getTangentForOffset(shaft.length - distance)!
            .position;
        expect(
          (behind - (tip - pointing * distance)).distance,
          lessThan(0.2),
          reason: 'RESET needs a visible straight shaft behind its arrowhead',
        );
      }
      final bounds = (Offset.zero & reset.size).deflate(2);
      for (final path in [reset.path, reset.arrow]) {
        for (final metric in path.computeMetrics()) {
          for (var i = 0; i <= 100; i++) {
            expect(
              bounds.contains(
                metric.getTangentForOffset(metric.length * i / 100)!.position,
              ),
              isTrue,
              reason:
                  'The entire RESET line and arrow must stay inside the canvas',
            );
          }
        }
      }
    }
  });
}

Future<({Path path, Path arrow, Offset center, Size size})> _paintReset(
  WidgetTester tester, {
  required Offset center,
}) async {
  ({Path path, Path arrow})? painted;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 240,
            child: FsmDiagram(
              height: 220,
              debugOnResetPainted: (value) => painted = value,
              nodes: [
                FsmDiagramNode(
                  center: center,
                  width: 76,
                  radius: 36,
                  child: Container(
                    key: const ValueKey('reset-target'),
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 4),
                    ),
                  ),
                ),
              ],
              transitions: const [
                FsmDiagramTransition(from: 0, to: 0, color: Colors.orange),
              ],
              resetTransition: const FsmResetTransition(
                to: 0,
                label: 'Reset',
                color: Colors.orange,
                start: Offset(0.05, 0.05),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(painted, isNotNull);
  final paintBox = tester.renderObject<RenderBox>(
    find.descendant(
      of: find.byType(FsmDiagram),
      matching: find.byType(CustomPaint),
    ),
  );
  final node = tester.renderObject<RenderBox>(
    find.byKey(const ValueKey('reset-target')),
  );
  return (
    path: painted!.path,
    arrow: painted!.arrow,
    center: paintBox.globalToLocal(
      node.localToGlobal(Offset(node.size.width / 2, 36)),
    ),
    size: paintBox.size,
  );
}
