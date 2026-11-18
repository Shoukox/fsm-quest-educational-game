/// Zustandsdaten mit stabiler ID, sichtbarem Namen, Moore-Ausgabe und relativer Zeichenposition.
class FsmState {
  const FsmState({
    required this.id,
    required this.label,
    this.output = '',
    this.x = 0.5,
    this.y = 0.5,
  });

  final String id;
  final String label;
  final String output;
  /// Horizontale Position relativ zur Zeichenbreite; die freie Sandbox erlaubt Werte außerhalb 0 bis 1.
  final double x;
  /// Vertikale Position relativ zur Zeichenhöhe; eine Ansichtsverschiebung verändert sie nicht.
  final double y;

  FsmState copyWith({
    String? id,
    String? label,
    String? output,
    double? x,
    double? y,
  }) {
    return FsmState(
      id: id ?? this.id,
      label: label ?? this.label,
      output: output ?? this.output,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
