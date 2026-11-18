import 'dart:math' as math;

import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Zeichnet kleine Lehrdiagramme mit bis zu zehn Zustandsknoten und gerouteten Übergängen.
/// Knoteninhalt und Positionen kommen vom Aufrufer; Kanten, Schleifen und Beschriftungen
/// werden gemeinsam angeordnet und bei schmaler Ansicht als ganze Zeichnung skaliert.
class FsmDiagram extends StatelessWidget {
  const FsmDiagram({
    required this.height,
    required this.nodes,
    required this.transitions,
    this.resetTransition,
    this.debugOnTransitionPathPainted,
    this.debugOnTransitionLabelPainted,
    this.debugOnResetPainted,
    super.key,
  }) : assert(nodes.length <= 10, 'FsmDiagram supports up to 10 nodes');

  final double height;
  final List<FsmDiagramNode> nodes;
  final List<FsmDiagramTransition> transitions;
  final FsmResetTransition? resetTransition;
  @visibleForTesting
  final ValueChanged<Path>? debugOnTransitionPathPainted;
  @visibleForTesting
  final ValueChanged<Rect>? debugOnTransitionLabelPainted;
  @visibleForTesting
  final ValueChanged<({Path path, Path arrow})>? debugOnResetPainted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ein Diagramm mit fester Höhe darf seine Sehnen nicht unbegrenzt strecken.
          // Die vorgegebene Anordnung bleibt erhalten und wird im begrenzten Zeichenbereich zentriert.
          final width = math.min(constraints.maxWidth, height * 2.4);
          // Unterhalb dieser Breite wird die gesamte Zeichnung (einschließlich Kindelementen
          // und Trefferflächen) gemeinsam skaliert, statt Knoten fester Größe zu stauchen.
          final layoutWidth = nodes.length >= 3
              ? math.max(360.0, width)
              : width;
          final layoutHeight = width > 0
              ? height * layoutWidth / width
              : height;
          final routedTransitions = _routeTransitions(transitions);
          final metrics = _layoutNodes(
            nodes,
            routedTransitions,
            layoutWidth,
            layoutHeight,
            resetTransition,
          );

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: height,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: layoutWidth,
                  height: layoutHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _FsmDiagramPainter(
                            nodes: metrics,
                            transitions: routedTransitions,
                            resetTransition: resetTransition,
                            colors: context.colors,
                            textStyles: context.textStyles,
                            fontFamily: Theme.of(
                              context,
                            ).textTheme.bodySmall?.fontFamily,
                            debugOnTransitionPathPainted:
                                debugOnTransitionPathPainted,
                            debugOnTransitionLabelPainted:
                                debugOnTransitionLabelPainted,
                            debugOnResetPainted: debugOnResetPainted,
                          ),
                        ),
                      ),
                      for (var i = 0; i < nodes.length; i++)
                        Positioned(
                          left: metrics[i].left,
                          top: metrics[i].top,
                          width: nodes[i].width,
                          child: nodes[i].child,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Beschreibt Mittelpunkt, Zeichenmaße und Widget-Inhalt eines Zustandsknotens.
class FsmDiagramNode {
  const FsmDiagramNode({
    required this.center,
    required this.width,
    required this.radius,
    required this.child,
  });

  final Offset center;
  final double width;
  final double radius;
  final Widget child;
}

/// Verbindet zwei Knotenindizes mit Beschriftung, Farbe und optionaler Kurvenvorgabe.
class FsmDiagramTransition {
  const FsmDiagramTransition({
    required this.from,
    required this.to,
    required this.color,
    this.label,
    this.isMuted = false,
    this.isHighlighted = false,
    this.curveDepth,
    this.curveSide,
  }) : assert(
         curveDepth == null || curveDepth >= 0.05 && curveDepth <= 0.48,
         'curveDepth must be between 0.05 and 0.48',
       ),
       assert(
         curveSide == null || curveSide == -1 || curveSide == 1,
         'curveSide must be -1 or 1',
       );

  final int from;
  final int to;
  final Color color;
  final String? label;
  final bool isMuted;
  final bool isHighlighted;
  final double? curveDepth;
  final int? curveSide;

  FsmDiagramTransition copyWithRouting({double? curveDepth, int? curveSide}) {
    return FsmDiagramTransition(
      from: from,
      to: to,
      color: color,
      label: label,
      isMuted: isMuted,
      isHighlighted: isHighlighted,
      curveDepth: curveDepth ?? this.curveDepth,
      curveSide: curveSide ?? this.curveSide,
    );
  }
}

List<FsmDiagramTransition> _routeTransitions(
  List<FsmDiagramTransition> transitions,
) {
  return [
    for (var index = 0; index < transitions.length; index++)
      _routeTransition(transitions, index),
  ];
}

FsmDiagramTransition _routeTransition(
  List<FsmDiagramTransition> transitions,
  int index,
) {
  final transition = transitions[index];
  if (transition.from == transition.to) {
    if (transition.curveSide != null) return transition;

    final relatedSelfLoopIndexes = <int>[
      for (
        var candidateIndex = 0;
        candidateIndex < transitions.length;
        candidateIndex++
      )
        if (transitions[candidateIndex].from == transition.from &&
            transitions[candidateIndex].to == transition.to)
          candidateIndex,
    ];
    if (relatedSelfLoopIndexes.length <= 1) return transition;

    final lane = relatedSelfLoopIndexes.indexOf(index);
    return transition.copyWithRouting(curveSide: lane.isEven ? -1 : 1);
  }

  final relatedIndexes = <int>[
    for (
      var candidateIndex = 0;
      candidateIndex < transitions.length;
      candidateIndex++
    )
      if (_connectsSameNodePair(transition, transitions[candidateIndex]))
        candidateIndex,
  ];
  if (relatedIndexes.length <= 1) return transition;

  final lane = relatedIndexes.indexOf(index);
  final physicalSide = lane.isEven ? -1 : 1;
  final depthLevel = lane ~/ 2;
  final directionSign = transition.from < transition.to ? 1 : -1;
  return transition.copyWithRouting(
    curveDepth:
        transition.curveDepth ??
        (0.24 + depthLevel * 0.10).clamp(0.05, 0.48).toDouble(),
    curveSide: transition.curveSide ?? physicalSide * directionSign,
  );
}

bool _connectsSameNodePair(
  FsmDiagramTransition first,
  FsmDiagramTransition second,
) {
  return first.from == second.from && first.to == second.to ||
      first.from == second.to && first.to == second.from;
}

/// Separater Startpfeil von außerhalb des Diagramms zum angegebenen Knotenindex.
class FsmResetTransition {
  const FsmResetTransition({
    required this.to,
    required this.label,
    required this.color,
    this.start,
    this.isMuted = false,
  });

  final int to;
  final String label;
  final Color color;
  final Offset? start;
  final bool isMuted;
}

class _FsmNodeMetrics {
  const _FsmNodeMetrics({
    required this.center,
    required this.radius,
    required this.left,
    required this.top,
  });

  final Offset center;
  final double radius;
  final double left;
  final double top;
}

List<_FsmNodeMetrics> _layoutNodes(
  List<FsmDiagramNode> nodes,
  List<FsmDiagramTransition> transitions,
  double width,
  double height,
  FsmResetTransition? reset,
) {
  if (nodes.isEmpty) return const [];
  final topInsets = [for (final node in nodes) node.radius + 10];
  final bottomInsets = [...topInsets];
  for (final transition in transitions) {
    final index = transition.from;
    if (index != transition.to || index < 0 || index >= nodes.length) continue;
    // Die Schleifenbeschriftung gehört neben dem runden Zustand zum sicheren Bereich.
    final insets = transition.curveSide == 1 ? bottomInsets : topInsets;
    insets[index] = math.max(insets[index], nodes[index].radius * 2.1 + 20);
  }
  final centers = [
    for (final node in nodes)
      Offset(node.center.dx * width, node.center.dy * height),
  ];
  var minimumShift = -double.infinity;
  var maximumShift = double.infinity;
  for (var i = 0; i < nodes.length; i++) {
    minimumShift = math.max(minimumShift, topInsets[i] - centers[i].dy);
    maximumShift = math.min(
      maximumShift,
      height - bottomInsets[i] - centers[i].dy,
    );
  }
  final shift = minimumShift <= maximumShift
      ? 0.0.clamp(minimumShift, maximumShift).toDouble()
      : 0.0;
  Offset constrain(int i, Offset center) {
    final halfWidth = math.min(nodes[i].width / 2 + 8, width / 2);
    final reserveReset =
        reset?.to == i &&
        transitions.any((edge) => edge.from == i && edge.to == i);
    // Platz für 10 px Knotenabstand, 20 px geraden Schaft und 8 px Rand.
    final resetInset = math.min(nodes[i].radius + 38, width / 2);
    final left = reserveReset && nodes[i].center.dx <= 0.5
        ? math.max(halfWidth, resetInset)
        : halfWidth;
    final right = reserveReset && nodes[i].center.dx > 0.5
        ? math.max(halfWidth, resetInset)
        : halfWidth;
    final top = math.min(topInsets[i], height / 2);
    final bottom = math.max(top, height - bottomInsets[i]);
    return Offset(
      center.dx.clamp(left, width - right).toDouble(),
      center.dy.clamp(top, bottom).toDouble(),
    );
  }

  for (var i = 0; i < centers.length; i++) {
    centers[i] = constrain(i, centers[i] + Offset(0, shift));
  }
  // Nur echte Kollisionen auflösen; bewusste Lektionslayouts werden bei einer
  // Änderung des Viewports nicht durch eine neue Graphanordnung ersetzt.
  for (var pass = 0; pass < 16; pass++) {
    var changed = false;
    for (var i = 0; i < centers.length; i++) {
      for (var j = i + 1; j < centers.length; j++) {
        final delta = centers[j] - centers[i];
        final hasLabel = transitions.any(
          (edge) =>
              (edge.from == i && edge.to == j ||
                  edge.from == j && edge.to == i) &&
              (edge.label?.isNotEmpty ?? false),
        );
        final requiredDistance =
            nodes[i].radius + nodes[j].radius + (hasLabel ? 64 : 28);
        if (delta.distance >= requiredDistance - 0.1) continue;
        final direction = delta.distance < 0.01
            ? const Offset(1, 0)
            : delta / delta.distance;
        final correction = direction * (requiredDistance - delta.distance) / 2;
        centers[i] = constrain(i, centers[i] - correction);
        centers[j] = constrain(j, centers[j] + correction);
        changed = true;
      }
    }
    if (!changed) break;
  }
  return [
    for (var i = 0; i < nodes.length; i++)
      _FsmNodeMetrics(
        center: centers[i],
        radius: nodes[i].radius,
        left: centers[i].dx - nodes[i].width / 2,
        top: centers[i].dy - nodes[i].radius,
      ),
  ];
}

class _FsmDiagramPainter extends CustomPainter {
  _FsmDiagramPainter({
    required this.nodes,
    required this.transitions,
    required this.resetTransition,
    required this.colors,
    required this.textStyles,
    required this.fontFamily,
    this.debugOnTransitionPathPainted,
    this.debugOnTransitionLabelPainted,
    this.debugOnResetPainted,
  });

  final List<_FsmNodeMetrics> nodes;
  final List<FsmDiagramTransition> transitions;
  final FsmResetTransition? resetTransition;
  final AppColorPalette colors;
  final AppTextStyleSet textStyles;
  final String? fontFamily;
  final ValueChanged<Path>? debugOnTransitionPathPainted;
  final ValueChanged<Rect>? debugOnTransitionLabelPainted;
  final ValueChanged<({Path path, Path arrow})>? debugOnResetPainted;
  Size? _routedSize;
  final Map<int, _ArcRoute> _routes = {};
  final List<_ReservedRoute> _reserved = [];
  final Map<(String, double, bool), TextPainter> _labelPainters = {};

  @override
  void paint(Canvas canvas, Size size) {
    if (_routedSize != size) {
      _planRoutes(size);
      _routedSize = size;
    }
    final reset = resetTransition;
    if (reset != null && _hasNode(reset.to)) {
      _drawResetTransition(canvas, size, reset);
    }

    for (var index = 0; index < transitions.length; index++) {
      final transition = transitions[index];
      if (!_hasNode(transition.from) || !_hasNode(transition.to)) continue;
      _drawTransition(canvas, size, transition, _routes[index]);
    }
  }

  bool _hasNode(int index) => index >= 0 && index < nodes.length;

  /// Reserviert zuerst Schleifen und danach stark eingeschränkte Kantenpaare.
  /// Weitere Routen berücksichtigen bereits belegte Linien- und Beschriftungsbereiche.
  void _planRoutes(Size size) {
    _routes.clear();
    _reserved.clear();
    // Schleifen samt Beschriftungsfeldern vor den gewöhnlichen Kanten reservieren.
    for (final transition in transitions) {
      if (transition.from != transition.to || !_hasNode(transition.from)) {
        continue;
      }
      final node = nodes[transition.from];
      final path = _selfTransitionPath(transition, node);
      final length = path.computeMetrics().first.length;
      final side = transition.curveSide?.toDouble() ?? -1;
      _reserved.add(
        _ReservedRoute(
          path,
          _labelRect(
            transition.label,
            node.center + Offset(0, side * node.radius * 2.1),
            math.max(28, length - 32),
            scaleWithWidth: true,
          ),
        ),
      );
    }
    final reset = resetTransition;
    if (reset != null && _hasNode(reset.to)) {
      final path = _resetPath(size, reset);
      if (path != null) _reserved.add(_ReservedRoute(path, null));
    }
    final indexes = [
      for (var i = 0; i < transitions.length; i++)
        if (transitions[i].from != transitions[i].to &&
            _hasNode(transitions[i].from) &&
            _hasNode(transitions[i].to))
          i,
    ];
    // Die am stärksten eingeschränkten (parallelen/gegenläufigen) Paare zuerst führen. Jeder
    // spätere Kandidat sieht die Bahnen, die frühere Kanten bereits belegen.
    final pairCounts = {
      for (final i in indexes)
        i: indexes
            .where((j) => _connectsSameNodePair(transitions[i], transitions[j]))
            .length,
    };
    indexes.sort((a, b) {
      final count = pairCounts[b]!.compareTo(pairCounts[a]!);
      return count == 0 ? a.compareTo(b) : count;
    });
    for (final index in indexes) {
      final transition = transitions[index];
      final route = _bestArcRoute(
        start: nodes[transition.from].center,
        end: nodes[transition.to].center,
        transition: transition,
        fromIndex: transition.from,
        toIndex: transition.to,
        canvasSize: size,
      );
      if (route == null) continue;
      _routes[index] = route;
      _reserved.add(
        _ReservedRoute(route.path, _arcLabelRect(transition, route)),
      );
    }
  }

  Rect? _arcLabelRect(FsmDiagramTransition transition, _ArcRoute route) =>
      _labelRect(
        transition.label,
        route.pointAt(route.labelFraction),
        math.max(40, route.length - 32),
      );

  Rect? _labelRect(
    String? label,
    Offset center,
    double maxWidth, {
    bool scaleWithWidth = false,
  }) {
    if (label == null || label.isEmpty) return null;
    final painter = _transitionTextPainter(label, maxWidth, scaleWithWidth);
    return Rect.fromCenter(
      center: center,
      width: painter.width + 12,
      height: painter.height + 6,
    );
  }

  Path? _resetPath(Size size, FsmResetTransition transition) {
    final to = nodes[transition.to];
    final start = transition.start == null
        ? Offset(to.center.dx, math.max(8, to.center.dy - to.radius - 62))
        : Offset(
            transition.start!.dx * size.width,
            transition.start!.dy * size.height,
          );
    final delta = to.center - start;
    final distance = delta.distance;
    if (distance == 0) return null;

    final direction = delta / distance;
    final end = to.center - direction * (to.radius + 10);
    final hasLoop = transitions.any(
      (edge) => edge.from == transition.to && edge.to == transition.to,
    );
    if (hasLoop) {
      // Über den freien äußeren Port anfahren, statt durch die Schleife oberhalb des
      // Anfangszustands zu laufen. Das kurze Endstück bleibt waagerecht.
      final side = to.center.dx <= size.width / 2 ? -1.0 : 1.0;
      final tip = to.center + Offset(side * (to.radius + 10), 0);
      final approach = tip + Offset(side * 20, 0);
      // Die Biegung VOR der Pfeilspitze beenden. Eine Tangente in einem einzelnen Punkt
      // ergibt unter den beiden Flügeln des Pfeils keinen sichtbaren Schaft.
      final x = side < 0
          ? math
                .min(start.dx, approach.dx - 8)
                .clamp(4.0, size.width - 4)
                .toDouble()
          : math
                .max(start.dx, approach.dx + 8)
                .clamp(4.0, size.width - 4)
                .toDouble();
      return Path()
        ..moveTo(x, start.dy)
        ..cubicTo(x, start.dy, x, approach.dy, approach.dx, approach.dy)
        ..lineTo(tip.dx, tip.dy);
    }
    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
  }

  void _drawResetTransition(
    Canvas canvas,
    Size size,
    FsmResetTransition transition,
  ) {
    final path = _resetPath(size, transition);
    if (path == null) return;
    final metric = path.computeMetrics().single;
    final tangent = metric.getTangentForOffset(metric.length);
    if (tangent == null) return;
    final color = transition.color.withValues(
      alpha: transition.isMuted ? 0.56 : 0.88,
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = transition.isMuted ? 4 : 5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
    final arrow = _drawArrowHead(
      canvas,
      tangent.position,
      tangent.vector,
      color,
    );
    debugOnResetPainted?.call((path: path, arrow: arrow));
    _drawResetLabel(
      canvas,
      transition.label,
      metric.getTangentForOffset(metric.length * 0.25)!.position,
      size,
    );
  }

  void _drawTransition(
    Canvas canvas,
    Size size,
    FsmDiagramTransition transition,
    _ArcRoute? route,
  ) {
    final from = nodes[transition.from];
    if (transition.from == transition.to) {
      _drawSelfTransition(canvas, transition, from);
      return;
    }

    if (route == null) return;
    final end = route.pointAt(1);
    final rect = Rect.fromCircle(center: route.center, radius: route.radius);
    final startAngle = route.startAngle;
    final sweepAngle = route.sweepAngle;
    final color = transition.color.withValues(
      alpha: transition.isMuted
          ? 0.56
          : transition.isHighlighted
          ? 1
          : 0.88,
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = transition.isMuted
          ? 4
          : transition.isHighlighted
          ? 7
          : 5
      ..strokeCap = StrokeCap.round;

    final endAngle = startAngle + sweepAngle;
    final tangentAngle =
        endAngle + (sweepAngle >= 0 ? math.pi / 2 : -math.pi / 2);
    final tangentDirection = Offset(
      math.cos(tangentAngle),
      math.sin(tangentAngle),
    );

    final path = Path()..arcTo(rect, startAngle, sweepAngle, false);
    debugOnTransitionPathPainted?.call(path);
    if (transition.isHighlighted) {
      _drawTransitionGlow(
        canvas,
        path: path,
        arrowTip: end,
        arrowDirection: tangentDirection,
        color: transition.color,
      );
    }

    canvas.drawPath(path, paint);
    _drawArrowHead(
      canvas,
      end,
      tangentDirection,
      color,
      strokeWidth: transition.isHighlighted ? 6 : 4,
    );

    final label = transition.label;
    if (label != null && label.isNotEmpty) {
      final labelCenter = route.pointAt(route.labelFraction);
      final arcLength = route.radius * sweepAngle.abs();
      _drawTransitionLabel(
        canvas,
        label,
        labelCenter,
        maxLabelWidth: math.max(40, arcLength - 32),
        isHighlighted: transition.isHighlighted,
        highlightColor: transition.color,
      );
    }
  }

  _ArcRoute? _bestArcRoute({
    required Offset start,
    required Offset end,
    required FsmDiagramTransition transition,
    required int fromIndex,
    required int toIndex,
    required Size canvasSize,
  }) {
    final chord = (end - start).distance;
    if (chord == 0) return null;

    final preferredSide =
        transition.curveSide?.toDouble() ??
        _sideTowardDiagramCenter(start, end);
    final requestedDepth = transition.curveDepth ?? 0.18;
    // Flache Bahnen sind entscheidend: Ein tiefer Bogen kann einen dritten Zustand treffen,
    // aber beide Richtungen auf dieselbe Seite zu legen, verdeckt diese Kollision nur.
    final depths = <double>{
      requestedDepth,
      0.025,
      0.05,
      0.08,
      0.12,
      0.18,
      0.24,
      0.32,
      0.40,
      0.48,
    };

    _ArcRoute? best;
    var bestScore = double.infinity;
    for (final side in [preferredSide, -preferredSide]) {
      for (final depth in depths) {
        final candidate = _arcRoute(
          start,
          end,
          side,
          depth,
          startRadius: nodes[fromIndex].radius + 6,
          endRadius: nodes[toIndex].radius + 10,
        );
        final clearance = _routeClearance(
          candidate,
          fromIndex: fromIndex,
          toIndex: toIndex,
          canvasSize: canvasSize,
        );
        final samples = [
          for (var i = 0; i <= 32; i++) candidate.pointAt(i / 32),
        ];
        var collisionPenalty = 0.0;
        for (final occupied in _reserved) {
          for (final point in samples.skip(2).take(29)) {
            // Gemeinsame Knotenports dürfen zusammenlaufen. Die Linien selbst müssen
            // getrennt bleiben, auch wenn beide auf derselben Seite liegen.
            if (nodes.any(
              (node) => (point - node.center).distance < node.radius + 16,
            )) {
              continue;
            }
            final distance = occupied.distanceTo(point);
            collisionPenalty += math.max(0, 12 - distance) * 300;
            if (occupied.label?.inflate(5).contains(point) ?? false) {
              collisionPenalty += 4000;
            }
          }
        }
        final routePenalty =
            math.max(0, -clearance) * 100000 + collisionPenalty;
        final preferencePenalty =
            (side == preferredSide ? 0 : 20) +
            (depth - requestedDepth).abs() * 30;
        for (final fraction in const [0.5, 0.38, 0.62, 0.26, 0.74]) {
          final labeled = candidate.withLabelFraction(fraction);
          final label = _arcLabelRect(transition, labeled);
          final score =
              routePenalty +
              _labelPenalty(label, canvasSize) +
              preferencePenalty +
              (fraction - 0.5).abs() * 10;
          if (score < bestScore) {
            bestScore = score;
            best = labeled;
          }
        }
      }
    }
    return best;
  }

  double _labelPenalty(Rect? rect, Size size) {
    if (rect == null) return 0;
    var penalty = 0.0;
    final overflow =
        math.max(0, 4 - rect.left) +
        math.max(0, 4 - rect.top) +
        math.max(0, rect.right - size.width + 4) +
        math.max(0, rect.bottom - size.height + 4);
    penalty += overflow * 100000;
    for (final node in nodes) {
      final closest = Offset(
        node.center.dx.clamp(rect.left, rect.right).toDouble(),
        node.center.dy.clamp(rect.top, rect.bottom).toDouble(),
      );
      penalty +=
          math.max(0, node.radius + 8 - (closest - node.center).distance) *
          100000;
    }
    for (final occupied in _reserved) {
      if (occupied.label?.inflate(6).overlaps(rect) ?? false) penalty += 100000;
      for (final point in occupied.samples) {
        if (rect.inflate(4).contains(point)) penalty += 4000;
      }
    }
    return penalty;
  }

  double _sideTowardDiagramCenter(Offset start, Offset end) {
    final chord = end - start;
    final direction = chord / chord.distance;
    final normal = Offset(-direction.dy, direction.dx);
    final midpoint = Offset.lerp(start, end, 0.5)!;
    final towardsCenter = _centroid() - midpoint;
    final centerSide =
        normal.dx * towardsCenter.dx + normal.dy * towardsCenter.dy;
    return centerSide > 0 ? 1 : -1;
  }

  _ArcRoute _arcRoute(
    Offset start,
    Offset end,
    double side,
    double depth, {
    required double startRadius,
    required double endRadius,
  }) {
    final delta = end - start;
    final chord = delta.distance;
    final direction = delta / chord;
    final normal = Offset(-direction.dy, direction.dx);
    final midpoint = Offset.lerp(start, end, 0.5)!;
    final radius = _radiusForCurveDepth(chord, depth);
    final halfChord = chord / 2;
    final centerOffset = math.sqrt(radius * radius - halfChord * halfChord);
    final center = midpoint + normal * centerOffset * side;
    final startAngle = math.atan2(start.dy - center.dy, start.dx - center.dx);
    final endAngle = math.atan2(end.dy - center.dy, end.dx - center.dx);
    final sweep = _minorSweep(startAngle, endAngle);
    // Die Mittelpunktverbindung am Rand jedes Knotens kürzen. So erhalten
    // gegenläufige Bahnen verschiedene Ports, und Pfeilspitzen bleiben tangential zum Pfad.
    final startTrim = 2 * math.asin((startRadius / (2 * radius)).clamp(0, 1));
    final endTrim = 2 * math.asin((endRadius / (2 * radius)).clamp(0, 1));
    return _ArcRoute(
      center: center,
      radius: radius,
      startAngle: startAngle + startTrim * sweep.sign,
      sweepAngle:
          math.max(0.001, sweep.abs() - startTrim - endTrim) * sweep.sign,
    );
  }

  double _routeClearance(
    _ArcRoute route, {
    required int fromIndex,
    required int toIndex,
    required Size canvasSize,
  }) {
    var clearance = double.infinity;
    for (var sample = 0; sample <= 32; sample++) {
      final angle = route.startAngle + route.sweepAngle * sample / 32;
      final point =
          route.center +
          Offset(math.cos(angle), math.sin(angle)) * route.radius;
      // Striche, Pfeilspitzen und Übergangsbeschriftungen bleiben innerhalb der Zeichenfläche.
      clearance = math.min(
        clearance,
        math.min(
          math.min(point.dx - 10, canvasSize.width - point.dx - 10),
          math.min(point.dy - 10, canvasSize.height - point.dy - 10),
        ),
      );
      for (var index = 0; index < nodes.length; index++) {
        if (index == fromIndex || index == toIndex) continue;
        // 18 px schützen den Knoten vor Strich, Pfeilspitze und Beschriftungsfeld.
        clearance = math.min(
          clearance,
          (point - nodes[index].center).distance - nodes[index].radius - 18,
        );
      }
    }
    return clearance;
  }

  Path _selfTransitionPath(
    FsmDiagramTransition transition,
    _FsmNodeMetrics node,
  ) {
    final side = transition.curveSide?.toDouble() ?? -1;
    final start =
        node.center + Offset(-node.radius * 0.70, side * node.radius * 0.72);
    final end =
        node.center + Offset(node.radius * 0.70, side * node.radius * 0.72);
    final firstControl =
        node.center + Offset(-node.radius * 1.75, side * node.radius * 2.25);
    final secondControl =
        node.center + Offset(node.radius * 1.75, side * node.radius * 2.25);
    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        firstControl.dx,
        firstControl.dy,
        secondControl.dx,
        secondControl.dy,
        end.dx,
        end.dy,
      );
  }

  void _drawSelfTransition(
    Canvas canvas,
    FsmDiagramTransition transition,
    _FsmNodeMetrics node,
  ) {
    final side = transition.curveSide?.toDouble() ?? -1;
    final path = _selfTransitionPath(transition, node);
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length);
    if (tangent == null) return;
    final end = tangent.position;
    final direction = tangent.vector / tangent.vector.distance;
    final color = transition.color.withValues(
      alpha: transition.isMuted
          ? 0.56
          : transition.isHighlighted
          ? 1
          : 0.88,
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = transition.isMuted
          ? 4
          : transition.isHighlighted
          ? 7
          : 5
      ..strokeCap = StrokeCap.round;

    if (transition.isHighlighted) {
      _drawTransitionGlow(
        canvas,
        path: path,
        arrowTip: end,
        arrowDirection: direction,
        color: transition.color,
      );
    }
    canvas.drawPath(path, paint);
    _drawArrowHead(
      canvas,
      end,
      direction,
      color,
      strokeWidth: transition.isHighlighted ? 6 : 4,
    );

    final label = transition.label;
    if (label != null && label.isNotEmpty) {
      _drawTransitionLabel(
        canvas,
        label,
        node.center + Offset(0, side * node.radius * 2.10),
        // Die Beschriftung bleibt an die tatsächliche Schleifengröße gebunden. Ein festes
        // Minimum von 52 px ließ `A = 1` in schmalen Diagrammen zu groß erscheinen.
        maxLabelWidth: math.max(28, metric.length - 32),
        scaleWithWidth: true,
        isHighlighted: transition.isHighlighted,
        highlightColor: transition.color,
      );
    }
  }

  double _radiusForCurveDepth(double chord, double depthFactor) {
    final depth = chord * depthFactor;
    return chord * chord / (8 * depth) + depth / 2;
  }

  void _drawTransitionGlow(
    Canvas canvas, {
    required Path path,
    required Offset arrowTip,
    required Offset arrowDirection,
    required Color color,
  }) {
    for (final layer in const [
      (strokeWidth: 24.0, blurSigma: 22.0, alpha: 0.42),
      (strokeWidth: 15.0, blurSigma: 12.0, alpha: 0.68),
      (strokeWidth: 10.0, blurSigma: 5.0, alpha: 0.82),
    ]) {
      final glowColor = color.withValues(alpha: layer.alpha);
      final glowPaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = layer.strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blurSigma);
      canvas.drawPath(path, glowPaint);
      _drawArrowHead(
        canvas,
        arrowTip,
        arrowDirection,
        glowColor,
        strokeWidth: layer.strokeWidth * 0.7,
        maskFilter: glowPaint.maskFilter,
      );
    }
  }

  Offset _centroid() {
    if (nodes.isEmpty) return Offset.zero;

    var x = 0.0;
    var y = 0.0;
    for (final node in nodes) {
      x += node.center.dx;
      y += node.center.dy;
    }

    return Offset(x / nodes.length, y / nodes.length);
  }

  double _minorSweep(double startAngle, double endAngle) {
    final clockwise = (endAngle - startAngle) % (math.pi * 2);
    return clockwise <= math.pi ? clockwise : clockwise - math.pi * 2;
  }

  Path _drawArrowHead(
    Canvas canvas,
    Offset tip,
    Offset direction,
    Color color, {
    double strokeWidth = 4,
    MaskFilter? maskFilter,
  }) {
    const arrowLength = 10.0;
    const arrowAngle = math.pi / 5;
    final baseAngle = math.atan2(direction.dy, direction.dx);
    final first =
        tip -
        Offset(
          math.cos(baseAngle - arrowAngle) * arrowLength,
          math.sin(baseAngle - arrowAngle) * arrowLength,
        );
    final second =
        tip -
        Offset(
          math.cos(baseAngle + arrowAngle) * arrowLength,
          math.sin(baseAngle + arrowAngle) * arrowLength,
        );
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = maskFilter;

    final arrow = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(first.dx, first.dy)
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(second.dx, second.dy);
    canvas.drawPath(arrow, arrowPaint);
    return arrow;
  }

  void _drawTransitionLabel(
    Canvas canvas,
    String label,
    Offset center, {
    required double maxLabelWidth,
    bool scaleWithWidth = false,
    bool isHighlighted = false,
    Color? highlightColor,
  }) {
    final textPainter = _transitionTextPainter(
      label,
      maxLabelWidth,
      scaleWithWidth,
    );
    final labelRect = Rect.fromCenter(
      center: center,
      width: textPainter.width + 12,
      height: textPainter.height + 6,
    );
    debugOnTransitionLabelPainted?.call(labelRect);
    final backgroundPaint = Paint()
      ..color = colors.background.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = isHighlighted ? highlightColor! : colors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.5 : 1;

    if (isHighlighted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          labelRect.inflate(7),
          const Radius.circular(7),
        ),
        Paint()
          ..color = highlightColor!.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        backgroundPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        borderPaint,
      );
    textPainter.paint(
      canvas,
      labelRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  TextPainter _transitionTextPainter(
    String label,
    double maxLabelWidth,
    bool scaleWithWidth,
  ) {
    return _labelPainters.putIfAbsent(
      (label, maxLabelWidth, scaleWithWidth),
      () => _createTransitionTextPainter(label, maxLabelWidth, scaleWithWidth),
    );
  }

  TextPainter _createTransitionTextPainter(
    String label,
    double maxLabelWidth,
    bool scaleWithWidth,
  ) {
    final captionStyle = textStyles.caption.copyWith(
      fontFamily: fontFamily,
      // Gelb (im hellen Design Bernstein) hebt Beschriftungen von den Übergangslinien ab
      // und bleibt auf beiden Zeichenflächen gut lesbar.
      color: colors.warning,
      fontWeight: FontWeight.w800,
    );
    final baseFontSize = captionStyle.fontSize ?? 12;
    final widthScale = (maxLabelWidth / 52).clamp(0.5, 1.0).toDouble();
    final baseStyle = scaleWithWidth
        ? captionStyle.copyWith(fontSize: baseFontSize * widthScale)
        : captionStyle;
    final availableTextWidth = math.max(16, maxLabelWidth - 12).toDouble();
    var textPainter = _transitionLabelPainter(label, baseStyle)..layout();

    if (textPainter.width > availableTextWidth) {
      final fittedFontSize = math
          .max(
            4.5,
            (baseStyle.fontSize ?? baseFontSize) *
                availableTextWidth /
                textPainter.width,
          )
          .toDouble();
      textPainter = _transitionLabelPainter(
        label,
        baseStyle.copyWith(fontSize: fittedFontSize),
      )..layout(maxWidth: availableTextWidth);
    }

    return textPainter;
  }

  TextPainter _transitionLabelPainter(String label, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: label, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
  }

  void _drawResetLabel(
    Canvas canvas,
    String label,
    Offset lineCenter,
    Size size,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyles.caption.copyWith(
          fontFamily: fontFamily,
          color: colors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (lineCenter.dx - textPainter.width / 2)
            .clamp(4, math.max(4, size.width - textPainter.width - 4))
            .toDouble(),
        math.max(4, lineCenter.dy - textPainter.height - 6),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _FsmDiagramPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.transitions != transitions ||
        oldDelegate.resetTransition != resetTransition ||
        oldDelegate.colors != colors ||
        oldDelegate.textStyles != textStyles ||
        oldDelegate.fontFamily != fontFamily;
  }
}

class _ArcRoute {
  const _ArcRoute({
    required this.center,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
    this.labelFraction = 0.5,
  });

  final Offset center;
  final double radius;
  final double startAngle;
  final double sweepAngle;
  final double labelFraction;
  double get length => radius * sweepAngle.abs();
  Path get path => Path()
    ..arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
  Offset pointAt(double fraction) {
    final angle = startAngle + sweepAngle * fraction;
    return center + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  _ArcRoute withLabelFraction(double fraction) => _ArcRoute(
    center: center,
    radius: radius,
    startAngle: startAngle,
    sweepAngle: sweepAngle,
    labelFraction: fraction,
  );
}

class _ReservedRoute {
  _ReservedRoute(Path path, this.label) {
    final metric = path.computeMetrics().first;
    samples = [
      for (var i = 0; i <= 32; i++)
        metric.getTangentForOffset(metric.length * i / 32)!.position,
    ];
  }
  final Rect? label;
  late final List<Offset> samples;

  double distanceTo(Offset point) {
    var distance = double.infinity;
    for (var i = 1; i < samples.length; i++) {
      final start = samples[i - 1];
      final delta = samples[i] - start;
      final lengthSquared = delta.distanceSquared;
      final offset = point - start;
      final fraction = lengthSquared == 0
          ? 0.0
          : ((offset.dx * delta.dx + offset.dy * delta.dy) / lengthSquared)
                .clamp(0, 1)
                .toDouble();
      distance = math.min(
        distance,
        (point - start - delta * fraction).distance,
      );
    }
    return distance;
  }
}
