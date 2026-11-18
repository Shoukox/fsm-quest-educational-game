import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/services/database_service.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/features/lesson/data/lesson_local_data_source.dart';
import 'package:bachelor/features/lesson/domain/models/lesson.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_widget.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:bachelor/features/profile/domain/models/cosmetic_item.dart';
import 'package:bachelor/features/progress/domain/models/lesson_progress.dart';
import 'package:bachelor/features/progress/domain/models/user_progress.dart';
import 'package:flutter/material.dart';

/// Verbindet Profilbearbeitung, Lernstatistik und Kauf beziehungsweise Auswahl von Accessoires.
class ProfilePage extends StatefulWidget {
  const ProfilePage({this.profileStorage, super.key});

  final UserProfileStorage? profileStorage;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _profileLoadTimeout = Duration(seconds: 2);

  late final UserProfileStorage _storage;
  final Set<String> _busyItems = {};
  Future<_ProfileSnapshot>? _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _storage = widget.profileStorage ?? UserProfileStorage();
    _snapshotFuture = _loadSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileSnapshot>(
      future: _snapshotFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text(context.l10n.t('profile.loadFailed')));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              context.l10n.t('profile.title'),
              style: context.textStyles.title,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.t('profile.subtitle'),
              style: context.textStyles.body,
            ),
            const SizedBox(height: 16),
            _ProfileHeader(data: data, onEdit: () => _editProfile(data)),
            const SizedBox(height: 16),
            _StatsGrid(progress: data.progress),
            const SizedBox(height: 20),
            _ChapterProgress(progress: data.progress),
            const SizedBox(height: 20),
            _WardrobeCard(
              data: data,
              busyItems: _busyItems,
              onPressed: _handleCosmetic,
            ),
          ],
        );
      },
    );
  }

  /// Lädt die Profilteile parallel; die einzelnen Lesehilfen begrenzen Wartezeit und setzen Ersatzwerte.
  Future<_ProfileSnapshot> _loadSnapshot() async {
    try {
      final results = await Future.wait<Object?>([
        _loadProgressSafely(),
        _loadNameSafely(),
        _loadOwnedCosmeticsSafely(),
        _loadEquippedCosmeticSafely(),
      ]);
      return _ProfileSnapshot(
        progress: results[0] as UserProgress,
        name: results[1] as String?,
        ownedCosmetics: results[2]! as Set<String>,
        equippedCosmetic: results[3] as String?,
      );
    } catch (_) {
      return const _ProfileSnapshot.empty();
    }
  }

  Future<String?> _loadNameSafely() async {
    try {
      return await _storage.getName().timeout(_profileLoadTimeout);
    } catch (_) {
      return null;
    }
  }

  Future<Set<String>> _loadOwnedCosmeticsSafely() async {
    try {
      return await _storage.getOwnedCosmetics().timeout(_profileLoadTimeout);
    } catch (_) {
      return <String>{};
    }
  }

  Future<String?> _loadEquippedCosmeticSafely() async {
    try {
      return await _storage.getEquippedCosmetic().timeout(_profileLoadTimeout);
    } catch (_) {
      return null;
    }
  }

  Future<UserProgress> _loadProgressSafely() async {
    try {
      return await _loadProgress().timeout(_profileLoadTimeout);
    } catch (_) {
      return _emptyProgress;
    }
  }

  static const _emptyProgress = UserProgress(
    totalXp: 0,
    streakDays: 0,
    hearts: 5,
    gems: 0,
    coins: 0,
  );

  Future<UserProgress> _loadProgress() async {
    try {
      return await DatabaseService.instance.getUserProgress();
    } catch (_) {
      return _emptyProgress;
    }
  }

  void _reload() {
    // Der Block gibt kein Future an setState zurück: dessen Callback muss
    // synchron bleiben, auch wenn er einen neuen Ladevorgang anstößt.
    setState(() {
      _snapshotFuture = _loadSnapshot();
    });
  }

  Future<void> _editProfile(_ProfileSnapshot data) async {
    // Der Dialog verwaltet seinen Text-Controller bis zu seinem vollständigen
    // Schließen und liefert den neuen Namen oder bei Abbruch null zurück.
    final username = await showDialog<String>(
      context: context,
      builder: (_) => _EditUsernameDialog(initialName: data.name ?? ''),
    );
    if (username == null || !mounted) return;

    try {
      await _storage.saveProfile(name: username);
      if (mounted) _reload();
    } catch (error, stackTrace) {
      debugPrint('Profile could not be saved: $error\n$stackTrace');
      if (mounted) {
        AppHaptics.warning();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('profile.saveFailed'))),
        );
      }
    }
  }

  /// Rüstet vorhandene Accessoires aus oder bezahlt und speichert einen Neukauf.
  /// Die Sperre pro Gegenstand verhindert überlappende Aufrufe durch mehrfaches Antippen.
  Future<void> _handleCosmetic(CosmeticItem item, _ProfileSnapshot data) async {
    if (_busyItems.contains(item.id)) return;
    setState(() => _busyItems.add(item.id));

    try {
      if (data.ownedCosmetics.contains(item.id)) {
        await _storage.setEquippedCosmetic(item.id);
        if (mounted) {
          AppHaptics.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.t('profile.shop.equipSuccess')),
            ),
          );
        }
      } else {
        final purchased = await DatabaseService.instance.trySpendCoins(
          item.price,
        );
        if (!purchased) {
          if (mounted) {
            AppHaptics.warning();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.t('profile.shop.notEnoughCoins')),
              ),
            );
          }
          return;
        }
        await _storage.addOwnedCosmetic(item.id);
        await _storage.setEquippedCosmetic(item.id);
        if (mounted) {
          AppHaptics.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.t('profile.shop.purchaseSuccess')),
            ),
          );
        }
      }
      if (mounted) _reload();
    } catch (_) {
      if (mounted) {
        AppHaptics.warning();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('profile.saveFailed'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busyItems.remove(item.id));
    }
  }
}

