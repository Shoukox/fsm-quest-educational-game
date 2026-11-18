import 'dart:async';
import 'package:bachelor/features/lesson/data/lesson_skip_service.dart';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/app_scaffold.dart';
import 'package:bachelor/features/lesson/data/lesson_local_data_source.dart';
import 'package:bachelor/features/lesson/data/lesson_repository.dart';
import 'package:bachelor/features/lesson/domain/logic/lesson_checker.dart';
import 'package:bachelor/features/lesson/domain/logic/lesson_progress_calculator.dart';
import 'package:bachelor/features/lesson/domain/logic/task_evaluator.dart';
import 'package:bachelor/features/lesson/domain/models/answer_result.dart';
import 'package:bachelor/features/lesson/domain/models/lesson.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';
import 'package:bachelor/features/lesson/domain/models/task_submission.dart';
import 'package:bachelor/features/lesson/domain/models/task_feedback.dart';
import 'package:bachelor/features/lesson/presentation/widgets/feedback_panel.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter1/intro_fsm_story.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter2/circuit_tables_story.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter2/digital_gates_review_story.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_progress_bar.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_task_interaction.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_story_registry.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter1/states_lesson_story.dart';
import 'package:bachelor/features/lesson/presentation/widgets/chapter1/transitions_lesson_story.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/controllers/mascot_controller.dart';
import 'package:bachelor/features/mascot/presentation/widgets/exit_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({required this.lessonId, this.skipStory = false, super.key});

  final String lessonId;
  final bool skipStory;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  static const _repository = LessonRepository(LessonLocalDataSource());
  static const _checker = LessonChecker();
  static const _taskEvaluator = TaskEvaluator();

  int _taskIndex = 0;
  int _visibleSteps = 1;
  int _firstTryCorrectAnswers = 0;
  int? _secondsLeft;
  Timer? _timer;
  final Set<String> _tasksWithMistakes = {};
  final Set<String> _completedTaskIds = {};
  bool _hasStarted = false;
  bool _shortcutActive = false;
  bool _showHint = false;
  bool _storyCompleted = false;
  double _storyProgress = 0;
  bool _isExitDialogVisible = false;
  AnswerResult? _feedback;
  StructuredTaskFeedback? _taskFeedback;

  @override
  void initState() {
    super.initState();
    _storyCompleted =
        widget.skipStory ||
        !const {
          'intro',
          'states',
          'transitions',
          'chapter_2',
          'chapter2-gates-review',
          'automata-creation-description',
          'automata-creation-tables',
          'chapter4-completion',
        }.contains(widget.lessonId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (const {
        'intro',
        'states',
        'transitions',
        'chapter_2',
        'chapter2-gates-review',
      }.contains(widget.lessonId)) {
        ref.read(mascotControllerProvider.notifier).hide();
      }
      _showStartDialog();
    });
  }

  Future<void> _showStartDialog() async {
    final lesson = _repository.getLessonById(widget.lessonId);
    if (lesson == null) return;

    // Die Beschreibung sofort anzeigen; Speicherzugriffe dürfen den Start nicht blockieren.
    final canSkip = _hasStoryForLesson && !widget.skipStory
        ? ref
              .read(lessonSkipServiceProvider)
              .isAvailable(widget.lessonId)
              .catchError((Object _) => false)
        : Future.value(false);
    final action = await showDialog<_LessonStartAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _LessonStartDialog(lesson: lesson, canSkip: canSkip),
    );
    if (!mounted) return;
    if (action == _LessonStartAction.skip) {
      try {
        final consumed = await ref
            .read(lessonSkipServiceProvider)
            .consume(widget.lessonId);
        if (!mounted) return;
        if (consumed) {
          setState(() {
            _shortcutActive = true;
            _storyCompleted = true;
            _hasStarted = true;
          });
          return;
        }
      } catch (_) {
        // Scheitert das Speichern des Versuchs, bleibt der normale Lektionsstart verfügbar.
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('lesson.start.skipUnavailable'))),
      );
      await _showStartDialog();
    } else if (action == _LessonStartAction.start) {
      setState(() => _hasStarted = true);
    } else {
      context.go('/');
    }
  }

  void _startTimerIfNeeded(Lesson lesson) {
    if (_timer != null) return;
    final timeLimit = lesson.timeLimitSeconds;
    if (timeLimit != null) {
      _secondsLeft = timeLimit;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final remaining = _secondsLeft;
        if (remaining == null) return;
        if (remaining <= 1) {
          _finishLesson();
        } else {
          setState(() => _secondsLeft = remaining - 1);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_hasStarted) {
          _requestExitLesson();
        } else {
          context.go('/');
        }
      },
      child: _buildLessonContent(context),
    );
  }

  Widget _buildLessonContent(BuildContext context) {
    final l10n = context.l10n;
    final lesson = _repository.getLessonById(widget.lessonId);
    if (lesson == null || lesson.tasks.isEmpty) {
      return AppScaffold(
        title: l10n.t('nav.learn'),
        leading: _lessonExitButton(),
        body: Center(
          child: Text(
            l10n.t('lesson.notFound', args: {'lessonId': widget.lessonId}),
          ),
        ),
      );
    }

    if (!_hasStarted) {
      return AppScaffold(
        title: l10n.t(lesson.title),
        leading: _lessonExitButton(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _startTimerIfNeeded(lesson);

    if (!_storyCompleted) {
      final registeredStory = LessonStoryRegistry.builderFor(lesson.storyId);
      return AppScaffold(
        title: l10n.t(lesson.title),
        leading: _lessonExitButton(),
        body: _lessonFrame(
          progress: _lessonProgress(lesson),
          child: registeredStory != null
              ? registeredStory(
                  onFinished: _finishStory,
                  onProgressChanged: _updateStoryProgress,
                )
              : switch (widget.lessonId) {
                  'intro' => IntroFsmStory(
                    onFinished: _finishStory,
                    onProgressChanged: _updateStoryProgress,
                  ),
                  'states' => StatesLessonStory(
                    onFinished: _finishStory,
                    onProgressChanged: _updateStoryProgress,
                  ),
                  'transitions' => TransitionsLessonStory(
                    onFinished: _finishStory,
                    onProgressChanged: _updateStoryProgress,
                  ),
                  'chapter2-gates-review' => DigitalGatesReviewStory(
                    onFinished: _finishStory,
                    onProgressChanged: _updateStoryProgress,
                  ),
                  _ => CircuitTablesStory(
                    onFinished: _finishStory,
                    onProgressChanged: _updateStoryProgress,
                  ),
                },
        ),
      );
    }

    final task = lesson.tasks[_taskIndex];
    final shouldShowHintButton =
        task.hint != null && _feedback?.isCorrect == false;
    final progress = _lessonProgress(lesson);
    final isLessonComplete = _isLessonComplete(lesson);

    return AppScaffold(
      title: lesson.isPracticalTest
          ? l10n.t('lesson.practicalTest')
          : l10n.t(lesson.title),
      leading: _lessonExitButton(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LessonProgressBar(value: progress, isSuccess: isLessonComplete),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LessonHeader(
                    lesson: lesson,
                    taskIndex: _taskIndex,
                    taskCount: lesson.tasks.length,
                    secondsLeft: _secondsLeft,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        _TaskPrompt(task: task),
                        if (task.inputSteps.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _InputSteps(
                            steps: task.inputSteps,
                            visibleSteps: _visibleSteps,
                            onShowNext: _visibleSteps < task.inputSteps.length
                                ? () => setState(() => _visibleSteps++)
                                : null,
                          ),
                        ],
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                alignment: Alignment.topCenter,
                                child: child,
                              ),
                            );
                          },
                          child: shouldShowHintButton
                              ? Column(
                                  key: const ValueKey('hint-controls'),
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (_showHint) _HintBox(task.hint!),
                                    TextButton.icon(
                                      onPressed: _toggleHint,
                                      style: const ButtonStyle(
                                        enableFeedback: false,
                                      ),
                                      icon: const Icon(Icons.lightbulb_outline),
                                      label: Text(
                                        _showHint
                                            ? l10n.t('lesson.hideHint')
                                            : l10n.t('lesson.needHint'),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('hint-hidden'),
                                ),
                        ),
                        const SizedBox(height: 8),
                        LessonTaskInteraction(
                          key: ValueKey(task.id),
                          task: task,
                          enabled: _feedback?.isCorrect != true,
                          feedback: _taskFeedback,
                          onEdited: _clearTaskFeedback,
                          onSubmitted: (submission) =>
                              _checkSubmission(task, submission),
                        ),
                        if (_feedback?.isCorrect == true) ...[
                          const SizedBox(height: 8),
                          FeedbackPanel(
                            message: _feedback!.message,
                            isCorrect: _feedback!.isCorrect,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: _taskIndex == lesson.tasks.length - 1
                        ? l10n.t('lesson.finish')
                        : l10n.t('lesson.next'),
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _feedback?.isCorrect == true ? _nextTask : null,
                  ),
                  if (lesson.isPracticalTest &&
                      _completedTaskIds.length < lesson.tasks.length &&
                      lesson.isPassingScore(
                        lesson.chapterId == 'chapter1'
                            ? _firstTryCorrectAnswers
                            : _completedTaskIds.length,
                      )) ...[
                    const SizedBox(height: 8),
                    AppOutlinedButton(
                      key: const ValueKey('submit-passed-test'),
                      label: l10n.t('lesson.submitTest'),
                      onPressed: _finishLesson,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lessonExitButton() {
    return IconButton(
      onPressed: _hasStarted
          ? _requestExitLesson
          : AppHaptics.wrapButton(() => context.go('/')),
      tooltip: context.l10n.t('lessonExit.title'),
      icon: const Icon(Icons.close_rounded),
    );
  }

  Future<void> _requestExitLesson() async {
    if (!_hasStarted || _isExitDialogVisible || !mounted) return;
    _isExitDialogVisible = true;
    AppHaptics.warning();

    final l10n = context.l10n;
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ExitConfirmationDialog(
          title: l10n.t('lessonExit.title'),
          message: l10n.t('lessonExit.message'),
          cancelLabel: l10n.t('lessonExit.stay'),
          confirmLabel: l10n.t('lessonExit.confirm'),
        );
      },
    );

    _isExitDialogVisible = false;
    if (shouldExit == true && mounted) _exitLessonWithoutSaving();
  }

  void _exitLessonWithoutSaving() {
    _timer?.cancel();
    ref.read(mascotControllerProvider.notifier).hide();
    context.go(
      '/lesson/${widget.lessonId}/result'
      '?score=$_firstTryCorrectAnswers'
      '&stars=0'
      '&xp=0'
      '&coins=0'
      '&abandoned=true',
    );
  }

  void _finishStory() {
    setState(() {
      _storyCompleted = true;
      _storyProgress = 1;
    });
    ref.read(mascotControllerProvider.notifier).hide();
  }

  void _updateStoryProgress(double progress) {
    if (!mounted) return;
    setState(() => _storyProgress = progress.clamp(0.0, 1.0).toDouble());
  }

  Widget _lessonFrame({required double progress, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LessonProgressBar(value: progress),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  double _lessonProgress(Lesson lesson) {
    return LessonProgressCalculator.calculate(
      isPracticalTest: lesson.isPracticalTest,
      hasStory: _hasStoryForLesson,
      storyCompleted: _storyCompleted,
      storyProgress: _storyProgress,
      completedTaskCount: _completedTaskIds.length,
      taskCount: lesson.tasks.length,
    );
  }

  bool _isLessonComplete(Lesson lesson) {
    if (!_storyCompleted || _completedTaskIds.length < lesson.tasks.length) {
      return false;
    }
    return !lesson.isPracticalTest ||
        (lesson.chapterId == 'chapter1'
            ? lesson.isPassingScore(_firstTryCorrectAnswers)
            : _completedTaskIds.length >= lesson.minimumCorrectAnswers);
  }

  bool get _hasStoryForLesson => const {
    'intro',
    'states',
    'transitions',
    'chapter_2',
    'chapter2-gates-review',
    'automata-creation-description',
    'automata-creation-tables',
    'chapter4-completion',
  }.contains(widget.lessonId);

  void _checkAnswer(LessonTask task, String answer) {
    final result = _checker.checkAnswer(task, answer, context.l10n);
    _applyAnswerResult(task, result);
  }

  void _toggleHint() {
    if (!_showHint) AppHaptics.hint();
    setState(() => _showHint = !_showHint);
  }

  void _checkSubmission(LessonTask task, TaskSubmission submission) {
    if (submission is ChoiceTaskSubmission && task.payload == null) {
      _checkAnswer(task, submission.answerId);
      return;
    }

    final evaluation = _taskEvaluator.evaluate(task, submission);
    _taskFeedback = evaluation.feedback;
    final result = AnswerResult(
      isCorrect: evaluation.isCorrect,
      message: evaluation.isCorrect
          ? LessonChecker.correctMessage(task, context.l10n)
          : LessonChecker.wrongMessage(context.l10n, evaluation.feedbackKey),
      xp: evaluation.isCorrect ? 10 : 0,
    );
    _applyAnswerResult(task, result);
  }

  void _clearTaskFeedback() {
    if (_taskFeedback == null) return;
    setState(() {
      _taskFeedback = null;
      _feedback = null;
      _showHint = false;
    });
    ref.read(mascotControllerProvider.notifier).hide();
  }

  // Gelöste Aufgaben und Erstlösungen werden getrennt erfasst: Nach einem
  // Fehlversuch zählt eine spätere richtige Antwort weiterhin zum Abschluss,
  // aber nicht mehr zur Zahl der fehlerfreien Erstlösungen für die Sterne.
  void _applyAnswerResult(LessonTask task, AnswerResult result) {
    if (!mounted) return;
    if (_shortcutActive && !result.isCorrect) {
      _failShortcut();
      return;
    }
    if (result.isCorrect) {
      AppHaptics.success();
    } else {
      AppHaptics.warning();
    }
    setState(() {
      _feedback = result;
      if (result.isCorrect) _showHint = false;
      if (result.isCorrect) _completedTaskIds.add(task.id);
      if (result.isCorrect && !_tasksWithMistakes.contains(task.id)) {
        _firstTryCorrectAnswers++;
      }
      if (!result.isCorrect) _tasksWithMistakes.add(task.id);
    });
    if (result.isCorrect) {
      ref.read(mascotControllerProvider.notifier).hide();
    } else {
      ref
          .read(mascotControllerProvider.notifier)
          .show(text: result.message, pose: MascotPose.thinking);
    }
  }

  // Ein Fehler im direkten Testeinstieg führt zum regulären Lernablauf zurück.
  // Der bereits gespeicherte Verbrauch des Testeinstiegs wird dabei nicht aufgehoben.
  void _failShortcut() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _shortcutActive = false;
      _storyCompleted = false;
      _storyProgress = 0;
      _taskIndex = 0;
      _firstTryCorrectAnswers = 0;
      _completedTaskIds.clear();
      _tasksWithMistakes.clear();
      _feedback = null;
      _taskFeedback = null;
      _showHint = false;
    });
    ref.read(mascotControllerProvider.notifier).hide();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.t('lesson.start.skipFailed'))),
    );
  }

  void _nextTask() {
    final lesson = _repository.getLessonById(widget.lessonId);
    if (lesson == null) return;

    if (_taskIndex == lesson.tasks.length - 1) {
      _finishLesson();
      return;
    }

    setState(() {
      _taskIndex++;
      _visibleSteps = 1;
      _showHint = false;
      _feedback = null;
      _taskFeedback = null;
    });
    ref.read(mascotControllerProvider.notifier).hide();
  }

  void _finishLesson() {
    _timer?.cancel();
    if (!mounted) return;
    final lesson = _repository.getLessonById(widget.lessonId);
    if (lesson == null) return;
    if (_shortcutActive &&
        (lesson.starsForFirstTryAnswers(_firstTryCorrectAnswers) != 3 ||
            _completedTaskIds.length != lesson.tasks.length)) {
      _failShortcut();
      return;
    }
    // Kapitel 1 bewertet Erstlösungen; spätere Kapiteltests verwenden die Zahl
    // gelöster Aufgaben. Diese unterschiedlichen Bestehensregeln bleiben erhalten.
    final chapterFailed =
        lesson.isPracticalTest &&
        (lesson.chapterId == 'chapter1'
            ? !lesson.isPassingScore(_firstTryCorrectAnswers)
            : _completedTaskIds.length < lesson.minimumCorrectAnswers);
    if (chapterFailed) {
      ref.read(mascotControllerProvider.notifier).hide();
      context.go(
        '/lesson/${widget.lessonId}/result'
        '?score=$_firstTryCorrectAnswers'
        '&stars=0'
        '&xp=0'
        '&coins=0'
        '&total=${lesson.tasks.length}'
        '&minimum=${lesson.minimumCorrectAnswers}'
        '&chapterFailed=true',
      );
      return;
    }
    final stars = lesson.starsForFirstTryAnswers(_firstTryCorrectAnswers);
    final earnedXp = lesson.xpForStars(stars);
    final earnedCoins = lesson.coinsForStars(stars);
    ref.read(mascotControllerProvider.notifier).hide();
    context.go(
      '/lesson/${widget.lessonId}/result'
      '?score=$_firstTryCorrectAnswers'
      '&stars=$stars'
      '&xp=$earnedXp'
      '&coins=$earnedCoins'
      '&total=${lesson.tasks.length}'
      '&minimum=${lesson.minimumCorrectAnswers}',
    );
  }
}

enum _LessonStartAction { start, skip }

class _LessonStartDialog extends StatelessWidget {
  const _LessonStartDialog({required this.lesson, required this.canSkip});

  final Lesson lesson;
  final Future<bool> canSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: AppHaptics.wrapButton(
                      () => Navigator.of(context).pop(),
                    ),
                    tooltip: l10n.t('common.cancel'),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Text(
                  l10n.t(lesson.title),
                  textAlign: TextAlign.center,
                  style: context.textStyles.title,
                ),
                if (lesson.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.t(lesson.subtitle!),
                    textAlign: TextAlign.center,
                    style: context.textStyles.body,
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.t('lesson.summary.${lesson.id}'),
                  key: const ValueKey('lesson-start-description'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RewardPreview(
                        icon: Icons.bolt_rounded,
                        value: '${lesson.xpReward} XP',
                        color: context.colors.xp,
                      ),
                      _RewardPreview(
                        icon: Icons.monetization_on_rounded,
                        value: '${lesson.coinReward}',
                        color: context.colors.warning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.t('lesson.start.rewardHint'),
                  textAlign: TextAlign.center,
                  style: context.textStyles.caption,
                ),
                if (lesson.minimumCorrectRatio > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.t(
                      'lesson.chapterTest.requirement',
                      args: {
                        'minimum': lesson.minimumCorrectAnswers,
                        'total': lesson.tasks.length,
                      },
                    ),
                    textAlign: TextAlign.center,
                    style: context.textStyles.caption.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  label: l10n.t('lesson.start.button'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  onPressed: () =>
                      Navigator.of(context).pop(_LessonStartAction.start),
                ),
                FutureBuilder<bool>(
                  future: canSkip,
                  builder: (context, snapshot) => snapshot.data != true
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              l10n.t('lesson.start.skipHint'),
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              key: const ValueKey('lesson-skip-once'),
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(_LessonStartAction.skip),
                              child: Text(l10n.t('lesson.start.skipOnce')),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardPreview extends StatelessWidget {
  const _RewardPreview({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: context.textStyles.body.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.lesson,
    required this.taskIndex,
    required this.taskCount,
    required this.secondsLeft,
  });

  final Lesson lesson;
  final int taskIndex;
  final int taskCount;
  final int? secondsLeft;

  @override
  Widget build(BuildContext context) {
    final seconds = secondsLeft;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t(lesson.title),
                style: context.textStyles.heading,
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.t(
                  'lesson.taskCount',
                  args: {'current': taskIndex + 1, 'total': taskCount},
                ),
                style: context.textStyles.caption,
              ),
            ],
          ),
        ),
        if (seconds != null)
          Chip(
            avatar: const Icon(Icons.timer_outlined, size: 18),
            label: Text('${seconds}s'),
          ),
      ],
    );
  }
}

