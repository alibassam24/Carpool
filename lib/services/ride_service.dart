// lib/services/ride_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_model.dart';
import '../core/result.dart';

class RideService {
  final SupabaseClient _sb = Supabase.instance.client;

  /// 🔎 Fetch rides from Supabase
  Future<Result<List<Ride>>> fetchRides({
    int limit = 50,
    String status = 'active',
  }) async {
    try {
      final rows = await _sb
          .from('rides')
          .select()
          .eq('status', status)
          .order('date_time', ascending: true)
          .limit(limit);

      final rides = (rows as List<dynamic>)
          .map((row) => Ride.fromMap(Map<String, dynamic>.from(row)))
          .toList();

      return Result.ok(rides);
    } catch (e) {
      return Result.err(AppFailure('fetch_failed', e.toString()));
    }
  }

  /// 📡 Stream realtime updates for rides
  Stream<List<Ride>> streamRides({String status = 'active'}) {
    return _sb
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('status', status)
        .order('date_time')
        .map((rows) =>
            rows.map((r) => Ride.fromMap(Map<String, dynamic>.from(r))).toList());
  }

  /// 📝 Create a ride in Supabase
  Future<Result<Ride>> createRide(Ride ride) async {
    try {
      final row = await _sb.from('rides').insert({
        'carpooler_id': ride.carpoolerId,
        'origin_text': ride.origin,
        'origin_lat': ride.originLat,
        'origin_lng': ride.originLng,
        'destination_text': ride.destination,
        'destination_lat': ride.destinationLat,
        'destination_lng': ride.destinationLng,
        'passenger_count': ride.seats,
        'date_time': ride.when.toIso8601String(),
        'price': ride.price,
        'gender_preference': ride.genderPreference,
        'notes': ride.notes,
        'status': 'active',
      }).select().single();

      return Result.ok(Ride.fromMap(Map<String, dynamic>.from(row)));
    } catch (e) {
      return Result.err(AppFailure('create_failed', e.toString()));
    }
  }

  /// ❌ Cancel a ride (soft delete)
  Future<Result<void>> cancelRide(int rideId) async {
    try {
      await _sb.from('rides').update({'status': 'cancelled'}).eq('id', rideId);
      return Result.ok(null);
    } catch (e) {
      return Result.err(AppFailure('cancel_failed', e.toString()));
    }
  }
}
