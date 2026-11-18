import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Eine Tabellenzeile mit aktuellem Zustand, Eingabe und zugehörigem Folgezustand.
class CircuitTransitionRow {
  const CircuitTransitionRow({
    required this.state,
    required this.input,
    required this.nextState,
  });

  final String state;
  final String input;
  final String nextState;
}

/// Eine Tabellenzeile mit Zustand und zustandsabhängiger Ausgabe.
class CircuitOutputRow {
  const CircuitOutputRow({required this.state, required this.output});

  final String state;
  final String output;
}

typedef CircuitCellBuilder<T> =
    Widget Function(BuildContext context, T row, int index);

/// Gemeinsame Übergangstabelle für die Schaltungslektionen und ihre Aufgaben.
/// Der Aufrufer liefert Zeilen und Ergebniszellen; Layout und Markierungen bleiben hier.
class CircuitTransitionTable extends StatelessWidget {
  const CircuitTransitionTable({
    required this.rows,
    required this.nextStateCellBuilder,
    this.selectedRow,
    this.onSelectRow,
    this.errorRows = const {},
    this.scaleToFit = false,
    super.key,
  });

  final List<CircuitTransitionRow> rows;
  final CircuitCellBuilder<CircuitTransitionRow> nextStateCellBuilder;
  final int? selectedRow;
  final ValueChanged<int>? onSelectRow;

  /// Vom Aufgaben-Feedback als falsch gemeldete Zeilen; in der Warnfarbe gezeichnet.
  final Set<int> errorRows;
  final bool scaleToFit;

  @override
  Widget build(BuildContext context) {
    final table = Table(
      border: TableBorder.all(
        color: context.colors.border.withValues(alpha: .85),
      ),
      columnWidths: const {
        0: FixedColumnWidth(82),
        1: FixedColumnWidth(82),
        2: FixedColumnWidth(174),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _headerRow(context, const ['Zustand', 'Eingang', 'Nächster Zustand']),
        _headerRow(context, const ['S', 'A', 'S′']),
        for (var index = 0; index < rows.length; index++)
          _dataRow(context, index),
      ],
    );
    return CircuitTableScale(width: 338, scaleToFit: scaleToFit, child: table);
  }

  TableRow _dataRow(BuildContext context, int index) {
    final row = rows[index];
    final selected = selectedRow == index;
    final error = errorRows.contains(index);
    return TableRow(
      decoration: _rowDecoration(context, selected: selected, error: error),
      children: [
        _cell(context, _stateLabel(context, row.state, error: error), index),
        _cell(context, Text(row.input, textAlign: TextAlign.center), index),
        _cell(
          context,
          nextStateCellBuilder(context, row, index),
          index,
          result: true,
        ),
      ],
    );
  }

  TableCell _cell(
    BuildContext context,
    Widget child,
    int index, {
    bool result = false,
  }) {
    final content = Container(
      color: result
          ? (errorRows.contains(index)
                    ? context.colors.danger
                    : context.colors.primary)
                .withValues(alpha: .12)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: child,
    );
    return TableCell(
      child: onSelectRow == null
          ? content
          : InkWell(onTap: () => onSelectRow!(index), child: content),
    );
  }
}

/// Ausgabetabelle mit austauschbaren Ergebniszellen, Zeilenauswahl und Fehlermarkierungen.
class CircuitOutputTable extends StatelessWidget {
  const CircuitOutputTable({
    required this.rows,
    required this.outputCellBuilder,
    this.selectedRow,
    this.onSelectRow,
    this.errorRows = const {},
    this.scaleToFit = false,
    super.key,
  });

  final List<CircuitOutputRow> rows;
  final CircuitCellBuilder<CircuitOutputRow> outputCellBuilder;
  final int? selectedRow;
  final ValueChanged<int>? onSelectRow;

  /// Vom Aufgaben-Feedback als falsch gemeldete Zeilen; in der Warnfarbe gezeichnet.
  final Set<int> errorRows;
  final bool scaleToFit;

  @override
  Widget build(BuildContext context) {
    final table = Table(
      border: TableBorder.all(
        color: context.colors.border.withValues(alpha: .85),
      ),
      columnWidths: const {0: FixedColumnWidth(110), 1: FixedColumnWidth(110)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _headerRow(context, const ['Zustand', 'Ausgang']),
        _headerRow(context, const ['S', 'Y']),
        for (var index = 0; index < rows.length; index++)
          _dataRow(context, index),
      ],
    );
    return CircuitTableScale(width: 220, scaleToFit: scaleToFit, child: table);
  }

  TableRow _dataRow(BuildContext context, int index) {
    final row = rows[index];
    final selected = selectedRow == index;
    final error = errorRows.contains(index);
    return TableRow(
      decoration: _rowDecoration(context, selected: selected, error: error),
      children: [
        _cell(context, _stateLabel(context, row.state, error: error), index),
        _cell(
          context,
          outputCellBuilder(context, row, index),
          index,
          result: true,
        ),
      ],
    );
  }

  TableCell _cell(
    BuildContext context,
    Widget child,
    int index, {
    bool result = false,
  }) {
    final content = Container(
      color: result
          ? (errorRows.contains(index)
                    ? context.colors.danger
                    : context.colors.primary)
                .withValues(alpha: .12)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: child,
    );
    return TableCell(
      child: onSelectRow == null
          ? content
          : InkWell(onTap: () => onSelectRow!(index), child: content),
    );
  }
}

/// Passt eine Tabelle an die verfügbare Breite an oder erlaubt horizontales Scrollen.
class CircuitTableScale extends StatelessWidget {
  const CircuitTableScale({
    required this.width,
    required this.child,
    this.scaleToFit = false,
    super.key,
  });

  final double width;
  final Widget child;
  final bool scaleToFit;

  @override
  Widget build(BuildContext context) {
    if (!scaleToFit) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: child),
        ),
      ),
    );
  }
}

TableRow _headerRow(BuildContext context, List<String> labels) => TableRow(
  decoration: BoxDecoration(color: context.colors.surfaceRaised),
  children: [
    for (final label in labels)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
  ],
);

BoxDecoration _rowDecoration(
  BuildContext context, {
  required bool selected,
  required bool error,
}) => BoxDecoration(
  color: error
      ? context.colors.danger.withValues(alpha: .14)
      : selected
      ? context.colors.primary.withValues(alpha: .12)
      : null,
);

/// Zustandszelle; eine falsche Zeile erhält zusätzlich ein Symbol, damit sie nicht
/// allein durch die Farbe gekennzeichnet ist.
Widget _stateLabel(BuildContext context, String state, {required bool error}) {
  final text = Text(state, textAlign: TextAlign.center);
  if (!error) return text;
  return Semantics(
    label: 'error',
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 16, color: context.colors.danger),
        const SizedBox(width: 4),
        text,
      ],
    ),
  );
}
