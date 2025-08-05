import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationRejectedScreen extends StatelessWidget {
  final String rejectionReason;

  const VerificationRejectedScreen({super.key, this.rejectionReason = 'Your documents were unclear or invalid.'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 100),
                const SizedBox(height: 16),
                const Text(
                  'Verification Rejected',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  rejectionReason,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.offAllNamed('/extended_signup'); // Resubmit documents
                  },
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text("Resubmit Documents"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF255A45),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Optional support/help flow
                  },
                  child: const Text(
                    "Need help? Contact support",
                    style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
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
