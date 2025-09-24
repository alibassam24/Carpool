import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("App preferences and settings will be here ⚙️"),
      ),
    );
  }
}
