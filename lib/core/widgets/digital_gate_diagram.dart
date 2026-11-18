import 'dart:math' as math;

import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/features/lesson/domain/logic/digital_gate_logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Animierte Gatterdarstellung mit Eingabebits, optionalen Negationen und berechneter Ausgabe.
class DigitalGateDiagram extends StatelessWidget {
  const DigitalGateDiagram({
    required this.type,
    required this.inputs,
    this.inputLabels,
    this.inputInverted,
    this.outputLabel,
    this.label,
    this.highlight = true,
    super.key,
  });

  final DigitalGateType type;
  final List<int> inputs;
  final List<String>? inputLabels;
  final List<bool>? inputInverted;
  final String? outputLabel;
  final String? label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final effectiveInputs = [
      for (var index = 0; index < inputs.length; index++)
        inputInverted != null &&
                index < inputInverted!.length &&
                inputInverted![index]
            ? 1 - inputs[index]
            : inputs[index],
    ];
    final output = DigitalGateLogic.evaluate(type, effectiveInputs);
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: TweenAnimationBuilder<double>(
            key: ValueKey('${type.name}-${inputs.join()}-$output'),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            builder: (context, progress, _) => CustomPaint(
              painter: _DigitalGatePainter(
                type: type,
                inputs: inputs,
                inputLabels: inputLabels,
                inputInverted: inputInverted,
                outputLabel: outputLabel,
                output: output,
                progress: progress,
                colors: context.colors,
                highlight: highlight,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        if (label != null) Text(label!, style: context.textStyles.caption),
      ],
    );
  }
}

/// Zeigt NOT- und AND-Gatter samt Verbindung als zusammenhängende, skalierbare Zeichnung.
class NotAndGateChainDiagram extends StatelessWidget {
  const NotAndGateChainDiagram({
    required this.input,
    required this.andInput,
    this.label,
    super.key,
  });

  final int input;
  final int andInput;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final inverted = DigitalGateLogic.evaluate(DigitalGateType.not, [input]);
    final output = DigitalGateLogic.evaluate(DigitalGateType.and, [
      inverted,
      andInput,
    ]);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final aspectRatio = constraints.maxWidth < 420 ? 1.55 : 1.85;
            return AspectRatio(
              aspectRatio: aspectRatio,
              child: TweenAnimationBuilder<double>(
                key: ValueKey('not-and-$input-$andInput-$output'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                builder: (context, progress, _) => CustomPaint(
                  painter: _NotAndChainPainter(
                    input: input,
                    andInput: andInput,
                    inverted: inverted,
                    output: output,
                    progress: progress,
                    colors: context.colors,
                  ),
                  size: Size.infinite,
                ),
              ),
            );
          },
        ),
        if (label != null) Text(label!, style: context.textStyles.caption),
      ],
    );
  }
}

class _NotAndChainPainter extends CustomPainter {
  _NotAndChainPainter({
    required this.input,
    required this.andInput,
    required this.inverted,
    required this.output,
    required this.progress,
    required this.colors,
  });

  final int input;
  final int andInput;
  final int inverted;
  final int output;
  final double progress;
  final AppColorPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final wire = Paint()
      ..color = colors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final gate = Paint()
      ..color = progress >= .55 ? colors.primary : colors.text
      ..strokeWidth = progress >= .55 ? 4 : 3
      ..style = PaintingStyle.stroke;
    final centerY = size.height / 2;
    final notLeft = size.width * .22;
    final notRight = size.width * .36;
    final andLeft = size.width * .61;
    final andRight = size.width * .82;
    final top = size.height * .28;
    final bottom = size.height * .72;
    // Den NOT-Ausgang auf den ersten AND-Eingang ausrichten.
    final notY = size.height * .42;
    final notTop = notY - size.height * .22;
    final notBottom = notY + size.height * .22;
    // Die AND-Eingänge sind gleichmäßig über den Gatterkörper verteilt.
    final andInputYs = [size.height * .42, size.height * .58];
    final inputStart = 24.0;
    final andInputStart = andLeft - math.min(size.width * .18, 84);
    final outputEnd = size.width - 28;
    final labelSize = (size.width * .030).clamp(9.0, 12.0);
    final valueSize = (size.width * .035).clamp(10.0, 13.0);
    final labelGap = (size.width * .014).clamp(4.0, 7.0);

