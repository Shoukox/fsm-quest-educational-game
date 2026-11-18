import 'package:flutter/material.dart';

/// Stellt eine Übergangsbeschriftung kompakt als Chip dar.
class TransitionLabelWidget extends StatelessWidget {
  const TransitionLabelWidget({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
