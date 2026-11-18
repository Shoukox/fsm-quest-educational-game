import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/database_service.dart';
import 'package:bachelor/core/services/developer_access_controller.dart';
import 'package:bachelor/core/widgets/fsm_diagram.dart';
import 'package:bachelor/core/widgets/fsm_diagram_labels.dart';
import 'package:bachelor/features/home/presentation/widgets/lesson_node.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:bachelor/features/progress/domain/models/lesson_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Zeigt die Kapitel und ihre Lektionen als grafischen Lernpfad.
/// Gespeicherter Fortschritt, Kapitelfreigaben und Entwicklerzugriff bestimmen den Knotenstatus.
class LessonPath extends StatefulWidget {
  const LessonPath({this.progressFuture, super.key});

  final Future<List<LessonProgress>>? progressFuture;

  static const _nodeWidth = 150.0;
  static const _nodeCircleSize = 88.0;

  static const _chapters = [
    _LessonChapter(
      unit: 'home.unit',
      title: 'home.title',
      unlockedSubtitle: 'home.subtitle',
      lockedSubtitle: 'home.subtitle',
      icon: Icons.account_tree,
      mapHeight: 650,
      nodes: [
        _LessonPathNode(
          lessonId: 'intro',
          title: 'path.intro.title',
          subtitle: 'path.intro.subtitle',
          icon: Icons.play_arrow_rounded,
          position: Offset(0.50, 0.03),
        ),
        _LessonPathNode(
          lessonId: 'states',
          title: 'path.states.title',
          subtitle: 'path.states.subtitle',
          icon: Icons.circle_outlined,
          position: Offset(0.15, 0.27),
        ),
        _LessonPathNode(
          lessonId: 'transitions',
          title: 'path.transitions.title',
          subtitle: 'path.transitions.subtitle',
          icon: Icons.arrow_forward_rounded,
          position: Offset(0.75, 0.49),
        ),
        _LessonPathNode(
          lessonId: 'chapter_test',
          title: 'path.test.title',
          subtitle: 'path.test.subtitle',
          icon: Icons.timer_outlined,
          position: Offset(0.50, 0.72),
        ),
      ],
    ),
    _LessonChapter(
      unit: 'home.chapter2.unit',
      title: 'path.chapter2.title',
      unlockedSubtitle: 'path.chapter2.unlocked',
      lockedSubtitle: 'path.chapter2.locked',
      icon: Icons.auto_awesome_rounded,
      unlockAfterLessonId: 'chapter_test',
      mapHeight: 650,
      nodes: [
        _LessonPathNode(
          lessonId: 'chapter2-gates-review',
          title: 'path.chapter2.review.title',
          subtitle: 'path.chapter2.review.subtitle',
          lockedSubtitle: 'path.chapter2.locked',
          icon: Icons.memory_rounded,
          position: Offset(0.50, 0.03),
        ),
        _LessonPathNode(
          lessonId: 'chapter_2',
          title: 'path.chapter2.lesson.title',
          subtitle: 'path.chapter2.lesson.subtitle',
          lockedSubtitle: 'path.chapter2.locked',
          icon: Icons.account_tree_rounded,
          position: Offset(0.18, 0.34),
        ),
        _LessonPathNode(
          lessonId: 'chapter_2_test',
          title: 'path.chapter2.test.title',
          subtitle: 'path.chapter2.test.subtitle',
          lockedSubtitle: 'path.chapter2.locked',
          icon: Icons.timer_outlined,
          position: Offset(0.75, 0.60),
        ),
      ],
    ),
    _LessonChapter(
      unit: 'home.chapter3.unit',
      title: 'path.chapter4.title',
      unlockedSubtitle: 'path.chapter4.unlocked',
      lockedSubtitle: 'path.chapter4.locked',
      icon: Icons.construction_rounded,
      unlockAfterLessonId: 'chapter_2_test',
      mapHeight: 470,
      nodes: [
        _LessonPathNode(
          lessonId: 'chapter4-completion',
          title: 'path.chapter4.lesson.title',
          subtitle: 'path.chapter4.lesson.subtitle',
          lockedSubtitle: 'path.chapter4.locked',
          icon: Icons.construction_rounded,
          position: Offset(0.20, 0.35),
        ),
        _LessonPathNode(
          lessonId: 'chapter_4_test',
          title: 'path.chapter4.test.title',
          subtitle: 'path.chapter4.test.subtitle',
          lockedSubtitle: 'path.chapter4.locked',
          icon: Icons.timer_outlined,
          position: Offset(0.80, 0.62),
        ),
      ],
    ),
    _LessonChapter(
      unit: 'home.chapter4.unit',
      title: 'creation.path.title',
      unlockedSubtitle: 'creation.path.unlocked',
      lockedSubtitle: 'creation.path.locked',
      icon: Icons.account_tree_outlined,
      unlockAfterLessonId: 'chapter_4_test',
      mapHeight: 620,
      nodes: [
        _LessonPathNode(
          lessonId: 'automata-creation-description',
          title: 'creation.description.title',
          subtitle: 'creation.path.description.subtitle',
          lockedSubtitle: 'creation.path.locked',
          icon: Icons.description_outlined,
          position: Offset(.20, .20),
        ),
        _LessonPathNode(
          lessonId: 'automata-creation-tables',
          title: 'creation.tables.title',
          subtitle: 'creation.path.tables.subtitle',
          lockedSubtitle: 'creation.path.locked',
          icon: Icons.table_chart_outlined,
          position: Offset(.65, .43),
        ),
        _LessonPathNode(
          lessonId: 'automata-creation-test',
          title: 'creation.path.test.title',
          subtitle: 'creation.path.test.subtitle',
          lockedSubtitle: 'creation.path.locked',
          icon: Icons.timer_outlined,
          position: Offset(.35, .70),
        ),
      ],
    ),
    _LessonChapter(
      unit: 'home.chapter5.unit',
      title: 'path.chapter5.title',
      unlockedSubtitle: 'path.chapter5.unlocked',
      lockedSubtitle: 'path.chapter5.locked',
      icon: Icons.workspace_premium_rounded,
      unlockAfterLessonId: 'automata-creation-test',
      mapHeight: 1120,
      nodes: [
        _LessonPathNode(
          lessonId: 'chapter5-theory',
          title: 'path.chapter5.theory.title',
          subtitle: 'path.chapter5.theory.subtitle',
          lockedSubtitle: 'path.chapter5.locked',
          icon: Icons.school_outlined,
          position: Offset(.18, .04),
        ),
        _LessonPathNode(
          lessonId: 'chapter5-tables',
          title: 'path.chapter5.tables.title',
          subtitle: 'path.chapter5.tables.subtitle',
          lockedSubtitle: 'path.chapter5.locked',
          icon: Icons.table_chart_outlined,
          position: Offset(.50, .20),
        ),
        _LessonPathNode(
          lessonId: 'chapter5-completion',
          title: 'path.chapter5.completion.title',
          subtitle: 'path.chapter5.completion.subtitle',
          lockedSubtitle: 'path.chapter5.locked',
          icon: Icons.build_outlined,
          position: Offset(.82, .38),
        ),
        _LessonPathNode(
          lessonId: 'chapter5-creation',
          title: 'path.chapter5.creation.title',
          subtitle: 'path.chapter5.creation.subtitle',
          lockedSubtitle: 'path.chapter5.locked',
          icon: Icons.account_tree_outlined,
          position: Offset(.18, .58),
        ),
        _LessonPathNode(
          lessonId: 'chapter5-diagnostics',
          title: 'path.chapter5.diagnostics.title',
          subtitle: 'path.chapter5.diagnostics.subtitle',
          lockedSubtitle: 'path.chapter5.locked',
          icon: Icons.search_rounded,
          position: Offset(.50, .78),
        ),
      ],
    ),
  ];

