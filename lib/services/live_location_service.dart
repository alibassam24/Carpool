import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling live location updates and streams
class LiveLocationService {
  final SupabaseClient _sb = Supabase.instance.client;

  /// 🚗 Update driver’s or rider’s live location
  /// If the row already exists (same `user_id`), it will be updated (upsert).
  Future<void> updateLocation({
    required String userId,
    required int rideId,
    required double lat,
    required double lng,
    double? speed,
    double? heading,
  }) async {
    try {
      await _sb.from('live_locations').upsert({
        'user_id': userId,
        'ride_id': rideId,
        'latitude': lat,
        'longitude': lng,
        'speed_kmh': speed,
        'heading': heading,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // 🔴 Important: don’t let location updates silently fail
      print("❌ Failed to update live location: $e");
      rethrow;
    }
  }

  /// 👀 Stream live location of a single user (e.g., driver)
  Stream<Map<String, dynamic>?> streamUserLocation(String userId) {
    return _sb
        .from('live_locations')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  /// 👀 Stream all users in a ride (driver + passengers if needed)
  Stream<List<Map<String, dynamic>>> streamRideLocations(int rideId) {
    return _sb
        .from('live_locations')
        .stream(primaryKey: ['user_id'])
        .eq('ride_id', rideId)
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  /// ❌ Delete a user’s live location (on ride end or cancel)
  Future<void> clearUserLocation(String userId) async {
    try {
      await _sb.from('live_locations').delete().eq('user_id', userId);
    } catch (e) {
      print("❌ Failed to clear live location: $e");
      rethrow;
    }
  }

  /// ❌ Clear all live locations for a ride (e.g., ride finished)
  Future<void> clearRideLocations(int rideId) async {
    try {
      await _sb.from('live_locations').delete().eq('ride_id', rideId);
    } catch (e) {
      print("❌ Failed to clear ride locations: $e");
      rethrow;
    }
  }
}