    canvas.drawLine(Offset(inputStart, notY), Offset(notLeft, notY), wire);
    canvas.drawLine(
      Offset(andInputStart, andInputYs[1]),
      Offset(andLeft, andInputYs[1]),
      wire,
    );
    final notOutputStart = notRight + 12;
    canvas.drawLine(Offset(notOutputStart, notY), Offset(andLeft, notY), wire);
    canvas.drawLine(
      Offset(andRight, centerY),
      Offset(outputEnd, centerY),
      wire,
    );

    final notShape = Path()
      ..moveTo(notLeft, notTop)
      ..lineTo(notRight, notY)
      ..lineTo(notLeft, notBottom)
      ..close();
    canvas.drawPath(notShape, gate);
    canvas.drawCircle(Offset(notRight + 6, notY), 5, gate);

    final andShape = Path()
      ..moveTo(andLeft, top)
      ..lineTo(andLeft + 16, top)
      ..cubicTo(andRight - 4, top, andRight, centerY - 24, andRight, centerY)
      ..cubicTo(
        andRight,
        centerY + 24,
        andRight - 4,
        bottom,
        andLeft + 16,
        bottom,
      )
      ..lineTo(andLeft, bottom)
      ..close();
    canvas.drawPath(andShape, gate);

    _text(
      canvas,
      'A',
      Offset(inputStart + 2, notY - labelGap - labelSize),
      colors.text,
      labelSize,
    );
    _text(
      canvas,
      '$input',
      Offset(inputStart + 2, notY + labelGap),
      colors.text,
      valueSize,
    );
    _text(
      canvas,
      'Ā',
      Offset(notRight + 12, notY - labelGap - labelSize),
      colors.text,
      labelSize,
    );
    _text(
      canvas,
      '$andInput',
      Offset(andInputStart + 2, andInputYs[1] + labelGap),
      colors.text,
      valueSize,
    );
    _text(
      canvas,
      'S₁',
      Offset(andInputStart + 2, andInputYs[1] - labelGap - labelSize),
      colors.text,
      labelSize,
    );
    _text(
      canvas,
      'S₁′',
      Offset(andRight + 4, centerY - labelGap - labelSize),
      colors.text,
      labelSize,
    );
    _text(
      canvas,
      '$output',
      Offset(andRight + 4, centerY + labelGap),
      colors.text,
      valueSize,
    );
    _text(canvas, 'NOT', Offset(notLeft + 12, top - 22), colors.text, 12);
    _text(canvas, 'AND', Offset(andLeft + 13, top - 22), colors.text, 12);

    final inputProgress = (progress / .28).clamp(0.0, 1.0);
    if (progress < .28) {
      _dot(
        canvas,
        Offset(inputStart + (notLeft - inputStart) * inputProgress, notY),
        input == 1,
      );
    }
    final secondProgress = (progress / .55).clamp(0.0, 1.0);
    if (progress < .55) {
      _dot(
        canvas,
        Offset(
          andInputStart + (andLeft - andInputStart) * secondProgress,
          andInputYs[1],
        ),
        andInput == 1,
      );
    }
    if (progress >= .28) {
      final chainProgress = ((progress - .28) / .27).clamp(0.0, 1.0);
      if (progress < .55) {
        final x = notOutputStart + (andLeft - notOutputStart) * chainProgress;
        _dot(canvas, Offset(x, notY), inverted == 1);
      }
    }
    if (progress >= .72) {
      final outputProgress = ((progress - .72) / .28).clamp(0.0, 1.0);
      _dot(
        canvas,
        Offset(andRight + (outputEnd - andRight) * outputProgress, centerY),
        output == 1,
      );
    }
  }

  void _dot(Canvas canvas, Offset point, bool isOne) {
    canvas.drawCircle(
      point,
      4.5,
      Paint()
        ..color = isOne ? colors.primary : colors.secondary
        ..style = PaintingStyle.fill,
    );
  }

  void _text(
    Canvas canvas,
    String value,
    Offset offset,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _NotAndChainPainter oldDelegate) =>
      oldDelegate.input != input ||
      oldDelegate.andInput != andInput ||
      oldDelegate.inverted != inverted ||
      oldDelegate.output != output ||
      oldDelegate.progress != progress ||
      oldDelegate.colors != colors;
}

