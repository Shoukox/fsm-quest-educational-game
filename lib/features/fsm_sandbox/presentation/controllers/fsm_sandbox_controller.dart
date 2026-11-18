import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fsmSandboxControllerProvider =
    NotifierProvider<FsmSandboxController, Fsm>(FsmSandboxController.new);

/// Stellt über Riverpod einen zunächst leeren Automaten als Sandbox-Zustand bereit.
class FsmSandboxController extends Notifier<Fsm> {
  @override
  Fsm build() {
    return const Fsm(states: [], transitions: []);
  }
}
