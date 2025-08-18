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

class _RequestsTabState extends State<RequestsTab> with SingleTickerProviderStateMixin {
  final RideController rideController = Get.find<RideController>();
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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
            // Search Bar
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
            // Status Filters
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
            // Requests List
            Expanded(
              child: allRequests.isEmpty
                  ? const Center(
                      child: Text(
                        "No requests found",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      key: _listKey,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: allRequests.length,
                      itemBuilder: (context, index) {
                        final item = allRequests[index];
                        return _AnimatedRequestCard(
                          key: ValueKey("${item.ride.id}-${item.request.passengerId}"),
                          item: item,
                          onUpdate: () => _highlightRequest(context),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
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

class _AnimatedRequestCard extends StatefulWidget {
  final _RequestItem item;
  final VoidCallback onUpdate;

  const _AnimatedRequestCard({super.key, required this.item, required this.onUpdate});

  @override
  State<_AnimatedRequestCard> createState() => _AnimatedRequestCardState();
}

class _AnimatedRequestCardState extends State<_AnimatedRequestCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RideController rideController = Get.find();
    final item = widget.item;

    return ScaleTransition(
      scale: _scaleAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            key: PageStorageKey("${item.ride.id}-${item.request.passengerId}"),
            onExpansionChanged: (val) => setState(() => _expanded = val),
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
                    Text(
                      "Seats requested: ${item.request.seatsRequested}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
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
                              widget.onUpdate();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            tooltip: "Reject",
                            onPressed: () {
                              rideController.respondToRequest(
                                  item.ride.id, item.request.passengerId, false);
                              widget.onUpdate();
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}

class _RequestItem {
  final Ride ride;
  final RideRequest request;

  _RequestItem({required this.ride, required this.request});
}
