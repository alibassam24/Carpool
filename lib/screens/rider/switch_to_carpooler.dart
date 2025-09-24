import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SwitchToCarpooler {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drive_eta_rounded,
                  color: Color(0xFF255A45), size: 36),
              const SizedBox(height: 10),
              const Text(
                "Switch to Carpooler Mode?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF255A45),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "As a carpooler, you’ll be able to post rides and accept ride requests from others.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context); // close bottom sheet
                  await _handleSwitch();
                },
                icon: const Icon(Icons.check),
                label: const Text("Confirm"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF255A45),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF255A45),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _handleSwitch() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      Get.snackbar("Error", "You must be logged in.",
          backgroundColor: Colors.red.shade50, colorText: Colors.black87);
      return;
    }

    try {
      final record = await client
          .from("users")
          .select("role, status")
          .eq("id", user.id)
          .maybeSingle();

      if (record == null) {
        Get.snackbar("Error", "Profile not found.",
            backgroundColor: Colors.red.shade50, colorText: Colors.black87);
        return;
      }

      String role = record["role"];
      String status = record["status"];

      if (role == "carpooler") {
        if (status == "verified") {
          Get.offAllNamed("/carpooler/home");
        } else {
          Get.offAllNamed("/carpooler/extended-signup");
        }
      } else {
        await client
            .from("users")
            .update({"role": "carpooler", "status": "pending"})
            .eq("id", user.id);

        Get.offAllNamed("/carpooler/extended-signup");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to switch role: $e",
          backgroundColor: Colors.red.shade50, colorText: Colors.black87);
    }
  }
}
