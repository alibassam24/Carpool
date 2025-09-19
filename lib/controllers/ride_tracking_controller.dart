import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class RideTrackingController extends GetxController {
  final supabase = Supabase.instance.client;

  Future<void> updateLocation(int rideId, String carpoolerId,
      double lat, double lng, double speed) async {
    await supabase.rpc('update_ride_location', params: {
      'ride_id': rideId,
      'carpooler': carpoolerId,
      'lat': lat,
      'lng': lng,
      'speed': speed,
    });
  }

  Future<List<dynamic>> getRidePath(int rideId) async {
    final res = await supabase.rpc('get_ride_path', params: {
      'ride_id': rideId,
    });
    return res;
  }
}
