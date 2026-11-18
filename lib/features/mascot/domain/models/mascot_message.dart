import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';

/// Navigationsbereiche, auf die die Maskottchen-Einführung verweisen kann.
enum MascotGuideTarget { lessonPath, sandbox, progress, settings }

/// Nachrichtenzustand mit Text, Pose, Sichtbarkeit und optionalem Navigationsauftrag.
class MascotMessage {
  const MascotMessage({
    required this.text,
    this.pose = MascotPose.greeting,
    this.isVisible = false,
    this.target = MascotGuideTarget.lessonPath,
    this.route,
    this.openLanguagePicker = false,
  });

  final String text;
  final MascotPose pose;
  final bool isVisible;
  final MascotGuideTarget target;
  final String? route;
  final bool openLanguagePicker;

  MascotMessage copyWith({
    String? text,
    MascotPose? pose,
    bool? isVisible,
    MascotGuideTarget? target,
    String? route,
    bool? openLanguagePicker,
  }) {
    return MascotMessage(
      text: text ?? this.text,
      pose: pose ?? this.pose,
      isVisible: isVisible ?? this.isVisible,
      target: target ?? this.target,
      route: route ?? this.route,
      openLanguagePicker: openLanguagePicker ?? this.openLanguagePicker,
    );
  }
}
