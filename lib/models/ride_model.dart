import 'package:get/get.dart';

class Ride {
  final String id; // uuid
  final String carpoolerId; // driver/carpooler user id (uuid)
  final String origin;
  final String destination;
  int seats; // mutable (local seat decrement only)
  final DateTime when;
  final String genderPreference;

  RxList<RideRequest> requests;

  Ride({
    required this.id,
    required this.carpoolerId,
    required this.origin,
    required this.destination,
    required this.seats,
    required this.when,
    this.genderPreference = "any",
    List<RideRequest>? requests,
  }) : requests = (requests ?? <RideRequest>[]).obs;

  void decrementSeat(int count) {
    if (seats - count >= 0) {
      seats -= count;
    }
  }

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id']?.toString() ?? '',
      carpoolerId: map['carpooler_id']?.toString() ?? '',
      origin: map['origin_text']?.toString() ?? '',
      destination: map['destination_text']?.toString() ?? '',
      seats: map['passenger_count'] ?? 0,
      when: DateTime.tryParse(map['date_time'] ?? '') ?? DateTime.now(),
      genderPreference: map['gender_preference']?.toString() ?? 'any',
      requests: [], // will fill separately if needed
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carpooler_id': carpoolerId,
      'origin_text': origin,
      'destination_text': destination,
      'passenger_count': seats,
      'date_time': when.toIso8601String(),
      'gender_preference': genderPreference,
    };
  }
}

class RideRequest {
  final String id; // uuid
  final String rideId;
  final String passengerId;
  final String passengerName;
  final int seatsRequested;
  final String status;

  RideRequest({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
    required this.seatsRequested,
    this.status = "pending",
  });

  RideRequest copyWith({
    String? id,
    String? rideId,
    String? passengerId,
    String? passengerName,
    int? seatsRequested,
    String? status,
  }) {
    return RideRequest(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      seatsRequested: seatsRequested ?? this.seatsRequested,
      status: status ?? this.status,
    );
  }

  factory RideRequest.fromMap(Map<String, dynamic> map) {
    return RideRequest(
      id: map['id']?.toString() ?? '',
      rideId: map['ride_id']?.toString() ?? '',
      passengerId: map['rider_id']?.toString() ?? '',
      passengerName: map['passenger_name']?.toString() ?? 'Unknown',
      seatsRequested: map['seats_requested'] ?? 1,
      status: map['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ride_id': rideId,
      'rider_id': passengerId,
      'passenger_name': passengerName,
      'seats_requested': seatsRequested,
      'status': status,
    };
  }
}
