import 'package:bachelor/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Kompakte Belohnungskarte mit zentriertem Titel; das Einblenden übernimmt der Aufrufer.
class RewardPopup extends StatelessWidget {
  const RewardPopup({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Text(title, textAlign: TextAlign.center));
  }
}
