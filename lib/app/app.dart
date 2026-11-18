import 'dart:async';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/router.dart';
import 'package:bachelor/app/theme/app_theme.dart';
import 'package:bachelor/app/theme/app_theme_mode_controller.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_overlay.dart';
import 'package:bachelor/features/onboarding/presentation/widgets/first_run_onboarding.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:bachelor/features/splash/presentation/widgets/startup_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Verbindet Navigation, Sprache und Design mit Startbildschirm und Einführung.
class FsmQuestApp extends ConsumerStatefulWidget {
  const FsmQuestApp({this.profileStorage, super.key});

  final UserProfileStorage? profileStorage;

  @override
  ConsumerState<FsmQuestApp> createState() => _FsmQuestAppState();
}

class _FsmQuestAppState extends ConsumerState<FsmQuestApp> {
  static const _splashDuration = Duration(seconds: 2);

  Timer? _splashTimer;
  bool _showSplash = true;
  bool? _isOnboardingCompleted;

  UserProfileStorage get _profileStorage {
    return widget.profileStorage ?? ref.read(userProfileStorageProvider);
  }

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
    _splashTimer = Timer(_splashDuration, () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOnboardingState() async {
    try {
      final isCompleted = await _profileStorage.isOnboardingCompleted();
      if (!mounted) return;
      setState(() => _isOnboardingCompleted = isCompleted);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isOnboardingCompleted = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final themePreference = ref.watch(appThemePreferenceProvider);

    return MaterialApp.router(
      title: 'FSM Quest',
      locale: Locale(language.code),
      debugShowCheckedModeBanner: false,
      theme: switch (themePreference) {
        AppThemePreference.light => AppTheme.light(),
        AppThemePreference.dark => AppTheme.dark(),
      },
      // Der längere Übergang lässt den Wechsel zwischen hellem und dunklem
      // Design als zusammenhängende Farbänderung erscheinen.
      themeAnimationDuration: const Duration(milliseconds: 450),
      themeAnimationCurve: Curves.easeInOutCubic,
      routerConfig: appRouter,
      builder: (context, child) {
        // Solange der gespeicherte Einführungsstatus fehlt, bleibt der Inhalt
        // nach dem Startbildschirm leer; die Hauptansicht erscheint erst danach.
        final content = switch ((_showSplash, _isOnboardingCompleted)) {
          (true, _) => const StartupSplash(),
          (false, null) => const SizedBox.shrink(),
          (false, false) => Navigator(
            onGenerateRoute: (_) {
              return MaterialPageRoute<void>(
                builder: (_) => FirstRunOnboarding(
                  profileStorage: _profileStorage,
                  onCompleted: () {
                    setState(() => _isOnboardingCompleted = true);
                  },
                ),
              );
            },
          ),
          (false, true) => MascotOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        };

        return AppLocalizations(language: language, child: content);
      },
    );
  }
}
