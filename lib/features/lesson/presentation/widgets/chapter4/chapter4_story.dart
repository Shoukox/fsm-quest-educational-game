import 'package:flutter/material.dart';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/fsm_diagram_preview.dart';
import 'package:bachelor/features/lesson/data/chapters/chapter4_content.dart';
import 'package:bachelor/features/lesson/data/chapters/chapter_fsm_fixtures.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_interaction_hint.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_scroll_continue_button.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_lesson_speech.dart';

/// Geführte Story zum Vervollständigen von Automaten im angezeigten Kapitel 3.
/// Der historische Klassenname bleibt erhalten; interaktive Szenen benötigen eine korrekte Auswahl.
class Chapter4Story extends StatefulWidget {
  const Chapter4Story({
    required this.onFinished,
    required this.onProgressChanged,
    super.key,
  });

  final VoidCallback onFinished;
  final ValueChanged<double> onProgressChanged;

  @override
  State<Chapter4Story> createState() => _Chapter4StoryState();
}

class _Chapter4StoryState extends State<Chapter4Story> {
  final _scrollController = ScrollController();
  final _completedScenes = <int>{};
  int _scene = 0;
  int _hintSignal = 0;
  String? _selectedAnswer;

  bool get _isLast => _scene == chapter4MainStory.scenes.length - 1;
  bool get _isInformational =>
      _scene == 0 || _scene == 1 || _scene == 2 || _isLast;
  bool get _canContinue =>
      _isInformational || _completedScenes.contains(_scene);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _select(String answer) {
    final choice = _choiceFor(_scene);
    setState(() {
      _selectedAnswer = answer;
      if (answer == choice?.correct) _completedScenes.add(_scene);
    });
  }

