import 'package:carpool_connect/controllers/ride_controller.dart';
import 'package:carpool_connect/tabs/carpooler_profile_tab.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:carpool_connect/tabs/ride_history_tab.dart';
import 'package:carpool_connect/widgets/create_ride_widget.dart';
import 'package:carpool_connect/models/ride_model.dart';
import 'package:carpool_connect/widgets/ride_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/ride_card.dart';
import 'package:carpool_connect/tabs/requests_tab.dart';

class CarpoolerHomeScreen extends StatefulWidget {
  const CarpoolerHomeScreen({super.key});

  @override
  State<CarpoolerHomeScreen> createState() => _CarpoolerHomeScreenState();
}

class _CarpoolerHomeScreenState extends State<CarpoolerHomeScreen> {
  int _currentIndex = 0;

  final RideController rideController = Get.put(RideController());

  final List<Widget> _tabs = [
    const HomeTab(),
    const Center(child: Text("Chats coming soon")),
    const RequestsTab(),
    const CarpoolerProfileTab(),
  ];

  void _openCreateRideSheet() {
    final currentUser = UserService.currentUser;
    if (currentUser == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return CreateRideWidget(
          currentUserId: currentUser.id,
          onCreated: (ride) {
            // The controller will handle adding it
            debugPrint("Ride created: ${ride.origin} → ${ride.destination}");
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF255A45),
        title: const Text("Carpooler Home"),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: _tabs[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateRideSheet,
        backgroundColor: const Color(0xFF255A45),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF255A45),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool showYourRides = true;
  final RideController rideController = Get.find();
  final currentUser = UserService.currentUser;

  void toggleRides(bool showYour) {
    setState(() {
      showYourRides = showYour;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rides = showYourRides
          ? rideController.rides
              .where((ride) => ride.carpoolerId == currentUser?.id)
              .toList()
          : rideController.rides;

      return Column(
        children: [
          const SizedBox(height: 16),

          // Segmented toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => toggleRides(true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: showYourRides
                              ? const Color(0xFF255A45)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Your Rides",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: showYourRides
                                ? Colors.white
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => toggleRides(false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: !showYourRides
                              ? const Color(0xFF255A45)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "All Rides",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: !showYourRides
                                ? Colors.white
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ride List
          Expanded(
            child: rides.isEmpty
                ? Center(
                    child: Text(
                      showYourRides
                          ? 'You have no rides.'
                          : 'No rides available.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rides.length,
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return RideCard(
                        ride: ride,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => RideDetailsModal(ride: ride),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF255A45)),
            accountName: const Text("Ali Bassam"),
            accountEmail: const Text("ali@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF255A45)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text("Loyalty Points"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Ride History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RideHistoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text("Switch Role"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