  @override
  LessonPathState createState() => LessonPathState();
}

/// Verwaltet Fortschrittsladen und die Scroll- sowie Hervorhebungsaktionen der Kapitelführung.
class LessonPathState extends State<LessonPath> {
  /// Dieser Wert bestimmt die Scrolldauer der Kapitel-Tour.
  static const Duration chapterTourDuration = Duration(seconds: 7);
  static const Duration chapterTourHeaderPause = Duration(milliseconds: 200);

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _chapterAnchors = List.generate(
    LessonPath._chapters.length,
    (_) => GlobalKey(),
  );
  late final Map<String, GlobalKey> _lessonAnchors = {
    for (final chapter in LessonPath._chapters)
      for (final node in chapter.nodes) node.lessonId: GlobalKey(),
  };
  late Future<List<LessonProgress>> _progressFuture;
  bool _chapter1Skipped = false;
  String? _focusedLessonId;
  String? _guidedLessonId;
  int _tourGeneration = 0;

  @override
  void initState() {
    super.initState();
    _progressFuture = widget.progressFuture ?? _loadLessonProgress();
    _loadChapter1SkipStatus();
  }

  @override
  void didUpdateWidget(covariant LessonPath oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressFuture != widget.progressFuture &&
        widget.progressFuture != null) {
      _progressFuture = widget.progressFuture!;
    }
  }

  @override
  void dispose() {
    _tourGeneration++;
    _scrollController.dispose();
    super.dispose();
  }

  /// Führt die Einführung durch die Kapitel und meldet den jeweils erreichten Abschnitt.
  Future<void> animateThroughChapters({
    required void Function(int index, int count, String unit, String title)
    onChapterChanged,
  }) async {
    final generation = ++_tourGeneration;
    final travelDuration = Duration(
      microseconds:
          (chapterTourDuration.inMicroseconds -
              chapterTourHeaderPause.inMicroseconds * _chapterAnchors.length) ~/
          (_chapterAnchors.length - 1),
    );
    await _waitForLayout();
    if (generation != _tourGeneration || !mounted) return;
    _notifyChapterChanged(onChapterChanged, 0);
    await Future<void>.delayed(chapterTourHeaderPause);
    if (generation != _tourGeneration || !mounted) return;

    for (var index = 1; index < _chapterAnchors.length; index++) {
      if (generation != _tourGeneration || !mounted) return;
      _notifyChapterChanged(onChapterChanged, index);
      final targetContext = _chapterAnchors[index].currentContext;
      if (targetContext != null && targetContext.mounted) {
        await Scrollable.ensureVisible(
          targetContext,
          // Die Kapitelüberschrift bleibt unter der fixierten Tour-Anzeige sichtbar.
          alignment: 0.24,
          duration: travelDuration,
          curve: Curves.easeInOutCubic,
        );
      }
      if (generation != _tourGeneration || !mounted) return;
      await Future<void>.delayed(chapterTourHeaderPause);
    }
  }

  void _notifyChapterChanged(
    void Function(int index, int count, String unit, String title) callback,
    int index,
  ) {
    final chapter = LessonPath._chapters[index];
    callback(
      index,
      LessonPath._chapters.length,
      context.l10n.t(chapter.unit),
      context.l10n.t(chapter.title),
    );
  }

  Future<void> scrollToTop() async {
    _tourGeneration++;
    await _waitForLayout();
    if (!_scrollController.hasClients || !mounted) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Scrollt zum Lektionsanker und hebt den zugehörigen Knoten für die Einführung hervor.
  Future<void> highlightLesson(String lessonId) async {
    _tourGeneration++;
    if (!mounted) return;
    setState(() {
      _focusedLessonId = lessonId;
      _guidedLessonId = lessonId;
    });
    await _waitForLayout();
    await _buildLessonAnchor(lessonId);
    final targetContext = _lessonAnchors[lessonId]?.currentContext;
    if (targetContext != null && targetContext.mounted && mounted) {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.18,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// Die Liste baut Kapitel erst bei Bedarf auf, daher hat eine Lektion weit außerhalb
  /// des Viewports (etwa in einem niedrigen Desktop-Fenster) noch keinen Kontext. Es wird
  /// jeweils um eine Viewport-Höhe zum Kapitel gescrollt, bis die Lektion aufgebaut ist.
  Future<void> _buildLessonAnchor(String lessonId) async {
    final targetChapter = LessonPath._chapters.indexWhere(
      (chapter) => chapter.nodes.any((node) => node.lessonId == lessonId),
    );
    if (targetChapter < 0) return;

    for (var step = 0; step < 20; step++) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_lessonAnchors[lessonId]?.currentContext?.mounted ?? false) return;

      final builtChapters = [
        for (var index = 0; index < _chapterAnchors.length; index++)
          if (_chapterAnchors[index].currentContext?.mounted ?? false) index,
      ];
      if (builtChapters.isEmpty) return;

      final position = _scrollController.position;
      final forward = targetChapter >= builtChapters.first;
      final target = forward
          ? (position.pixels + position.viewportDimension).clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            )
          : (position.pixels - position.viewportDimension).clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            );
      if (target == position.pixels) return;

      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  void setChapter1Skipped(bool skipped) {
    if (!mounted || _chapter1Skipped == skipped) return;
    setState(() => _chapter1Skipped = skipped);
  }

  Future<void> _waitForLayout() async {
    for (var frame = 0; frame < 8; frame++) {
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (_scrollController.hasClients) return;
    }
  }

  Future<void> _loadChapter1SkipStatus() async {
    final skipped = await UserProfileStorage().hasChapter1Skipped();
    if (mounted) setState(() => _chapter1Skipped = skipped);
  }

  @override
  Widget build(BuildContext context) {
    final developerAccess = DeveloperAccessController.instance;
    return AnimatedBuilder(
      animation: developerAccess,
      builder: (context, _) => FutureBuilder<List<LessonProgress>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          final unlockAllLevels = developerAccess.unlockAllLevels;
          final progressById = {
            for (final progress in snapshot.data ?? const <LessonProgress>[])
              progress.lessonId: progress,
          };
          final completedIds = {
            for (final progress in progressById.values)
              if (progress.isCompleted) progress.lessonId,
          };

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              for (
                var chapterIndex = 0;
                chapterIndex < LessonPath._chapters.length;
                chapterIndex++
              ) ...[
                _buildChapter(
                  context,
                  chapter: LessonPath._chapters[chapterIndex],
                  chapterIndex: chapterIndex,
                  progressById: progressById,
                  completedIds: completedIds,
                  unlockAllLevels: unlockAllLevels,
                ),
                if (chapterIndex < LessonPath._chapters.length - 1)
                  const SizedBox(height: 30),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildChapter(
    BuildContext context, {
    required _LessonChapter chapter,
    required int chapterIndex,
    required Map<String, LessonProgress> progressById,
    required Set<String> completedIds,
    required bool unlockAllLevels,
  }) {
    final l10n = context.l10n;
    final isChapter1Skipped =
        chapterIndex == 0 &&
        _chapter1Skipped &&
        !completedIds.contains('chapter_test');
    final isUnlocked =
        chapter.unlockAfterLessonId == null ||
        completedIds.contains(chapter.unlockAfterLessonId) ||
        (chapterIndex == 1 && _chapter1Skipped);
    final statuses = [
      for (var index = 0; index < chapter.nodes.length; index++)
        _statusFor(
          chapter: chapter,
          completedIds: completedIds,
          index: index,
          isChapterUnlocked: isUnlocked,
          unlockAllLevels: unlockAllLevels,
        ),
    ];

    return Column(
      key: _chapterAnchors[chapterIndex],
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CourseHeader(
          key: ValueKey('course-header-${chapterIndex + 1}'),
          unit: l10n.t(chapter.unit),
          title: l10n.t(chapter.title),
          subtitle: l10n.t(
            isUnlocked ? chapter.unlockedSubtitle : chapter.lockedSubtitle,
          ),
          statusLabel: isChapter1Skipped
              ? l10n.t('path.chapter1.skipped')
              : null,
          icon: chapter.icon,
          isLocked: !isUnlocked,
          animationDelay: Duration(milliseconds: chapterIndex * 80),
        ),
        const SizedBox(height: 18),
        _ChapterLessonMap(
          chapter: chapter,
          statuses: statuses,
          progressById: progressById,
          completedIds: completedIds,
          lessonAnchors: _lessonAnchors,
          focusedLessonId: _focusedLessonId,
          guidedLessonId: _guidedLessonId,
        ),
      ],
    );
  }

  Future<List<LessonProgress>> _loadLessonProgress() async {
    try {
      return await DatabaseService.instance.getLessonProgress();
    } catch (_) {
      return const [];
    }
  }

  LessonNodeStatus _statusFor({
    required _LessonChapter chapter,
    required Set<String> completedIds,
    required int index,
    required bool isChapterUnlocked,
    required bool unlockAllLevels,
  }) {
    final node = chapter.nodes[index];
    if (!isChapterUnlocked && !unlockAllLevels) return LessonNodeStatus.locked;
    if (completedIds.contains(node.lessonId)) {
      return LessonNodeStatus.completed;
    }
    if (index == 0 || unlockAllLevels) return LessonNodeStatus.current;

    final previousNode = chapter.nodes[index - 1];
    if (completedIds.contains(previousNode.lessonId)) {
      return LessonNodeStatus.current;
    }
    return LessonNodeStatus.locked;
  }
}

class _ChapterLessonMap extends StatelessWidget {
  const _ChapterLessonMap({
    required this.chapter,
    required this.statuses,
    required this.progressById,
    required this.completedIds,
    required this.lessonAnchors,
    required this.focusedLessonId,
    required this.guidedLessonId,
  });

  final _LessonChapter chapter;
  final List<LessonNodeStatus> statuses;
  final Map<String, LessonProgress> progressById;
  final Set<String> completedIds;
  final Map<String, GlobalKey> lessonAnchors;
  final String? focusedLessonId;
  final String? guidedLessonId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FsmDiagram(
      height: chapter.mapHeight,
      nodes: [
        for (var index = 0; index < chapter.nodes.length; index++)
          FsmDiagramNode(
            center: _nodeCenter(
              chapter.nodes[index].position,
              chapter.mapHeight,
            ),
            width: LessonPath._nodeWidth,
            radius: LessonPath._nodeCircleSize / 2,
            child: LessonNode(
              key: lessonAnchors[chapter.nodes[index].lessonId],
              lessonId: chapter.nodes[index].lessonId,
              title: l10n.t(chapter.nodes[index].title),
              subtitle: _subtitleFor(
                l10n,
                chapter.nodes[index],
                statuses[index],
              ),
              icon: chapter.nodes[index].icon,
              status: statuses[index],
              stars: progressById[chapter.nodes[index].lessonId]?.stars ?? 0,
              isFocused: focusedLessonId == chapter.nodes[index].lessonId,
              isInteractive:
                  guidedLessonId == null ||
                  guidedLessonId == chapter.nodes[index].lessonId,
            ),
          ),
      ],
      resetTransition: FsmResetTransition(
        to: 0,
        label: FsmDiagramLabels.reset,
        color: statuses.first == LessonNodeStatus.locked
            ? context.colors.locked
            : context.colors.primary,
        start: Offset(
          0.3,
          _nodeCenter(chapter.nodes.first.position, chapter.mapHeight).dy /
              chapter.mapHeight,
        ),
        isMuted: statuses.first == LessonNodeStatus.locked,
      ),
      transitions: [
        for (var index = 0; index < chapter.nodes.length - 1; index++)
          FsmDiagramTransition(
            from: index,
            to: index + 1,
            color: statuses[index + 1] == LessonNodeStatus.locked
                ? context.colors.locked
                : statuses[index] == LessonNodeStatus.completed
                ? context.colors.primary
                : context.colors.primaryDark,
            isMuted: statuses[index + 1] == LessonNodeStatus.locked,
          ),
      ],
    );
  }

  static Offset _nodeCenter(Offset position, double mapHeight) {
    return Offset(
      position.dx,
      (mapHeight * position.dy + LessonPath._nodeCircleSize / 2) / mapHeight,
    );
  }

  String _subtitleFor(
    AppLocalizations l10n,
    _LessonPathNode node,
    LessonNodeStatus status,
  ) {
    return switch (status) {
      LessonNodeStatus.completed => l10n.t('path.solved'),
      LessonNodeStatus.current =>
        node.lessonId == 'chapter_test'
            ? l10n.t('path.finalCheck')
            : node.lessonId == 'chapter_2'
            ? l10n.t(node.subtitle)
            : l10n.t('path.continue'),
      LessonNodeStatus.unlocked => l10n.t(node.subtitle),
      LessonNodeStatus.locked => l10n.t(node.lockedSubtitle ?? 'path.locked'),
    };
  }
}

class _LessonChapter {
  const _LessonChapter({
    required this.unit,
    required this.title,
    required this.unlockedSubtitle,
    required this.lockedSubtitle,
    required this.icon,
    required this.mapHeight,
    required this.nodes,
    this.unlockAfterLessonId,
  });

  final String unit;
  final String title;
  final String unlockedSubtitle;
  final String lockedSubtitle;
  final IconData icon;
  final double mapHeight;
  final List<_LessonPathNode> nodes;
  final String? unlockAfterLessonId;
}

class _LessonPathNode {
  const _LessonPathNode({
    required this.lessonId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.position,
    this.lockedSubtitle,
  });

  final String lessonId;
  final String title;
  final String subtitle;
  final String? lockedSubtitle;
  final IconData icon;
  final Offset position;
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({
    required this.unit,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isLocked,
    required this.animationDelay,
    this.statusLabel,
    super.key,
  });

  final String unit;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLocked;
  final Duration animationDelay;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final backgroundColor = isLocked ? colors.locked : colors.primaryDark;
    final textColor = isLocked ? colors.mutedText : colors.onDarkAccent;
    final mutedColor = isLocked ? colors.mutedText : colors.onDarkAccentMuted;

    Widget headerText() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unit,
          style: context.textStyles.caption.copyWith(
            color: mutedColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: context.textStyles.heading.copyWith(color: textColor),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: context.textStyles.caption.copyWith(color: textColor),
        ),
        if (statusLabel != null) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.warning),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                statusLabel!,
                style: context.textStyles.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    Widget headerIcon(double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isLocked
            ? colors.surfaceRaised
            : colors.courseHeaderIconBackground,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(
        isLocked ? Icons.lock_rounded : icon,
        color: textColor,
        size: size * (34 / 62),
      ),
    );

    return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: isLocked ? Border.all(color: colors.border) : null,
            boxShadow: [
              BoxShadow(
                color: isLocked
                    ? colors.shadow.withValues(alpha: 0.10)
                    : colors.courseHeaderShadow,
                blurRadius: isLocked ? 8 : 18,
                offset: Offset(0, isLocked ? 4 : 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // In einem schmalen Bereich (etwa einem geteilten Fenster) passt ein
              // 62-px-Symbol nicht neben den Text. Beide werden gestapelt, statt die
              // Textspalte auf die Breite null zu stauchen.
              if (constraints.maxWidth < 180) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headerText(),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: headerIcon(48),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: headerText()),
                  const SizedBox(width: 12),
                  headerIcon(62),
                ],
              );
            },
          ),
        )
        .animate(delay: animationDelay)
        .fadeIn(duration: 260.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
