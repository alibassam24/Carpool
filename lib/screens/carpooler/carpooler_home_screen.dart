import 'package:flutter/material.dart';

class CarpoolerHomeScreen extends StatelessWidget {
  const CarpoolerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Off-white background
      appBar: AppBar(
        title: const Text('Carpooler Home'),
        backgroundColor: const Color(0xFF255A45), // Dark green
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Welcome, Carpooler! 🚗",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF255A45),
              ),
            ),
            const SizedBox(height: 20),
            _buildDashboardTile(
              context,
              icon: Icons.add_circle_outline,
              title: "Post a New Ride",
              onTap: () {
                // Navigate to ride posting screen
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardTile(
              context,
              icon: Icons.history,
              title: "Ride History",
              onTap: () {
                // Navigate to ride history screen
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardTile(
              context,
              icon: Icons.attach_money_rounded,
              title: "Earnings",
              onTap: () {
                // Navigate to earnings screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: const Color(0xFFE6F2EF), // Muted olive background
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 28, color: const Color(0xFF255A45)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
