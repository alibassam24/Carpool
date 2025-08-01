import 'package:carpool_connect/screens/auth/choose_role_screen.dart';
import 'package:get/get.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

// Later we'll import: login_screen.dart, onboarding_screen.dart

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const onboarding ='/onboarding';
  static const roles='/roles';
  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: onboarding, page: ()=>const OnboardingScreen()),
    GetPage(name: onboarding, page: ()=>const ChooseRoleScreen())
 
  ];
}
