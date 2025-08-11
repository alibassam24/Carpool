import 'package:carpool_connect/services/ride_service.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:carpool_connect/widgets/create_ride_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarpoolerHomeScreen extends StatefulWidget {
  const CarpoolerHomeScreen({super.key});

  @override
  State<CarpoolerHomeScreen> createState() => _CarpoolerHomeScreenState();
}

class _CarpoolerHomeScreenState extends State<CarpoolerHomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _tabs = [
    const HomeTab(),
    const Center(child: Text("Chats coming soon")),
    const Center(child: Text("Requests coming soon")),
    const Center(child: Text("Profile coming soon")),
  ];

  void _openCreateRideSheet() {
  final currentUser = UserService.currentUser;
  if (currentUser == null) {
  Get.snackbar('Error', 'User not logged in');
  return; // prevent opening the sheet
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return CreateRideWidget(
        currentUserId: currentUser.id,
        onCreated: (ride) {
          // optional: update local state, show snackbar already happens inside widget
          setState(() {
            // if you track a local _myRides list, insert newly created ride here
          });
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
      drawer: AppDrawer(),
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
  List<Ride> rides = [];

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  void _loadRides() {
    setState(() {
      rides = RideService.getRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      return const Center(child: Text('No rides available.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: ListTile(
            leading: const Icon(Icons.directions_car, color: Color(0xFF255A45)),
            title: Text('${ride.origin} → ${ride.destination}'),
            subtitle: Text('Seats: ${ride.seats} • Time: ${ride.when.toLocal()}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}


/* class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyRides = [
      {"destination": "Downtown", "seats": 3, "time": "5:00 PM"},
      {"destination": "Airport", "seats": 2, "time": "7:30 AM"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyRides.length,
      itemBuilder: (context, index) {
        final ride = dummyRides[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: const Icon(Icons.directions_car, color: Color(0xFF255A45)),
            title: Text("${ride['destination']}"),
            subtitle: Text("Seats: ${ride['seats']} • Time: ${ride['time']}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
} */

class CreateCarpoolForm extends StatelessWidget {
  CreateCarpoolForm({super.key});

  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _seatsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        const Center(
          child: Text(
            "Create Carpool Request",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _pickupController,
          decoration: const InputDecoration(labelText: "Pickup Location"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _destinationController,
          decoration: const InputDecoration(labelText: "Destination"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _seatsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Seats Available"),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField(
          items: const [
            DropdownMenuItem(value: "Any", child: Text("Any Gender")),
            DropdownMenuItem(value: "Male", child: Text("Male Only")),
            DropdownMenuItem(value: "Female", child: Text("Female Only")),
          ],
          onChanged: (value) {},
          decoration: const InputDecoration(labelText: "Gender Preference"),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                "Success",
                "Carpool request created!",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF255A45),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Create Request"),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
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
            onTap: () {},
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
