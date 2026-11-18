import 'package:bachelor/features/home/presentation/widgets/lesson_path.dart';
import 'package:bachelor/features/home/presentation/widgets/chapter_onboarding_guide.dart';
import 'package:bachelor/features/mascot/presentation/controllers/mascot_controller.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_message.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zeigt den Lernpfad und startet die Kapitelführung erst nach der allgemeinen Maskottchen-Einführung.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<LessonPathState> _lessonPathKey =
      GlobalKey<LessonPathState>();
  bool _showChapterGuide = false;
  bool _checkingChapterChoice = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareOnboarding();
    });
  }

  Future<void> _prepareOnboarding() async {
    await ref.read(mascotControllerProvider.notifier).showIntroIfNeeded();
    if (!mounted || ref.read(mascotControllerProvider).isVisible) return;
    await _maybeShowChapterGuide();
  }

  Future<void> _maybeShowChapterGuide() async {
    if (_showChapterGuide || _checkingChapterChoice || !mounted) return;
    _checkingChapterChoice = true;
    try {
      final alreadyResolved = await ref
          .read(userProfileStorageProvider)
          .hasChapter1EntryChoiceResolved();
      if (!mounted || alreadyResolved) return;
      if (ref.read(mascotControllerProvider).isVisible) return;
      setState(() => _showChapterGuide = true);
    } finally {
      _checkingChapterChoice = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MascotMessage>(mascotControllerProvider, (previous, next) {
      if (previous?.isVisible == true && !next.isVisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeShowChapterGuide();
        });
      }
    });

    return Stack(
      children: [
        LessonPath(key: _lessonPathKey),
        if (_showChapterGuide)
          ChapterOnboardingGuide(lessonPathKey: _lessonPathKey),
      ],
    );
  }
}
