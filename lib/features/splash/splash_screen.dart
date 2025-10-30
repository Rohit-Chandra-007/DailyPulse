import 'dart:async';

import 'package:dailypulse/core/animations/common_animations.dart';
import 'package:flutter/material.dart';

import '../../core/animations/splash_animations.dart';
import '../../core/routes/fade_page_route.dart';
import '../auth/widgets/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashAnimations _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    _animations = SplashAnimations(
      logoController: AnimationController(
        duration: AnimationDurations.verySlow,
        vsync: this,
      ),
      textController: AnimationController(
        duration: AnimationDurations.slow,
        vsync: this,
      ),
      pulseController: AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      ),
    );
  }

  void _startAnimationSequence() async {
    // Play the animation sequence
    await _animations.playSequence();

    // Navigate after delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Navigate to auth wrapper with fade transition
    Navigator.of(context).pushReplacement(
      FadePageRoute(
        page: const AuthWrapper(),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A237E),
                    const Color(0xFF0D47A1),
                    const Color(0xFF01579B),
                  ]
                : [
                    const Color(0xFF42A5F5),
                    const Color(0xFF1E88E5),
                    const Color(0xFF1565C0),
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _animations.logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _animations.logoFade,
                    child: ScaleTransition(
                      scale: _animations.logoScale,
                      child: AnimatedBuilder(
                        animation: _animations.pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animations.pulse.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 60,
                            color: isDark
                                ? const Color(0xFF1565C0)
                                : const Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Animated Brand Name
              AnimatedBuilder(
                animation: _animations.textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _animations.textFade,
                    child: SlideTransition(
                      position: _animations.textSlide,
                      child: Column(
                        children: [
                          Text(
                            'DailyPulse',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track Your Mood, Every Day',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
