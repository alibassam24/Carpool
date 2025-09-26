import 'package:get/get.dart';

/// Ride entity (maps directly to `rides` table)
class Ride {
  final int id; // bigint in DB → stored as string
  final String carpoolerId; // driver/carpooler user id (uuid)
  final String origin;
  final String destination;
  int seats; // passenger_count
  final DateTime when;
  final String genderPreference;

  /// local reactive list of requests (not always hydrated from DB)
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
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0, 
      carpoolerId: map['carpooler_id']?.toString() ?? '',
      origin: map['origin_text']?.toString() ?? '',
      destination: map['destination_text']?.toString() ?? '',
      seats: map['passenger_count'] is int
          ? map['passenger_count']
          : int.tryParse(map['passenger_count']?.toString() ?? '0') ?? 0,
      when: DateTime.tryParse(map['date_time']?.toString() ?? '') ??
          DateTime.now(),
      genderPreference: map['gender_preference']?.toString() ?? 'any',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carpooler_id': carpoolerId,
      'origin_text': origin,
      'destination_text': destination,
      'passenger_count': seats,
      'date_time': when.toIso8601String(),
      'gender_preference': genderPreference,
    };
  }
}

/// RideRequest entity (maps to `ride_requests` table)
class RideRequest {
  final String id; // bigint in DB → stored as string
  final String rideId;
  final String passengerId; // rider_id
  final String passengerName; // not in schema, only local
  final int seatsRequested;
  final String status; // requested | accepted | rejected | cancelled

  RideRequest({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
    required this.seatsRequested,
    this.status = "requested",
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
      passengerName: map['passenger_name']?.toString() ??
          'Unknown', // 🔹 Not in DB, enrich later with join
      seatsRequested: map['seats_requested'] is int
          ? map['seats_requested']
          : int.tryParse(map['seats_requested']?.toString() ?? '1') ?? 1,
      status: map['status']?.toString() ?? 'requested',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ride_id': rideId,
      'rider_id': passengerId,
      'seats_requested': seatsRequested,
      'status': status,
    };
  }
}
