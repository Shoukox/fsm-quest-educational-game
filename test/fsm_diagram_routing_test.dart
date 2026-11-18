import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bachelor/app/theme/app_theme.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:bachelor/features/lesson/data/lesson_local_data_source.dart';
import 'package:bachelor/features/lesson/domain/models/task_payload.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    if (const bool.fromEnvironment('FSM_CAPTURE')) {
      final fontFile = File('C:/Windows/Fonts/arial.ttf');
      if (await fontFile.exists()) {
        final bytes = await fontFile.readAsBytes();
        await (FontLoader(
          'FsmQa',
        )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      }
    }
  });
  testWidgets('chapter 2 reciprocal transitions have separate visible lanes', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final width in [760.0, 280.0, 360.0, 600.0, 1000.0]) {
      final diagram = await _paintChapterDiagram(tester, width);
      final forward = diagram.paths[(0, 2)]!.computeMetrics().single;
      final backward = diagram.paths[(2, 0)]!.computeMetrics().single;
      final forwardMiddle = forward.getTangentForOffset(forward.length / 2)!;
      final backwardMiddle = backward.getTangentForOffset(backward.length / 2)!;
      expect(
        (forwardMiddle.position - backwardMiddle.position).distance *
            diagram.scale,
        greaterThanOrEqualTo(32),
        reason: 's0->s2 and s2->s0 must not merge at width $width',
      );
      _expectClearDiagram(diagram, 'width $width');
    }
  });

  testWidgets(
    'routing still separates edges when transition order is reversed',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final width in [280.0, 760.0]) {
        final diagram = await _paintChapterDiagram(
          tester,
          width,
          reverse: true,
        );
        _expectClearDiagram(diagram, 'reversed, width $width');
      }
    },
  );

  testWidgets('highlight changes do not move nodes or reroute other edges', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final initial = await _paintChapterDiagram(tester, 600);
    final highlighted = await _paintChapterDiagram(
      tester,
      600,
      highlight: true,
    );
    expect(highlighted.centers, initial.centers);
    expect(highlighted.labels, initial.labels);
    for (final edge in initial.paths.keys) {
      final before = _samplePath(initial.paths[edge]!);
      final after = _samplePath(highlighted.paths[edge]!);
      expect(after, before);
    }
  });
}

void _expectClearDiagram(_DiagramSnapshot diagram, String reason) {
  final bounds = Offset.zero & diagram.size;
  expect(diagram.labels, hasLength(6));
  for (var i = 0; i < diagram.labels.length; i++) {
    final label = diagram.labels[i];
    expect(
      bounds.contains(label.topLeft) && bounds.contains(label.bottomRight),
      isTrue,
      reason: '$reason: clipped label $i',
    );
    for (var j = i + 1; j < diagram.labels.length; j++) {
      expect(
        label.inflate(2).overlaps(diagram.labels[j]),
        isFalse,
        reason: '$reason: labels $i and $j overlap',
      );
    }
    for (final node in diagram.centers) {
      final closest = Offset(
        node.dx.clamp(label.left, label.right).toDouble(),
        node.dy.clamp(label.top, label.bottom).toDouble(),
      );
      expect(
        (node - closest).distance,
        greaterThanOrEqualTo(40),
        reason: '$reason: label $i overlaps a node',
      );
    }
  }
  for (final entry in diagram.paths.entries) {
    final samples = _samplePath(entry.value);
    final (from, to) = entry.key;
    expect(
      (samples.first - diagram.centers[from]).distance,
      closeTo(42, 0.5),
      reason: '$reason: wrong source port',
    );
    expect(
      (samples.last - diagram.centers[to]).distance,
      closeTo(46, 0.5),
      reason: '$reason: wrong target port',
    );
    for (final point in samples) {
      expect(
        bounds.contains(point),
        isTrue,
        reason: '$reason: clipped path ${entry.key}',
      );
      for (var i = 0; i < diagram.centers.length; i++) {
        if (i == from || i == to) continue;
        expect(
          (point - diagram.centers[i]).distance,
          greaterThanOrEqualTo(54),
          reason: '$reason: ${entry.key} hits unrelated node $i',
        );
      }
    }
  }
  final edges = diagram.paths.values.toList();
  for (var i = 0; i < edges.length; i++) {
    final points = _samplePath(edges[i]);
    for (var j = i + 1; j < edges.length; j++) {
      final other = _samplePath(edges[j]);
      var clearance = double.infinity;
      for (final point in points) {
        if (diagram.centers.any((center) => (point - center).distance < 56)) {
          continue;
        }
        for (final candidate in other) {
          clearance = math.min(clearance, (point - candidate).distance);
        }
      }
      expect(
        clearance * diagram.scale,
        greaterThanOrEqualTo(8),
        reason: '$reason: paths $i and $j overlap',
      );
    }
  }
}

