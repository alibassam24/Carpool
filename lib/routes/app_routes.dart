import '../screens/carpooler/carpooler_signup.dart';
import '../screens/carpooler/verification_pending_screen.dart';
import 'package:get/get.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/choose_role_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

import '../screens/carpooler/carpooler_home_screen.dart';
import '../screens/rider/rider_home_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const onboarding = '/onboarding';
  static const roles = '/roles';
  static const extendedSignup = '/extended_signup';
  static const carpoolerHome = '/carpooler_home';
  static const riderHome = '/rider_home';
  static const verificationPending = '/verification_pending'; 
  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: roles, page: () => const ChooseRoleScreen()),
    GetPage(name: extendedSignup, page: () => const ExtendedCarpoolerSignupScreen()),
    GetPage(name: carpoolerHome, page: () => const CarpoolerHomeScreen()),
    GetPage(name: riderHome, page: () => const RiderHomeScreen()),
    GetPage(name: verificationPending, page: () => const VerificationPendingScreen()),
    GetPage(name: carpoolerHome, page: () => const CarpoolerHomeScreen()),
  ];
}
