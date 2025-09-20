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

    Timer(const Duration(seconds: 2), _decideNextScreen);
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

      // Check if session exists
      final session = supabase.auth.currentSession;
      if (session == null || session.user == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // Double-check user validity (in case account was deleted)
      final userRes = await supabase.auth.getUser();
      if (userRes.user == null) {
        await supabase.auth.signOut();
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // If logged in and valid → go to ChooseRole
      Get.offAllNamed(AppRoutes.roles);
    } catch (e, st) {
      debugPrint("❌ Splash decision error: $e\n$st");

      // On any error → reset session and send to login
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
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
              const CircularProgressIndicator(
                color: Color(0xFF255A45), // Primary Green
              ),
            ],
          ),
        ),
      ),
    );
  }
}
