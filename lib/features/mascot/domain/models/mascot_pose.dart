import 'dart:math' as math;

/// Ordnet den Maskottchen-Posen ihre Bildvarianten für eine zufällige Auswahl zu.
enum MascotPose {
  celebrate(['assets/mascot/celebrate1.png']),
  greeting(['assets/mascot/greeting1.png']),
  happy(['assets/mascot/happy1.png', 'assets/mascot/happy2.png']),
  icon(['assets/mascot/icon.png']),
  sad(['assets/mascot/sad1.png']),
  speaking([
    'assets/mascot/speaking1.png',
    'assets/mascot/speaking2.png',
    'assets/mascot/speaking3.png',
    'assets/mascot/speaking4.png',
  ]),
  thinking(['assets/mascot/thinking1.png', 'assets/mascot/thinking2.png']);

  const MascotPose(this.assetPaths);

  final List<String> assetPaths;

  String randomAssetPath(math.Random random) {
    return assetPaths[random.nextInt(assetPaths.length)];
  }
}
