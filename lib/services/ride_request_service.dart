// lib/services/ride_request_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/result.dart';

class RideRequestService {
  final SupabaseClient _sb = Supabase.instance.client;
  RealtimeChannel? _channel;

  Future<Result<String>> sendRequest({required int rideId, required String riderId}) async {
    try {
      // Optional pre-checks: wallet balance, ride seats left via RPC or select
      final insert = await _sb.from('carpool_requests').insert({
        'ride_id': rideId,
        'rider_id': riderId,
        'status': 'pending', // will map to 'requested' under the view trigger
      }).select('id').single();

      final id = insert['id'].toString();
      return Result.ok(id);
    } catch (e) {
      return Result.err(AppFailure('send_request_failed', 'Could not send request'));
    }
  }

  Future<Result<void>> cancelRequest({required String requestId}) async {
    try {
      await _sb.from('carpool_requests').update({'status': 'cancelled'}).eq('id', requestId);
      return Result.ok(null);
    } catch (e) {
      return Result.err(AppFailure('cancel_failed', 'Could not cancel request'));
    }
  }

  /// Listen to request status changes (accepted/rejected/cancelled)
  void listenForStatus({
    required String requestId,
    required void Function(String status) onChange,
  }) {
    _channel?.unsubscribe();
   _channel = _sb
    .channel('ride_requests:$requestId')
    .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'ride_requests',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq, // required!
        column: 'id',
        value: requestId,
      ),
      callback: (payload) {
        final s = payload.newRecord['status'] as String;
        onChange(s == 'requested' ? 'pending' : s);
      },
    )
    .subscribe();

  }

  void dispose() {
    _channel?.unsubscribe();
  }
}
