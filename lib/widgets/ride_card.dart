import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ride_model.dart';
import '../services/user_service.dart';
import '../controllers/ride_controller.dart';
import 'ride_details.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;

  RideCard({super.key, required this.ride, this.onTap});

  final RideController rideController = Get.find();
  final currentUser = UserService.currentUser;

  @override
  Widget build(BuildContext context) {
    final bool isOwner = ride.carpoolerId == currentUser?.id;
    final bool isFull = (ride.seats) <= 0;

    // We’ll eventually load requests from DB; for now, keep empty
    final bool alreadyRequested = ride.requests.any(
      (r) => r.passengerId == currentUser?.id && r.status == 'pending',
    );

    /// Trailing button logic
    Widget trailing;
    if (isOwner) {
      trailing = const SizedBox.shrink();
    } else if (currentUser == null) {
      trailing = _luxButton("Login to Join", disabled: true);
    } else if (isFull) {
      trailing = _luxButton("Full", disabled: true);
    } else if (alreadyRequested) {
      trailing = _luxButton("Requested", disabled: true);
    } else {
      trailing = ElevatedButton(
        onPressed: () async {
          try {
            await rideController.requestRide(ride.id.toString()); // ✅ uses RPC
            Get.snackbar(
              'Request Sent',
              'You requested to join this ride.',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
              backgroundColor: Colors.green.shade50,
              colorText: Colors.black87,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString(),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
              backgroundColor: Colors.red.shade50,
              colorText: Colors.black87,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF255A45),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ??
            () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => RideDetailsModal(ride: ride),
              );
            },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading Icon
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF255A45).withOpacity(0.1),
              child: const Icon(Icons.directions_car,
                  size: 28, color: Color(0xFF255A45)),
            ),
            const SizedBox(width: 12),

            // Ride info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${ride.origin} → ${ride.destination}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Seats left: ${ride.seats} • ${ride.when.toLocal()}",
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  // 🚨 Owner request handling will come later when we wire requests table
                ],
              ),
            ),

            trailing,
          ],
        ),
      ),
    );
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