class _ProfileSnapshot {
  const _ProfileSnapshot.empty()
    : progress = const UserProgress(
        totalXp: 0,
        streakDays: 0,
        hearts: 5,
        gems: 0,
        coins: 0,
      ),
      name = null,
      ownedCosmetics = const <String>{},
      equippedCosmetic = null;

  const _ProfileSnapshot({
    required this.progress,
    required this.name,
    required this.ownedCosmetics,
    required this.equippedCosmetic,
  });

  final UserProgress progress;
  final String? name;
  final Set<String> ownedCosmetics;
  final String? equippedCosmetic;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.data, required this.onEdit});

  final _ProfileSnapshot data;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Row(
        children: [
          MascotWidget(
            pose: MascotPose.happy,
            size: 104,
            cosmeticId: data.equippedCosmetic,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name?.isNotEmpty == true
                      ? data.name!
                      : l10n.t('profile.unknown'),
                  style: context.textStyles.heading,
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.t('profile.username')}: ${data.name?.isNotEmpty == true ? data.name : l10n.t('profile.unknown')}',
                  style: context.textStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: AppHaptics.wrapButton(onEdit),
            tooltip: l10n.t('profile.edit'),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.progress});

  final UserProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final level = progress.totalXp ~/ 100 + 1;
    final stats = [
      _ProfileStat(
        Icons.bolt_rounded,
        l10n.t('profile.stats.xp', args: {'xp': progress.totalXp}),
        context.colors.xp,
      ),
      _ProfileStat(
        Icons.star_rounded,
        l10n.t('profile.stats.stars', args: {'stars': progress.totalStars}),
        context.colors.warning,
      ),
      _ProfileStat(
        Icons.monetization_on_rounded,
        l10n.t('profile.stats.coins', args: {'coins': progress.coins}),
        context.colors.warning,
      ),
      _ProfileStat(
        Icons.local_fire_department_rounded,
        l10n.t('profile.stats.streak', args: {'days': progress.streakDays}),
        context.colors.heart,
      ),
      _ProfileStat(
        Icons.military_tech_rounded,
        l10n.t('profile.stats.level', args: {'level': level}),
        context.colors.secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: columns == 3 ? 2.25 : 1.9,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [for (final stat in stats) _StatTile(stat: stat)],
        );
      },
    );
  }
}

