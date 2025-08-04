import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF255A45), size: 100),
              const SizedBox(height: 20),
              const Text(
                'Documents Submitted 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF255A45)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your documents are under review. Once verified, your carpooler account will be activated.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // Temporarily redirect to carpooler home
                  Get.offAllNamed('/carpooler_home');
                },
                icon: const Icon(Icons.home),
                label: const Text("Go to Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
