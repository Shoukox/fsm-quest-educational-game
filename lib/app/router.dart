import 'package:bachelor/app/main_shell.dart';
import 'package:bachelor/features/fsm_sandbox/presentation/pages/fsm_sandbox_page.dart';
import 'package:bachelor/features/home/presentation/pages/home_page.dart';
import 'package:bachelor/features/lesson/presentation/pages/lesson_page.dart';
import 'package:bachelor/features/lesson/presentation/pages/lesson_result_page.dart';
import 'package:bachelor/features/progress/presentation/pages/progress_page.dart';
import 'package:bachelor/features/profile/presentation/pages/profile_page.dart';
import 'package:bachelor/features/settings/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const lesson = '/lesson/:lessonId';
  static const lessonResult = '/lesson/:lessonId/result';
  static const sandbox = '/sandbox';
  static const progress = '/progress';
  static const profile = '/profile';
  static const settings = '/settings';
}

// Die Hauptseiten teilen sich den HomeShell. Lektion und Ergebnis liegen
// außerhalb dieses Rahmens und werden ohne dessen Navigation angezeigt.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return HomeShell(location: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.sandbox,
          name: 'sandbox',
          builder: (context, state) => const FsmSandboxPage(),
        ),
        GoRoute(
          path: AppRoutes.progress,
          name: 'progress',
          builder: (context, state) => const ProgressPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.lesson,
      name: 'lesson',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';
        return LessonPage(lessonId: lessonId);
      },
    ),
    GoRoute(
      path: AppRoutes.lessonResult,
      name: 'lessonResult',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';
        final score =
            int.tryParse(state.uri.queryParameters['score'] ?? '') ?? 0;
        final stars =
            int.tryParse(state.uri.queryParameters['stars'] ?? '') ?? 1;
        final earnedXp =
            int.tryParse(state.uri.queryParameters['xp'] ?? '') ?? 0;
        final earnedCoins =
            int.tryParse(state.uri.queryParameters['coins'] ?? '') ?? 0;
        final abandoned = state.uri.queryParameters['abandoned'] == 'true';
        final chapterFailed =
            state.uri.queryParameters['chapterFailed'] == 'true';
        final taskCount =
            int.tryParse(state.uri.queryParameters['total'] ?? '') ?? 15;
        final minimumCorrect =
            int.tryParse(state.uri.queryParameters['minimum'] ?? '') ?? 3;
        return LessonResultPage(
          lessonId: lessonId,
          score: score,
          stars: stars,
          earnedXp: earnedXp,
          earnedCoins: earnedCoins,
          abandoned: abandoned,
          chapterFailed: chapterFailed,
          taskCount: taskCount,
          minimumCorrect: minimumCorrect,
        );
      },
    ),
  ],
);
