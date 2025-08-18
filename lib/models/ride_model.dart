import 'package:get/get.dart';

class Ride {
  final String id;
  final String origin;
  final String destination;
  int seats; // make mutable so seats can be decremented
  final DateTime when;
  final String driverId;
  String genderPreference; 
  // 🔹 Requests list
  RxList<RideRequest> requests;

  Ride({
    required this.id,
    required this.origin,
    required this.destination,
    required this.seats,
    required this.when,
    required this.driverId,
    this.genderPreference="Any",
    List<RideRequest>? requests,
  }): requests = (requests ?? <RideRequest>[]).obs;

  void decrementSeat(int count) {
  if (seats - count >= 0) {
    seats -= count; // reduce seats
  }
}
}

class RideRequest {
  final String passengerId;
  final String passengerName;
  final int seatsRequested;
  final String status; // pending, accepted, rejected
  

  RideRequest({
    required this.passengerId,
    required this.passengerName,
    required this.seatsRequested,
    this.status = "pending",
   
  });

  // 👇 Utility to clone with new values
  RideRequest copyWith({
    String? passengerId,
    String? passengerName,
    int? seatsRequested,
    String? status,
  }) {
    return RideRequest(
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      seatsRequested: seatsRequested ?? this.seatsRequested,
      status: status ?? this.status,
    );
  }
}



