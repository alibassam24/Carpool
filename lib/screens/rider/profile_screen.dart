import 'package:carpool_connect/screens/rider/switch_to_carpooler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ride_history_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';


class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  final _client = Supabase.instance.client;
  String? _userName;
  String? _email;
  int _points = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = "User not logged in.";
          _loading = false;
        });
        return;
      }

      _email = user.email;

      final record = await _client
          .from("users")
          .select("loyalty_points")
          .eq("id", user.id)
          .maybeSingle();

      if (record != null) {
        _points = record["loyalty_points"] ?? 0;
      }

      // If you store name in profiles table
      final profile = await _client
          .from("profiles")
          .select("id, phone")
          .eq("id", user.id)
          .maybeSingle();

      _userName = profile?["phone"] ?? user.email?.split("@").first ?? "User";

      setState(() {
        _loading = false;
      });
    } catch (e, st) {
      debugPrint("❌ Profile load error: $e\n$st");
      setState(() {
        _error = "Failed to load profile. Please try again.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF255A45)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red, fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF255A45),
                        ),
                        child: const Text("Retry",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView(
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
                                _userName ?? "User",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF255A45),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(_email ?? "no-email"),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF255A45)),
                          onPressed: () {
                            Get.snackbar(
                                "Coming Soon", "Edit profile not implemented yet");
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 💎 Loyalty Card
                    _buildLoyaltyCard(_points),

                    const SizedBox(height: 20),

                    // 🎁 Referral Program
                    _buildReferralCard("JOHN240"), // TODO: generate real referral code

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
                      onTap: () => Get.to(() => const RideHistoryScreen()),
                    ),
                    _buildProfileTile(
                      icon: Icons.directions_car_filled,
                      label: "Switch to Carpooler Mode",
                      onTap: () => SwitchToCarpooler.show(context),
                    ),
                    _buildProfileTile(
                      icon: Icons.support_agent,
                      label: "Help & Support",
                      onTap: () => Get.to(() => const SupportScreen()),
                    ),
                    _buildProfileTile(
                      icon: Icons.settings,
                      label: "Settings",
                      onTap: () => Get.to(() => const SettingsScreen()),
                    ),

                    const SizedBox(height: 40),

                    // 🚪 Logout Button (improved UI)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await Supabase.instance.client.auth.signOut();
                            Get.offAllNamed("/login");
                          } catch (e) {
                            Get.snackbar("Error", "Logout failed: $e",
                                backgroundColor: Colors.red.shade50,
                                colorText: Colors.black87);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                Get.snackbar("Coming Soon", "Rewards feature not implemented");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF255A45),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.card_giftcard,
            color: Color(0xFF255A45), size: 36),
        title: const Text("Refer & Earn"),
        subtitle:
            Text("Share your code to earn rewards.\nCode: $referralCode"),
        trailing: ElevatedButton(
          onPressed: () {
            Get.snackbar("Coming Soon", "Referral sharing not implemented yet");
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
