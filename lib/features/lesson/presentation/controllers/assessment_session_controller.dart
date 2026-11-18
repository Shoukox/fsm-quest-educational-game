import 'package:flutter/foundation.dart';
import 'package:bachelor/features/lesson/domain/models/assessment_policy.dart';

/// Erfasst Testfrist, gelöste Aufgaben und Erstlösungen einer Prüfungssitzung.
class AssessmentSessionController extends ChangeNotifier {
  AssessmentSessionController({
    this.policy = const AssessmentPolicy(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;
  final AssessmentPolicy policy;
  final DateTime Function() _now;
  DateTime? _deadline;
  bool finished = false;
  final solved = <String>{};
  final firstTry = <String>{};
  int get secondsLeft => _deadline == null
      ? policy.timeLimitSeconds
      : _deadline!
            .difference(_now())
            .inSeconds
            .clamp(0, policy.timeLimitSeconds);
  // Ein erneuter Start verlängert eine bereits gesetzte Frist nicht.
  void start() {
    _deadline ??= _now().add(Duration(seconds: policy.timeLimitSeconds));
    notifyListeners();
  }

  /// Liefert nur bei einer neu aufgenommenen Aufgaben-ID `true`.
  bool recordSolved(String taskId, {required bool firstAttempt}) {
    if (finished) return false;
    final added = solved.add(taskId);
    if (firstAttempt) firstTry.add(taskId);
    notifyListeners();
    return added;
  }

  bool get passed => solved.length >= policy.minimumSolved;
  /// Beendet eine gestartete Sitzung bei Fristablauf genau einmal.
  bool timeout() {
    if (finished || _deadline == null || secondsLeft > 0) return false;
    finished = true;
    notifyListeners();
    return true;
  }

  void finish() {
    if (finished) return;
    finished = true;
    notifyListeners();
  }
}
