import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/core/services/app_haptics.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sprachauswahl, die den Riverpod-Sprachzustand anzeigt und Änderungen lokal speichern lässt.
class AppLanguageDropdown extends ConsumerWidget {
  const AppLanguageDropdown({this.overlayController, super.key});

  final OverlayPortalController? overlayController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);

    return DropdownFlutter<AppLanguage>(
      // Der sprachabhängige Schlüssel erneuert die interne Auswahl nach externen Sprachwechseln.
      key: ValueKey('app-language-${language.code}'),
      overlayController: overlayController,
      initialItem: language,
      hintText: context.l10n.t('settings.language'),
      items: AppLanguage.values,
      headerBuilder: (context, selectedLanguage, enabled) {
        return _LanguageOption(language: selectedLanguage);
      },
      listItemBuilder: (context, option, isSelected, onItemSelect) {
        return InkWell(
          onTap: onItemSelect,
          child: _LanguageOption(language: option, isSelected: isSelected),
        );
      },
      onChanged: (value) {
        if (value == null) return;
        AppHaptics.selection();
        ref.read(appLanguageProvider.notifier).setLanguage(value);
      },
      decoration: CustomDropdownDecoration(
        closedFillColor: context.colors.surfaceRaised,
        expandedFillColor: context.colors.surfaceRaised,
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.language, this.isSelected = false});

  final AppLanguage language;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                _flagFor(language),
                style: const TextStyle(
                  fontSize: 22,
                  height: 1,
                  fontFamilyFallback: [
                    'Segoe UI Emoji',
                    'Apple Color Emoji',
                    'Noto Color Emoji',
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              language.label,
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                height: 1,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check, size: 16),
          ],
        ],
      ),
    );
  }

  String _flagFor(AppLanguage language) {
    return switch (language) {
      AppLanguage.en => '\u{1F1EC}\u{1F1E7}',
      AppLanguage.de => '\u{1F1E9}\u{1F1EA}',
      AppLanguage.ru => '\u{1F1F7}\u{1F1FA}',
    };
  }
}
