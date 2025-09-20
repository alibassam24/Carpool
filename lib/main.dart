import 'dart:async';

import 'package:carpool_connect/screens/auth/choose_role_screen.dart';
import 'package:carpool_connect/screens/carpooler/carpooler_home_screen.dart';
import 'package:carpool_connect/screens/carpooler/carpooler_signup.dart';
import 'package:carpool_connect/screens/carpooler/verification_pending_screen.dart';
import 'package:carpool_connect/screens/onboarding/onboarding_screen.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:carpool_connect/views/connection_test_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:app_links/app_links.dart';
import '../screens/splash/splash_screen.dart';
import '../core/theme/app_theme.dart';
import '/routes/app_routes.dart';
import 'controllers/ride_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late final AppLinks _appLinks; 

void main() async{
  await GetStorage.init();
  Get.put(RideController());
   WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://akqimqdesfakpmeydccn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrcWltcWRlc2Zha3BtZXlkY2NuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxNzU5MDcsImV4cCI6MjA3Mzc1MTkwN30.u-RCYk-AzrgeNCTEW1zA76ZQPYLUwWOvnHuiSLt9THY',
  );
  UserService.setTestUser();
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {
      print("✅ User confirmed and signed in: ${data.session?.user.id}");
      Get.offAllNamed(AppRoutes.roles); // Navigate to choose role
    } else if (event == AuthChangeEvent.signedOut) {
      print("🚪 User signed out");
      Get.offAllNamed(AppRoutes.login);
    }
  });



  // ✅ Deep link listener
 _appLinks = AppLinks();

  // Listen for deep links
  _appLinks.uriLinkStream.listen((Uri? uri) async {
    if (uri != null) {
      debugPrint("📩 Deep link received: $uri");

      final token = uri.queryParameters['access_token'];
      if (token != null) {
        try {
          await Supabase.instance.client.auth.setSession(token);
          Get.offAllNamed(AppRoutes.roles);
        } catch (e) {
          debugPrint("❌ Failed to set session: $e");
          Get.snackbar("Error", "Session error. Please try logging in again.");
        }
      }
    }
  });
  runApp(const CarpoolApp());
}

class CarpoolApp extends StatelessWidget {
  const CarpoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  

    //home: CarpoolerHomeScreen(),
   // home: const ConnectionTestWidget(),
     initialRoute: AppRoutes.splash,
     getPages: AppRoutes.routes,
     title: 'Carpool Connect',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    );
  }
}
