import 'package:carpool_connect/tabs/ride_history_tab.dart';

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
  static const rideHistory='/ride_history';
  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: roles,
      page: () => const ChooseRoleScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: extendedSignup,
      page: () => const ExtendedCarpoolerSignupScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 450),
    ),
    GetPage(
      name: carpoolerHome,
      page: () => const CarpoolerHomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: riderHome,
      page: () => const RiderHomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: verificationPending,
      page: () => const VerificationPendingScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: rideHistory,
      page: () => const RideHistoryScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
