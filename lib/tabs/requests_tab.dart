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
      List<Ride> myRides = rideController.rides
          .where((ride) => ride.driverId == currentUser?.id)
          .toList();

      List<_RequestItem> allRequests = [];
      for (var ride in myRides) {
        for (var req in ride.requests) {
          if (_filterStatus != 'All' && req.status != _filterStatus.toLowerCase()) continue;
          if (_searchController.text.isNotEmpty &&
              !req.passengerName.toLowerCase().contains(_searchController.text.toLowerCase()))
            continue;

          allRequests.add(_RequestItem(ride: ride, request: req));
        }
      }

      return RefreshIndicator(
        onRefresh: () async => rideController.rides.refresh(),
        child: Column(
          children: [
            // Search bar
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
            // Filter buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['All', 'Pending', 'Accepted', 'Rejected'].map((status) {
                  bool isSelected = _filterStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filterStatus = status),
                    selectedColor: const Color(0xFF1ABC4A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Requests list
            Expanded(
              child: allRequests.isEmpty
                  ? const Center(child: Text("No requests found"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: allRequests.length,
                      itemBuilder: (context, index) {
                        final item = allRequests[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            title: Text(
                              "${item.ride.origin} → ${item.ride.destination}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text("Passenger: ${item.request.passengerName}",
                                    style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text("Seats requested: ${item.request.seatsRequested}",
                                    style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                _statusBadge(item.request.status),
                              ],
                            ),
                            trailing: item.request.status == "pending"
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        tooltip: "Accept",
                                        onPressed: () {
                                          rideController.respondToRequest(
                                              item.ride.id, item.request.passengerId, true);
                                          _highlightRequest(context);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        tooltip: "Reject",
                                        onPressed: () {
                                          rideController.respondToRequest(
                                              item.ride.id, item.request.passengerId, false);
                                          _highlightRequest(context);
                                        },
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (status) {
      case "pending":
        bgColor = Colors.orange.shade400;
        break;
      case "accepted":
        bgColor = Colors.green.shade600;
        break;
      case "rejected":
        bgColor = Colors.red.shade400;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  void _highlightRequest(BuildContext context) {
    final snack = SnackBar(
      content: const Text("Request updated"),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1ABC4A),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}

class _RequestItem {
  final Ride ride;
  final RideRequest request;

  _RequestItem({required this.ride, required this.request});
}
