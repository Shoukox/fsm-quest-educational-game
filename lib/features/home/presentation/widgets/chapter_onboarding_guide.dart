import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/features/home/presentation/widgets/lesson_path.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_widget.dart';
import 'package:bachelor/features/mascot/presentation/widgets/speech_bubble.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:flutter/material.dart';

enum _ChapterEntryChoice { start, skip }

enum _GuideStage {
  tourIntro,
  touring,
  courseSummary,
  returningToStart,
  chapterOneIntro,
  startHandoff,
  skipHandoff,
}

/// Führt durch die Kapitelübersicht und die Wahl des Einstiegs in Kapitel 1.
/// Die Phasen koordinieren Scrollbewegungen, Dialoge und die gespeicherte Einstiegsentscheidung.
class ChapterOnboardingGuide extends StatefulWidget {
  const ChapterOnboardingGuide({required this.lessonPathKey, super.key});

  final GlobalKey<LessonPathState> lessonPathKey;

  @override
  State<ChapterOnboardingGuide> createState() => _ChapterOnboardingGuideState();
}

class _ChapterOnboardingGuideState extends State<ChapterOnboardingGuide> {
  _GuideStage _stage = _GuideStage.tourIntro;
  bool _transitionInProgress = false;
  bool _entryChoiceResolved = false;
  int _tourChapterIndex = 0;
  int _tourChapterCount = 0;
  String _tourChapterUnit = '';
  String _tourChapterTitle = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runChapterTour());
  }

  Future<void> _runChapterTour() async {
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted || _stage != _GuideStage.tourIntro) return;

    setState(() => _stage = _GuideStage.touring);
    await widget.lessonPathKey.currentState?.animateThroughChapters(
      onChapterChanged: (index, count, unit, title) {
        if (!mounted) return;
        setState(() {
          _tourChapterIndex = index;
          _tourChapterCount = count;
          _tourChapterUnit = unit;
          _tourChapterTitle = title;
        });
      },
    );

    if (mounted && _stage == _GuideStage.touring) {
      setState(() => _stage = _GuideStage.courseSummary);
    }
  }

  bool get _skipTourVisible => switch (_stage) {
    _GuideStage.tourIntro ||
    _GuideStage.touring ||
    _GuideStage.courseSummary => true,
    _ => false,
  };

  String get _messageKey => switch (_stage) {
    _GuideStage.tourIntro || _GuideStage.touring => 'mascot.chapterTour.intro',
    _GuideStage.courseSummary => 'mascot.chapterTour.summary',
    _GuideStage.chapterOneIntro => 'mascot.chapter1.intro',
    _GuideStage.startHandoff => 'mascot.chapter1.startHandoff',
    _GuideStage.skipHandoff => 'mascot.chapter2.skipHandoff',
    _GuideStage.returningToStart => 'mascot.chapterTour.intro',
  };

  void _handleBackgroundTap() {
    if (_transitionInProgress) return;
    switch (_stage) {
      case _GuideStage.courseSummary:
        _returnToChapterOne();
      case _GuideStage.chapterOneIntro:
        _showEntryChoice();
      case _GuideStage.tourIntro ||
          _GuideStage.touring ||
          _GuideStage.returningToStart ||
          _GuideStage.startHandoff ||
          _GuideStage.skipHandoff:
        return;
    }
  }

  Future<void> _skipChapterTour() async {
    if (_transitionInProgress) return;
    _transitionInProgress = true;
    setState(() => _stage = _GuideStage.returningToStart);
    await widget.lessonPathKey.currentState?.scrollToTop();
    if (mounted) setState(() => _stage = _GuideStage.chapterOneIntro);
    _transitionInProgress = false;
  }

  Future<void> _returnToChapterOne() async {
    if (_transitionInProgress) return;
    _transitionInProgress = true;
    await widget.lessonPathKey.currentState?.scrollToTop();
    if (mounted) setState(() => _stage = _GuideStage.chapterOneIntro);
    _transitionInProgress = false;
  }

  Future<void> _showEntryChoice() async {
    if (_transitionInProgress) return;
    _transitionInProgress = true;
    final storage = UserProfileStorage();

    while (mounted && !_entryChoiceResolved) {
      final choice = await showDialog<_ChapterEntryChoice>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.72),
        builder: _buildEntryChoiceDialog,
      );
      if (!mounted) break;

      if (choice == _ChapterEntryChoice.start) {
        await storage.setChapter1EntryChoiceResolved();
        await widget.lessonPathKey.currentState?.highlightLesson('intro');
        if (mounted) {
          setState(() {
            _entryChoiceResolved = true;
            _stage = _GuideStage.startHandoff;
          });
        }
        break;
      }

      if (choice == _ChapterEntryChoice.skip) {
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.72),
          builder: _buildSkipConfirmationDialog,
        );
        if (!mounted) break;
        if (confirmed != true) continue;

        await storage.setChapter1Skipped(true);
        await storage.setChapter1EntryChoiceResolved();
        widget.lessonPathKey.currentState?.setChapter1Skipped(true);
        await widget.lessonPathKey.currentState?.highlightLesson(
          'chapter2-gates-review',
        );
        if (mounted) {
          setState(() {
            _entryChoiceResolved = true;
            _stage = _GuideStage.skipHandoff;
          });
        }
        break;
      }
    }

    _transitionInProgress = false;
  }

  Widget _buildEntryChoiceDialog(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.t('mascot.chapter1.choice.title')),
        content: Text(l10n.t('mascot.chapter1.choice.body')),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_ChapterEntryChoice.skip),
            child: Text(l10n.t('mascot.chapter1.choice.skip')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_ChapterEntryChoice.start),
            child: Text(l10n.t('mascot.chapter1.choice.start')),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipConfirmationDialog(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.t('mascot.chapter1.skip.confirmTitle')),
        content: Text(l10n.t('mascot.chapter1.skip.confirmBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.t('mascot.chapter1.skip.return')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.t('mascot.chapter1.skip.confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isHandoff =
        _stage == _GuideStage.startHandoff || _stage == _GuideStage.skipHandoff;

    return Stack(
      children: [
        if (!isHandoff)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleBackgroundTap,
              child: ColoredBox(color: context.colors.mascotScrim),
            ),
          ),
        if (_skipTourVisible)
          Positioned(
            top: 8,
            right: 12,
            child: SafeArea(
              child: FilledButton.tonalIcon(
                onPressed: _skipChapterTour,
                icon: const Icon(Icons.skip_next_rounded),
                label: Text(l10n.t('mascot.chapterTour.skip')),
              ),
            ),
          ),
        if (_stage == _GuideStage.touring && _tourChapterCount > 0)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 64,
            left: 16,
            right: 16,
            child: _ChapterTourProgress(
              chapterNumber: _tourChapterIndex + 1,
              chapterCount: _tourChapterCount,
              unit: _tourChapterUnit,
              title: _tourChapterTitle,
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 108,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 270,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 142,
                      child: IgnorePointer(
                        child: SpeechBubble(
                          message: l10n.t(_messageKey),
                          tailAlignment: 0.15,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: MascotWidget(
                          pose: _stage == _GuideStage.chapterOneIntro
                              ? MascotPose.greeting
                              : MascotPose.speaking,
                          size: 138,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChapterTourProgress extends StatelessWidget {
  const _ChapterTourProgress({
    required this.chapterNumber,
    required this.chapterCount,
    required this.unit,
    required this.title,
  });

  final int chapterNumber;
  final int chapterCount;
  final String unit;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progressLabel = context.l10n.t(
      'mascot.chapterTour.progress',
      args: {'chapter': chapterNumber, 'total': chapterCount},
    );

    return Material(
      color: colors.surfaceRaised,
      elevation: 12,
      shadowColor: colors.primary.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: colors.warning, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.route_rounded, color: colors.primary, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    progressLabel,
                    style: context.textStyles.caption.copyWith(
                      color: colors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.body.copyWith(
                color: colors.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.caption.copyWith(
                color: colors.mutedText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: chapterNumber / chapterCount,
                minHeight: 6,
                color: colors.primary,
                backgroundColor: colors.border,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
