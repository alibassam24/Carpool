import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class SosController extends GetxController {
  final supabase = Supabase.instance.client;

  Future<int?> triggerSOS(String userId, int rideId, double lat, double lng) async {
    final res = await supabase.rpc('trigger_sos', params: {
      'user_id': userId,
      'ride_id': rideId,
      'lat': lat,
      'lng': lng,
    });
    return res;
  }
}
