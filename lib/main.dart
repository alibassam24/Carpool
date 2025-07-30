import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/splash/splash_screen.dart';
import '../core/theme/app_theme.dart';
import '/routes/app_routes.dart';
void main() {
  runApp(const CarpoolApp());
}

class CarpoolApp extends StatelessWidget {
  const CarpoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  
    initialRoute: AppRoutes.splash,
    getPages: AppRoutes.routes,
      title: 'Carpool Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    );
  }
}
