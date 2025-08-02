import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy values
    final String userName = "John Doe";
    final String email = "johndoe@example.com";
    final int points = 240;
    final String referralCode = "JOHN240";

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 👤 Profile Header
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF255A45),
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF255A45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(email),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF255A45)),
                onPressed: () {
                  // Navigate to edit profile
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // 💎 Loyalty Card
          _buildLoyaltyCard(points),

          const SizedBox(height: 20),

          // 🎁 Referral Program
          _buildReferralCard(referralCode),

          const SizedBox(height: 24),

          // ⚙️ Account Options
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
            onTap: () {},
          ),
          _buildProfileTile(
            icon: Icons.settings,
            label: "Settings",
            onTap: () {},
          ),
          _buildProfileTile(
            icon: Icons.support_agent,
            label: "Help & Support",
            onTap: () {},
          ),

          const SizedBox(height: 40),

          // 🚪 Logout Button
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Add logout logic
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(int points) {
    return Card(
      color: const Color(0xFFA8CABA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star_rounded, size: 40, color: Color(0xFF255A45)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$points Carpool Points",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF255A45),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Earn more points by riding and referring."),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // View rewards or redeem
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF255A45),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text("Redeem", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard(String referralCode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.card_giftcard, color: Color(0xFF255A45), size: 36),
        title: const Text("Refer & Earn"),
        subtitle: Text("Share your code to earn rewards.\nCode: $referralCode"),
        trailing: ElevatedButton(
          onPressed: () {
            // Share referral
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF255A45),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text("Share", style: TextStyle(color: Colors.white)),
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