/// Zeigt Eingangsbit und gespeichertes Ausgangsbit eines getakteten Flipflops.
class FlipFlopDiagram extends StatelessWidget {
  const FlipFlopDiagram({this.input = 0, this.output = 0, super.key});

  final int input;
  final int output;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 150,
    child: CustomPaint(
      painter: _FlipFlopPainter(
        input: input,
        output: output,
        colors: context.colors,
      ),
      size: Size.infinite,
    ),
  );
}

class _FlipFlopPainter extends CustomPainter {
  _FlipFlopPainter({
    required this.input,
    required this.output,
    required this.colors,
  });

  final int input;
  final int output;
  final AppColorPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = colors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final outline = Paint()
      ..color = colors.text
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final left = 42.0;
    final boxLeft = size.width * .34;
    final boxRight = size.width * .68;
    final top = 32.0;
    final bottom = 118.0;
    final centerY = (top + bottom) / 2;
    final textSize = (size.width * .045).clamp(9.0, 13.0);
    canvas.drawRect(Rect.fromLTRB(boxLeft, top, boxRight, bottom), outline);
    canvas.drawLine(Offset(left, centerY), Offset(boxLeft, centerY), line);
    canvas.drawLine(
      Offset(boxRight, centerY),
      Offset(size.width - 42, centerY),
      line,
    );
    canvas.drawLine(Offset(boxLeft + 18, 12), Offset(boxLeft + 18, top), line);
    final clock = Path()
      ..moveTo(boxLeft + 11, top - 10)
      ..lineTo(boxLeft + 25, top - 10)
      ..lineTo(boxLeft + 18, top)
      ..close();
    canvas.drawPath(clock, line);
    _text(canvas, 'D', Offset(8, centerY - 22), fontSize: textSize);
    _text(canvas, '$input', Offset(12, centerY - 2), fontSize: textSize);
    _text(
      canvas,
      'Q',
      Offset(size.width - 34, centerY - 22),
      fontSize: textSize,
    );
    _text(
      canvas,
      '$output',
      Offset(size.width - 28, centerY - 2),
      fontSize: textSize,
    );
    _centerText(canvas, 'CLK', boxLeft + 18, 0, textSize);
    _centerText(
      canvas,
      'Flip-Flop',
      (boxLeft + boxRight) / 2,
      centerY - 10,
      textSize,
    );
  }

  void _text(
    Canvas canvas,
    String value,
    Offset offset, {
    required double fontSize,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: colors.text,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _centerText(
    Canvas canvas,
    String value,
    double centerX,
    double y,
    double fontSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: colors.text,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(centerX - painter.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant _FlipFlopPainter oldDelegate) =>
      oldDelegate.input != input ||
      oldDelegate.output != output ||
      oldDelegate.colors != colors;
}

/// Stellt berechnete Folgezustandsbits den bereits gespeicherten Bits gegenüber.
class ClockStorageDiagram extends StatelessWidget {
  const ClockStorageDiagram({
    this.calculatedBits = const [1, 0],
    this.storedBits = const [1, 0],
    super.key,
  });

  final List<int> calculatedBits;
  final List<int> storedBits;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 180,
    child: CustomPaint(
      painter: _ClockStoragePainter(
        calculatedBits: calculatedBits,
        storedBits: storedBits,
        colors: context.colors,
      ),
      size: Size.infinite,
    ),
  );
}

class _ClockStoragePainter extends CustomPainter {
  _ClockStoragePainter({
    required this.calculatedBits,
    required this.storedBits,
    required this.colors,
  });

  final List<int> calculatedBits;
  final List<int> storedBits;
  final AppColorPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = colors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final box = Paint()
      ..color = colors.text
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = colors.surface
      ..style = PaintingStyle.fill;
    final left = 42.0;
    final boxLeft = size.width * .38;
    final boxRight = size.width * .68;
    final top = 38.0;
    final bottom = 142.0;
    final ys = [72.0, 112.0];

    canvas.drawRect(Rect.fromLTRB(boxLeft, top, boxRight, bottom), fill);
    canvas.drawRect(Rect.fromLTRB(boxLeft, top, boxRight, bottom), box);
    for (var index = 0; index < ys.length; index++) {
      final y = ys[index];
      canvas.drawLine(Offset(left, y), Offset(boxLeft, y), line);
      canvas.drawLine(Offset(boxRight, y), Offset(size.width - 42, y), line);
      _text(
        canvas,
        'D${index == 0 ? '₁' : '₀'}',
        Offset(8, y - 22),
        colors.text,
      );
      _text(canvas, '${calculatedBits[index]}', Offset(10, y - 4), colors.text);
      _text(
        canvas,
        'S${index == 0 ? '₁' : '₀'}',
        Offset(size.width - 34, y - 22),
        colors.text,
      );
      _text(
        canvas,
        '${storedBits[index]}',
        Offset(size.width - 28, y - 4),
        colors.text,
      );
    }
    final clockX = boxLeft + (boxRight - boxLeft) / 2;
    canvas.drawLine(Offset(clockX, 12), Offset(clockX, top), line);
    final arrow = Path()
      ..moveTo(clockX - 7, top - 10)
      ..lineTo(clockX + 7, top - 10)
      ..lineTo(clockX, top)
      ..close();
    canvas.drawPath(arrow, line);
    _text(canvas, 'CLK', Offset(clockX - 17, 0), colors.text);
    _text(
      canvas,
      'D → Flip-Flops → S',
      Offset(size.width * .27, bottom + 10),
      colors.text,
    );
  }

  void _text(Canvas canvas, String value, Offset offset, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ClockStoragePainter oldDelegate) =>
      !listEquals(oldDelegate.calculatedBits, calculatedBits) ||
      !listEquals(oldDelegate.storedBits, storedBits) ||
      oldDelegate.colors != colors;
}

