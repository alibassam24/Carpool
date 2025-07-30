import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Integrate real email reset logic (e.g., Firebase Auth)
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar("Success", "Reset link sent to your email");
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar("Error", "Failed to send reset link");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF255A45)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF255A45),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your email and we’ll send you a password reset link.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),

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
                const SizedBox(height: 24),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: "Send Reset Link",
                        onPressed: _sendResetLink,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
