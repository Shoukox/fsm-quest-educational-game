import 'dart:io';

import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/main_shell.dart';
import 'package:bachelor/app/theme/app_theme.dart';
import 'package:bachelor/features/lesson/presentation/pages/lesson_page.dart';
import 'package:bachelor/features/lesson/presentation/pages/lesson_result_page.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('sad mascot pose uses a project asset', () {
    expect(MascotPose.sad.assetPaths, ['assets/mascot/sad1.png']);
    expect(File('assets/mascot/sad1.png').existsSync(), isTrue);
  });

  testWidgets('back from the home menu opens the mascot exit dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AppLocalizations(
          language: AppLanguage.en,
          child: const HomeShell(location: '/', child: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Exit app?'), findsOneWidget);
    expect(find.byType(MascotWidget), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Exit app?'), findsNothing);
  });

  testWidgets('leaving a lesson asks for confirmation and opens results', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/lesson/states',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (context, state) {
            return LessonPage(lessonId: state.pathParameters['lessonId'] ?? '');
          },
        ),
        GoRoute(
          path: '/lesson/:lessonId/result',
          builder: (context, state) {
            return Scaffold(
              body: Text(
                'results abandoned=${state.uri.queryParameters['abandoned']}',
              ),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          builder: (context, child) {
            return AppLocalizations(
              language: AppLanguage.en,
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Leave lesson?'), findsOneWidget);
    expect(find.textContaining('will not be saved'), findsOneWidget);

    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    expect(find.text('results abandoned=true'), findsOneWidget);
  });

  testWidgets('abandoned results explicitly show that nothing was saved', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AppLocalizations(
          language: AppLanguage.en,
          child: const LessonResultPage(
            lessonId: 'states',
            score: 2,
            stars: 0,
            earnedXp: 0,
            earnedCoins: 0,
            abandoned: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lesson interrupted'), findsOneWidget);
    expect(find.textContaining('Progress was not saved'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
  });

  testWidgets('result next button opens the following lesson', (tester) async {
    final router = GoRouter(
      initialLocation: '/lesson/intro/result',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (context, state) => Scaffold(
            body: Text('lesson=${state.pathParameters['lessonId']}'),
          ),
        ),
        GoRoute(
          path: '/lesson/:lessonId/result',
          builder: (context, state) => LessonResultPage(
            lessonId: state.pathParameters['lessonId'] ?? '',
            stars: 0,
            earnedXp: 0,
            earnedCoins: 0,
            abandoned: true,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
        builder: (context, child) => AppLocalizations(
          language: AppLanguage.en,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next lesson'));
    await tester.pumpAndSettle();

    expect(find.text('lesson=states'), findsOneWidget);
  });
}
