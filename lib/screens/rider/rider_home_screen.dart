import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ride_controller.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _selectedIndex = 0;
  final RideController rideController = Get.put(RideController());

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _RidesScreenWrapper(controller: rideController),
      const MessagesScreen(),
      const RiderProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFA8CABA).withOpacity(0.15),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF255A45),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Rides',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _RidesScreenWrapper extends StatelessWidget {
  final RideController controller;
  const _RidesScreenWrapper({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.rides.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF255A45)),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.fetchRides(reset: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                ),
                child: const Text("Retry",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      if (controller.rides.isEmpty) {
        return const Center(
          child: Text(
            "No rides found nearby 🚗",
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        );
      }

      return Column(
        children: [
          // 🔹 Placeholder for Map (later integrate Google Maps / Mapbox)
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: const Center(
              child: Text(
                "🗺 Map coming soon (Google/Mapbox)",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
                    !controller.isLoadingMore.value) {
                  controller.fetchRides(); // Pagination
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.rides.length,
                itemBuilder: (context, index) {
                  final ride = controller.rides[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF255A45),
                        child: Icon(Icons.directions_car, color: Colors.white),
                      ),
                      title: Text("${ride.origin} → ${ride.destination}"),
                      subtitle: Text(
                        "Seats: ${ride.seats} | Gender: ${ride.genderPreference}",
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          try {
                            await controller.requestRide(ride.id);
                            Get.snackbar("Request Sent",
                                "Ride request submitted ✅",
                                backgroundColor: Colors.green.shade50,
                                colorText: Colors.black87);
                          } catch (e) {
                            Get.snackbar("Error",
                                "Failed to request ride: $e",
                                backgroundColor: Colors.red.shade50,
                                colorText: Colors.black87);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF255A45),
                        ),
                        child: const Text("Request",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
