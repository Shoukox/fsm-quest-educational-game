import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/app/theme/app_theme_mode_controller.dart';
import 'package:bachelor/core/widgets/app_card.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:bachelor/core/services/developer_access_controller.dart';
import 'package:bachelor/core/widgets/app_language_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsLanguageDropdownOpenProvider =
    NotifierProvider<SettingsLanguageDropdownOpenController, int>(
      SettingsLanguageDropdownOpenController.new,
    );

/// Signalzähler zum Öffnen der Sprachauswahl, etwa durch die Maskottchen-Einführung.
class SettingsLanguageDropdownOpenController extends Notifier<int> {
  @override
  int build() => 0;

  void requestOpen() {
    state++;
  }
}

/// Bietet Sprach- und Designauswahl sowie außerhalb von Release-Builds die Entwicklerfreigabe an.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _languageOverlayController = OverlayPortalController();
  final _developerAccess = DeveloperAccessController.instance;

  @override
  void initState() {
    super.initState();
    _developerAccess.load();
  }

  @override
  Widget build(BuildContext context) {
    final themePreference = ref.watch(appThemePreferenceProvider);
    final unlockAllLevels = _developerAccess.unlockAllLevels;
    final l10n = context.l10n;

    ref.listen<int>(settingsLanguageDropdownOpenProvider, (previous, next) {
      if (previous == null) return;
      if (next == previous) return;
      if (!_languageOverlayController.isShowing) {
        _languageOverlayController.show();
      }
    });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.t('settings.title'), style: context.textStyles.title),
        const SizedBox(height: 8),
        Text(l10n.t('settings.description'), style: context.textStyles.caption),
        const SizedBox(height: 16),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  l10n.t('settings.language'),
                  style: context.textStyles.heading,
                ),
              ),
              const Spacer(flex: 1),
              Expanded(
                flex: 5,
                child: AppLanguageDropdown(
                  overlayController: _languageOverlayController,
                ),
              ),
            ],
          ),
        ),
        if (!kReleaseMode) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.developer_mode_outlined),
                title: Text(l10n.t('settings.developerAccess')),
                subtitle: Text(l10n.t('settings.developerAccess.description')),
                value: unlockAllLevels,
                onChanged: (enabled) {
                  AppHaptics.selection();
                  _developerAccess.setUnlockAllLevels(enabled);
                  setState(() {});
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.t('settings.theme'), style: context.textStyles.heading),
              const SizedBox(height: 12),
              SegmentedButton<AppThemePreference>(
                selected: {themePreference},
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: AppThemePreference.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(l10n.t('settings.theme.light')),
                  ),
                  ButtonSegment(
                    value: AppThemePreference.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(l10n.t('settings.theme.dark')),
                  ),
                ],
                onSelectionChanged: (selection) {
                  AppHaptics.selection();
                  ref
                      .read(appThemePreferenceProvider.notifier)
                      .setTheme(selection.first);
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  enableFeedback: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
