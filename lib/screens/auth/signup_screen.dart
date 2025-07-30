import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // TODO: Replace with real signup logic
        await Future.delayed(const Duration(seconds: 2));
        Get.snackbar("Success", "Account created successfully");
        Get.off(() => const LoginScreen());
      } catch (e) {
        Get.snackbar("Signup Failed", e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Account 🚗",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF255A45),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Join the carpooling community and start saving!",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),

                CustomTextField(
                  controller: nameController,
                  hintText: "Full Name",
                  validator: (value) =>
                      value == null || value.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: phoneController,
                  hintText: "Phone Number",
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Phone number required";
                    if (value.length < 10) return "Enter a valid phone number";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: emailController,
                  hintText: "Email",
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
                  hintText: "Password",
                  obscureText: _obscurePass,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    if (value.length < 6) return "Minimum 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: confirmPassController,
                  hintText: "Confirm Password",
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please confirm password";
                    if (value != passwordController.text) return "Passwords do not match";
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: "Sign Up",
                        onPressed: _signup,
                      ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Get.off(() => const LoginScreen()),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF255A45),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
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
