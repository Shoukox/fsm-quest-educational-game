import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:flutter/material.dart';

/// Primäre App-Schaltfläche mit haptischer Rückmeldung und anpassbarer Textdarstellung.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.allowLabelWrap = false,
    this.expandToAvailableWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  /// Erlaubt bis zu zwei Textzeilen; andernfalls wird die Beschriftung einzeilig verkleinert.
  final bool allowLabelWrap;
  final bool expandToAvailableWidth;

  @override
  Widget build(BuildContext context) {
    final child = allowLabelWrap
        ? SizedBox(
            width: double.infinity,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          );

    final button = FilledButton(
      onPressed: AppHaptics.wrapButton(onPressed),
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(enableFeedback: false),
      child: child,
    );

    return expandToAvailableWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Sekundäre Aktion mit denselben Mindestmaßen und derselben Form wie [AppButton].
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: AppHaptics.wrapButton(onPressed),
      icon: icon ?? const SizedBox.shrink(),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.primary,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: context.colors.primary),
      ).copyWith(enableFeedback: false),
    );
  }
}