class _DigitalGatePainter extends CustomPainter {
  _DigitalGatePainter({
    required this.type,
    required this.inputs,
    required this.inputLabels,
    required this.inputInverted,
    required this.outputLabel,
    required this.output,
    required this.progress,
    required this.colors,
    required this.highlight,
  });

  final DigitalGateType type;
  final List<int> inputs;
  final List<String>? inputLabels;
  final List<bool>? inputInverted;
  final String? outputLabel;
  final int output;
  final double progress;
  final AppColorPalette colors;
  final bool highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final wire = Paint()
      ..color = highlight ? colors.primary : colors.mutedText
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const inputEnd = .42;
    const gateEnd = .64;
    final gateIsActive = progress >= inputEnd;
    final outputIsActive = progress >= gateEnd;
    final gatePaint = Paint()
      ..color = gateIsActive && highlight ? colors.primary : colors.text
      ..strokeWidth = gateIsActive && highlight ? 4 : 3
      ..style = PaintingStyle.stroke;
    // Der Gatterkörper ist deckend. Dadurch bleiben Inversionskreise an Eingängen hinter
    // der Gattergrenze, statt darüber zu erscheinen.
    final gateFill = Paint()
      ..color = colors.surface
      ..style = PaintingStyle.fill;
    final centerY = size.height / 2;
    final gateLeft = size.width * .40;
    final gateRight = size.width * .68;
    final gateTop = size.height * .25;
    final gateBottom = size.height * .75;
    // Die Mitte einer kubischen Kurve erreicht ihre Kontrollpunkte nicht. Die
    // AND-Kontrollpunkte werden daher nach außen verschoben, damit `gateRight` die sichtbare rechte Kante ist.
    final andControlRight = gateRight + (gateRight - (gateLeft + 34)) / 3;
    // AND hat eine gerade Eingangskante, OR und XOR haben eine gebogene.
    final gateInputX = switch (type) {
      DigitalGateType.not => gateLeft,
      DigitalGateType.and => gateLeft + 10,
      _ => gateLeft + 28,
    };
    final straightInputX = switch (type) {
      DigitalGateType.not => gateLeft,
      DigitalGateType.and => gateLeft + 10,
      _ => gateLeft,
    };

