import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_widget.dart';
import 'package:flutter/material.dart';

/// Bestätigungsdialog mit Maskottchen; gibt beim Verlassen `true` und beim Bleiben `false` zurück.
class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    super.key,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MascotWidget(pose: MascotPose.sad, size: 150),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textStyles.title,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.textStyles.body,
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stayButton = OutlinedButton(
                    onPressed: AppHaptics.wrapButton(
                      () => Navigator.of(context).pop(false),
                    ),
                    child: Text(
                      cancelLabel,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  );
                  final leaveButton = AppButton(
                    label: confirmLabel,
                    icon: const Icon(Icons.exit_to_app_rounded),
                    onPressed: () => Navigator.of(context).pop(true),
                  );
                  if (constraints.maxWidth < 340) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: double.infinity, child: stayButton),
                        const SizedBox(height: 10),
                        leaveButton,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: stayButton),
                      const SizedBox(width: 10),
                      Expanded(child: leaveButton),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
