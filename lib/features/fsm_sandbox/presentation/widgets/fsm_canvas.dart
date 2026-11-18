import 'package:bachelor/features/fsm_sandbox/presentation/controllers/fsm_editor_controller.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/widgets/fsm_workspace.dart';
import 'package:flutter/material.dart';

/// Bindet eine Arbeitsfläche an einen eigenen Editor-Controller und verwaltet dessen Lebensdauer.
class FsmCanvas extends StatefulWidget {
  const FsmCanvas({super.key});

  @override
  State<FsmCanvas> createState() => _FsmCanvasState();
}

class _FsmCanvasState extends State<FsmCanvas> {
  late final FsmEditorController _controller = FsmEditorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FsmWorkspace(controller: _controller, height: double.infinity);
  }
}
