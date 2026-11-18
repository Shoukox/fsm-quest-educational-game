import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Gemeinsamer Seitenrahmen mit optionaler Titelleiste und geschütztem Inhaltsbereich.
/// Ohne [title] wird keine AppBar erzeugt; [leading] und [actions] gehören nur zu ihr.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.actions,
    this.leading,
    super.key,
  });

  /// Ein Titel aktiviert die obere Leiste; `null` lässt den Inhalt ohne Titelleiste stehen.
  final String? title;
  /// Seiteninhalt, der durch SafeArea Abstand zu Systemleisten und Aussparungen hält.
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              leading: leading,
              actions: actions,
              backgroundColor: context.colors.background,
              // Farbüberlagerung und Scrollschatten bleiben aus, damit die Leiste optisch
              // mit dem Seitenhintergrund verbunden bleibt, auch wenn Inhalt darunter scrollt.
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              scrolledUnderElevation: 0,
            ),
      body: SafeArea(child: body),
    );
  }
}
