import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Konkrete Türsituationen für die bildgestützten Zustandsbeispiele des ersten Kapitels.
enum LessonDoorImageState { closed, open, opening, closing }

/// Zeichnet eine Türsituation im Zustandsknoten, bevor die formale Zustandsnotation eingeführt wird.
class LessonDoorImage extends StatelessWidget {
  const LessonDoorImage({
    required this.state,
    this.size = 52,
    this.color,
    super.key,
  });

  final LessonDoorImageState state;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LessonDoorImagePainter(
        color: color ?? context.colors.primary,
        state: state,
      ),
    );
  }
}

/// Bildgestützter Zustandsknoten mit Beschriftung, optionaler Ausgabe und Aktivitätsmarkierung.
class LessonDoorImageNode extends StatelessWidget {
  const LessonDoorImageNode({
    required this.label,
    required this.state,
    this.isCurrent = false,
    this.isMuted = false,
    this.output,
    super.key,
  });

  final String label;
  final LessonDoorImageState state;
  final bool isCurrent;
  final bool isMuted;
  final String? output;

  @override
  Widget build(BuildContext context) {
    final borderColor = isMuted
        ? context.colors.mutedText
        : isCurrent
        ? context.colors.primary
        : context.colors.secondary;
    final imageColor = isMuted ? context.colors.mutedText : borderColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 104,
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent
            ? context.colors.stateHighlight
            : context.colors.surfaceRaised,
        border: Border.all(color: borderColor, width: isCurrent ? 5 : 2),
        boxShadow: [
          if (isCurrent)
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.34),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LessonDoorImage(state: state, size: 48, color: imageColor),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.textStyles.caption.copyWith(
                color: isMuted ? context.colors.mutedText : context.colors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (output case final value?)
              Text(
                value,
                textAlign: TextAlign.center,
                style: context.textStyles.caption.copyWith(
                  color: isMuted
                      ? context.colors.mutedText
                      : context.colors.warning,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LessonDoorImagePainter extends CustomPainter {
  const _LessonDoorImagePainter({required this.color, required this.state});

  final Color color;
  final LessonDoorImageState state;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.shortestSide * 0.065).clamp(1.5, 4.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final frame = Rect.fromLTWH(
      size.width * 0.18,
      size.height * 0.10,
      size.width * 0.64,
      size.height * 0.78,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(size.shortestSide * 0.07)),
      stroke,
    );

    final movement = switch (state) {
      LessonDoorImageState.closed => 0.0,
      LessonDoorImageState.open => 0.26,
      LessonDoorImageState.opening => 0.14,
      LessonDoorImageState.closing => 0.08,
    };
    final gap = size.width * movement;
    final panelTop = frame.top + size.height * 0.04;
    final panelBottom = frame.bottom - size.height * 0.04;
    final panelHeight = panelBottom - panelTop;
    final panelWidth = (frame.width - gap) / 2;
    final leftPanel = Rect.fromLTWH(
      frame.left + gap / 2,
      panelTop,
      panelWidth,
      panelHeight,
    );
    final rightPanel = Rect.fromLTWH(
      frame.left + frame.width / 2 + gap / 2,
      panelTop,
      panelWidth,
      panelHeight,
    );

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          leftPanel,
          Radius.circular(size.shortestSide * 0.04),
        ),
        fill,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          rightPanel,
          Radius.circular(size.shortestSide * 0.04),
        ),
        fill,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          leftPanel,
          Radius.circular(size.shortestSide * 0.04),
        ),
        stroke,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          rightPanel,
          Radius.circular(size.shortestSide * 0.04),
        ),
        stroke,
      );

    final handleRadius = size.shortestSide * 0.035;
    canvas
      ..drawCircle(
        Offset(leftPanel.right - handleRadius * 2, frame.center.dy),
        handleRadius,
        stroke,
      )
      ..drawCircle(
        Offset(rightPanel.left + handleRadius * 2, frame.center.dy),
        handleRadius,
        stroke,
      )
      ..drawLine(
        Offset(frame.left, frame.bottom + size.height * 0.04),
        Offset(frame.right, frame.bottom + size.height * 0.04),
        stroke,
      );

    if (state == LessonDoorImageState.opening ||
        state == LessonDoorImageState.closing) {
      final arrowY = size.height * 0.94;
      final arrowDirection = state == LessonDoorImageState.opening ? -1.0 : 1.0;
      final arrowStart = Offset(size.width * 0.40, arrowY);
      final arrowEnd = Offset(size.width * 0.60, arrowY);
      final start = arrowDirection < 0 ? arrowEnd : arrowStart;
      final end = arrowDirection < 0 ? arrowStart : arrowEnd;
      canvas.drawLine(start, end, stroke);
      canvas.drawLine(
        end,
        end + Offset(-arrowDirection * size.width * 0.08, -size.height * 0.05),
        stroke,
      );
      canvas.drawLine(
        end,
        end + Offset(-arrowDirection * size.width * 0.08, size.height * 0.05),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LessonDoorImagePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.state != state;
  }
}

