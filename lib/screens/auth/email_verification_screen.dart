import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  Future<void> _openMailApp() async {
    final Uri gmail = Uri.parse("mailto:");
    if (!await launchUrl(gmail)) {
      Get.snackbar("Error", "Could not open mail app");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Cream background
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration (optional: add your own mailbox.png in assets/images/)
              const Text(
                "Verify Your Email 📩",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF255A45),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "We’ve sent a verification link to your inbox.\n"
                "Please confirm and return here to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF255A45), // Green background
                    foregroundColor: Colors.white, // ✅ White text
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _openMailApp,
                  child: const Text("Open Mail App"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
