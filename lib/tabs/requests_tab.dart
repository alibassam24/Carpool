import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carpool_connect/controllers/ride_controller.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:carpool_connect/models/ride_model.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  final RideController rideController = Get.find<RideController>();
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.currentUser;

    return Obx(() {
      // 🔹 Only show rides owned by the logged-in carpooler
      List<Ride> myRides = rideController.rides
          .where((ride) => ride.carpoolerId == currentUser?.id)
          .toList();

      // 🔹 Collect all requests across rides
      List<_RequestItem> allRequests = [];
      for (var ride in myRides) {
        for (var req in ride.requests) {
          if (_filterStatus != 'All' &&
              req.status.toLowerCase() != _filterStatus.toLowerCase()) continue;
          if (_searchController.text.isNotEmpty &&
              !req.passengerName.toLowerCase().contains(
                  _searchController.text.trim().toLowerCase())) continue;

          allRequests.add(_RequestItem(ride: ride, request: req));
        }
      }

      return RefreshIndicator(
        onRefresh: () async => rideController.refreshRides(),
        child: Column(
          children: [
            // 🔎 Search
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search by passenger name",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // 🔹 Status Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['All', 'Pending', 'Accepted', 'Rejected'].map((status) {
                  final isSelected = _filterStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filterStatus = status),
                    selectedColor: const Color(0xFF255A45),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Request Cards
            Expanded(
              child: allRequests.isEmpty
                  ? const Center(
                      child: Text(
                        "No requests found",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: allRequests.length,
                      itemBuilder: (context, index) {
                        final item = allRequests[index];
                        return _RequestCard(
                          key: ValueKey("${item.ride.id}-${item.request.passengerId}"),
                          item: item,
                          onUpdate: () => _showSnack(context, "Request updated"),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF255A45),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _RequestItem item;
  final VoidCallback onUpdate;

  const _RequestCard({super.key, required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final RideController rideController = Get.find();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        key: PageStorageKey("${item.ride.id}-${item.request.passengerId}"),
        title: Text(
          "${item.ride.origin} → ${item.ride.destination}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text("Passenger: ${item.request.passengerName}"),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Seats requested: ${item.request.seatsRequested}"),
                const SizedBox(height: 6),
                _statusBadge(item.request.status),
                const SizedBox(height: 8),
                if (item.request.status == "pending")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: "Accept",
                        onPressed: () {
                          rideController.respondToRequest(
                              item.ride.id, item.request.passengerId, true);
                          onUpdate();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: "Reject",
                        onPressed: () {
                          rideController.respondToRequest(
                             item.ride.id, item.request.passengerId, false);
                          onUpdate();
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    switch (status) {
      case "pending":
        bg = Colors.orange;
        break;
      case "accepted":
        bg = Colors.green;
        break;
      case "rejected":
        bg = Colors.red;
        break;
      default:
        bg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RequestItem {
  final Ride ride;
  final RideRequest request;
  _RequestItem({required this.ride, required this.request});
}
