import 'dart:math' as math;

import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:flutter/material.dart';

/// Zeigt eine Bildvariante der gewählten Pose mit optionalem kosmetischem Symbol.
class MascotWidget extends StatefulWidget {
  const MascotWidget({
    required this.pose,
    this.size = 150,
    this.cosmeticId,
    super.key,
  });

  final MascotPose pose;
  final double size;
  final String? cosmeticId;

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget> {
  final _random = math.Random();
  late String _assetPath;

  @override
  void initState() {
    super.initState();
    _assetPath = widget.pose.randomAssetPath(_random);
  }

  @override
  void didUpdateWidget(covariant MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Die Bildvariante wechselt nur bei einer neuen Pose und bleibt bei normalen Builds stabil.
    if (oldWidget.pose != widget.pose) {
      _assetPath = widget.pose.randomAssetPath(_random);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cosmetic = widget.cosmeticId;
    return Semantics(
      label: cosmetic == null ? null : 'mascot-$cosmetic',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            _assetPath,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          ),
          if (cosmetic != null)
            Positioned(
              top: widget.size * 0.02,
              right: widget.size * 0.05,
              child: Container(
                width: widget.size * 0.30,
                height: widget.size * 0.30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _iconForCosmetic(cosmetic),
                  size: widget.size * 0.18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconForCosmetic(String id) {
    return switch (id) {
      'cap' => Icons.school_rounded,
      'scarf' => Icons.dry_cleaning_rounded,
      'glasses' => Icons.visibility_rounded,
      'crown' => Icons.workspace_premium_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }
}
