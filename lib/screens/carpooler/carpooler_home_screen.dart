import 'package:carpool_connect/controllers/ride_controller.dart';
import 'package:carpool_connect/services/ride_service.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:carpool_connect/widgets/create_ride_widget.dart';
import 'package:carpool_connect/models/ride_model.dart';
import 'package:carpool_connect/widgets/ride_details.dart';
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

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final RideController rideController = Get.find();
    final currentUser = UserService.currentUser;

    final showYourRides = true.obs; // Toggle for "Your Rides" vs "All Rides"

    return Column(
      children: [
        const SizedBox(height: 16),

        // 🔹 Toggle Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _toggleButton(
                  label: "Your Rides",
                  isSelected: showYourRides.value,
                  onTap: () => showYourRides.value = true,
                ),
                const SizedBox(width: 12),
                _toggleButton(
                  label: "All Rides",
                  isSelected: !showYourRides.value,
                  onTap: () => showYourRides.value = false,
                ),
              ],
            );
          }),
        ),

        const SizedBox(height: 16),

        // 🔹 Ride List
        Expanded(
          child: Obx(() {
            final rides = showYourRides.value
                ? rideController.rides
                    .where((ride) => ride.driverId == currentUser?.id)
                    .toList()
                : rideController.rides.toList();

            if (rides.isEmpty) {
              return const Center(
                child: Text(
                  'No rides available.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];

                final bool isOwner = ride.driverId == currentUser?.id;
                final bool isFull = (ride.seats ?? 0) <= 0;
                final bool alreadyRequested = ride.requests.any(
                  (r) => r.passengerId == currentUser?.id && r.status == 'pending',
                );

                Widget trailing;

                if (isOwner) {
                  trailing = Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: ride.requests.map((req) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(req.passengerName),
                            const SizedBox(width: 6),
                            if (req.status == 'pending') ...[
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  rideController.respondToRequest(
                                      ride.id, req.passengerId, true);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  rideController.respondToRequest(
                                      ride.id, req.passengerId, false);
                                },
                              ),
                            ] else ...[
                              Text(
                                req.status.capitalizeFirst ?? req.status,
                                style: TextStyle(
                                  color: req.status == 'accepted'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  );
                } else if (currentUser == null) {
                  trailing = _luxButton("Login to Join", disabled: true);
                } else if (isFull) {
                  trailing = _luxButton("Full", disabled: true);
                } else if (alreadyRequested) {
                  trailing = _luxButton("Requested", disabled: true);
                } else {
                  trailing = AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      key: ValueKey(ride.seats), // animate on seats change
                      onPressed: () {
                        final request = RideRequest(
                          passengerId: currentUser!.id,
                          passengerName: currentUser.name,
                          seatsRequested: 1,
                          status: 'pending',
                        );

                        rideController.addRequest(ride.id, request);

                        Get.snackbar(
                          'Request Sent',
                          'You requested to join this ride.',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(12),
                          borderRadius: 12,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF255A45),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        'Join Ride',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFF255A45).withOpacity(0.1),
                      child: const Icon(Icons.directions_car,
                          size: 28, color: Color(0xFF255A45)),
                    ),
                    title: Text(
                      "${ride.origin} → ${ride.destination}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "Seats left: ${ride.seats} • ${ride.when.toLocal()}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: trailing,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => RideDetailsModal(ride: ride),
                      );
                    },
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  /// 🔹 Toggle button widget
  Widget _toggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF255A45) : Colors.white, //const Color(0xFF1E3A8A)
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF255A45), width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF255A45),
          ),
        ),
      ),
    );
  }

  /// 🔹 Luxury button for join states
  Widget _luxButton(String label, {bool disabled = false}) {
    return OutlinedButton(
      onPressed: disabled ? null : () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        side: BorderSide(
          color: disabled ? Colors.grey.shade400 : const Color(0xFF255A45),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: disabled ? Colors.grey.shade500 : const Color(0xFF255A45),
        ),
      ),
    );
  }
}



/* 
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final RideController rideController = Get.find();
    final currentUser = UserService.currentUser;

    return Obx(() {
      if (rideController.rides.isEmpty) {
        return const Center(
          child: Text(
            'No rides available.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rideController.rides.length,
        itemBuilder: (context, index) {
          final ride = rideController.rides[index];

          final bool isOwner = ride.driverId == currentUser?.id;
          final bool isFull = (ride.seats ?? 0) <= 0;
          final bool alreadyRequested = ride.requests.any(
            (r) => r.passengerId == currentUser?.id && r.status == 'pending',
          );

          Widget trailing;

          if (isOwner) {
            trailing = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: ride.requests.map((req) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(req.passengerName),
                      const SizedBox(width: 6),
                      if (req.status == 'pending') ...[
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            rideController.respondToRequest(
                                ride.id, req.passengerId, true);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            rideController.respondToRequest(
                                ride.id, req.passengerId, false);
                          },
                        ),
                      ] else ...[
                        Text(
                          req.status.capitalizeFirst ?? req.status,
                          style: TextStyle(
                            color: req.status == 'accepted'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          } else if (currentUser == null) {
            trailing = _luxButton("Login to Join", disabled: true);
          } else if (isFull) {
            trailing = _luxButton("Full", disabled: true);
          } else if (alreadyRequested) {
            trailing = _luxButton("Requested", disabled: true);
          } else {
            trailing = AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                key: ValueKey(ride.seats), // animate on seats change
                onPressed: () {
                  final request = RideRequest(
                    passengerId: currentUser.id,
                    passengerName: currentUser.name,
                    seatsRequested: 1,
                    status: 'pending',
                  );

                  rideController.addRequest(ride.id, request);

                  Get.snackbar(
                    'Request Sent',
                    'You requested to join this ride.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(12),
                    borderRadius: 12,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'Join Ride',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                child: const Icon(Icons.directions_car,
                    size: 28, color: Color(0xFF1E3A8A)),
              ),
              title: Text(
                "${ride.origin} → ${ride.destination}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                "Seats left: ${ride.seats} • ${ride.when.toLocal()}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: trailing,
              onTap: () {
                 showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => RideDetailsModal(ride: ride),
  );
              },
            ),
          );
        },
      );
    });
  }

  Widget _luxButton(String label, {bool disabled = false}) {
    return OutlinedButton(
      onPressed: disabled ? null : () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        side: BorderSide(
          color: disabled ? Colors.grey.shade400 : const Color(0xFF1E3A8A),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: disabled ? Colors.grey.shade500 : const Color(0xFF1E3A8A),
        ),
      ),
    );
  }
} */

/* lass RequestsTab extends StatelessWidget {
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
                                rideController.acceptRequest(ride.id, req.passengerId);
                                Get.snackbar('Accepted', 'Request accepted',
                                    snackPosition: SnackPosition.BOTTOM);
                              },
                            ),
                            IconButton(
                              tooltip: 'Reject',
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                rideController.rejectRequest(ride.id, req.passengerId);
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
 */
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
                      "Seats requested: ${req.seatsRequested} • Status: ${req.status}"),
                  trailing: isPending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Accept',
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                rideController.respondToRequest(
                                    ride.id, req.passengerId, true);
                              },
                            ),
                            IconButton(
                              tooltip: 'Reject',
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                rideController.respondToRequest(
                                    ride.id, req.passengerId, false);
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
