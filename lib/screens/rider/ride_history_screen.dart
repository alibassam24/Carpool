import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride History"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Your past rides will appear here 🚗"),
      ),
    );
  }
}
