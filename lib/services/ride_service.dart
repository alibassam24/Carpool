import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:carpool_connect/models/ride_model.dart';

class RideService {
  static final List<Ride> _rides = [];

  /// create a ride (simulates network delay)
  static Future<Ride> createRide(Ride ride) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    _rides.add(ride);
    return ride;
  }

  /// get list of rides (most recent first)
  static List<Ride> getRides() {
    return _rides.reversed.toList();
  }

  /// convenience factory for building a Ride object
  /* static Ride buildRide({
    required String createdBy,
    required String origin,
    required String destination,
    required DateTime when,
    required int seats,
    double? price,
    String genderPreference = "",
    String notes = "",
  }) {
    return Ride(
      id: const Uuid().v4(),
      origin: origin,
      destination: destination,
      when: when,
      seats: seats,
      driverId: createdBy,
    );
  } */
 static Ride buildRide({
  required String createdBy,
  required String origin,
  required String destination,
  required DateTime when,
  required int seats,
  double? price,
  String genderPreference = "Any",
  String notes = "",
  List<RideRequest>? requests, // optional initial requests
}) {
  return Ride(
    id: const Uuid().v4(),
    origin: origin,
    destination: destination,
    seats: seats,
    when: when,
    driverId: createdBy,
    genderPreference: genderPreference,
    requests: requests ?? [], // initialize as empty list if null
  );
}

}