/// Darstellung eines Drehkreuzes mit Schiebeklappe, wie bei U-Bahnen oder Toiletten.
enum LessonTurnstileImageState { locked, unlocked, opening, closing }

class LessonTurnstileImage extends StatelessWidget {
  const LessonTurnstileImage({
    required this.state,
    this.size = 52,
    this.color,
    super.key,
  });

  final LessonTurnstileImageState state;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LessonTurnstileImagePainter(
        color: color ?? context.colors.primary,
        state: state,
      ),
    );
  }
}

class LessonTurnstileImageNode extends StatelessWidget {
  const LessonTurnstileImageNode({
    required this.label,
    required this.state,
    this.isCurrent = false,
    this.isMuted = false,
    super.key,
  });

  final String label;
  final LessonTurnstileImageState state;
  final bool isCurrent;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final borderColor = isMuted
        ? context.colors.mutedText
        : isCurrent
        ? context.colors.primary
        : context.colors.secondary;
    final imageColor = isMuted ? context.colors.mutedText : borderColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 104,
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent
            ? context.colors.stateHighlight
            : context.colors.surfaceRaised,
        border: Border.all(color: borderColor, width: isCurrent ? 5 : 2),
        boxShadow: [
          if (isCurrent)
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.34),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LessonTurnstileImage(state: state, size: 48, color: imageColor),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.textStyles.caption.copyWith(
                color: isMuted ? context.colors.mutedText : context.colors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animiertes physisches Drehkreuz für den Simulator der Zustandslektion.
class LessonTurnstileAnimation extends StatefulWidget {
  const LessonTurnstileAnimation({
    required this.isUnlocked,
    this.height = 150,
    super.key,
  });

  final bool isUnlocked;
  final double height;

  @override
  State<LessonTurnstileAnimation> createState() =>
      _LessonTurnstileAnimationState();
}

class _LessonTurnstileAnimationState extends State<LessonTurnstileAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
    value: widget.isUnlocked ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant LessonTurnstileAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isUnlocked == widget.isUnlocked) return;
    if (widget.isUnlocked) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: CustomPaint(
            painter: _LessonTurnstileScenePainter(
              color: context.colors.primary,
              accentColor: context.colors.warning,
              progress: Curves.easeInOutCubic.transform(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _LessonTurnstileImagePainter extends CustomPainter {
  const _LessonTurnstileImagePainter({
    required this.color,
    required this.state,
  });

  final Color color;
  final LessonTurnstileImageState state;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.shortestSide * 0.065).clamp(1.5, 4.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    final guide = Paint()
      ..color = color.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.strokeWidth * 0.72
      ..strokeCap = StrokeCap.round;

    final progress = switch (state) {
      LessonTurnstileImageState.locked => 0.0,
      LessonTurnstileImageState.unlocked => 1.0,
      LessonTurnstileImageState.opening => 0.5,
      LessonTurnstileImageState.closing => 0.5,
    };
    _drawSlidingGates(
      canvas,
      size: size,
      progress: progress,
      housingStroke: stroke,
      housingFill: fill,
      gateStroke: stroke,
      gateFill: fill,
      guideStroke: guide,
    );

    if (state == LessonTurnstileImageState.opening ||
        state == LessonTurnstileImageState.closing) {
      _drawSlidingDirection(
        canvas,
        size: size,
        opening: state == LessonTurnstileImageState.opening,
        paint: guide,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LessonTurnstileImagePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.state != state;
  }
}

class _LessonTurnstileScenePainter extends CustomPainter {
  const _LessonTurnstileScenePainter({
    required this.color,
    required this.accentColor,
    required this.progress,
  });

  final Color color;
  final Color accentColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final mutedStroke = Paint()
      ..color = color.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final gateStroke = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final gateFill = Paint()
      ..color = accentColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final guide = Paint()
      ..color = color.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final floorY = height * 0.88;
    canvas
      ..drawLine(
        Offset(width * 0.06, floorY),
        Offset(width * 0.94, floorY),
        mutedStroke,
      )
      ..drawLine(
        Offset(width * 0.16, floorY),
        Offset(width * 0.30, height * 0.77),
        mutedStroke,
      )
      ..drawLine(
        Offset(width * 0.84, floorY),
        Offset(width * 0.70, height * 0.77),
        mutedStroke,
      );

    _drawSlidingGates(
      canvas,
      size: size,
      progress: progress,
      housingStroke: mutedStroke,
      housingFill: fill,
      gateStroke: gateStroke,
      gateFill: gateFill,
      guideStroke: guide,
    );

    final indicatorFill = Paint()
      ..color = accentColor.withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;
    final indicator = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.43, height * 0.11, width * 0.14, height * 0.09),
      const Radius.circular(5),
    );
    canvas
      ..drawRRect(indicator, indicatorFill)
      ..drawRRect(indicator, stroke);
  }

  @override
  bool shouldRepaint(covariant _LessonTurnstileScenePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.progress != progress;
  }
}

void _drawSlidingGates(
  Canvas canvas, {
  required Size size,
  required double progress,
  required Paint housingStroke,
  required Paint housingFill,
  required Paint gateStroke,
  required Paint gateFill,
  required Paint guideStroke,
}) {
  final width = size.width;
  final height = size.height;
  final housingTop = height * 0.28;
  final housingBottom = height * 0.86;
  final housingWidth = width * 0.17;
  final leftHousingX = width * 0.09;
  final rightHousingX = width * 0.74;
  final panelWidth = width * 0.12;
  final panelTop = height * 0.38;
  final panelBottom = height * 0.70;
  final leftClosedX = width * 0.50 - panelWidth;
  final rightClosedX = width * 0.50;
  final leftOpenX = leftHousingX + housingWidth - panelWidth;
  final rightOpenX = rightHousingX;
  final leftX = leftClosedX + (leftOpenX - leftClosedX) * progress;
  final rightX = rightClosedX + (rightOpenX - rightClosedX) * progress;

  final leftHousing = RRect.fromRectAndRadius(
    Rect.fromLTWH(
      leftHousingX,
      housingTop,
      housingWidth,
      housingBottom - housingTop,
    ),
    Radius.circular(width * 0.035),
  );
  final rightHousing = RRect.fromRectAndRadius(
    Rect.fromLTWH(
      rightHousingX,
      housingTop,
      housingWidth,
      housingBottom - housingTop,
    ),
    Radius.circular(width * 0.035),
  );
  canvas
    ..drawRRect(leftHousing, housingFill)
    ..drawRRect(leftHousing, housingStroke)
    ..drawRRect(rightHousing, housingFill)
    ..drawRRect(rightHousing, housingStroke);

  final guideY = panelBottom + height * 0.055;
  canvas
    ..drawLine(
      Offset(leftOpenX + panelWidth / 2, guideY),
      Offset(leftClosedX + panelWidth / 2, guideY),
      guideStroke,
    )
    ..drawLine(
      Offset(rightClosedX + panelWidth / 2, guideY),
      Offset(rightOpenX + panelWidth / 2, guideY),
      guideStroke,
    );

  final leftPanel = RRect.fromRectAndRadius(
    Rect.fromLTWH(leftX, panelTop, panelWidth, panelBottom - panelTop),
    Radius.circular(width * 0.025),
  );
  final rightPanel = RRect.fromRectAndRadius(
    Rect.fromLTWH(rightX, panelTop, panelWidth, panelBottom - panelTop),
    Radius.circular(width * 0.025),
  );
  canvas
    ..drawRRect(leftPanel, gateFill)
    ..drawRRect(leftPanel, gateStroke)
    ..drawRRect(rightPanel, gateFill)
    ..drawRRect(rightPanel, gateStroke);

  final indicatorRadius = width * 0.035;
  for (final x in [
    leftHousingX + housingWidth / 2,
    rightHousingX + housingWidth / 2,
  ]) {
    canvas
      ..drawCircle(
        Offset(x, housingTop - height * 0.035),
        indicatorRadius,
        housingFill,
      )
      ..drawCircle(
        Offset(x, housingTop - height * 0.035),
        indicatorRadius,
        housingStroke,
      );
  }
}

void _drawSlidingDirection(
  Canvas canvas, {
  required Size size,
  required bool opening,
  required Paint paint,
}) {
  final width = size.width;
  final y = size.height * 0.16;
  final leftStart = Offset(width * 0.47, y);
  final leftEnd = Offset(width * (opening ? 0.34 : 0.50), y);
  final rightStart = Offset(width * 0.53, y);
  final rightEnd = Offset(width * (opening ? 0.66 : 0.50), y);
  _drawArrow(canvas, start: leftStart, end: leftEnd, paint: paint);
  _drawArrow(canvas, start: rightStart, end: rightEnd, paint: paint);
}

void _drawArrow(
  Canvas canvas, {
  required Offset start,
  required Offset end,
  required Paint paint,
}) {
  canvas.drawLine(start, end, paint);
  final vector = end - start;
  final distance = vector.distance;
  if (distance == 0) return;
  final direction = vector / distance;
  final normal = Offset(-direction.dy, direction.dx);
  const arrowSize = 4.0;
  final base = end - direction * arrowSize * 1.6;
  canvas
    ..drawLine(end, base + normal * arrowSize, paint)
    ..drawLine(end, base - normal * arrowSize, paint);
}
