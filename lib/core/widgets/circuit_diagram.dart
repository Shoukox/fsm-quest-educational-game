import 'dart:math' as math;

import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/models/circuit_definition.dart';

export 'package:bachelor/core/models/circuit_definition.dart'
    show CircuitDiagramVariant;

/// Zeigt die Schaltungen aus Kapitel 2 mit optionaler Hervorhebung und animiertem Signalfluss.
class CircuitDiagram extends StatelessWidget {
  const CircuitDiagram({
    super.key,
    this.variant = CircuitDiagramVariant.base,
    this.showFormula = false,
    this.highlight = CircuitHighlight.none,
    this.state = 0,
    this.input = 0,
    this.signalProgress,
  });

  final CircuitHighlight highlight;
  final CircuitDiagramVariant variant;
  final bool showFormula;
  final int state;
  final int input;
  final double? signalProgress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            // Dies ist das Seitenverhältnis der ursprünglichen Schaltungsaufgabe.
            aspectRatio: 343 / 235,
            child: CustomPaint(
              painter: _CircuitPainter(
                colors: context.colors,
                variant: variant,
                highlight: highlight,
                state: state,
                input: input,
                signalProgress: signalProgress,
              ),
            ),
          ),
          if (showFormula) ...[
            const SizedBox(height: 6),
            Text(
              variant.changedFormula,
              textAlign: TextAlign.center,
              style: context.textStyles.caption.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  _CircuitPainter({
    required this.colors,
    required this.variant,
    required this.highlight,
    required this.state,
    required this.input,
    this.signalProgress,
  });

  final AppColorPalette colors;
  final CircuitDiagramVariant variant;
  final CircuitHighlight highlight;
  final int state;
  final int input;
  final double? signalProgress;

  @override
  void paint(Canvas canvas, Size size) {
    const referenceSize = Size(343, 235);
    final scale = size.width / referenceSize.width;
    canvas.save();
    canvas.scale(scale);

    final wire = Paint()
      ..color = colors.text
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;
    final active = Paint()
      ..color = colors.primary
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final activeFill = Paint()
      ..color = colors.primary.withValues(alpha: .14)
      ..style = PaintingStyle.fill;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void label(
      String text,
      Offset offset, {
      Color? color,
      double fontSize = 11,
      FontStyle fontStyle = FontStyle.normal,
      bool alignRightCenter = false,
    }) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color ?? colors.text,
          fontSize: fontSize,
          fontFamily: 'serif',
          fontStyle: fontStyle,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        alignRightCenter
            ? offset - Offset(textPainter.width, textPainter.height / 2)
            : offset,
      );
    }

    void polyline(List<Offset> points, Paint paint) {
      final value = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        final previous = points[i - 1];
        final point = points[i];
        if (point.dx != previous.dx && point.dy != previous.dy) {
          value.lineTo(previous.dx, point.dy);
        }
        value.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(value, paint);
    }

    void arrow(Offset from, Offset to, Paint paint) {
      canvas.drawLine(from, to, paint);
      final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
      const length = 6.0;
      final left = Offset(
        to.dx - length * math.cos(angle - math.pi / 6),
        to.dy - length * math.sin(angle - math.pi / 6),
      );
      final right = Offset(
        to.dx - length * math.cos(angle + math.pi / 6),
        to.dy - length * math.sin(angle + math.pi / 6),
      );
      // Die Vorlage verwendet offene dreieckige Pfeilspitzen (keine gefüllten Rauten).
      // Getrennte Striche erhalten den dünnen technischen Zeichenstil, wenn die
      // Schaltung auf schmalen Bildschirmen verkleinert wird.
      canvas.drawLine(to, left, paint);
      canvas.drawLine(to, right, paint);
    }

    void bubble(Offset center) {
      canvas.drawCircle(center, 2.4, Paint()..color = colors.surface);
      canvas.drawCircle(center, 2.4, wire);
    }

    void andGate(Rect bounds, {bool highlighted = false}) {
      final path = Path()
        ..moveTo(bounds.left, bounds.top)
        ..lineTo(bounds.left + bounds.width * .48, bounds.top)
        ..cubicTo(
          bounds.right - 2,
          bounds.top,
          bounds.right,
          bounds.center.dy - bounds.height * .19,
          bounds.right,
          bounds.center.dy,
        )
        ..cubicTo(
          bounds.right,
          bounds.center.dy + bounds.height * .19,
          bounds.right - 2,
          bounds.bottom,
          bounds.left + bounds.width * .48,
          bounds.bottom,
        )
        ..lineTo(bounds.left, bounds.bottom)
        ..close();
      if (highlighted) canvas.drawPath(path, activeFill);
      canvas.drawPath(path, highlighted ? active : wire);
    }

    /// Liefert gleichmäßig verteilte Eingangsports entlang der flachen Kante eines
    /// AND-Gatters. So bleiben 2-Eingangs-Gatter und das 3-Eingangs-Gatter `S₁′` ordentlich,
    /// und auch ein künftiges 4-Eingangs-Gatter kommt ohne neue Geometrie aus.
    List<Offset> andInputPorts(Rect bounds, int count) {
      assert(count >= 2 && count <= 4);
      final spacing = bounds.height / (count + 1);
      return List.generate(
        count,
        (index) => Offset(bounds.left, bounds.top + spacing * (index + 1)),
      );
    }

    void xorGate(Rect bounds, {bool highlighted = false}) {
      // Quadratische Rückkanten haben einen linearen y-Parameter: Die beiden Ports auf
      // 1/4 und 3/4 der Höhe treffen die Kontur an genau derselben x-Koordinate.
      final main = Path()
        ..moveTo(bounds.left + 8, bounds.top)
        ..quadraticBezierTo(
          bounds.left + 32,
          bounds.center.dy,
          bounds.left + 8,
          bounds.bottom,
        )
        ..quadraticBezierTo(
          bounds.right - 7,
          bounds.bottom,
          bounds.right,
          bounds.center.dy,
        )
        ..quadraticBezierTo(
          bounds.right - 7,
          bounds.top,
          bounds.left + 8,
          bounds.top,
        )
        ..close();
      final extra = Path()
        ..moveTo(bounds.left + 2, bounds.top)
        ..quadraticBezierTo(
          bounds.left + 26,
          bounds.center.dy,
          bounds.left + 2,
          bounds.bottom,
        );
      if (highlighted) canvas.drawPath(main, activeFill);
      canvas.drawPath(main, highlighted ? active : wire);
      canvas.drawPath(extra, highlighted ? active : wire);
    }

    final isMemory =
        highlight == CircuitHighlight.memory ||
        highlight == CircuitHighlight.all;
    final isNext =
        highlight == CircuitHighlight.nextState ||
        highlight == CircuitHighlight.all;
    final isNextStateInput = isMemory || isNext;
    final isSignalPath = isMemory || isNext;
    final isOutput =
        highlight == CircuitHighlight.output ||
        highlight == CircuitHighlight.all;

    final inputLabel = switch (variant) {
      CircuitDiagramVariant.base => 'A',
      CircuitDiagramVariant.practiceX => 'X',
      _ => 'B',
    };
    final invertedInputLabel = 'NOT $inputLabel';

    const topXor = Rect.fromLTWH(58, 34, 42, 32);
    const topAnd = Rect.fromLTWH(117, 52, 33, 29);
    const bottomAnd = Rect.fromLTWH(108, 146, 44, 36);
    const outputAnd = Rect.fromLTWH(279, 104, 34, 28);
    const memory = Rect.fromLTWH(206, 41, 32, 148);
    final topAndInputs = andInputPorts(topAnd, 2);
    final topLogicInputs = variant == CircuitDiagramVariant.finalAndNextState
        ? andInputPorts(topXor, 2)
        : const [Offset(75, 42), Offset(75, 58)];

    List<Offset> topLogicWire(Offset source, Offset target) {
      if (variant != CircuitDiagramVariant.finalAndNextState) {
        return [source, target];
      }

      // AND-Ports sind vertikal verteilt, während die Rückkopplungsleitungen auf den
      // ursprünglichen XOR-Ebenen ankommen. Die Führung über eine explizite Ecke verhindert,
      // dass eine technische Schaltung eine diagonale Verbindung andeutet.
      const bendX = 42.0;
      return [
        source,
        Offset(bendX, source.dy),
        Offset(bendX, target.dy),
        target,
      ];
    }

    final bottomAndInputs = andInputPorts(bottomAnd, 3);
    final outputAndInputs = variant == CircuitDiagramVariant.finalXorOutput
        ? [
            Offset(outputAnd.left + 17, outputAnd.top + outputAnd.height / 4),
            Offset(
              outputAnd.left + 17,
              outputAnd.top + outputAnd.height * 3 / 4,
            ),
          ]
        : andInputPorts(outputAnd, 2);
    const inputBubbleRadius = 2.4;
    final bottomFirstPort = Offset(
      bottomAndInputs[0].dx -
          (variant == CircuitDiagramVariant.finalMixedState
              ? 0
              : inputBubbleRadius),
      bottomAndInputs[0].dy,
    );
    final outputFirstPort = Offset(
      outputAndInputs[0].dx -
          (variant == CircuitDiagramVariant.finalXorOutput
              ? 0
              : inputBubbleRadius),
      outputAndInputs[0].dy,
    );

    // Rückkopplungsleitungen: Ecken und Ebenen entsprechen der Aufgabenzeichnung.
    polyline([
      const Offset(238, 83),
      const Offset(259, 83),
      const Offset(259, 7),
      const Offset(22, 7),
      const Offset(22, 155),
    ], isSignalPath ? active : wire);
    polyline(
      topLogicWire(const Offset(22, 42), topLogicInputs[0]),
      isSignalPath ? active : wire,
    );
    polyline([
      const Offset(22, 155),
      bottomFirstPort,
    ], isSignalPath ? active : wire);
    polyline([
      const Offset(238, 146),
      const Offset(259, 146),
      const Offset(259, 229),
      const Offset(16, 229),
      const Offset(16, 58),
    ], isSignalPath ? active : wire);
    polyline(
      topLogicWire(const Offset(16, 58), topLogicInputs[1]),
      isNextStateInput ? active : wire,
    );
    polyline([
      const Offset(16, 164),
      Offset(bottomAndInputs[1].dx - inputBubbleRadius, bottomAndInputs[1].dy),
    ], isNextStateInput ? active : wire);
    polyline([
      const Offset(100, 50),
      const Offset(108, 50),
      Offset(108, topAndInputs[0].dy),
      topAndInputs[0],
    ], isNext ? active : wire);
    polyline([
      Offset(94, topAndInputs[1].dy),
      topAndInputs[1],
    ], isNext ? active : wire);
    // Ā ist der dritte Eingang des S₁′-Gatters.
    polyline([
      const Offset(82.6, 173),
      Offset(bottomAndInputs[2].dx - inputBubbleRadius, bottomAndInputs[2].dy),
    ], isNext ? active : wire);
    polyline([
      const Offset(150, 66.5),
      const Offset(179, 66.5),
      const Offset(179, 83),
      const Offset(206, 83),
    ], isNext ? active : wire);
    polyline([
      const Offset(152, 164),
      const Offset(179, 164),
      const Offset(179, 146),
      const Offset(206, 146),
    ], isNext ? active : wire);
    polyline([
      const Offset(238, 83),
      const Offset(257, 83),
      Offset(257, outputAndInputs[0].dy),
      outputFirstPort,
    ], isOutput ? active : wire);
    polyline([
      const Offset(238, 146),
      const Offset(258, 146),
      Offset(258, outputAndInputs[1].dy),
      outputAndInputs[1],
    ], isOutput ? active : wire);

    if (variant == CircuitDiagramVariant.finalAndNextState) {
      andGate(topXor, highlighted: isNext);
    } else {
      xorGate(topXor, highlighted: isNext);
    }
    andGate(topAnd, highlighted: isNext);
    andGate(bottomAnd, highlighted: isNext);
    if (variant == CircuitDiagramVariant.finalXorOutput) {
      xorGate(outputAnd, highlighted: isOutput);
    } else {
      andGate(outputAnd, highlighted: isOutput);
    }
    if (isMemory) canvas.drawRect(memory, activeFill);
    canvas.drawRect(memory, isMemory ? active : wire);
    if (variant != CircuitDiagramVariant.finalMixedState) {
      bubble(bottomFirstPort);
    }
    bubble(
      Offset(bottomAndInputs[1].dx - inputBubbleRadius, bottomAndInputs[1].dy),
    );
    if (variant != CircuitDiagramVariant.finalXorOutput) {
      bubble(outputFirstPort);
    }

    // Richtungspfeile gehören zur ursprünglichen Notation des Schaltwerks.
    arrow(
      const Offset(222, 31),
      const Offset(222, 41),
      isMemory ? active : wire,
    );
    arrow(
      const Offset(222, 199),
      const Offset(222, 189),
      isMemory ? active : wire,
    );
    arrow(
      const Offset(313, 118),
      const Offset(328, 118),
      isOutput ? active : wire,
    );

    label('CLK', const Offset(212, 19), fontSize: 11);
    label(
      inputLabel,
      Offset(88, topAndInputs[1].dy),
      fontSize: 11,
      fontStyle: FontStyle.italic,
      alignRightCenter: true,
    );
    label(
      'S₀′',
      const Offset(191, 60),
      fontSize: 11,
      fontStyle: FontStyle.italic,
    );
    label(
      'S₁′',
      const Offset(191, 123),
      fontSize: 11,
      fontStyle: FontStyle.italic,
    );
    label(
      'S₁S₀',
      const Offset(211, 110),
      fontSize: 11,
      fontStyle: FontStyle.italic,
    );
    label(
      'S₀',
      const Offset(242, 63),
      fontSize: 11,
      fontStyle: FontStyle.italic,
    );
    label(
      'S₁',
      const Offset(242, 126),
      fontSize: 11,
      fontStyle: FontStyle.italic,
    );
    label(
      'Y',
      const Offset(333, 114),
      fontSize: 11,
      fontStyle: FontStyle.italic,
    );
    label('Reset', const Offset(211, 203), fontSize: 10);
    label(
      invertedInputLabel,
      Offset(76, bottomAndInputs[2].dy),
      fontSize: 11,
      fontStyle: FontStyle.italic,
      alignRightCenter: true,
    );

    if (signalProgress != null) {
      _drawSignalTrace(canvas, signalProgress!.clamp(0.0, 1.0));
    }

    canvas.restore();
  }

  void _drawSignalTrace(Canvas canvas, double progress) {
    final paint = Paint()
      ..color = colors.stateHighlight
      ..style = PaintingStyle.fill;

    Offset pointOnPath(List<Offset> points, double value) {
      if (value <= 0) return points.first;
      if (value >= 1) return points.last;
      final segmentLength = 1 / (points.length - 1);
      final segment = (value / segmentLength).floor();
      final local = (value - segment * segmentLength) / segmentLength;
      final from = points[segment];
      final to = points[segment + 1];
      return Offset(
        from.dx + (to.dx - from.dx) * local,
        from.dy + (to.dy - from.dy) * local,
      );
    }

    void draw(List<Offset> points, double start, double end) {
      if (progress < start) return;
      final local = ((progress - start) / (end - start)).clamp(0.0, 1.0);
      canvas.drawCircle(pointOnPath(points, local), 3.5, paint);
    }

    // Eingänge laufen zuerst über die Leitungen in die eigentlichen Gatterkörper.
    draw(
      [const Offset(94, 71.3333333), const Offset(117, 71.3333333)],
      0.0,
      0.22,
    );
    draw(
      [
        const Offset(16, 58),
        const Offset(75, 58),
        const Offset(78, 50),
        const Offset(100, 50),
      ],
      0.0,
      0.22,
    );
    draw(
      [
        const Offset(22, 42),
        const Offset(75, 42),
        const Offset(78, 50),
        const Offset(100, 50),
      ],
      0.0,
      0.22,
    );
    draw(
      [
        const Offset(16, 164),
        const Offset(103.2, 164),
        const Offset(130, 164),
        const Offset(152, 164),
      ],
      0.0,
      0.22,
    );
    draw(
      [
        const Offset(22, 155),
        const Offset(103.2, 155),
        const Offset(130, 164),
        const Offset(152, 164),
      ],
      0.0,
      0.22,
    );
    draw(
      [
        const Offset(82.6, 173),
        const Offset(105.6, 173),
        const Offset(130, 164),
        const Offset(152, 164),
      ],
      0.0,
      0.22,
    );

    // Gatterausgänge laufen über ihre Verbindungsleitungen weiter zu den Flipflops.
    draw(
      [
        const Offset(100, 50),
        const Offset(108, 50),
        const Offset(108, 61.6666667),
        const Offset(117, 61.6666667),
        const Offset(150, 66.5),
        const Offset(179, 66.5),
        const Offset(179, 83),
        const Offset(206, 83),
      ],
      0.22,
      0.58,
    );
    draw(
      [
        const Offset(152, 164),
        const Offset(179, 164),
        const Offset(179, 146),
        const Offset(206, 146),
      ],
      0.22,
      0.58,
    );

    // Das gespeicherte Ergebnis läuft anschließend durch das Ausgangs-AND-Gatter zu Y.
    draw(
      [
        const Offset(238, 83),
        const Offset(257, 83),
        const Offset(257, 113.3333333),
        const Offset(276.6, 113.3333333),
        const Offset(296, 118),
        const Offset(313, 118),
        const Offset(328, 118),
      ],
      0.58,
      1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.highlight != highlight ||
        oldDelegate.state != state ||
        oldDelegate.input != input ||
        oldDelegate.signalProgress != signalProgress ||
        oldDelegate.colors != colors;
  }
}

enum CircuitHighlight { none, all, memory, nextState, output }

extension CircuitDiagramVariantFormula on CircuitDiagramVariant {
  String get changedFormula => switch (this) {
    CircuitDiagramVariant.base =>
      'S₀′ = A ∧ (S₁ XOR S₀), S₁′ = Ā ∧ ¬S₁ ∧ ¬S₀, Y = S₁ ∧ ¬S₀',
    CircuitDiagramVariant.practiceX =>
      'D0 = X AND (S1 XOR S0); D1 = NOT X AND NOT S1 AND NOT S0; Y = S1 AND NOT S0',
    CircuitDiagramVariant.finalAndNextState => 'D0 = B AND S1 AND S0',
    CircuitDiagramVariant.finalMixedState => 'D1 = NOT B AND NOT S1 AND S0',
    CircuitDiagramVariant.finalXorOutput => 'Y = S₁ XOR S₀',
  };
}
