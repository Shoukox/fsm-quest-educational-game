enum DigitalGateType { xor, and, not }

/// Wertet die unterstützten Gatter für binäre Eingaben aus; leere Eingaben ergeben 0.
abstract final class DigitalGateLogic {
  static int evaluate(DigitalGateType type, List<int> inputs) {
    if (inputs.isEmpty) return 0;
    return switch (type) {
      DigitalGateType.xor =>
        inputs.where((value) => value == 1).length.isOdd ? 1 : 0,
      DigitalGateType.and => inputs.every((value) => value == 1) ? 1 : 0,
      DigitalGateType.not => inputs.first == 0 ? 1 : 0,
    };
  }
}
