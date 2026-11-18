import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Stellt den Aufgabentitel als Überschrift in einer gemeinsamen App-Karte dar.
class TaskCard extends StatelessWidget {
  const TaskCard({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Text(title, style: context.textStyles.heading));
  }
}
