import 'package:flutter/material.dart';
import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/fsm_diagram_preview.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_story.dart';
import 'package:bachelor/features/fsm_sandbox/domain/models/fsm.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_lesson_speech.dart';

/// Allgemeine Szenenfolge mit übersetzten Erklärungen, optionalem Diagramm und Fortschrittsmeldung.
class GenericChapterStory extends StatefulWidget {
  const GenericChapterStory({
    required this.titleKey,
    this.definition,
    this.sceneKeys,
    this.diagram,
    required this.onFinished,
    required this.onProgressChanged,
    super.key,
  });
  final String titleKey;
  final StoryDefinition? definition;
  final List<String>? sceneKeys;
  final Fsm? diagram;
  final VoidCallback onFinished;
  final ValueChanged<double> onProgressChanged;

  StoryDefinition get storyDefinition =>
      definition ??
      StoryDefinition(
        id: titleKey,
        scenes: [
          for (var i = 0; i < (sceneKeys?.length ?? 0); i++)
            StorySceneDefinition(
              id: '$titleKey-$i',
              narrationKey: sceneKeys![i],
              objectiveId: '$titleKey-objective-$i',
              stage: i == 0 ? StoryStage.welcome : StoryStage.guided,
            ),
        ],
      );
  @override
  State<GenericChapterStory> createState() => _GenericChapterStoryState();
}

class _GenericChapterStoryState extends State<GenericChapterStory> {
  var index = 0;
  var acknowledged = false;

  String _stageTitle(StoryStage stage) => switch (stage) {
    StoryStage.welcome => 'lesson.storyWelcomeTitle',
    StoryStage.recall => 'lesson.storyRecallTitle',
    StoryStage.demo => 'lesson.storyObserveTitle',
    StoryStage.guided => 'lesson.storyThinkTitle',
    StoryStage.practice => 'lesson.storyPracticeTitle',
    StoryStage.summary => 'lesson.storySummaryTitle',
  };

  String _stageInstruction(StoryStage stage) => switch (stage) {
    StoryStage.welcome => 'lesson.storyWelcomeInstruction',
    StoryStage.recall => 'lesson.storyRecallInstruction',
    StoryStage.demo => 'lesson.storyObserveInstruction',
    StoryStage.guided => 'lesson.storyThinkInstruction',
    StoryStage.practice => 'lesson.storyPracticeInstruction',
    StoryStage.summary => 'lesson.storySummaryInstruction',
  };

  @override
  Widget build(BuildContext context) {
    final scene = widget.storyDefinition.scenes[index];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 12),
            children: [
              MascotLessonSpeech(
                message: context.l10n.t(scene.narrationKey),
                pose: scene.stage == StoryStage.summary
                    ? MascotPose.celebrate
                    : index.isEven
                    ? MascotPose.speaking
                    : MascotPose.thinking,
                animationId:
                    '${widget.definition?.id ?? widget.titleKey}-$index',
              ),
              const SizedBox(height: 12),
              if (widget.diagram != null)
                FsmDiagramPreview(fsm: widget.diagram!),
              const SizedBox(height: 12),
              Text(
                context.l10n.t(widget.titleKey),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              _StageLabel(stage: scene.stage),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.t(_stageTitle(scene.stage)),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(context.l10n.t(_stageInstruction(scene.stage))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('${index + 1} / ${widget.storyDefinition.scenes.length}'),
              CheckboxListTile(
                value: acknowledged,
                onChanged: (value) =>
                    setState(() => acknowledged = value ?? false),
                title: Text(context.l10n.t('lesson.storyAcknowledge')),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        AppButton(
          label: context.l10n.t(
            index + 1 == widget.storyDefinition.scenes.length
                ? 'common.finish'
                : 'common.next',
          ),
          onPressed: acknowledged
              ? () {
                  if (index + 1 == widget.storyDefinition.scenes.length) {
                    widget.onFinished();
                  } else {
                    setState(() {
                      index++;
                      acknowledged = false;
                    });
                    widget.onProgressChanged(
                      index / (widget.storyDefinition.scenes.length - 1),
                    );
                  }
                }
              : null,
        ),
      ],
    );
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel({required this.stage});
  final StoryStage stage;
  @override
  Widget build(BuildContext context) => Chip(
    avatar: const Icon(Icons.school_outlined, size: 18),
    label: Text(stage.name.toUpperCase()),
  );
}
