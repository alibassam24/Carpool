import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class CarpoolerProfileTab extends StatelessWidget {
  const CarpoolerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = box.read('userName') ?? 'John Doe';
    final int loyaltyPoints = box.read('loyaltyPoints') ?? 120;
    final int totalRides = box.read('totalRides') ?? 18;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: const Color(0xFFE6F2EF),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF255A45),
                      child: const Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF255A45),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Loyalty Points: $loyaltyPoints",
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("Total Rides", "$totalRides"),
                _buildStatCard("Passengers", "56"),
                _buildStatCard("Earnings", "PKR 8,500"),
              ],
            ),
            const SizedBox(height: 20),

            // Ride History
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: const Color(0xFFE6F2EF),
              leading: const Icon(Icons.history, color: Color(0xFF255A45)),
              title: const Text("Ride History"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.toNamed('/ride_history');
              },
            ),
            const SizedBox(height: 12),

            // Switch to Rider
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: const Color(0xFFE6F2EF),
              leading: const Icon(Icons.swap_horiz, color: Color(0xFF255A45)),
              title: const Text("Switch to Rider"),
              onTap: () {
                Get.offAllNamed('/rider_home');
              },
            ),
            const SizedBox(height: 12),

            // Logout
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.red.shade50,
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                box.erase(); // clears local storage
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFE6F2EF),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF255A45),
                ),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
