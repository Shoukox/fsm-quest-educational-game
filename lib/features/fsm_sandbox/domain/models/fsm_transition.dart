class FsmTransition {
  const FsmTransition({
    required this.fromStateId,
    required this.toStateId,
    required this.symbol,
  });

  final String fromStateId;
  final String toStateId;
  final String symbol;

  String get id => '$fromStateId::$symbol::$toStateId';

  /// Liest die Eingabe vor dem ersten `/` aus einer Mealy-Beschriftung.
  /// Ohne Trennzeichen gilt die gesamte, außen bereinigte Beschriftung als Eingabe.
  String get inputSymbol {
    final separator = symbol.indexOf('/');
    if (separator < 0) return symbol.trim();
    return symbol.substring(0, separator).trim();
  }

  /// Liest die Mealy-Ausgabe nach dem ersten `/`; ohne Trennzeichen bleibt sie leer.
  String get outputValue {
    final separator = symbol.indexOf('/');
    if (separator < 0) return '';
    return symbol.substring(separator + 1).trim();
  }

  FsmTransition copyWith({
    String? fromStateId,
    String? toStateId,
    String? symbol,
  }) {
    return FsmTransition(
      fromStateId: fromStateId ?? this.fromStateId,
      toStateId: toStateId ?? this.toStateId,
      symbol: symbol ?? this.symbol,
    );
  }
}
