import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Zeigt die Lernserie mit passender Singular- oder Pluralübersetzung für die Tageszahl.
class StreakWidget extends StatelessWidget {
  const StreakWidget({required this.days, super.key});

  final int days;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        context.l10n.t(
          days == 1 ? 'progress.streak' : 'progress.streakPlural',
          args: {'days': days},
        ),
      ),
    );
  }
}
