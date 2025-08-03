import 'package:carpool_connect/screens/auth/choose_role_screen.dart';
import 'package:carpool_connect/screens/carpooler/carpooler_home_screen.dart';
import 'package:carpool_connect/screens/carpooler/carpooler_signup.dart';
import 'package:carpool_connect/screens/rider/rider_home_screen.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/user_service.dart'; // <-- Add this import
import 'package:get_storage/get_storage.dart';

final box = GetStorage();


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;
  void _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    final user = UserService.authenticate(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      UserService.login(user); // Set the current user

      final savedRole = box.read('userRole');
      Get.snackbar("Success", "Welcome back, ${user.name}");

      if (savedRole != null) {
        if (savedRole == 'rider') {
          Get.offAll(() => const RiderHomeScreen());
        } else if (savedRole == 'carpooler') {
          if (user.role == "Carpooler") {
            Get.offAll(() => const CarpoolerHomeScreen());
          } else {
            Get.offAll(() => const ExtendedCarpoolerSignupScreen());
          }
        }
      } else {
        Get.offAll(() => const ChooseRoleScreen());
      }
    } else {
      Get.snackbar("Login Failed", "Invalid credentials");
    }

    setState(() => _isLoading = false);
  }
}

  /* void _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    final user = UserService.authenticate(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      UserService.login(user); // Set the current user

      final savedRole = box.read('userRole');
      Get.snackbar("Success", "Welcome back, ${user.name}");

      if (savedRole != null) {
        if (savedRole == 'rider') {
          Get.offAll(() => const RiderHomeScreen());
        } else if (savedRole == 'carpooler') {
          if (user.role == "Carpooler") {
            Get.offAll(() => const CarpoolerHomeScreen());
          } else {
            Get.offAll(() => const ExtendedCarpoolerSignupScreen());
          }
        }
      } else {
        Get.offAll(() => const ChooseRoleScreen());
      }
    } else {
      Get.snackbar("Login Failed", "Invalid credentials");
    }

    setState(() => _isLoading = false);
  }
} */

  /* void _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    final user = UserService.authenticate(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      UserService.login(user); // sets currentUser
      final savedRole = box.read('userRole');
      Get.snackbar("Success", "Welcome back, ${user.name}");
      Get.to(() => const ChooseRoleScreen());
    } else {
      Get.snackbar("Login Failed", "Invalid credentials");
    }

    setState(() => _isLoading = false);
  }
} */

        /* void _login() async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isLoading = true);
            try {
              await Future.delayed(const Duration(seconds: 1)); // Simulate delay

              final user = UserService.authenticate(
                emailController.text.trim(),
                passwordController.text.trim(),
              );

              if (user != null) {
                Get.snackbar("Success", "Welcome, ${user.name}!");
                Get.to(() => const ChooseRoleScreen());
              } else {
                Get.snackbar("Login Failed", "Invalid email or password");
              }
            } catch (e) {
              Get.snackbar("Error", "An unexpected error occurred");
            } finally {
              setState(() => _isLoading = false);
            }
          }
        } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF255A45),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Login to your account to continue carpooling.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email is required";
                    if (!GetUtils.isEmail(value)) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    if (value.length < 6) return "Password must be at least 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xFF255A45)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: "Login",
                        onPressed: _login,
                        backgroundColor: const Color(0xFF255A45),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Get.to(() => const SignupScreen()),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xFF255A45),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
