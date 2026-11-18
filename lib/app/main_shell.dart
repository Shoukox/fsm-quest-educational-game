import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/router.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/services/database_service.dart';
import 'package:bachelor/features/mascot/presentation/mascot_guide_anchors.dart';
import 'package:bachelor/features/mascot/presentation/widgets/exit_confirmation_dialog.dart';
import 'package:bachelor/features/progress/domain/models/user_progress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Rahmt die Hauptseiten mit Navigation und einer gemeinsamen Statusanzeige ein.
/// Ab 900 Pixel Breite liegt die Navigation seitlich, sonst am unteren Rand.
class HomeShell extends StatelessWidget {
  const HomeShell({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  int get _selectedIndex {
    if (location.startsWith(AppRoutes.sandbox)) return 1;
    if (location.startsWith(AppRoutes.progress)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    if (location.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex;
    final l10n = context.l10n;

    final items = [
      _BottomNavigationItem(
        label: l10n.t('nav.learn'),
        icon: Icons.school_outlined,
        selectedIcon: Icons.school,
      ),
      _BottomNavigationItem(
        label: l10n.t('nav.sandbox'),
        icon: Icons.account_tree_outlined,
        selectedIcon: Icons.account_tree,
      ),
      _BottomNavigationItem(
        label: l10n.t('nav.progress'),
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events,
      ),
      _BottomNavigationItem(
        label: l10n.t('nav.profile'),
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
      _BottomNavigationItem(
        label: l10n.t('nav.settings'),
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
      ),
    ];

    void selectDestination(int index) {
      if (index == selectedIndex) return;
      AppHaptics.selection();
      if (index == 0) context.go(AppRoutes.home);
      if (index == 1) context.go(AppRoutes.sandbox);
      if (index == 2) context.go(AppRoutes.progress);
      if (index == 3) context.go(AppRoutes.profile);
      if (index == 4) context.go(AppRoutes.settings);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wideLayout = constraints.maxWidth >= 900;

        return PopScope(
          canPop: kIsWeb,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop || kIsWeb) return;

            // Zurück führt zuerst zum Lernpfad; erst dort wird das Verlassen der App bestätigt.
            if (selectedIndex != 0) {
              context.go(AppRoutes.home);
              return;
            }

            final shouldExit = await _showExitDialog(context);
            if (shouldExit && context.mounted) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: SafeArea(
              child: Row(
                children: [
                  if (wideLayout)
                    MascotGuideAnchors.wrapRail(
                      _SideNavigationRail(
                        selectedIndex: selectedIndex,
                        items: items,
                        onSelected: selectDestination,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        _TopStatsBar(
                          canGoBack: selectedIndex != 0,
                          onBack: () => context.go(AppRoutes.home),
                        ),
                        Expanded(
                          child: wideLayout
                              ? Align(
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1200,
                                    ),
                                    child: child,
                                  ),
                                )
                              : child,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: wideLayout
                ? null
                : _BottomNavigationBar(
                    selectedIndex: selectedIndex,
                    items: items,
                    onSelected: selectDestination,
                  ),
          ),
        );
      },
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final l10n = context.l10n;
    AppHaptics.warning();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ExitConfirmationDialog(
          title: l10n.t('exitDialog.title'),
          message: l10n.t('exitDialog.message'),
          cancelLabel: l10n.t('common.cancel'),
          confirmLabel: l10n.t('exitDialog.confirm'),
        );
      },
    );

    return result ?? false;
  }
}

class _SideNavigationRail extends StatelessWidget {
  const _SideNavigationRail({
    required this.selectedIndex,
    required this.items,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_BottomNavigationItem> items;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: NavigationRail(
        backgroundColor: colors.surface,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        labelType: NavigationRailLabelType.all,
        minWidth: 88,
        selectedIconTheme: IconThemeData(color: colors.onPrimary),
        unselectedIconTheme: IconThemeData(color: colors.mutedText),
        destinations: [
          for (var index = 0; index < items.length; index++)
            NavigationRailDestination(
              // Nur eines der beiden Symbole wird gebaut; der Anker-Schlüssel bleibt eindeutig.
              icon: MascotGuideAnchors.wrap(index, Icon(items[index].icon)),
              selectedIcon: MascotGuideAnchors.wrap(
                index,
                Icon(items[index].selectedIcon),
              ),
              label: Text(items[index].label),
            ),
        ],
      ),
    );
  }
}

class _BottomNavigationItem {
  const _BottomNavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.selectedIndex,
    required this.items,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_BottomNavigationItem> items;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MediaQuery.withNoTextScaling(
      child: SafeArea(
        top: false,
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: MascotGuideAnchors.wrap(
                    index,
                    _BottomNavigationDestination(
                      item: items[index],
                      isSelected: index == selectedIndex,
                      onTap: () => onSelected(index),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationDestination extends StatelessWidget {
  const _BottomNavigationDestination({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _BottomNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = isSelected ? colors.onPrimary : colors.mutedText;
    final labelColor = isSelected ? colors.text : colors.mutedText;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopStatsBar extends StatefulWidget {
  const _TopStatsBar({required this.canGoBack, required this.onBack});

  final bool canGoBack;
  final VoidCallback onBack;

  @override
  State<_TopStatsBar> createState() => _TopStatsBarState();
}

class _TopStatsBarState extends State<_TopStatsBar> {
  late final Future<UserProgress> _progressFuture = DatabaseService.instance
      .getUserProgress();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProgress>(
      future: _progressFuture,
      builder: (context, snapshot) {
        final progress = snapshot.data;

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 380;
            return Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  bottom: BorderSide(color: context.colors.border),
                ),
              ),
              child: Row(
                children: [
                  if (widget.canGoBack) ...[
                    IconButton(
                      onPressed: AppHaptics.wrapButton(widget.onBack),
                      icon: const Icon(Icons.arrow_back),
                      color: context.colors.secondary,
                      tooltip: context.l10n.t('common.back'),
                    ),
                    const SizedBox(width: 4),
                  ],
                  _CourseChip(compact: compact),
                  const SizedBox(width: 12),
                  // Expanded nutzt den übrigen Platz vollständig, damit die
                  // Statuswerte am rechten Rand ausgerichtet bleiben.
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatChip(
                            icon: Icons.bolt_rounded,
                            value: '${progress?.totalXp ?? 0}',
                            color: context.colors.xp,
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            icon: Icons.monetization_on_rounded,
                            value: '${progress?.coins ?? 0}',
                            color: context.colors.warning,
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            icon: Icons.star_rounded,
                            value: '${progress?.totalStars ?? 0}',
                            color: context.colors.warning,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CourseChip extends StatelessWidget {
  const _CourseChip({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.memory, color: context.colors.secondary, size: 20),
          if (!compact) ...[
            const SizedBox(width: 8),
            const Text('FSM', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
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
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          value,
          style: context.textStyles.body.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
