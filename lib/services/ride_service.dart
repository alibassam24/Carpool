// lib/services/ride_service.dart
import 'dart:async';
import 'package:uuid/uuid.dart';

class Ride {
  final String id;
  final String createdBy; // user id
  final String origin;
  final String destination;
  final DateTime when;
  final int seats;
  final double? price;
  final String genderPreference;
  final String notes;
  final DateTime createdAt;

  Ride({
    required this.id,
    required this.createdBy,
    required this.origin,
    required this.destination,
    required this.when,
    required this.seats,
    this.price,
    required this.genderPreference,
    required this.notes,
    required this.createdAt,
  });
}

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
  static Ride buildRide({
    required String createdBy,
    required String origin,
    required String destination,
    required DateTime when,
    required int seats,
    double? price,
    required String genderPreference,
    required String notes,
  }) {
    return Ride(
      id: const Uuid().v4(),
      createdBy: createdBy,
      origin: origin,
      destination: destination,
      when: when,
      seats: seats,
      price: price,
      genderPreference: genderPreference,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }
}
