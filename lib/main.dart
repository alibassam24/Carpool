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

import '../screens/splash/splash_screen.dart';
import '../core/theme/app_theme.dart';
import '/routes/app_routes.dart';
import 'controllers/ride_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async{
  await GetStorage.init();
  Get.put(RideController());
   WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://akqimqdesfakpmeydccn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrcWltcWRlc2Zha3BtZXlkY2NuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxNzU5MDcsImV4cCI6MjA3Mzc1MTkwN30.u-RCYk-AzrgeNCTEW1zA76ZQPYLUwWOvnHuiSLt9THY',
  );
  UserService.setTestUser();
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
