import 'package:bachelor/features/mascot/domain/models/mascot_message.dart';
import 'package:flutter/widgets.dart';

/// Verbindet die Einführung mit den tatsächlichen Positionen der Navigationseinträge.
/// Der Seitenrahmen markiert Einträge über [wrap]; [rectFor] liefert deren globale
/// Grenzen sowohl für die untere Navigation als auch für die seitliche Leiste.
abstract final class MascotGuideAnchors {
  static final Map<MascotGuideTarget, GlobalKey> _keys = {
    for (final target in MascotGuideTarget.values)
      target: GlobalKey(debugLabel: 'mascot-anchor-${target.name}'),
  };

  /// Liefert das Führungsziel zum Navigationsindex oder `null`, wenn dort kein Ziel vorgesehen ist.
  static MascotGuideTarget? targetForNavigationIndex(int index) {
    return switch (index) {
      0 => MascotGuideTarget.lessonPath,
      1 => MascotGuideTarget.sandbox,
      2 => MascotGuideTarget.progress,
      4 => MascotGuideTarget.settings,
      _ => null,
    };
  }

  /// Markiert [child] als den Navigationseintrag an [index].
  static Widget wrap(int index, Widget child) {
    final target = targetForNavigationIndex(index);
    if (target == null) return child;
    return KeyedSubtree(key: _keys[target], child: child);
  }

  static final GlobalKey _railKey = GlobalKey(debugLabel: 'mascot-anchor-rail');

  /// Markiert die gesamte seitliche Navigation, damit das Maskottchen daneben stehen kann.
  static Widget wrapRail(Widget rail) =>
      KeyedSubtree(key: _railKey, child: rail);

  /// Globale Grenzen der seitlichen Navigation; bei unterer Navigation fehlt dieser Bereich.
  static Rect? railRect() => _rectOf(_railKey);

  /// Globale Grenzen des Zieleintrags oder `null`, solange er nicht angeordnet ist.
  static Rect? rectFor(MascotGuideTarget target) => _rectOf(_keys[target]);

  static Rect? _rectOf(GlobalKey? key) {
    final renderObject = key?.currentContext?.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return null;
    }
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
}
