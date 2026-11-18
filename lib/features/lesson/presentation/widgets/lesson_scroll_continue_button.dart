import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Scrollt zuerst zum Ende einer Szene und schaltet danach zur nächsten Szene weiter.
/// Eine optionale Lesebestätigung kann auch für vollständig sichtbare Szenen verlangt werden.
class LessonScrollContinueButton extends StatefulWidget {
  const LessonScrollContinueButton({
    required this.controller,
    required this.onContinue,
    this.requireReadAcknowledgement = false,
    super.key,
  });

  final ScrollController controller;
  final VoidCallback? onContinue;
  final bool requireReadAcknowledgement;

  @override
  State<LessonScrollContinueButton> createState() =>
      _LessonScrollContinueButtonState();
}

class _LessonScrollContinueButtonState
    extends State<LessonScrollContinueButton> {
  static const _bottomTolerance = 12.0;
  // Zunächst zum Lesen auffordern. Nach dem Layout kann direkt weitergeschaltet
  // werden, wenn die Szene vollständig sichtbar ist und keine Bestätigung verlangt.
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updatePosition);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  @override
  void didUpdateWidget(covariant LessonScrollContinueButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_updatePosition);
    widget.controller.addListener(_updatePosition);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePosition);
    super.dispose();
  }

  void _updatePosition() {
    if (!mounted || !widget.controller.hasClients) return;
    final position = widget.controller.position;
    if (position.maxScrollExtent <= _bottomTolerance) {
      final atBottom = !widget.requireReadAcknowledgement;
      if (atBottom != _isAtBottom) setState(() => _isAtBottom = atBottom);
      return;
    }
    final atBottom =
        position.pixels >= position.maxScrollExtent - _bottomTolerance;
    if (atBottom == _isAtBottom) return;
    setState(() => _isAtBottom = atBottom);
  }

  void _handlePressed() {
    if (_isAtBottom) {
      widget.onContinue?.call();
      return;
    }
    if (!widget.controller.hasClients) return;
    if (widget.controller.position.maxScrollExtent <= _bottomTolerance) {
      setState(() => _isAtBottom = true);
      widget.onContinue?.call();
      return;
    }
    widget.controller.animateTo(
      widget.controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDown = !_isAtBottom;
    return AppButton(
      label: isDown
          ? context.l10n.t('common.down')
          : context.l10n.t('common.next'),
      icon: isDown
          ? const Icon(Icons.keyboard_arrow_down_rounded)
          : const Icon(Icons.arrow_forward_rounded),
      onPressed: _isAtBottom && widget.onContinue == null
          ? null
          : _handlePressed,
    );
  }
}