class _ProfileStat {
  const _ProfileStat(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final _ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(stat.icon, color: stat.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stat.label,
              style: context.textStyles.caption.copyWith(
                color: context.colors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterProgress extends StatelessWidget {
  const _ChapterProgress({required this.progress});

  static const _lessons = LessonLocalDataSource();
  static const _chapterIds = [
    'chapter1',
    'chapter2',
    'chapter3',
    'chapter4',
    'chapter5',
  ];

  final UserProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progressById = {
      for (final item in progress.lessons) item.lessonId: item,
    };
    final lessonsByChapter = <String, List<Lesson>>{};
    for (final lesson in _lessons.getLessons()) {
      (lessonsByChapter[lesson.chapterId] ??= []).add(lesson);
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('profile.chapterProgress.title'),
            style: context.textStyles.heading,
          ),
          const SizedBox(height: 12),
          for (final chapterId in _chapterIds)
            ..._chapterWidgets(
              context: context,
              chapterId: chapterId,
              lessons: lessonsByChapter[chapterId] ?? const [],
              progressById: progressById,
              addBottomSpacing: chapterId != _chapterIds.last,
            ),
        ],
      ),
    );
  }

  List<Widget> _chapterWidgets({
    required BuildContext context,
    required String chapterId,
    required List<Lesson> lessons,
    required Map<String, LessonProgress> progressById,
    required bool addBottomSpacing,
  }) {
    final completed = lessons
        .where((lesson) => progressById[lesson.id]?.isCompleted == true)
        .length;
    return [
      Text(
        context.l10n.t(
          'profile.chapterProgress.item',
          args: {
            'chapter': _chapterLabel(context.l10n, chapterId),
            'completed': completed.toString(),
            'total': lessons.length.toString(),
          },
        ),
        style: context.textStyles.body.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 5),
      LinearProgressIndicator(
        value: lessons.isEmpty ? 0 : completed / lessons.length,
        minHeight: 8,
        borderRadius: BorderRadius.circular(5),
      ),
      if (addBottomSpacing) const SizedBox(height: 14),
    ];
  }

  String _chapterLabel(AppLocalizations l10n, String chapterId) {
    final number = switch (chapterId) {
      'chapter1' => 1,
      'chapter2' => 2,
      'chapter3' => 3,
      'chapter4' => 4,
      'chapter5' => 5,
      _ => null,
    };
    return number == null
        ? chapterId
        : l10n.t(
            'profile.chapterProgress.chapter',
            args: {'number': number.toString()},
          );
  }
}

class _WardrobeCard extends StatelessWidget {
  const _WardrobeCard({
    required this.data,
    required this.busyItems,
    required this.onPressed,
  });

  final _ProfileSnapshot data;
  final Set<String> busyItems;
  final Future<void> Function(CosmeticItem item, _ProfileSnapshot data)
  onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.t('profile.shop.title'), style: context.textStyles.heading),
          const SizedBox(height: 4),
          Text(
            l10n.t('profile.shop.subtitle'),
            style: context.textStyles.caption,
          ),
          const SizedBox(height: 10),
          for (final item in cosmeticItems)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: context.colors.background,
                child: Icon(item.icon, color: context.colors.secondary),
              ),
              title: Text(l10n.t(item.titleKey)),
              subtitle: Text(
                '${l10n.t(item.descriptionKey)}\n${item.price} ${l10n.t('profile.stats.coins', args: {'coins': ''}).trim()}',
              ),
              isThreeLine: true,
              trailing: _itemButton(context, item),
            ),
        ],
      ),
    );
  }

  Widget _itemButton(BuildContext context, CosmeticItem item) {
    final owned = data.ownedCosmetics.contains(item.id);
    final equipped = data.equippedCosmetic == item.id;
    final busy = busyItems.contains(item.id);
    return SizedBox(
      width: 92,
      child: OutlinedButton(
        onPressed: AppHaptics.wrapButton(
          busy || equipped ? null : () => onPressed(item, data),
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                equipped
                    ? context.l10n.t('profile.shop.equipped')
                    : owned
                    ? context.l10n.t('profile.shop.equip')
                    : context.l10n.t('profile.shop.buy'),
              ),
      ),
    );
  }
}

class _EditUsernameDialog extends StatefulWidget {
  const _EditUsernameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.t('profile.editTitle')),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        onSubmitted: (_) => Navigator.of(context).pop(_controller.text),
        decoration: InputDecoration(
          labelText: l10n.t('profile.username'),
          hintText: l10n.t('profile.usernameHint'),
          helperText: l10n.t('profile.usernameHelper'),
          helperMaxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: AppHaptics.wrapButton(() => Navigator.of(context).pop()),
          child: Text(l10n.t('common.cancel')),
        ),
        FilledButton(
          onPressed: AppHaptics.wrapButton(
            () => Navigator.of(context).pop(_controller.text),
          ),
          child: Text(l10n.t('common.save')),
        ),
      ],
    );
  }
}
