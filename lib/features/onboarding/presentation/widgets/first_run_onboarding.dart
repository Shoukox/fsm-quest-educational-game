import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/widgets/app_button.dart';
import 'package:bachelor/core/widgets/app_language_dropdown.dart';
import 'package:bachelor/features/mascot/domain/models/mascot_pose.dart';
import 'package:bachelor/features/mascot/presentation/widgets/mascot_widget.dart';
import 'package:bachelor/features/mascot/presentation/widgets/speech_bubble.dart';
import 'package:bachelor/features/profile/data/user_profile_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Begrüßt neue Lernende, bietet die Sprachauswahl an und speichert den gewählten Benutzernamen.
class FirstRunOnboarding extends StatefulWidget {
  const FirstRunOnboarding({
    required this.onCompleted,
    this.profileStorage,
    super.key,
  });

  final VoidCallback onCompleted;
  final UserProfileStorage? profileStorage;

  @override
  State<FirstRunOnboarding> createState() => _FirstRunOnboardingState();
}

class _FirstRunOnboardingState extends State<FirstRunOnboarding> {
  final _usernameController = TextEditingController();
  late final UserProfileStorage _profileStorage;
  bool _isSaving = false;

  // Fini begrüßt zuerst und erklärt das Spiel, bevor nach dem Namen gefragt wird.
  bool _showGreeting = true;

  @override
  void initState() {
    super.initState();
    _profileStorage = widget.profileStorage ?? UserProfileStorage();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_isSaving || _usernameController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      await _profileStorage.saveProfile(name: _usernameController.text);
    } catch (error) {
      // Die App bleibt auch dann nutzbar, wenn der lokale Speicher während
      // eines Tests oder beim frühen Start vorübergehend nicht verfügbar ist.
      debugPrint('Onboarding profile could not be saved: $error');
    }

    if (!mounted) return;
    widget.onCompleted();
  }

  Widget _buildMascot(String animationKey) {
    return MascotWidget(pose: MascotPose.greeting, size: 180)
        .animate(key: ValueKey(animationKey))
        .fadeIn(duration: 220.ms)
        .scale(
          begin: const Offset(0.84, 0.84),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 760.ms,
        );
  }

  Widget _buildGreeting(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      key: const ValueKey('onboarding-greeting'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SpeechBubble(
          message: l10n.t('onboarding.greeting.message'),
          tailAlignment: 0.5,
        ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.12, end: 0),
        const SizedBox(height: 8),
        _buildMascot('onboarding-greeting-mascot'),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: l10n.t('onboarding.greeting.start'),
            onPressed: () => setState(() => _showGreeting = false),
            icon: const Icon(Icons.arrow_forward, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameForm(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      key: const ValueKey('onboarding-username-form'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMascot('onboarding-username'),
        const SizedBox(height: 22),
        Text(
          l10n.t('onboarding.username.title'),
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        TextField(
          key: ValueKey(l10n.t('onboarding.username.label')),
          controller: _usernameController,
          autofocus: true,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          onSubmitted: (_) => _complete(),
          decoration: InputDecoration(
            labelText: l10n.t('onboarding.username.label'),
            hintText: l10n.t('onboarding.username.hint'),
            helperText: l10n.t('onboarding.username.helper'),
            // Längere Hinweise umbrechen, damit auch der deutsche Text vollständig sichtbar bleibt.
            helperMaxLines: 3,
            filled: true,
            fillColor: context.colors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: context.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: context.colors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _usernameController,
            builder: (context, _) {
              final canContinue =
                  _usernameController.text.trim().isNotEmpty && !_isSaving;
              return AppButton(
                label: l10n.t('common.next'),
                onPressed: canContinue ? _complete : null,
                icon: const Icon(Icons.arrow_forward, size: 20),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 84, 28, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: _showGreeting
                          ? _buildGreeting(context)
                          : _buildUsernameForm(context),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 12,
              right: 16,
              child: SizedBox(
                width: 154,
                child: AppLanguageDropdown(
                  key: ValueKey('onboarding-language-dropdown'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
