import 'package:bachelor/app/app.dart';
import 'package:bachelor/app/router.dart';
import 'package:bachelor/core/widgets/app_language_dropdown.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:bachelor/features/splash/presentation/widgets/startup_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows onboarding before the home screen on first launch', (
    tester,
  ) async {
    final profileStorage = _FakeUserProfileStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileStorageProvider.overrideWithValue(profileStorage),
        ],
        child: FsmQuestApp(profileStorage: profileStorage),
      ),
    );

    expect(find.byType(StartupSplash), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Hi, I\'m Fini!'), findsOneWidget);
    expect(find.text('Choose a username for the game.'), findsNothing);
    expect(find.byType(AppLanguageDropdown), findsOneWidget);

    await tester.tap(find.text('Let\'s go'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Choose a username for the game.'), findsOneWidget);
    expect(find.byType(AppLanguageDropdown), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('Username')),
        matching: find.byType(EditableText),
      ),
      'Alice',
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Finite State Machines'), findsOneWidget);
    expect(find.text('Intro to FSM'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Glad to see you, Alice'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('I\'ll be your guide in FSM Quest'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.textContaining('Together, we\'ll learn finite-state machines'),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('lesson path'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('This is Sandbox'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Progress'), findsOneWidget);
    expect(find.textContaining('Here you can see your XP'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Settings'), findsOneWidget);
    expect(
      find.textContaining('Here you can change the language'),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.textContaining('Choose the language that feels'),
      findsOneWidget,
    );
    expect(find.text('English'), findsWidgets);
    expect(find.text('Deutsch'), findsWidgets);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('head back to the lesson path'), findsOneWidget);
    expect(appRouter.routeInformationProvider.value.uri.path, AppRoutes.home);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Finite State Machines'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('changes language from the onboarding corner dropdown', (
    tester,
  ) async {
    final profileStorage = _FakeUserProfileStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileStorageProvider.overrideWithValue(profileStorage),
        ],
        child: FsmQuestApp(profileStorage: profileStorage),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.byKey(const ValueKey('onboarding-language-dropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch').last);
    await tester.pumpAndSettle();

    expect(find.text('Los geht\'s'), findsOneWidget);
    expect(find.byType(AppLanguageDropdown), findsOneWidget);

    await tester.tap(find.text('Los geht\'s'));
    await tester.pumpAndSettle();

    expect(find.text('Weiter'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _FakeUserProfileStorage extends UserProfileStorage {
  bool isCompleted = false;
  bool hasSeenIntro = false;
  String? name;

  @override
  Future<bool> isOnboardingCompleted() async {
    return isCompleted;
  }

  @override
  Future<String?> getName() async {
    return name;
  }

  @override
  Future<bool> hasSeenMascotIntro() async {
    return hasSeenIntro;
  }

  @override
  Future<void> setMascotIntroSeen() async {
    hasSeenIntro = true;
  }

  @override
  Future<void> saveProfile({required String name}) async {
    this.name = name.trim();
    isCompleted = true;
  }
}
