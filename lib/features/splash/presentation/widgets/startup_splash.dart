import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Animiert das App-Symbol beim Start; die Anzeigedauer steuert das übergeordnete App-Widget.
class StartupSplash extends StatefulWidget {
  const StartupSplash({super.key});

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.68, end: 1).animate(_scale),
            child: Image.asset(
              'assets/icon.png',
              width: 168,
              height: 168,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
