import 'package:get/get.dart';

class Ride {
  final int? id; // bigint (Supabase PK)
  final String carpoolerId; // driver/carpooler user id (uuid)
  final String origin;
  final String destination;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  int seats; // mutable (local seat decrement only)
  final DateTime when;
  final String genderPreference;
  final double? price;
  final String? notes;

  RxList<RideRequest> requests;

  Ride({
    this.id,
    required this.carpoolerId,
    required this.origin,
    required this.destination,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    required this.seats,
    required this.when,
    this.genderPreference = "any",
    this.price,
    this.notes,
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
      originLat: (map['origin_lat'] as num?)?.toDouble(),
      originLng: (map['origin_lng'] as num?)?.toDouble(),
      destinationLat: (map['destination_lat'] as num?)?.toDouble(),
      destinationLng: (map['destination_lng'] as num?)?.toDouble(),
      seats: map['passenger_count'] ?? 0,
      when: DateTime.tryParse(map['date_time'] ?? '') ?? DateTime.now(),
      genderPreference: map['gender_preference']?.toString() ?? 'any',
      price: (map['price'] as num?)?.toDouble(),
      notes: map['notes']?.toString(),
      requests: [], // can be populated later
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carpooler_id': carpoolerId,
      'origin_text': origin,
      'destination_text': destination,
      'origin_lat': originLat,
      'origin_lng': originLng,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'passenger_count': seats,
      'date_time': when.toIso8601String(),
      'gender_preference': genderPreference,
      'price': price,
      'notes': notes,
    };
  }
}

class RideRequest {
  final String id; // uuid
  final int rideId;
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
    int? rideId,
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
      rideId: map['ride_id'] is int
          ? map['ride_id']
          : int.tryParse(map['ride_id'].toString()) ?? 0,
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