class _TaskPrompt extends StatelessWidget {
  const _TaskPrompt({required this.task});

  final LessonTask task;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(context.l10n.t(task.difficulty.localizationKey)),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(context.l10n.t(task.resolvedKind.localizationKey)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (task.concept != null) ...[
            Text(
              context.l10n.t(task.concept!),
              style: context.textStyles.caption,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            context.l10n.t(task.prompt),
            key: const ValueKey('task-prompt-text'),
            style: context.textStyles.body.copyWith(fontSize: 13, height: 1.3),
          ),
          if (task.instruction != null) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.t(task.instruction!),
              style: context.textStyles.body.copyWith(
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InputSteps extends StatelessWidget {
  const _InputSteps({
    required this.steps,
    required this.visibleSteps,
    required this.onShowNext,
  });

  final List<String> steps;
  final int visibleSteps;
  final VoidCallback? onShowNext;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.t('lesson.trace'), style: context.textStyles.body),
          const SizedBox(height: 8),
          for (final step in steps.take(visibleSteps))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.chevron_right, size: 18),
                  const SizedBox(width: 4),
                  Expanded(child: Text(context.l10n.t(step))),
                ],
              ),
            ),
          if (onShowNext != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onShowNext,
                child: Text(context.l10n.t('lesson.showNext')),
              ),
            ),
        ],
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox(this.hint);

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: context.colors.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(context.l10n.t(hint))),
          ],
        ),
      ),
    );
  }
}
