import 'package:bachelor/core/services/local_storage_service.dart';
import 'package:bachelor/features/fsm_sandbox/domain/logic/fsm_sandbox_tools.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';

/// Speichert den gezeichneten Sandbox-Automaten für spätere Besuche lokal.
class FsmSandboxStorage {
  FsmSandboxStorage({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  static const sandboxFsmKey = 'sandbox_fsm';

  final LocalStorageService _storage;

  Future<Fsm?> load() async {
    return FsmJsonCodec.decode(await _storage.getString(sandboxFsmKey));
  }

  Future<void> save(Fsm fsm) {
    return _storage.setString(sandboxFsmKey, FsmJsonCodec.encode(fsm));
  }
}
