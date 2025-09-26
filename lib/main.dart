import 'dart:async';
import 'package:carpool_connect/screens/auth/email_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'controllers/ride_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/user_service.dart';

// Screens
import 'screens/splash/splash_screen.dart';

late final AppLinks _appLinks;
const kMapboxToken = 'pk.eyJ1IjoiYWxpYmFzc2FtMiIsImEiOiJjbWZ4em43N2EwYzM3MnFzZmJiaDFvaTF0In0.nPYkSAGLMpToqI883WZVig';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Load environment variables
    await dotenv.load(fileName: ".env");

    // ✅ Init GetStorage (local storage)
    await GetStorage.init();

    // ✅ Initialize Supabase BEFORE using client
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );

    // ✅ Put RideController globally AFTER Supabase is ready
    Get.put(RideController(), permanent: true);

    // (Optional) set test user for dev
    UserService.setTestUser();

    // ✅ Listen for auth events
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;
      debugPrint("🔑 Auth event: $event, user: ${user?.id}");

      try {
        if ((event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) &&
            Get.currentRoute == AppRoutes.splash) {
          Future.delayed(const Duration(seconds: 2), () {
            if (Get.currentRoute == AppRoutes.splash) {
              Get.offAllNamed(AppRoutes.roles);
            }
          });
        }

        if (event == AuthChangeEvent.signedOut) {
          if (Get.currentRoute != AppRoutes.splash) {
            Get.offAllNamed(AppRoutes.login);
          }
        }
      } catch (e, st) {
        debugPrint("❌ Auth listener error: $e\n$st");
        if (Get.isOverlaysOpen) {
          Get.back();
        }
        Get.snackbar(
          "Error",
          "Something went wrong. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });

    // ✅ Setup deep link listener
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen(
      (Uri? uri) async {
        if (uri == null) return;
        debugPrint("📩 Deep link received: $uri");

        final token = uri.queryParameters['access_token'];
        if (token != null) {
          try {
            await Supabase.instance.client.auth.setSession(token);
            Get.offAllNamed(AppRoutes.roles);
          } catch (e, st) {
            debugPrint("❌ Failed to set session: $e\n$st");
            Get.snackbar("Error", "Session error. Please try logging in again.");
          }
        }
      },
      onError: (err) {
        debugPrint("❌ Deep link error: $err");
        Get.snackbar("Error", "Invalid deep link.");
      },
    );

    runApp(const CarpoolApp());
  } catch (e, st) {
    debugPrint("❌ Fatal error during app init: $e\n$st");
    runApp(const ErrorApp());
  }
}

/// ✅ Normal app entry
class CarpoolApp extends StatelessWidget {
  const CarpoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Carpool Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}

/// ✅ Fallback app if init fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            "⚠️ App failed to start. Check configuration.",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
