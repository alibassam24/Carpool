import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("FAQs and contact options will be here 📞"),
      ),
    );
  }
}
