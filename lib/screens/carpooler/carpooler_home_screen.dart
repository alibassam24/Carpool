import 'package:carpool_connect/controllers/ride_controller.dart';
import 'package:carpool_connect/services/ride_service.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:carpool_connect/widgets/create_ride_widget.dart';
import 'package:carpool_connect/models/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
 // 🔹 import your GetX RideController
 // 🔹 make sure your Ride model is accessible

class CarpoolerHomeScreen extends StatefulWidget {
  const CarpoolerHomeScreen({super.key});

  @override
  State<CarpoolerHomeScreen> createState() => _CarpoolerHomeScreenState();
}

class _CarpoolerHomeScreenState extends State<CarpoolerHomeScreen> {
  int _currentIndex = 0;

  final RideController rideController = Get.put(RideController()); // 🔹 attach controller once
final List<Widget> _tabs = [
  const HomeTab(),
  const Center(child: Text("Chats coming soon")),
  const RequestsTab(),   // ✅ now uses the real tab
  const Center(child: Text("Profile coming soon")),
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
            // 🔹 Now we update the GetX controller, so Obx list updates instantly
           // rideController.addRide(ride);
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

/* class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final RideController rideController = Get.find();

    return Obx(() {
      if (rideController.rides.isEmpty) {
        return const Center(child: Text('No rides available.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rideController.rides.length,
        itemBuilder: (context, index) {
          final ride = rideController.rides[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ],
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
    });
  }
} */

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final RideController rideController = Get.find();
    final currentUser = UserService.currentUser; // used for conditional UI

    return Obx(() {
      if (rideController.rides.isEmpty) {
        return const Center(child: Text('No rides available.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rideController.rides.length,
        itemBuilder: (context, index) {
          final ride = rideController.rides[index];

          final bool isOwner = ride.driverId == currentUser?.id; // your model uses `createdBy`
          final bool isFull = (ride.seats ?? 0) <= 0; // safeguard if seats is nullable
          final bool alreadyRequested = ride.requests
              .any((r) => r.passengerId == currentUser?.id && r.status == 'pending');

          Widget trailing;

          if (isOwner) {
            // Driver shouldn’t request their own ride
            trailing = const Icon(Icons.arrow_forward_ios, size: 16);
          } else if (currentUser == null) {
            // Not logged in -> show disabled button prompting login
            trailing = OutlinedButton(
              onPressed: null,
              child: const Text('Login to Join'),
            );
          } else if (isFull) {
            trailing = OutlinedButton(
              onPressed: null,
              child: const Text('Full'),
            );
          } else if (alreadyRequested) {
            trailing = OutlinedButton(
              onPressed: null,
              child: const Text('Requested'),
            );
          } else {
            trailing = ElevatedButton(
              onPressed: () {
                // Basic: request 1 seat for now (we’ll add seat picker later)
                final request = RideRequest(
                  passengerId: currentUser.id,
                  passengerName: currentUser.name,
                  seatsRequested: 1,
                  status: 'pending',
                );

                // Because `requests` is an RxList, this will notify dependents
                ride.requests.add(request);

                Get.snackbar(
                  'Request sent',
                  'Your request to join this ride has been sent.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Join'),
            );
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.directions_car, color: Color(0xFF255A45)),
              title: Text('${ride.origin} → ${ride.destination}'),
              subtitle: Text('Seats: ${ride.seats} • Time: ${ride.when.toLocal()}'),
              trailing: trailing,
              onTap: () {
                // (Optional) later we can open a Ride Details screen here
              },
            ),
          );
        },
      );
    });
  }
}
class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final RideController rideController = Get.find<RideController>();

    return Obx(() {
      if (rideController.rides.isEmpty) {
        return const Center(child: Text("No rides yet"));
      }

      return ListView(
        children: rideController.rides.map((ride) {
          if (ride.requests.isEmpty) {
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text("${ride.origin} → ${ride.destination}"),
                subtitle: const Text("No requests yet"),
              ),
            );
          }

          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text("${ride.origin} → ${ride.destination}"),
              subtitle: Text("Requests: ${ride.requests.length}"),
              children: ride.requests.map((req) {
                final bool isPending = req.status == "pending";

                return ListTile(
                  title: Text(req.passengerName),
                  subtitle: Text(
                    "Seats requested: ${req.seatsRequested} • Status: ${req.status}",
                  ),
                  trailing: isPending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Accept',
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                rideController.acceptRequest(ride, req);
                                Get.snackbar('Accepted', 'Request accepted',
                                    snackPosition: SnackPosition.BOTTOM);
                              },
                            ),
                            IconButton(
                              tooltip: 'Reject',
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                rideController.rejectRequest(ride, req);
                                Get.snackbar('Rejected', 'Request rejected',
                                    snackPosition: SnackPosition.BOTTOM);
                              },
                            ),
                          ],
                        )
                      : Text(
                          req.status.toUpperCase(),
                          style: TextStyle(
                            color: req.status == "accepted"
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      );
    });
  }
}

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
