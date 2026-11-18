import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/router.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/services/database_service.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_scaffold.dart';
import 'package:bachelor/features/lesson/data/lesson_local_data_source.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Zeigt Abschluss oder Abbruch und stößt die passende Speicherung des Ergebnisses an.
class LessonResultPage extends StatefulWidget {
  const LessonResultPage({
    required this.lessonId,
    required this.stars,
    required this.earnedXp,
    required this.earnedCoins,
    this.abandoned = false,
    this.chapterFailed = false,
    this.taskCount = 15,
    this.minimumCorrect = 3,
    this.score = 0,
    super.key,
  });

  final String lessonId;
  final int score;
  final int stars;
  final int earnedXp;
  final int earnedCoins;
  final bool abandoned;
  final bool chapterFailed;
  final int taskCount;
  final int minimumCorrect;

  @override
  State<LessonResultPage> createState() => _LessonResultPageState();
}

class _LessonResultPageState extends State<LessonResultPage> {
  static const _dataSource = LessonLocalDataSource();

  // Das Future wird einmal pro Seitenzustand erzeugt, damit erneute Builds keine
  // weiteren Belohnungen buchen. Abbrüche speichern keinen Abschluss; ein nicht
  // bestandener Kapitel-1-Test setzt den zugehörigen Kapitelfortschritt zurück.
  late final Future<void> _saveFuture = widget.abandoned
      ? Future<void>.value()
      : widget.chapterFailed && widget.lessonId == 'chapter_test'
      ? _resetCurrentChapter()
      : widget.chapterFailed
      ? Future<void>.value()
      : _completeLesson();

  Future<void> _completeLesson() async {
    await DatabaseService.instance.completeLesson(
      lessonId: widget.lessonId,
      score: widget.score,
      stars: widget.stars,
      earnedXp: widget.earnedXp,
      earnedCoins: widget.earnedCoins,
    );
    if (widget.lessonId == 'chapter_test') {
      await UserProfileStorage().setChapter1Skipped(false);
    }
  }

  Future<void> _resetCurrentChapter() async {
    final lesson = _dataSource.getLessonById(widget.lessonId);
    if (lesson == null) {
      return DatabaseService.instance.resetFirstChapterProgress();
    }

    final chapterLessons = _dataSource
        .getLessons()
        .where((item) => item.chapterId == lesson.chapterId)
        .toList();
    if (chapterLessons.isEmpty) {
      return DatabaseService.instance.resetFirstChapterProgress();
    }

    await DatabaseService.instance.resetChapterProgress(
      lessonIds: [for (final item in chapterLessons) item.id],
      firstLessonId: chapterLessons.first.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: _saveFuture,
          builder: (context, snapshot) {
            final hasError = snapshot.hasError;
            final isSaving = snapshot.connectionState != ConnectionState.done;
            final l10n = context.l10n;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.abandoned
                      ? l10n.t('result.abandoned')
                      : widget.chapterFailed
                      ? l10n.t('result.chapterFailed')
                      : hasError
                      ? l10n.t('result.saveFailed')
                      : isSaving
                      ? l10n.t('result.saving')
                      : l10n.t('result.saved'),
                  textAlign: TextAlign.center,
                  style: context.textStyles.title,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t(
                    widget.abandoned
                        ? 'result.abandonedLesson'
                        : widget.chapterFailed
                        ? 'result.chapterFailedDetail'
                        : 'result.completed',
                    args: {
                      'lessonId': widget.lessonId,
                      'score': widget.score,
                      'total': widget.taskCount,
                      'minimum': widget.minimumCorrect,
                    },
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('result.firstTryScore', args: {'score': widget.score}),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                if (!widget.chapterFailed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < 3; index++)
                        Icon(
                          Icons.star_rounded,
                          size: 42,
                          color: index < widget.stars
                              ? context.colors.warning
                              : context.colors.locked,
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                Text(
                  widget.abandoned || widget.chapterFailed
                      ? l10n.t(
                          widget.chapterFailed
                              ? 'result.chapterNoRewards'
                              : 'result.noRewards',
                        )
                      : l10n.t(
                          'result.rewards',
                          args: {
                            'xp': widget.earnedXp,
                            'coins': widget.earnedCoins,
                          },
                        ),
                  textAlign: TextAlign.center,
                  style: context.textStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: context.textStyles.caption,
                  ),
                ],
                const SizedBox(height: 24),
                if (!widget.chapterFailed) ...[
                  AppButton(
                    label: l10n.t('result.nextLesson'),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: isSaving
                        ? null
                        : () => context.go(_nextLessonRoute()),
                  ),
                  const SizedBox(height: 8),
                ],
                AppButton(
                  label: l10n.t(
                    widget.chapterFailed
                        ? 'result.restartChapter'
                        : 'result.repeatLesson',
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  onPressed: isSaving
                      ? null
                      : () => context.go(
                          widget.chapterFailed
                              ? '/lesson/${_chapterStartLessonId()}'
                              : '/lesson/${widget.lessonId}',
                        ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: AppHaptics.wrapButton(
                    isSaving ? null : () => context.go(AppRoutes.home),
                  ),
                  child: Text(l10n.t('result.backHome')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _nextLessonRoute() {
    final lessons = _dataSource.getLessons();
    final currentIndex = lessons.indexWhere(
      (lesson) => lesson.id == widget.lessonId,
    );
    if (currentIndex < 0 || currentIndex == lessons.length - 1) {
      return AppRoutes.home;
    }
    return '/lesson/${lessons[currentIndex + 1].id}';
  }

  String _chapterStartLessonId() {
    final lesson = _dataSource.getLessonById(widget.lessonId);
    if (lesson == null) return 'intro';
    for (final item in _dataSource.getLessons()) {
      if (item.chapterId == lesson.chapterId) return item.id;
    }
    return 'intro';
  }
}
