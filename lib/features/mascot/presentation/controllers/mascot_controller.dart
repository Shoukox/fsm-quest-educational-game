import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/router.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_message.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mascotControllerProvider =
    NotifierProvider<MascotController, MascotMessage>(MascotController.new);

/// Steuert sichtbare Maskottchen-Nachrichten und geführte Nachrichtenfolgen.
class MascotController extends Notifier<MascotMessage> {
  bool _introHandledThisSession = false;
  List<MascotMessage> _pendingMessages = const [];

  @override
  MascotMessage build() {
    return const MascotMessage(
      text: '',
      pose: MascotPose.greeting,
      isVisible: false,
    );
  }

  void show({
    required String text,
    MascotPose pose = MascotPose.speaking,
    MascotGuideTarget target = MascotGuideTarget.lessonPath,
  }) {
    _pendingMessages = const [];
    state = MascotMessage(
      text: text,
      pose: pose,
      isVisible: true,
      target: target,
    );
  }

  void showSequence(List<MascotMessage> messages) {
    if (messages.isEmpty) return;
    _pendingMessages = messages.skip(1).toList(growable: false);
    state = messages.first.copyWith(isVisible: true);
  }

  /// Zeigt die nächste Nachricht oder blendet das Maskottchen am Ende der Folge aus.
  MascotMessage? advanceOrHide() {
    if (_pendingMessages.isEmpty) {
      hide();
      return null;
    }

    final next = _pendingMessages.first;
    _pendingMessages = _pendingMessages.skip(1).toList(growable: false);
    state = next.copyWith(isVisible: true);
    return state;
  }

  void hide() {
    _pendingMessages = const [];
    state = state.copyWith(isVisible: false);
  }

  Future<void> showIntroIfNeeded() async {
    // Die Sitzungssperre wird vor dem ersten await gesetzt, damit parallele
    // Aufrufe die Einführung nicht mehrfach laden und anzeigen.
    if (_introHandledThisSession) return;
    _introHandledThisSession = true;

    final storage = ref.read(userProfileStorageProvider);

    try {
      final hasSeenIntro = await storage.hasSeenMascotIntro();
      if (hasSeenIntro) return;

      await storage.setMascotIntroSeen();
      final language = ref.read(appLanguageProvider);
      final username = await storage.getName();
      final trimmedUsername = username?.trim() ?? '';

      showSequence([
        MascotMessage(
          text: translate(
            language,
            trimmedUsername.isEmpty
                ? 'mascot.intro.greeting'
                : 'mascot.intro.greeting.username',
            args: {'username': trimmedUsername},
          ),
          pose: MascotPose.greeting,
          target: MascotGuideTarget.lessonPath,
          route: AppRoutes.home,
        ),
        MascotMessage(
          text: translate(language, 'mascot.intro.identity'),
          pose: MascotPose.speaking,
          target: MascotGuideTarget.lessonPath,
          route: AppRoutes.home,
        ),
        MascotMessage(
          text: translate(language, 'mascot.intro.mission'),
          pose: MascotPose.speaking,
          target: MascotGuideTarget.lessonPath,
          route: AppRoutes.home,
        ),
        MascotMessage(
          text: translate(language, 'mascot.intro.lessonPath'),
          pose: MascotPose.speaking,
          target: MascotGuideTarget.lessonPath,
          route: AppRoutes.home,
        ),
        MascotMessage(
          text: translate(language, 'mascot.intro.sandbox'),
          pose: MascotPose.speaking,
          target: MascotGuideTarget.sandbox,
          route: AppRoutes.sandbox,
        ),
        MascotMessage(
          text: translate(language, 'mascot.intro.progress'),
          pose: MascotPose.speaking,
          target: MascotGuideTarget.progress,
          route: AppRoutes.progress,
        ),
        MascotMessage(
          text: translate(language, 'mascot.intro.settings'),
          pose: MascotPose.speaking,
          target: MascotGuideTarget.settings,
          route: AppRoutes.settings,
        ),
        MascotMessage(
          text: translate(language, 'mascot.intro.languages'),
          pose: MascotPose.speaking,
          target: MascotGuideTarget.settings,
          route: AppRoutes.settings,
          openLanguagePicker: true,
        ),
        MascotMessage(
          text: translate(language, 'mascot.intro.returnHome'),
          pose: MascotPose.greeting,
          target: MascotGuideTarget.lessonPath,
          route: AppRoutes.home,
        ),
      ]);
    } catch (ex) {
      final language = ref.read(appLanguageProvider);
      show(
        text: translate(language, 'mascot.fallback'),
        pose: MascotPose.greeting,
      );
    }
  }
}