    double curveParameterForY(double y) {
      // Den genauen Punkt suchen, an dem die OR/XOR-Eingangskurve diese Eingangshöhe
      // erreicht. So kreuzen die Leitungen die Kurve nicht.
      var low = 0.0;
      var high = 1.0;
      for (var iteration = 0; iteration < 16; iteration++) {
        final t = (low + high) / 2;
        final curveY = _cubic(
          bottom: gateBottom,
          control: gateBottom - 24,
          control2: gateTop + 24,
          top: gateTop,
          t: t,
        );
        if (curveY > y) {
          low = t;
        } else {
          high = t;
        }
      }
      return (low + high) / 2;
    }

    double xorOuterInputX(double y) {
      // XOR-Eingangsleitungen enden am zusätzlichen äußeren Bogen. Der kurze Abschnitt
      // zwischen beiden Bögen bleibt bewusst ohne Leitung.
      final t = curveParameterForY(y);
      return _cubic(
        bottom: gateLeft + 16,
        control: gateLeft + 32,
        control2: gateLeft + 32,
        top: gateLeft + 16,
        t: t,
      );
    }

    final inputYs = type == DigitalGateType.not
        ? [centerY]
        : [size.height * .36, size.height * .64];
    final wireStartX = 42.0;

    for (var index = 0; index < inputYs.length; index++) {
      final y = inputYs[index];
      final inverted =
          inputInverted != null &&
          index < inputInverted!.length &&
          inputInverted![index];
      final inputConnectionX = type == DigitalGateType.xor
          ? xorOuterInputX(y)
          : straightInputX;
      // Ein Inversionskreis am Eingang bleibt außerhalb des Gatterkörpers. Seine rechte Kante
      // berührt die gerade AND-Eingangskante, sodass die deckende Gatterfläche
      // den Kreis nicht halbiert.
      final bubbleX = type == DigitalGateType.and
          ? inputConnectionX - 5
          : inputConnectionX + 1;
      canvas.drawLine(
        Offset(wireStartX, y),
        Offset(inverted ? bubbleX - 5 : inputConnectionX, y),
        wire,
      );
      _text(canvas, '${inputs[index]}', Offset(2, y - 11), colors.text, 16);
      if (inputLabels != null && index < inputLabels!.length) {
        _text(canvas, inputLabels![index], Offset(16, y - 27), colors.text, 12);
      }
      if (inverted) {
        canvas.drawCircle(Offset(bubbleX, y), 5, gatePaint);
      }
      final inputProgress = (progress / inputEnd).clamp(0.0, 1.0);
      final inputX =
          wireStartX + (inputConnectionX - wireStartX) * inputProgress;
      final inputSignal = Paint()
        ..color = inputs[index] == 1 ? colors.primary : colors.secondary
        ..style = PaintingStyle.fill;
      if (progress < inputEnd) {
        canvas.drawCircle(Offset(inputX, y), 4.5, inputSignal);
      }
    }

