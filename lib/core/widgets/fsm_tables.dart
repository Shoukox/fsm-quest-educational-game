import 'package:flutter/material.dart';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/widgets/circuit_tables.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm_transition.dart';

/// Leitet Übergangszeilen aus Automat und Eingabealphabet ab.
/// Für Lektionen gelten feste Fachüberschriften; die Sandbox kann Zustandsnamen,
/// Startmarkierung, übersetzte Überschriften und widersprüchliche Übergänge anzeigen.
class FsmTransitionTable extends StatelessWidget {
  const FsmTransitionTable({
    required this.fsm,
    required this.inputAlphabet,
    this.showStateLabels = false,
    this.markInitialState = false,
    this.markConflicts = false,
    this.localizedHeaders = false,
    super.key,
  });

  final Fsm fsm;
  final List<String> inputAlphabet;
  final bool showStateLabels;
  final bool markInitialState;
  final bool markConflicts;
  final bool localizedHeaders;

  @override
  Widget build(BuildContext context) {
    final isMealy = fsm.outputMode == FsmOutputMode.mealy;
    final table = Table(
      border: TableBorder.all(
        color: context.colors.border.withValues(alpha: .85),
      ),
      columnWidths: {
        0: const FixedColumnWidth(96),
        1: const FixedColumnWidth(82),
        2: const FixedColumnWidth(160),
        if (isMealy) 3: const FixedColumnWidth(82),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _headerRow(context, [
          _heading(context, 'state', 'Zustand'),
          _heading(context, 'input', 'Eingang'),
          _heading(context, 'nextState', 'Nächster Zustand'),
          if (isMealy) _heading(context, 'output', 'Ausgang'),
        ]),
        _headerRow(context, ['S', 'A', 'S′', if (isMealy) 'Y']),
        for (final state in fsm.states)
          for (final input in inputAlphabet)
            _transitionRow(context, state.id, input, isMealy),
      ],
    );
    return CircuitTableScale(
      width: isMealy ? 420 : 338,
      scaleToFit: true,
      child: table,
    );
  }

  String _heading(BuildContext context, String key, String german) {
    return localizedHeaders ? context.l10n.t('fsmTable.$key') : german;
  }

  TableRow _transitionRow(
    BuildContext context,
    String stateId,
    String input,
    bool isMealy,
  ) {
    final matches = fsm.transitions
        .where(
          (transition) =>
              transition.fromStateId == stateId &&
              transition.inputSymbol == input,
        )
        .toList();
    final conflict = markConflicts && matches.length > 1;
    // Im Konfliktmodus alle passenden Übergänge zeigen, damit Mehrdeutigkeiten sichtbar bleiben.
    final shown = conflict ? matches : matches.take(1).toList();
    String join(String Function(FsmTransition) value) =>
        shown.isEmpty ? '-' : shown.map(value).join(' / ');

    return _dataRow(context, [
      _stateName(stateId, markInitial: true),
      input,
      join((transition) => _stateName(transition.toStateId)),
      if (isMealy) join((transition) => _orDash(transition.outputValue)),
    ], warningColumns: conflict ? {2, if (isMealy) 3} : const {});
  }

  String _stateName(String stateId, {bool markInitial = false}) {
    final name = showStateLabels
        ? fsm.stateById(stateId)?.label ?? stateId
        : stateId;
    final isInitial =
        markInitial && markInitialState && fsm.initialStateId == stateId;
    return isInitial ? '→ $name' : name;
  }
}

/// Zeigt zustandsabhängige Ausgaben mit optionalen Zustandsnamen und Startmarkierung.
class FsmOutputTable extends StatelessWidget {
  const FsmOutputTable({
    required this.fsm,
    this.showStateLabels = false,
    this.markInitialState = false,
    this.localizedHeaders = false,
    super.key,
  });

  final Fsm fsm;
  final bool showStateLabels;
  final bool markInitialState;
  final bool localizedHeaders;

  @override
  Widget build(BuildContext context) {
    final table = Table(
      border: TableBorder.all(
        color: context.colors.border.withValues(alpha: .85),
      ),
      columnWidths: const {0: FixedColumnWidth(120), 1: FixedColumnWidth(110)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _headerRow(context, [
          localizedHeaders ? context.l10n.t('fsmTable.state') : 'Zustand',
          localizedHeaders ? context.l10n.t('fsmTable.output') : 'Ausgang',
        ]),
        _headerRow(context, const ['S', 'Y']),
        for (final state in fsm.states)
          _dataRow(context, [
            [
              if (markInitialState && fsm.initialStateId == state.id) '→',
              showStateLabels ? state.label : state.id,
            ].join(' '),
            showStateLabels ? _orDash(state.output) : state.output,
          ]),
      ],
    );
    return CircuitTableScale(width: 230, scaleToFit: true, child: table);
  }
}

String _orDash(String value) => value.trim().isEmpty ? '-' : value;

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

TableRow _dataRow(
  BuildContext context,
  List<String> values, {
  Set<int> warningColumns = const {},
}) => TableRow(
  children: [
    for (var index = 0; index < values.length; index++)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        color: warningColumns.contains(index)
            ? context.colors.danger.withValues(alpha: .12)
            : null,
        child: Text(
          warningColumns.contains(index) ? '${values[index]} ⚠' : values[index],
          textAlign: TextAlign.center,
          style: warningColumns.contains(index)
              ? TextStyle(
                  color: context.colors.danger,
                  fontWeight: FontWeight.w700,
                )
              : null,
        ),
      ),
  ],
);
