import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_model.dart';
import '../core/result.dart';
import '../core/result.dart';

class RideService {
  final SupabaseClient _sb = Supabase.instance.client;

  /// 🔎 Fetch rides using RPC (with optional filters/pagination)
  Future<Result<List<Ride>>> fetchRides({
    int limit = 50,
    String status = 'active',
  }) async {
    try {
      final rows = await _sb.rpc('search_rides', params: {
        'p_status': status,
        'p_limit': limit,
      });

      final rides = (rows as List<dynamic>)
          .map((row) => Ride.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      return Result.ok(rides);
    } catch (e) {
      return Result.err(AppFailure('fetch_failed', e.toString()));
    }
  }

  /// 📡 Stream realtime updates for active rides
  Stream<List<Ride>> streamRides() {
    return _sb
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('status', 'active')
        .order('date_time')
        .map(
          (rows) => rows
              .map((row) => Ride.fromMap(Map<String, dynamic>.from(row)))
              .toList(),
        );
  }

  /// 🏗️ Build a new Ride object before saving
  Ride buildRide({
    required String createdBy,
    required String origin,
    required String destination,
    required DateTime when,
    required int seats,
    double? price,
    required String genderPreference,
    String? notes,
  }) {
    return Ride(
      carpoolerId: createdBy,
      origin: origin,
      destination: destination,
      when: when,
      seats: seats,
      price: price,
      genderPreference: genderPreference,
      notes: notes,
    );
  }

  /// 📝 Create a ride in Supabase
  Future<Result<Ride>> createRide(Ride ride) async {
    try {
      final row = await _sb
          .from('rides')
          .insert(ride.toMap())
          .select()
          .single();

      return Result.ok(Ride.fromMap(Map<String, dynamic>.from(row)));
    } catch (e) {
      return Result.err(AppFailure('create_failed', e.toString()));
    }
  }

  /// ❌ Cancel (soft delete) a ride
  Future<Result<void>> cancelRide(int rideId) async {
    try {
      await _sb.from('rides').update({'status': 'cancelled'}).eq('id', rideId);
      return Result.ok(null);
    } catch (e) {
      return Result.err(AppFailure('cancel_failed', e.toString()));
    }
  }
}
