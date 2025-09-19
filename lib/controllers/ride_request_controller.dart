import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class RideRequestController extends GetxController {
  final supabase = Supabase.instance.client;

  var requests = [].obs;

  Future<void> requestRide(int rideId, String riderId) async {
    await supabase.rpc('request_ride', params: {
      'ride_id': rideId,
      'rider': riderId,
    });
  }

  Future<void> respondToRequest(int requestId, String carpoolerId, String status) async {
    await supabase.rpc('respond_to_request', params: {
      'request_id': requestId,
      'carpooler': carpoolerId,
      'new_status': status,
    });
  }
}