    final gate = Path();
    if (type == DigitalGateType.not) {
      gate
        ..moveTo(gateLeft, gateTop)
        ..lineTo(gateRight, centerY)
        ..lineTo(gateLeft, gateBottom)
        ..close();
      canvas.drawPath(gate, gateFill);
      canvas.drawPath(gate, gatePaint);
      canvas.drawCircle(Offset(gateRight + 6, centerY), 5, gatePaint);
    } else if (type == DigitalGateType.and) {
      gate
        ..moveTo(gateInputX, gateTop)
        ..lineTo(gateLeft + 34, gateTop)
        ..cubicTo(
          andControlRight,
          gateTop,
          andControlRight,
          gateBottom,
          gateLeft + 34,
          gateBottom,
        )
        ..lineTo(gateInputX, gateBottom)
        ..close();
      canvas.drawPath(gate, gateFill);
      canvas.drawPath(gate, gatePaint);
    } else {
      gate
        ..moveTo(gateInputX, gateTop)
        ..cubicTo(
          gateLeft + 35,
          gateTop,
          gateRight,
          centerY - 24,
          gateRight,
          centerY,
        )
        ..cubicTo(
          gateRight,
          centerY + 24,
          gateLeft + 35,
          gateBottom,
          gateInputX,
          gateBottom,
        )
        // Die Eingangsseite eines OR-Gatters ist gebogen und keine gerade Kante.
        ..cubicTo(
          gateLeft + 45,
          gateBottom - 24,
          gateLeft + 45,
          gateTop + 24,
          gateInputX,
          gateTop,
        )
        ..close();
      canvas.drawPath(gate, gateFill);
      canvas.drawPath(gate, gatePaint);
      if (type == DigitalGateType.xor) {
        final extra = Path()
          // Der zweite XOR-Bogen verläuft nah und parallel zum Gatterkörper.
          ..moveTo(gateLeft + 16, gateTop)
          ..cubicTo(
            gateLeft + 32,
            gateTop + 24,
            gateLeft + 32,
            gateBottom - 24,
            gateLeft + 16,
            gateBottom,
          );
        canvas.drawPath(extra, gatePaint);
      }
    }

    final outputX = type == DigitalGateType.not ? gateRight + 14 : gateRight;
    final outputWire = Paint()
      ..color = outputIsActive && highlight ? colors.primary : wire.color
      ..strokeWidth = outputIsActive && highlight ? 4 : wire.strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(outputX, centerY),
      Offset(size.width - 42, centerY),
      outputWire,
    );
    _text(
      canvas,
      '$output',
      Offset(size.width - 20, centerY - 11),
      colors.text,
      16,
    );
    if (outputLabel != null) {
      _text(
        canvas,
        outputLabel!,
        Offset(size.width - 42, centerY - 27),
        colors.text,
        12,
      );
    }
    _text(
      canvas,
      type.name.toUpperCase(),
      Offset(gateLeft + 8, gateTop - 25),
      colors.text,
      13,
    );

    if (outputIsActive) {
      final outputProgress = ((progress - gateEnd) / (1 - gateEnd)).clamp(
        0.0,
        1.0,
      );
      final dot = Offset(
        outputX + (size.width - 42 - outputX) * outputProgress,
        centerY,
      );
      final outputSignal = Paint()
        ..color = output == 1 ? colors.primary : colors.secondary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dot, 4.5, outputSignal);
    }
  }

  double _cubic({
    required double bottom,
    required double control,
    required double control2,
    required double top,
    required double t,
  }) {
    final inverse = 1 - t;
    return inverse * inverse * inverse * bottom +
        3 * inverse * inverse * t * control +
        3 * inverse * t * t * control2 +
        t * t * t * top;
  }

  void _text(
    Canvas canvas,
    String value,
    Offset offset,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _DigitalGatePainter oldDelegate) =>
      oldDelegate.type != type ||
      !listEquals(oldDelegate.inputs, inputs) ||
      !listEquals(oldDelegate.inputLabels, inputLabels) ||
      !listEquals(oldDelegate.inputInverted, inputInverted) ||
      oldDelegate.outputLabel != outputLabel ||
      oldDelegate.output != output ||
      oldDelegate.progress != progress ||
      oldDelegate.colors != colors;
}
