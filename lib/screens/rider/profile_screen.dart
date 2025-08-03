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
      //backgroundColor:  const Color(0xFFA8CABA),
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
       title: const Text("Profile"),
          backgroundColor: const Color(0xFF255A45),
        //backgroundColor:  const Color(0xFFA8CABA),
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
            icon: Icons.directions_car_filled,
            label: "Switch to Carpooler Mode",
            onTap: () => _showSwitchRoleModal(context),
          ),
          _buildProfileTile(
            icon: Icons.support_agent,
            label: "Help & Support",
            onTap: () {},
          ),

          _buildProfileTile(
            icon: Icons.settings,
            label: "Settings",
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
  void _showSwitchRoleModal(BuildContext context) {
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
            const Icon(Icons.swap_horiz, color: Color(0xFF255A45), size: 36),
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
              onPressed: () {
                Navigator.pop(context);
                Get.snackbar(
                  "Role Switched",
                  "You're now in Carpooler mode.",
                  backgroundColor: const Color(0xFF255A45),
                  colorText: Colors.white,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );
                // TODO: switch role logic here
              },
              icon: const Icon(Icons.check),
              label: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF255A45),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF255A45),
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
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFFA8CABA),
     // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
       // tileColor: Colors.white,
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