  void _next() {
    if (!_canContinue) {
      setState(() => _hintSignal++);
      showLessonInteractionPrompt(context, _scrollController);
      return;
    }
    if (_isLast) {
      widget.onFinished();
      return;
    }
    setState(() {
      _completedScenes.add(_scene);
      _scene++;
      _selectedAnswer = null;
    });
    widget.onProgressChanged(_scene / (chapter4MainStory.scenes.length - 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  void _back() {
    if (_scene == 0) return;
    setState(() {
      _scene--;
      _selectedAnswer = null;
    });
    widget.onProgressChanged(_scene / (chapter4MainStory.scenes.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final scene = chapter4MainStory.scenes[_scene];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              MascotLessonSpeech(
                message: context.l10n.t(scene.narrationKey),
                pose: _isLast ? MascotPose.celebrate : MascotPose.speaking,
                animationId: 'chapter4-story-$_scene-$_hintSignal',
              ),
              const SizedBox(height: 14),
              AppCard(child: _SceneBody(scene: _scene)),
              if (!_isInformational)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: LessonInteractionHint(
                    signal: _hintSignal,
                    child: _ChoicePanel(
                      scene: _scene,
                      selected: _selectedAnswer,
                      completed: _canContinue,
                      onSelected: _select,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_scene > 0) ...[
              Expanded(
                child: AppOutlinedButton(
                  onPressed: _back,
                  icon: const Icon(Icons.arrow_back),
                  label: context.l10n.t('common.back'),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: _isLast
                  ? AppButton(
                      label: context.l10n.t('common.finish'),
                      onPressed: _next,
                    )
                  : LessonScrollContinueButton(
                      controller: _scrollController,
                      onContinue: _next,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SceneBody extends StatelessWidget {
  const _SceneBody({required this.scene});
  final int scene;

  @override
  Widget build(BuildContext context) {
    if (scene == 0) return const _Chapter4WelcomeBody();
    final contentScene = scene - 1;
    final (titleKey, fsm, highlighted) = switch (contentScene) {
      0 => ('chapter4.visual.welcome.title', chapter4CoinMachine, <String>{}),
      1 => (
        'chapter4.visual.partial.title',
        chapter4CoinMachinePartial,
        <String>{},
      ),
      2 => ('chapter4.visual.states.title', chapter4CoinMachinePartial, {'q1'}),
      3 => (
        'chapter4.visual.transition.title',
        chapter4CoinMachinePartial,
        {'q1'},
      ),
      4 => ('chapter4.visual.check.title', chapter4CoinMachine, <String>{}),
      _ => ('chapter4.visual.complete.title', chapter4CoinMachine, <String>{}),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contentScene >= 2 && contentScene <= 4)
          _ProcedureIndicator(step: contentScene - 1),
        if (contentScene >= 2 && contentScene <= 4) const SizedBox(height: 12),
        Text(
          context.l10n.t(titleKey),
          textAlign: TextAlign.center,
          style: context.textStyles.title,
        ),
        const SizedBox(height: 12),
        FsmDiagramPreview(fsm: fsm, highlightedStateIds: highlighted),
        if (contentScene == 1 ||
            contentScene == 3 ||
            contentScene == 4 ||
            contentScene == 5) ...[
          const SizedBox(height: 12),
          _RuleCallout(
            textKey:
                'chapter4.visual.${switch (contentScene) {
                  1 => 'partial',
                  3 => 'transition',
                  4 => 'check',
                  _ => 'complete',
                }}.rule',
          ),
        ],
      ],
    );
  }
}

class _Chapter4WelcomeBody extends StatelessWidget {
  const _Chapter4WelcomeBody();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        context.l10n.t('chapter4.visual.intro.title'),
        textAlign: TextAlign.center,
        style: context.textStyles.title,
      ),
      const SizedBox(height: 14),
      Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 88,
          color: context.colors.primary,
        ),
      ),
      const SizedBox(height: 12),
      _RuleCallout(textKey: 'chapter4.visual.intro.body'),
    ],
  );
}

class _ProcedureIndicator extends StatelessWidget {
  const _ProcedureIndicator({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('chapter4-completion-step-$step'),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: context.colors.primary.withValues(alpha: .12),
      border: Border.all(color: context.colors.primary),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      context.l10n.t(
        'chapter4.visual.step',
        args: {'current': step, 'total': 3},
      ),
      textAlign: TextAlign.center,
      style: context.textStyles.body.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class _RuleCallout extends StatelessWidget {
  const _RuleCallout({required this.textKey});
  final String textKey;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colors.primary.withValues(alpha: .12),
      border: Border.all(color: context.colors.primary),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      children: [
        Icon(Icons.lightbulb_rounded, color: context.colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(context.l10n.t(textKey), style: context.textStyles.body),
        ),
      ],
    ),
  );
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.scene,
    required this.selected,
    required this.completed,
    required this.onSelected,
  });
  final int scene;
  final String? selected;
  final bool completed;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final choice = _choiceFor(scene)!;
    final feedback = selected == null
        ? null
        : selected == choice.correct
        ? choice.correctKey
        : choice.incorrectKey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.t(choice.questionKey),
          style: context.textStyles.body.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final answer in choice.answers)
              ChoiceChip(
                label: Text(context.l10n.t(answer)),
                selected: selected == answer,
                onSelected: completed ? null : (_) => onSelected(answer),
              ),
          ],
        ),
        if (feedback != null) ...[
          const SizedBox(height: 8),
          Text(context.l10n.t(feedback)),
        ],
      ],
    );
  }
}

_Choice? _choiceFor(int scene) => switch (scene) {
  3 => const _Choice(
    'chapter4.check.state.question',
    ['chapter4.answer.q0', 'chapter4.answer.q1', 'chapter4.answer.q2'],
    'chapter4.answer.q1',
    'chapter4.check.state.correct',
    'chapter4.check.state.incorrect',
  ),
  4 => const _Choice(
    'chapter4.check.transition.question',
    [
      'chapter4.answer.q1toQ2',
      'chapter4.answer.q1toQ0',
      'chapter4.answer.q0toQ2',
    ],
    'chapter4.answer.q1toQ2',
    'chapter4.check.transition.correct',
    'chapter4.check.transition.incorrect',
  ),
  5 => const _Choice(
    'chapter4.check.complete.question',
    [
      'chapter4.answer.complete',
      'chapter4.answer.missing',
      'chapter4.answer.duplicate',
    ],
    'chapter4.answer.complete',
    'chapter4.check.complete.correct',
    'chapter4.check.complete.incorrect',
  ),
  _ => null,
};

class _Choice {
  const _Choice(
    this.questionKey,
    this.answers,
    this.correct,
    this.correctKey,
    this.incorrectKey,
  );
  final String questionKey;
  final List<String> answers;
  final String correct;
  final String correctKey;
  final String incorrectKey;
}
