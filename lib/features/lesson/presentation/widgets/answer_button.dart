import 'package:bachelor/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Antwortoption mit voller verfügbarer Breite und bis zu zwei Textzeilen.
class AnswerButton extends StatelessWidget {
  const AnswerButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      allowLabelWrap: true,
      expandToAvailableWidth: true,
    );
  }
}
