// lib/services/ride_actions_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class RideActionsService {
  final SupabaseClient _sb = Supabase.instance.client;

  /// Subscribe to a single ride row and notify when `status` changes.
  StreamSubscription<List<Map<String, dynamic>>> subscribeRideStatus({
    required int rideId,
    required void Function(String status) onChange,
  }) {
    return _sb
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .listen((rows) {
      if (rows.isEmpty) return;
      final s = rows.first['status']?.toString() ?? 'active';
      onChange(s);
    });
  }

  /// Read one ride (for guards or quick refresh)
  Future<Map<String, dynamic>?> fetchRide(int rideId) async {
    final row = await _sb.from('rides').select().eq('id', rideId).maybeSingle();
    return (row == null) ? null : Map<String, dynamic>.from(row);
  }

  /// Cancel the ride (allowed only if NOT started/completed).
  /// Throws on failure so caller can show a snackbar with the reason.
  Future<void> cancelRide({required int rideId}) async {
    final ride = await fetchRide(rideId);
    if (ride == null) {
      throw 'Ride not found';
    }
    final status = (ride['status'] ?? 'active').toString();
    if (status == 'started' || status == 'completed') {
      throw 'Ride already $status. Cannot cancel.';
    }
    await _sb.from('rides').update({'status': 'cancelled'}).eq('id', rideId);
  }

  /// Send SOS: creates an 'active' sos_alert if none exists for this user+ride.
  Future<void> sendSOS({
    required int rideId,
    double? lat,
    double? lng,
  }) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw 'Not logged in';

    // Prevent duplicates: check if there's an active SOS already
    final existing = await _sb
        .from('sos_alerts')
        .select('id')
        .eq('ride_id', rideId)
        .eq('user_id', user.id)
        .eq('status', 'active')
        .limit(1);
    if (existing is List && existing.isNotEmpty) {
      return; // already active → no-op
    }

    await _sb.from('sos_alerts').insert({
      'ride_id': rideId,
      'user_id': user.id,
      'latitude': lat,
      'longitude': lng,
      'status': 'active',
      'triggered_at': DateTime.now().toIso8601String(),
    });

     //Optional: notify driver/admin in your notifications table
     await _sb.from('notifications').insert({
       'user_id': user.id,
       'type': 'sos',
       'message': 'SOS triggered for ride $rideId',
     });
  }
}
