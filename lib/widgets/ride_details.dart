import 'dart:ui';
import 'package:carpool_connect/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carpool_connect/models/ride_model.dart';
import 'package:carpool_connect/controllers/ride_controller.dart';

class RideDetailsModal extends StatefulWidget {
  final Ride ride;
  const RideDetailsModal({super.key, required this.ride});

  @override
  State<RideDetailsModal> createState() => _RideDetailsModalState();
}

class _RideDetailsModalState extends State<RideDetailsModal> with SingleTickerProviderStateMixin {
  final RideController rideController = Get.find<RideController>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.currentUser;
    final ride = widget.ride;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: constraints.maxHeight * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.97),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 36), // space for close button
                          // HEADER: Origin → Destination
                          Row(
                            children: [
                              const Icon(Icons.directions_car, size: 30, color: Color(0xFF255A45)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "${ride.origin} → ${ride.destination}",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF255A45),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // RIDE INFO CHIPS
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _infoChip(Icons.event, "${ride.when.toLocal()}"),
                              _infoChip(Icons.event_seat, "${ride.seats} seats"),
                              _infoChip(Icons.person, ride.genderPreference),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // PASSENGER REQUESTS (only for driver)
                          if (ride.driverId == currentUser?.id)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Requests",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                if (ride.requests.isEmpty)
                                  const Text("No requests yet",
                                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                                ...ride.requests.map((req) {
                                  Color bgColor;
                                  if (req.status == "accepted") {
                                    bgColor = Colors.green.shade50;
                                  } else if (req.status == "pending") {
                                    bgColor = Colors.amber.shade50;
                                  } else {
                                    bgColor = Colors.red.shade50;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(req.passengerName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600, fontSize: 16)),
                                        if (req.status == "pending")
                                          Row(
                                            children: [
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
                                            ],
                                          )
                                        else
                                          Text(
                                            req.status.capitalizeFirst!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: req.status == "accepted"
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),

                          const SizedBox(height: 28),

                          // JOIN RIDE BUTTON
                          if (ride.driverId != currentUser?.id && ride.seats > 0)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final request = RideRequest(
                                    passengerId: currentUser!.id,
                                    passengerName: currentUser.name,
                                    seatsRequested: 1,
                                    status: 'pending',
                                  );

                                  ride.requests.add(request);
                                  rideController.rides.refresh();

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
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 10,
                                ),
                                child: const Text(
                                  "Join Ride",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // CLOSE BUTTON
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 28, color: Colors.grey),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade300, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.green.shade900),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
