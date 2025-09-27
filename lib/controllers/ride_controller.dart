import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carpool_connect/models/ride_model.dart';

class RideController extends GetxController {
  // ======= Public reactive state =======
  final rides = <Ride>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;

  // ======= Paging =======
  int _page = 0;
  final int _pageSize = 10;
  bool _hasMore = true;

  // ======= Request cooldown =======
  final Map<String, DateTime> _lastRequestAttempt = {};

  // ======= Supabase =======
  final _sb = Supabase.instance.client;
  RealtimeChannel? _ridesChannel;

  // ======= Config =======
  final bool enableRealtime = true;

  @override
  void onInit() {
    super.onInit();
    fetchRides(reset: true);

    if (enableRealtime) {
      _ridesChannel = _sb.channel('public:rides')
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'rides',
          callback: (payload) {
            try {
              final data = payload.newRecord;
              if (data == null) return;
              final ride = Ride.fromMap(data);

              final idx = rides.indexWhere((r) => r.id == ride.id);
              if (idx == -1) {
                rides.insert(0, ride);
              } else {
                rides[idx] = ride;
              }
              rides.refresh();
            } catch (e, st) {
              debugPrint("❌ Realtime insert error: $e\n$st");
            }
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'rides',
          callback: (payload) {
            try {
              final data = payload.newRecord;
              if (data == null) return;
              final updated = Ride.fromMap(data);

              final idx = rides.indexWhere((r) => r.id == updated.id);
              if (idx != -1) {
                rides[idx] = updated;
                rides.refresh();
              }
            } catch (e, st) {
              debugPrint("❌ Realtime update error: $e\n$st");
            }
          },
        )
        ..subscribe();
    }
  }

  @override
  void onClose() {
    _ridesChannel?.unsubscribe();
    _ridesChannel = null;
    super.onClose();
  }

  // ======= Public API =======

  /// Fetch rides with paging. Call with `reset: true` for pull-to-refresh.
  Future<void> fetchRides({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _hasMore = true;
      rides.clear();
      errorMessage.value = '';
    }

    if (!_hasMore) return;

    if (_page == 0) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final from = _page * _pageSize;
      final to = (_page + 1) * _pageSize - 1;

      final res = await _sb
          .from('rides')
          .select('''
            id,
            carpooler_id,
            vehicle_id,
            origin_text,
            destination_text,
            price,
            passenger_count,
            date_time,
            status,
            gender_preference
          ''')
          .eq('status', 'active')
          .order('date_time', ascending: true)
          .range(from, to);

      final list = (res as List?) ?? [];
      final mapped = list.map((e) => Ride.fromMap(e)).toList();

      if (mapped.isEmpty) {
        _hasMore = false;
      } else {
        rides.addAll(mapped);
        _page++;
      }
    } on PostgrestException catch (e) {
      debugPrint("❌ Postgres error: ${e.message}");
      errorMessage.value = e.message;
    } catch (e, st) {
      debugPrint("❌ fetchRides error: $e\n$st");
      errorMessage.value = 'Failed to fetch rides. Please pull to refresh.';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> respondToRequest(int rideId, String passengerId, bool accept) async {
  final newStatus = accept ? 'accepted' : 'rejected';

  try {
    // 🔹 Update in DB
    await _sb
        .from('ride_requests')
        .update({'status': newStatus})
        .match({'ride_id': rideId, 'rider_id': passengerId});

    // 🔹 Update local state
    final rideIndex = rides.indexWhere((r) => r.id == rideId);
    if (rideIndex != -1) {
      final ride = rides[rideIndex];
      final reqIndex = ride.requests.indexWhere((r) => r.passengerId == passengerId);
      if (reqIndex != -1) {
        ride.requests[reqIndex] =
            ride.requests[reqIndex].copyWith(status: newStatus);
        rides.refresh();
      }
    }
  } on PostgrestException catch (e) {
    debugPrint("❌ respondToRequest Postgres error: ${e.message}");
    Get.snackbar("Error", e.message, backgroundColor: Colors.red.shade50);
  } catch (e) {
    debugPrint("❌ respondToRequest error: $e");
    Get.snackbar("Error", "Failed to update request", backgroundColor: Colors.red.shade50);
  }
}




  /// Search by location (optional, requires RPC).
  Future<void> searchRidesByLocation({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _sb.rpc('search_rides', params: {
        'origin_lat': lat,
        'origin_lng': lng,
        'radius_km': radiusKm,
      });

      final list = (res as List?) ?? [];
      rides.assignAll(list.map((e) => Ride.fromMap(e)).toList());
      _page = 0;
      _hasMore = false;
    } catch (e, st) {
      debugPrint("❌ searchRidesByLocation error: $e\n$st");
      errorMessage.value = 'Search failed. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Rider requests a ride via RPC.
   /// Rider requests a ride via RPC. Includes cooldown to prevent spamming.
  Future<void> requestRide(String rideId) async {
  // Cooldown
  final now = DateTime.now();
  final last = _lastRequestAttempt[rideId];
  if (last != null && now.difference(last) < const Duration(seconds: 2)) {
    throw 'Please wait a moment before trying again.';
  }
  _lastRequestAttempt[rideId.toString()] = now;

  final userId = _sb.auth.currentUser?.id;
  if (userId == null) {
    throw 'You must be logged in to request a ride.';
  }

  try {
    await _sb.rpc('request_ride', params: {
      'ride_id': rideId, // uuid
      'rider': userId,   // uuid
    });
  } on PostgrestException catch (e) {
    debugPrint("❌ requestRide Postgrest error: ${e.message}");
    throw e.message ?? 'Request failed.';
  } catch (e) {
    debugPrint("❌ requestRide error: $e");
    throw 'Failed to request ride. Please try again.';
  }
}


  Future<void> refreshRides() => fetchRides(reset: true);
}

extension RideControllerMutations on RideController {
  void addRide(Ride ride) {
    final idx = rides.indexWhere((r) => r.id == ride.id);
    if (idx == -1) {
      rides.insert(0, ride); // prepend newest
    } else {
      rides[idx] = ride; // replace if already exists
    }
    rides.refresh();
  }
}
