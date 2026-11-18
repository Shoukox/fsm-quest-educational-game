import 'package:flutter/material.dart';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/widgets/fsm_diagram_preview.dart';
import 'package:bachelor/core/widgets/fsm_tables.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/lesson/data/chapters/automata_creation_content.dart';
import 'package:bachelor/features/lesson/data/chapters/automata_creation_fixtures.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_story.dart';
import 'package:bachelor/features/lesson/presentation/widgets/lesson_scroll_continue_button.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_lesson_speech.dart';

/// Erklärt die Automatenkonstruktion im angezeigten Kapitel 4.
/// Der Einstieg erfolgt wahlweise über ein Alltagsszenario oder über Übergangs- und Ausgabetabellen.
class AutomataCreationStory extends StatefulWidget {
  const AutomataCreationStory({
    required this.fromTables,
    required this.onFinished,
    required this.onProgressChanged,
    super.key,
  });

  final bool fromTables;
  final VoidCallback onFinished;
  final ValueChanged<double> onProgressChanged;

  @override
  State<AutomataCreationStory> createState() => _AutomataCreationStoryState();
}

class _AutomataCreationStoryState extends State<AutomataCreationStory> {
  final _scrollController = ScrollController();
  int _scene = 0;
  final Map<int, String> _answers = {};

  bool get _hasCheck => widget.fromTables ? _scene == 1 : _scene == 2;
  bool get _canContinue => !_hasCheck || _answers[_scene] == 'q2';

  bool get _isLast => _scene == _story.scenes.length - 1;
  StoryDefinition get _story =>
      widget.fromTables ? creationTableStory : creationDescriptionStory;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _next() {
    if (!_canContinue) return;
    if (_isLast) {
      widget.onFinished();
      return;
    }
    setState(() => _scene++);
    widget.onProgressChanged(_scene / (_story.scenes.length - 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  void _back() {
    if (_scene == 0) return;
    setState(() => _scene--);
    widget.onProgressChanged(_scene / (_story.scenes.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final scene = _story.scenes[_scene];
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
                animationId: 'creation-${widget.fromTables}-$_scene',
              ),
              const SizedBox(height: 14),
              AppCard(
                child: _AutomataCreationScene(
                  fromTables: widget.fromTables,
                  scene: _scene,
                ),
              ),
              if (_hasCheck) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.t(
                    widget.fromTables
                        ? 'creation.check.tables'
                        : 'creation.check.description',
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final state in ['q0', 'q1', 'q2'])
                      ChoiceChip(
                        key: ValueKey('creation-check-$state'),
                        label: Text(state),
                        selected: _answers[_scene] == state,
                        onSelected: (_) =>
                            setState(() => _answers[_scene] = state),
                      ),
                  ],
                ),
                if (_answers.containsKey(_scene))
                  Text(
                    context.l10n.t(
                      _canContinue
                          ? 'creation.check.correct'
                          : 'creation.check.incorrect',
                    ),
                  ),
              ],
              if (_isLast) ...[
                const SizedBox(height: 12),
                _Callout(text: context.l10n.t('creation.defaultRule')),
              ],
              const SizedBox(height: 8),
              Text('${_scene + 1} / ${_story.scenes.length}'),
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
                      onPressed: _canContinue ? _next : null,
                    )
                  : LessonScrollContinueButton(
                      key: ValueKey('creation-continue-$_scene'),
                      controller: _scrollController,
                      onContinue: _canContinue ? _next : null,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AutomataCreationScene extends StatelessWidget {
  const _AutomataCreationScene({required this.fromTables, required this.scene});

  final bool fromTables;
  final int scene;

  Fsm get _fsm => fromTables ? creationParkingBarrier : _descriptionFsm;
  String get _prefix => fromTables ? 'creation.tables' : 'creation.description';
  int get _visualScene => fromTables ? scene : scene - 1;

  Fsm get _descriptionFsm {
    if (scene == 0) return Fsm.empty;
    if (scene == 1) {
      return creationBikeRental.copyWith(
        states: [creationBikeRental.states.first],
        transitions: const [],
      );
    }
    if (scene == 2) {
      return creationBikeRental.copyWith(
        states: creationBikeRental.states,
        transitions: const [],
      );
    }
    return creationBikeRental;
  }

  @override
  Widget build(BuildContext context) {
    if (!fromTables && scene == 0) {
      return const _AutomataCreationWelcomeScene();
    }
    final title = context.l10n.t('$_prefix.visual.$_visualScene.title');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textStyles.title,
        ),
        const SizedBox(height: 12),
        if (!fromTables && scene == 1)
          const _BikeDescriptionIllustration()
        else if (fromTables && (scene == 1 || scene == 2)) ...[
          FsmTransitionTable(fsm: _fsm, inputAlphabet: _inputs),
          const SizedBox(height: 12),
          FsmOutputTable(fsm: _fsm),
        ] else
          FsmDiagramPreview(fsm: _fsm),
        const SizedBox(height: 12),
        _Callout(text: context.l10n.t('$_prefix.visual.$_visualScene.body')),
      ],
    );
  }

  List<String> get _inputs => fromTables
      ? ['ticket', 'timeout']
      : ['valid code', 'wrong code', 'take bike', 'timeout', 'return bike'];
}

class _AutomataCreationWelcomeScene extends StatelessWidget {
  const _AutomataCreationWelcomeScene();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        context.l10n.t('creation.description.welcome.title'),
        textAlign: TextAlign.center,
        style: context.textStyles.title,
      ),
      const SizedBox(height: 14),
      Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          Icons.account_tree_rounded,
          size: 90,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 12),
      _Callout(text: context.l10n.t('creation.description.welcome.body')),
    ],
  );
}

class _BikeDescriptionIllustration extends StatelessWidget {
  const _BikeDescriptionIllustration();

  @override
  Widget build(BuildContext context) => Container(
    height: 150,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(
      Icons.pedal_bike,
      size: 88,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

class _Callout extends StatelessWidget {
  const _Callout({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: context.textStyles.body),
  );
}
