import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Timer(const Duration(seconds: 2), () {
      _decideNextScreen();
    });
  }

  Future<void> _decideNextScreen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (isFirstTime) {
      await prefs.setBool('is_first_time', false);
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session == null || session.user == null) {
      // Not logged in → Login
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // ✅ Logged in → always go to ChooseRole
    Get.offAllNamed(AppRoutes.roles);

  } catch (e) {
    debugPrint("❌ Splash decision error: $e");
    Get.offAllNamed(AppRoutes.login);
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Background Cream
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo1.png',
                height: 150,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Color(0xFF255A45)), // Primary Green
            ],
          ),
        ),
      ),
    );
  }
}
