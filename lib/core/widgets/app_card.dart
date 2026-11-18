import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Einheitliche Inhaltskarte mit Innenabstand sowie optional transparentem Rahmen und Hintergrund.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.isTransparent = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isTransparent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isTransparent ? Colors.transparent : context.colors.surface,
        border: Border.all(
          color: isTransparent ? Colors.transparent : context.colors.border,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
