import 'package:flutter/material.dart';

/// Reusable splash screen animations
class SplashAnimations {
  final AnimationController logoController;
  final AnimationController textController;
  final AnimationController pulseController;

  late final Animation<double> logoScale;
  late final Animation<double> logoFade;
  late final Animation<double> textFade;
  late final Animation<Offset> textSlide;
  late final Animation<double> pulse;

  SplashAnimations({
    required this.logoController,
    required this.textController,
    required this.pulseController,
  }) {
    _initAnimations();
  }

  void _initAnimations() {
    // Logo animations
    logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.elasticOut),
    );

    logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animations
    textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: textController, curve: Curves.easeIn),
    );

    textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: textController, curve: Curves.easeOut),
    );

    // Pulse animation
    pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  /// Execute the splash animation sequence
  Future<void> playSequence() async {
    await logoController.forward();
    await textController.forward();
    pulseController.repeat(reverse: true);
  }

  void dispose() {
    logoController.dispose();
    textController.dispose();
    pulseController.dispose();
  }
}