List<Offset> _samplePath(Path path) {
  final metric = path.computeMetrics().single;
  final count = (metric.length / 2).ceil();
  return [
    for (var i = 0; i <= count; i++)
      metric.getTangentForOffset(metric.length * i / count)!.position,
  ];
}

class _DiagramSnapshot {
  const _DiagramSnapshot(
    this.paths,
    this.labels,
    this.centers,
    this.size,
    this.scale,
  );
  final Map<(int, int), Path> paths;
  final List<Rect> labels;
  final List<Offset> centers;
  final Size size;
  final double scale;
}

Future<_DiagramSnapshot> _paintChapterDiagram(
  WidgetTester tester,
  double width, {
  bool reverse = false,
  bool highlight = false,
}) async {
  final lesson = const LessonLocalDataSource().getLessonById('chapter_2')!;
  final fsm =
      (lesson.tasks.firstWhere((task) => task.id == 'chapter2-trace').payload!
              as Aa7TraceStatePayload)
          .fsm;
  final indexes = {
    for (var i = 0; i < fsm.states.length; i++) fsm.states[i].id: i,
  };
  final paths = <Path>[];
  final labels = <Rect>[];
  final transitions = reverse
      ? fsm.transitions.reversed.toList()
      : fsm.transitions;
  final boundaryKey = GlobalKey();
  await tester.binding.setSurfaceSize(Size(width, 300));
  await tester.pumpWidget(
    MaterialApp(
      theme: const bool.fromEnvironment('FSM_CAPTURE')
          ? AppTheme.dark().copyWith(
              textTheme: AppTheme.dark().textTheme.apply(fontFamily: 'FsmQa'),
            )
          : AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: FsmDiagram(
              height: 260,
              debugOnTransitionPathPainted: paths.add,
              debugOnTransitionLabelPainted: labels.add,
              nodes: [
                for (final state in fsm.states)
                  FsmDiagramNode(
                    center: Offset(state.x, state.y),
                    width: 76,
                    radius: 36,
                    child: Container(
                      key: ValueKey(state.id),
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xff201c19),
                        border: Border.all(color: Colors.orange, width: 4),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.id,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'y = ${state.output}',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
              transitions: [
                for (final transition in transitions)
                  FsmDiagramTransition(
                    from: indexes[transition.fromStateId]!,
                    to: indexes[transition.toStateId]!,
                    label: transition.symbol,
                    color: Colors.orange,
                    isHighlighted: highlight && transition.fromStateId == 's0',
                  ),
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
  if (const bool.fromEnvironment('FSM_CAPTURE') && !reverse && !highlight) {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundaryKey),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/fsm-layout/chapter2-${width.toInt()}.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
  }
  final paintBox = tester.renderObject<RenderBox>(
    find.descendant(
      of: find.byType(FsmDiagram),
      matching: find.byType(CustomPaint),
    ),
  );
  final pairs = [
    for (final edge in transitions)
      if (edge.fromStateId != edge.toStateId)
        (indexes[edge.fromStateId]!, indexes[edge.toStateId]!),
  ];
  final centers = <Offset>[];
  for (final state in fsm.states) {
    final node = tester.renderObject<RenderBox>(find.byKey(ValueKey(state.id)));
    centers.add(
      paintBox.globalToLocal(
        node.localToGlobal(Offset(node.size.width / 2, 36)),
      ),
    );
  }
  final scale =
      (paintBox.localToGlobal(const Offset(1, 0)) -
              paintBox.localToGlobal(Offset.zero))
          .distance;
  return _DiagramSnapshot(
    {for (var i = 0; i < pairs.length; i++) pairs[i]: paths[i]},
    labels,
    centers,
    paintBox.size,
    scale,
  );
}
