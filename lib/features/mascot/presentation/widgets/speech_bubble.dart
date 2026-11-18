import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

const _speechTailSize = Size(26, 18);
const _speechTailTipOffset = 26 * 0.72;

/// Responsive Sprechblase mit anpassbarer Pfeilposition und mehrzeiligem Inhalt.
/// Es muss genau eine Textquelle übergeben werden: [message] oder [messageSpan].
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    this.message,
    this.messageSpan,
    this.tailAlignment = 0.78,
    super.key,
  }) : assert(
         message != null || messageSpan != null,
         'Provide either message or messageSpan.',
       ),
       assert(
         message == null || messageSpan == null,
         'Provide only one of message or messageSpan.',
       );

  final String? message;
  final InlineSpan? messageSpan;
  final double tailAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final compactness = ((availableWidth - 220) / 200).clamp(0.0, 1.0);
        final fontSize = 13.5 + (2.5 * compactness);
        final horizontalPadding = availableWidth < 320 ? 12.0 : 20.0;
        final verticalPadding = availableWidth < 320 ? 12.0 : 16.0;
        final textStyle = context.textStyles.body.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
        );
        final maxTailLeft = availableWidth - 44;
        final tailLeft = maxTailLeft <= 18.0
            ? ((constraints.maxWidth - _speechTailSize.width) / 2)
                  .clamp(0.0, double.infinity)
                  .toDouble()
            : (constraints.maxWidth * tailAlignment - _speechTailTipOffset)
                  .clamp(18.0, maxTailLeft)
                  .toDouble();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(color: context.colors.border),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow,
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: messageSpan == null
                    ? Text(
                        message!,
                        style: textStyle,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                        textWidthBasis: TextWidthBasis.parent,
                      )
                    : RichText(
                        text: TextSpan(
                          style: textStyle,
                          children: [messageSpan!],
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
              ),
            ),
            Positioned(
              left: tailLeft,
              bottom: -13,
              child: CustomPaint(
                size: _speechTailSize,
                painter: _SpeechBubbleTailPainter(
                  fillColor: context.colors.surface,
                  borderColor: context.colors.border,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SpeechBubbleTailPainter extends CustomPainter {
  const _SpeechBubbleTailPainter({
    required this.fillColor,
    required this.borderColor,
  });

  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.72, size.height)
      ..close();

    canvas
      ..drawPath(
        path,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
  }

  @override
  bool shouldRepaint(covariant _SpeechBubbleTailPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
