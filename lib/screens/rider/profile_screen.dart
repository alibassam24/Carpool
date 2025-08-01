import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Brand background
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF255A45), // Brand primary
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 User Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF255A45),
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "John Doe", // Replace with dynamic name
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF255A45),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("johndoe@example.com"), // Replace with dynamic email
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ⭐ Loyalty Points Card
            Card(
              color: const Color(0xFFA8CABA), // Accent color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 36, color: Color(0xFF255A45)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "You have 240 Carpool Points",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF255A45),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Keep riding to earn rewards!",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ⚙️ Options
            const Text(
              "Account",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF255A45),
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileTile(
              icon: Icons.history,
              label: "Ride History",
              onTap: () {
                // Navigate to history screen
              },
            ),
            _buildProfileTile(
              icon: Icons.settings,
              label: "Settings",
              onTap: () {
                // Navigate to settings
              },
            ),
            _buildProfileTile(
              icon: Icons.support_agent,
              label: "Help & Support",
              onTap: () {
                // Navigate to support
              },
            ),
            const Spacer(),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // logout logic here
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF255A45)),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
