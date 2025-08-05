import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:lottie/lottie.dart'; // 👈 Add in pubspec.yaml

class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  State<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  bool _isVerified = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _startStatusCheck();
  }

  void _startStatusCheck() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      bool isVerified = await mockVerifyStatus();
      if (isVerified) {
        timer.cancel();
        setState(() => _isVerified = true);
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/carpooler_home');
      } else {
        setState(() => _checking = false);
      }
    });
  }

  Future<bool> mockVerifyStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal:24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/verified.json', // Add a success or waiting animation
                  width: 280,
                  height: 180,
                  repeat: true,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Documents Submitted 🎉',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF255A45),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We’re currently reviewing your submitted documents. This usually takes a few minutes.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _checking
                    ? const CircularProgressIndicator(
                        color: Color(0xFF255A45),
                        strokeWidth: 3,
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          _startStatusCheck();
                          setState(() => _checking = true);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Check Again"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF255A45),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
