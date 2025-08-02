import 'package:flutter/material.dart';

class SwitchToCarpoolerScreen extends StatelessWidget {
  const SwitchToCarpoolerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Become a Carpooler"),
        backgroundColor: Color(0xFF255A45),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.drive_eta_rounded, size: 80, color: Color(0xFF255A45)),
            const SizedBox(height: 24),
            const Text(
              "Start Earning by Offering Rides!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF255A45),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "As a carpooler, you can offer rides, set your schedule, and earn rewards for every trip.",
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Change user role and navigate to carpooler dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF255A45),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Become a Carpooler",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
