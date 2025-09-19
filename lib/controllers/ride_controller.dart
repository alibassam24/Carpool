import 'package:carpool_connect/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carpool_connect/models/ride_model.dart';
import 'package:carpool_connect/services/mock_data.dart';
class RideController extends GetxController {
  var rides = <Ride>[].obs;

 @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    rides.assignAll(MockData.generateMockRides());
  });
    //   Future.delayed(Duration(milliseconds: 100), () {
    //   rides.assignAll(MockData.generateMockRides());
    // });
   //  rides.assignAll(MockData.generateMockRides());
    // Load mock rides initially
   // Future.microtask(() {
  //  rides.assignAll(MockData.generateMockRides());
  //});
  }
  // 🔹 Add a new ride
  void addRide(Ride ride) {
    rides.insert(0, ride); // newest first
    rides.refresh();
  }

  // 🔹 Add a new request
  void addRequest(String rideId, RideRequest request) {
    final ride = rides.firstWhereOrNull((r) => r.id == rideId);
    if (ride == null) return;

    // Prevent duplicate pending requests
    final exists = ride.requests.any(
        (r) => r.passengerId == request.passengerId && r.status == 'pending');
    if (exists) return;

    ride.requests.add(request);
    ride.requests.refresh();
    rides.refresh();
  }

  // 🔹 Accept a request and decrement seats
  void acceptRequest(String rideId, String passengerId) {
    final ride = rides.firstWhereOrNull((r) => r.id == rideId);
    if (ride == null) return;

    final idx = ride.requests.indexWhere(
        (r) => r.passengerId == passengerId && r.status == 'pending');
    if (idx == -1) return;

    final req = ride.requests[idx];

    if (ride.seats >= req.seatsRequested) {
      ride.seats -= req.seatsRequested;
      ride.requests[idx] = req.copyWith(status: 'accepted');
      ride.requests.refresh();
      rides.refresh();

      Get.snackbar(
        "Request Accepted",
        "${req.passengerName} added — seats left: ${ride.seats}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error",
        "Not enough seats available",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 🔹 Reject a request
  void rejectRequest(String rideId, String passengerId) {
    final ride = rides.firstWhereOrNull((r) => r.id == rideId);
    if (ride == null) return;

    final idx = ride.requests.indexWhere(
        (r) => r.passengerId == passengerId && r.status == 'pending');
    if (idx == -1) return;

    final req = ride.requests[idx];
    ride.requests[idx] = req.copyWith(status: 'rejected');
    ride.requests.refresh();
    rides.refresh();

    Get.snackbar(
      "Request Rejected",
      "${req.passengerName}'s request was rejected",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 🔹 General respond function (accept or reject) — preserves all logic
  void respondToRequest(String rideId, String passengerId, bool accept) {
    final ride = rides.firstWhereOrNull((r) => r.id == rideId);
    if (ride == null) return;

    final idx = ride.requests.indexWhere(
        (r) => r.passengerId == passengerId && r.status == 'pending');
    if (idx == -1) return;

    final req = ride.requests[idx];

    if (accept) {
      // Accept request
      if (ride.seats >= req.seatsRequested) {
        ride.seats -= req.seatsRequested;
        ride.requests[idx] = req.copyWith(status: 'accepted');
        Get.snackbar(
          "Request Accepted",
          "${req.passengerName} added — seats left: ${ride.seats}",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error",
          "Not enough seats available",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } else {
      // Reject request
      ride.requests[idx] = req.copyWith(status: 'rejected');
      Get.snackbar(
        "Request Rejected",
        "${req.passengerName}'s request was rejected",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    ride.requests.refresh();
    rides.refresh();
  }
}
/* import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RideController extends GetxController {
  final supabase = Supabase.instance.client;

  var rides = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRides();

    // Subscribe to realtime rides updates
    supabase.channel('rides')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'rides',
        callback: (payload) {
          fetchRides();
        },
      )
      .subscribe();
  }

  Future<void> fetchRides() async {
    final res = await supabase.from('rides').select();
    rides.value = res;
  }

  Future<int?> createRide(Map<String, dynamic> params) async {
    final res = await supabase.rpc('create_ride', params: params);
    return res;
  }

  Future<List<dynamic>> searchRides(
      double lat, double lng, double radius) async {
    final res = await supabase.rpc('search_rides', params: {
      'origin_lat': lat,
      'origin_lng': lng,
      'radius_km': radius,
    });
    return res;
  }
}
*/