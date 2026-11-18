import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Zeigt eine Rückmeldung mit Erfolgssymbol oder Fehlersymbol und passender Farbe.
class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    required this.message,
    required this.isCorrect,
    super.key,
  });

  final String message;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? context.colors.primary : context.colors.danger;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.error, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
